# Warped Speed - Image Generation System

## Overview

The image generation system in Warped Speed follows a "database-first" approach where we always check for existing assets before generating new ones. This document details the architecture, workflow, and implementation of the image generation system.

## Core Principles

1. **Database-First Approach**
   - Always search for existing assets before generating
   - Store all generated assets for future use
   - Categorize and tag assets for efficient retrieval

2. **Graceful Fallback Chain**
   - Primary: Cached/database images
   - Secondary: Dzine API (high quality)
   - Tertiary: DALL-E API (faster, direct)
   - Fallback: Placeholder images

3. **Asset Organization**
   - Categorized storage by type and context
   - Proper metadata tagging
   - Hierarchical organization

## Database Schema

The image system relies on two primary tables:

1. **images** - Stores the actual image data and metadata
2. **image_mapping** - Maps images to game entities

See [DATABASE.md](./DATABASE.md) for the complete schema.

## Image Types

1. **Scene Images** (512x512 or 768x512)
   - Location backgrounds
   - Environment illustrations
   - Event scenes

2. **Character Images**
   - Portrait (256x256) - Face/head only
   - Full Body (512x768) - Complete character

3. **Item Images** (128x128 or 256x256)
   - Equipment icons
   - Inventory items
   - Consumables

4. **UI Elements** (various sizes)
   - Buttons
   - Decorative elements
   - Backgrounds

## Image Generation Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Request for │     │ Check DB for│     │ Found?      │
│ Image       │────►│ Similar     │────►│ Yes ──────┐ │
└─────────────┘     └─────────────┘     │ No        │ │
                                        ▼           │ │
┌─────────────┐     ┌─────────────┐     ┌─────────┐ │ │
│ Save Image  │     │ Generate    │     │ Try     │ │ │
│ to Database │◄────│ Image via   │◄────│ Dzine   │ │ │
└─────────────┘     │ API         │     │ API     │ │ │
       │            └─────────────┘     └─────────┘ │ │
       │                   ▲                 │       │ │
       │                   │              Error      │ │
       │                   │                 ▼       │ │
       │            ┌─────────────┐     ┌─────────┐ │ │
       │            │ Try DALL-E  │◄────│ Fallback│ │ │
       │            │ API         │     │ Logic   │ │ │
       └───────────►└─────────────┘     └─────────┘ │ │
                                                    │ │
┌─────────────┐                                     │ │
│ Return      │◄────────────────────────────────────┘ │
│ Image to    │◄───────────────────────────────────────┘
│ Client      │
└─────────────┘
```

## Implementation Details

### Image Search Service

The image search service handles finding existing images based on prompt similarity:

```javascript
/**
 * Find existing image based on prompt and metadata
 * @param {string} prompt - The image generation prompt
 * @param {Object} options - Search options (category, size, etc.)
 * @returns {Promise<Object|null>} Found image or null
 */
async function findSimilarImage(prompt, options = {}) {
  const {
    category = 'scene',
    subcategory = null,
    width = null,
    height = null
  } = options;
  
  // First try exact match
  const exactMatch = await db.query(`
    SELECT * FROM images 
    WHERE prompt = @prompt 
    AND category = @category
    ${subcategory ? 'AND subcategory = @subcategory' : ''}
    ${width ? 'AND width = @width' : ''}
    ${height ? 'AND height = @height' : ''}
  `, {
    prompt,
    category,
    subcategory,
    width, 
    height
  });
  
  if (exactMatch.length > 0) {
    return exactMatch[0];
  }
  
  // If no exact match, try similarity search
  // Extract keywords from prompt
  const keywords = extractKeywords(prompt);
  
  // Build query with keywords
  let similarityQuery = `
    SELECT *, 
      (
        ${keywords.map((k, i) => `CASE WHEN prompt LIKE '%${k}%' THEN ${10 - i} ELSE 0 END`).join(' + ')}
      ) as similarity_score
    FROM images
    WHERE category = @category
    ${subcategory ? 'AND subcategory = @subcategory' : ''}
    ${width ? 'AND width = @width' : ''}
    ${height ? 'AND height = @height' : ''}
    ORDER BY similarity_score DESC
    LIMIT 1
  `;
  
  const similarMatches = await db.query(similarityQuery, {
    category,
    subcategory,
    width,
    height
  });
  
  if (similarMatches.length > 0 && similarMatches[0].similarity_score > 0) {
    return similarMatches[0];
  }
  
  // No matches found
  return null;
}
```

### Image Generation Service

The image generation service coordinates the process of generating images through various APIs:

```javascript
/**
 * Generate image based on prompt, with database caching
 * @param {string} prompt - The image generation prompt
 * @param {Object} options - Generation options
 * @returns {Promise<string>} URL or data URI of the image
 */
async function generateImage(prompt, options = {}) {
  // Set defaults
  const {
    width = 512,
    height = 512,
    category = 'scene',
    subcategory = null,
    style = 'cinematic',
    forceRegenerate = false
  } = options;
  
  try {
    // Step 1: Check database for similar image (skip if forceRegenerate)
    if (!forceRegenerate) {
      const existingImage = await imageSearchService.findSimilarImage(prompt, {
        category,
        subcategory,
        width,
        height
      });
      
      if (existingImage) {
        console.log(`Using existing ${category} image from database`);
        return existingImage.url || `data:image/webp;base64,${existingImage.binary_data}`;
      }
    }
    
    // Step 2: Try generating with Dzine (primary API)
    try {
      console.log(`Generating ${category} image with Dzine: "${prompt.substring(0, 30)}..."`);
      
      const taskId = await dzineService.createImageTask(prompt, {
        width,
        height,
        styleIntensity: 0.7,
        quality: style === 'detailed' ? 2 : 1
      });
      
      const imageUrl = await dzineService.pollTaskUntilComplete(taskId);
      
      // Step 3: Save to database
      await saveImageToDatabase({
        prompt,
        url: imageUrl,
        category,
        subcategory,
        width,
        height,
        api_source: 'dzine'
      });
      
      return imageUrl;
    } catch (dzineError) {
      console.warn('Dzine generation failed, falling back to DALL-E:', dzineError.message);
      
      // Step 4: Fallback to DALL-E
      try {
        const dalleUrl = await dalleService.generateImage(prompt, {
          size: `${width}x${height}`
        });
        
        // Save to database
        await saveImageToDatabase({
          prompt,
          url: dalleUrl,
          category,
          subcategory,
          width,
          height,
          api_source: 'dalle'
        });
        
        return dalleUrl;
      } catch (dalleError) {
        console.error('DALL-E generation failed:', dalleError.message);
        // Return placeholder
        return getPlaceholderImage(category);
      }
    }
  } catch (error) {
    console.error('Image generation failed:', error);
    return getPlaceholderImage(category);
  }
}
```

### Database Storage

Store images in the database with proper categorization:

```javascript
/**
 * Save generated image to database
 * @param {Object} imageData - Image data to save
 * @returns {Promise<Object>} Saved image record
 */
async function saveImageToDatabase(imageData) {
  const {
    prompt,
    url,
    category,
    subcategory = null,
    width,
    height,
    api_source,
    entity_type = null,
    entity_id = null
  } = imageData;
  
  // Generate a unique ID
  const imageId = generateUniqueId();
  
  // Extract tags from prompt
  const tags = extractTagsFromPrompt(prompt);
  
  // If URL provided, fetch binary data
  let binaryData = null;
  if (url) {
    try {
      const response = await fetch(url);
      const buffer = await response.arrayBuffer();
      binaryData = Buffer.from(buffer).toString('base64');
    } catch (error) {
      console.warn('Failed to fetch binary data from URL:', error);
    }
  }
  
  // Save image record
  const imageRecord = await db.query(`
    INSERT INTO images (
      image_id, category, subcategory, prompt, 
      tags, width, height, url, binary_data, 
      api_source, created_at
    ) VALUES (
      @imageId, @category, @subcategory, @prompt,
      @tags, @width, @height, @url, @binaryData,
      @apiSource, GETDATE()
    )
    
    SELECT * FROM images WHERE image_id = @imageId
  `, {
    imageId,
    category,
    subcategory,
    prompt,
    tags: JSON.stringify(tags),
    width,
    height,
    url,
    binaryData,
    apiSource: api_source
  });
  
  // If entity information provided, create mapping
  if (entity_type && entity_id) {
    await db.query(`
      INSERT INTO image_mapping (
        image_id, entity_type, entity_id, created_at
      ) VALUES (
        @imageId, @entityType, @entityId, GETDATE()
      )
    `, {
      imageId,
      entityType: entity_type,
      entityId: entity_id
    });
  }
  
  return imageRecord[0];
}
```

## Specialized Image Generators

### Character Portraits

```javascript
/**
 * Generate character portrait
 * @param {Object} character - Character data
 * @returns {Promise<string>} Portrait image URL
 */
async function generateCharacterPortrait(character) {
  const {
    name,
    species,
    gender,
    role,
    traits = []
  } = character;
  
  // Build a detailed prompt
  const prompt = `
    Portrait of ${gender} ${species} ${role} named ${name}, 
    with ${traits.join(', ')}, 
    close-up face view, detailed features, character portrait, 
    cinematic lighting, sci-fi style
  `.trim();
  
  return await generateImage(prompt, {
    width: 256,
    height: 256,
    category: 'character',
    subcategory: 'portrait',
    entity_type: 'character',
    entity_id: character.character_id
  });
}
```

### Scene Images

```javascript
/**
 * Generate location scene image
 * @param {Object} location - Location data
 * @returns {Promise<string>} Scene image URL
 */
async function generateLocationImage(location) {
  const {
    name,
    type,
    description,
    features = []
  } = location;
  
  // Build a detailed prompt
  const prompt = `
    Sci-fi ${type} environment: ${name}, 
    featuring ${features.join(', ')}, 
    ${description}, 
    detailed wide-angle view, atmospheric lighting
  `.trim();
  
  return await generateImage(prompt, {
    width: 768,
    height: 512,
    category: 'location',
    subcategory: type,
    entity_type: 'location',
    entity_id: location.location_id
  });
}
```

### Item Images

```javascript
/**
 * Generate item image
 * @param {Object} item - Item data
 * @returns {Promise<string>} Item image URL
 */
async function generateItemImage(item) {
  const {
    name,
    category,
    rarity,
    description
  } = item;
  
  // Build a detailed prompt
  const prompt = `
    Sci-fi ${rarity} ${category}: ${name}, 
    ${description}, 
    isolated on dark background, 
    detailed, icon style, game asset
  `.trim();
  
  return await generateImage(prompt, {
    width: 256,
    height: 256,
    category: 'item',
    subcategory: category,
    entity_type: 'item',
    entity_id: item.item_id
  });
}
```

## Performance Optimization

### In-Memory Caching

Implement an in-memory cache for frequently used images:

```javascript
// Simple in-memory LRU cache
const imageCache = new Map();
const MAX_CACHE_SIZE = 100;

/**
 * Get image from cache
 * @param {string} key - Cache key (typically imageId)
 * @returns {string|null} Image URL or null if not found
 */
function getFromCache(key) {
  if (imageCache.has(key)) {
    const value = imageCache.get(key);
    // Move to front (most recently used)
    imageCache.delete(key);
    imageCache.set(key, value);
    return value;
  }
  return null;
}

/**
 * Add image to cache
 * @param {string} key - Cache key (typically imageId)
 * @param {string} value - Image URL or data
 */
function addToCache(key, value) {
  // Evict oldest item if at capacity
  if (imageCache.size >= MAX_CACHE_SIZE) {
    const oldestKey = imageCache.keys().next().value;
    imageCache.delete(oldestKey);
  }
  
  imageCache.set(key, value);
}
```

### Preloading

Preload likely-needed images:

```javascript
/**
 * Preload images for a game scene
 * @param {Object} scene - Scene data
 */
async function preloadSceneImages(scene) {
  const promises = [];
  
  // Preload location image
  promises.push(generateLocationImage(scene.location));
  
  // Preload NPC portraits
  for (const npc of scene.npcs) {
    promises.push(generateCharacterPortrait(npc));
  }
  
  // Preload key items
  for (const item of scene.items) {
    promises.push(generateItemImage(item));
  }
  
  // Execute all in parallel
  await Promise.allSettled(promises);
}
```

## Integration with Game Components

### Scene Component

```javascript
class SceneRenderer {
  constructor() {
    this.imageService = new ImageGenerationService();
    this.sceneElement = document.getElementById('sceneImage');
    this.loadingOverlay = document.getElementById('loadingOverlay');
  }
  
  async renderScene(location) {
    // Show loading state
    this.showLoading(true);
    
    try {
      // Get/generate image
      const imageUrl = await this.imageService.generateLocationImage(location);
      
      // Apply image
      this.sceneElement.style.backgroundImage = `url('${imageUrl}')`;
    } catch (error) {
      console.error('Failed to render scene:', error);
      // Apply fallback
      this.sceneElement.style.backgroundImage = `url('${getPlaceholderImage('scene')}')`;
    } finally {
      // Hide loading state
      this.showLoading(false);
    }
  }
  
  showLoading(isLoading) {
    this.loadingOverlay.style.display = isLoading ? 'flex' : 'none';
  }
}
```

### Character Portrait Component

```javascript
class CharacterPortraitRenderer {
  constructor() {
    this.imageService = new ImageGenerationService();
    this.portraitContainer = document.getElementById('portraitContainer');
  }
  
  async renderPortrait(character) {
    const portraitElement = document.createElement('div');
    portraitElement.className = 'character-portrait loading';
    this.portraitContainer.appendChild(portraitElement);
    
    try {
      const imageUrl = await this.imageService.generateCharacterPortrait(character);
      portraitElement.style.backgroundImage = `url('${imageUrl}')`;
    } catch (error) {
      console.error('Failed to render portrait:', error);
      portraitElement.style.backgroundImage = `url('${getPlaceholderImage('portrait')}')`;
    } finally {
      portraitElement.classList.remove('loading');
    }
    
    return portraitElement;
  }
}
```

## Phase 1 vs Phase 2 Implementation

### Phase 1 (Text-only)

During Phase 1, the image system is prepared but not actively used:

1. Create database tables for images
2. Implement backend services for image generation and storage
3. Set up API endpoints for image generation
4. Add placeholder UI components that will be replaced with images in Phase 2

### Phase 2 (With Images)

In Phase 2, the image system becomes fully operational:

1. Activate image generation for scenes, characters, and items
2. Replace placeholders with actual image components
3. Implement preloading for better performance
4. Add caching at multiple levels (browser, memory, database)

## Best Practices

1. **Always check the database first**
   - Reduce API costs and improve performance
   - Build up a library of reusable assets over time

2. **Store complete metadata**
   - Prompt used for generation
   - Image dimensions
   - API source
   - Entity associations

3. **Use appropriate image dimensions**
   - Don't generate larger images than needed
   - Maintain consistent aspect ratios

4. **Implement robust error handling**
   - Multiple fallback levels
   - Graceful degradation
   - Never block the game flow due to image failures

5. **Optimize network usage**
   - Compress images appropriately
   - Consider WebP format for modern browsers
   - Implement progressive loading where appropriate

## Conclusion

The image generation system is designed to be efficient, reliable, and database-driven. By always checking for existing assets before generating new ones, the system builds up a growing library of reusable images that improves performance and reduces API costs over time.

In Phase 1, focus on setting up the database structure and services without actively using images. In Phase 2, activate the full image generation system and replace placeholders with generated images. 