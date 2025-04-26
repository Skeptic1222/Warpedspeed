# Warped Speed - API Integration Documentation

## Overview

This document provides detailed guidance on integrating external AI APIs with the Warped Speed application. The primary APIs used in the project are:

1. OpenAI API (GPT models and DALL-E)
2. Dzine API (enhanced image generation)

## API Keys Management

### Environment Variables

All API keys must be stored as environment variables, never hardcoded in source code:

```
OPENAI_API_KEY=sk-your_openai_api_key_here
DZINE_API_KEY=your_dzine_api_key_here
```

### Key Rotation and Security

- Rotate API keys periodically for security
- Use restricted keys with appropriate permissions
- Monitor usage to detect unusual patterns
- Keep production keys separate from development keys

## OpenAI API Integration

### Initialization

```javascript
import { Configuration, OpenAIApi } from 'openai';

// Initialize OpenAI client
const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);
```

### Text Generation with GPT Models

```javascript
/**
 * Generate text using GPT model
 * @param {Array} messages - Array of message objects with role and content
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} Generated text
 */
async function generateText(messages, options = {}) {
  const {
    model = 'gpt-4',
    temperature = 0.7,
    maxTokens = 1024,
    frequencyPenalty = 0,
    presencePenalty = 0,
  } = options;
  
  try {
    const response = await openai.createChatCompletion({
      model,
      messages,
      temperature,
      max_tokens: maxTokens,
      frequency_penalty: frequencyPenalty,
      presence_penalty: presencePenalty,
    });
    
    return response.data.choices[0].message.content;
  } catch (error) {
    console.error('Error generating text:', error);
    throw new Error(`OpenAI API Error: ${error.message}`);
  }
}
```

### Image Generation with DALL-E

```javascript
/**
 * Generate image using DALL-E
 * @param {string} prompt - Image generation prompt
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} URL of generated image
 */
async function generateImage(prompt, options = {}) {
  const {
    size = '512x512',
    n = 1,
    responseFormat = 'url',
  } = options;
  
  try {
    const response = await openai.createImage({
      prompt,
      n,
      size,
      response_format: responseFormat,
    });
    
    return response.data.data[0].url;
  } catch (error) {
    console.error('Error generating image:', error);
    throw new Error(`DALL-E API Error: ${error.message}`);
  }
}
```

### Rate Limiting and Retry Logic

```javascript
/**
 * Execute API call with retry logic
 * @param {Function} apiCall - Function that makes the API call
 * @param {Object} options - Configuration options
 * @returns {Promise<any>} API response
 */
async function executeWithRetry(apiCall, options = {}) {
  const {
    maxRetries = 3,
    initialDelay = 1000,
    maxDelay = 10000,
  } = options;
  
  let attempts = 0;
  let delay = initialDelay;
  
  while (attempts < maxRetries) {
    try {
      return await apiCall();
    } catch (error) {
      attempts++;
      
      // Only retry on rate limit errors or server errors
      if (error.response?.status !== 429 && 
          error.response?.status < 500 && 
          attempts === maxRetries) {
        throw error;
      }
      
      console.warn(`API call failed, retrying (${attempts}/${maxRetries})`);
      
      // Exponential backoff with jitter
      await new Promise(resolve => 
        setTimeout(resolve, delay * (1 + Math.random() * 0.2))
      );
      
      delay = Math.min(delay * 2, maxDelay);
    }
  }
  
  throw new Error(`API call failed after ${maxRetries} attempts`);
}
```

## Dzine API Integration

### Introduction to Dzine

Dzine provides high-quality image generation but requires a specific two-step process:
1. Create a task (returns a task ID)
2. Poll for task completion (task ID → image URL)

This asynchronous design is challenging but can be managed with proper implementation.

### Dzine API Endpoints

- Task creation: `https://papi.dzine.ai/openapi/v1/create_task_txt2img`
- Task polling: `https://papi.dzine.ai/openapi/v1/get_task_progress/{task_id}`

### Authentication

Dzine uses a direct API key in the Authorization header (without 'Bearer' prefix):

```javascript
headers: {
  'Content-Type': 'application/json',
  'Authorization': process.env.DZINE_API_KEY
}
```

### Task Creation

```javascript
/**
 * Create an image generation task in Dzine
 * @param {string} prompt - Image generation prompt
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} Task ID for polling
 */
async function createDzineTask(prompt, options = {}) {
  const {
    width = 512,
    height = 512,
    styleIntensity = 0.7,
    quality = 1,
    outputFormat = 'webp'
  } = options;
  
  const payload = {
    prompt,
    target_w: width,
    target_h: height,
    style_intensity: styleIntensity,
    quality_mode: quality,
    output_format: outputFormat,
    generate_slots: [1, 0, 0, 0]  // Generate one image in first slot
  };
  
  try {
    const response = await fetch('https://papi.dzine.ai/openapi/v1/create_task_txt2img', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': process.env.DZINE_API_KEY
      },
      body: JSON.stringify(payload)
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(`Dzine API Error: ${errorData.message || response.statusText}`);
    }
    
    const data = await response.json();
    
    if (data.task_id) {
      return data.task_id;
    } else {
      throw new Error('No task_id received from Dzine API');
    }
  } catch (error) {
    console.error('Error creating Dzine task:', error);
    throw error;
  }
}
```

### Polling for Task Completion

```javascript
/**
 * Poll for Dzine task completion
 * @param {string} taskId - Task ID from createDzineTask
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} URL of generated image
 */
async function pollDzineTask(taskId, options = {}) {
  const {
    maxAttempts = 30,
    interval = 2000,  // 2 seconds between polls
    timeout = 120000  // 2 minutes total timeout
  } = options;
  
  const startTime = Date.now();
  let attempts = 0;
  
  while (attempts < maxAttempts && Date.now() - startTime < timeout) {
    try {
      const response = await fetch(`https://papi.dzine.ai/openapi/v1/get_task_progress/${taskId}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': process.env.DZINE_API_KEY
        }
      });
      
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`Dzine API Error: ${errorData.message || response.statusText}`);
      }
      
      const data = await response.json();
      
      if (data.status === 'succeed') {
        // Success - extract image URL from first slot
        if (data.generate_result_slots && data.generate_result_slots.length > 0) {
          return data.generate_result_slots[0];
        } else {
          throw new Error('No image URL in successful Dzine response');
        }
      } else if (data.status === 'failed') {
        throw new Error(`Dzine task failed: ${data.error || 'Unknown error'}`);
      }
      
      // Still in progress, wait and try again
      attempts++;
      await new Promise(resolve => setTimeout(resolve, interval));
    } catch (error) {
      console.error(`Error polling Dzine task (attempt ${attempts}):`, error);
      if (error.message.includes('Dzine task failed')) {
        throw error; // Don't retry on task failure
      }
      attempts++;
      await new Promise(resolve => setTimeout(resolve, interval));
    }
  }
  
  throw new Error(`Dzine task timed out after ${attempts} attempts`);
}
```

### Complete Dzine Integration Flow

```javascript
/**
 * Generate image using Dzine with polling
 * @param {string} prompt - Image generation prompt
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} URL of generated image
 */
async function generateDzineImage(prompt, options = {}) {
  try {
    // First check database for existing image with similar prompt
    const existingImage = await databaseService.findSimilarImage(prompt, options);
    if (existingImage) {
      console.log('Using existing image from database');
      return existingImage.url;
    }
    
    // Step 1: Create the task
    const taskId = await createDzineTask(prompt, options);
    
    // Step 2: Poll for completion
    const imageUrl = await pollDzineTask(taskId, options);
    
    // Step 3: Save to database for future reuse
    await databaseService.saveGeneratedImage({
      prompt,
      url: imageUrl,
      width: options.width || 512,
      height: options.height || 512,
      api_source: 'dzine'
    });
    
    return imageUrl;
  } catch (error) {
    console.error('Error generating Dzine image:', error);
    
    // Fall back to DALL-E if Dzine fails
    if (options.fallbackToDALLE) {
      console.log('Falling back to DALL-E');
      return await generateImage(prompt, options);
    }
    
    throw error;
  }
}
```

### Error Handling for Dzine

Common Dzine error scenarios and how to handle them:

1. **Task creation fails**
   - Check API key validity
   - Verify request format (especially prompt length)
   - Fall back to DALL-E

2. **Polling timeout**
   - Dzine queue may be congested
   - Increase timeout parameter
   - Fall back to DALL-E

3. **Task fails during processing**
   - Check prompt for policy violations
   - Try with a different style or quality setting
   - Fall back to DALL-E

## Image Search Before Generation

Always search for existing images before generating new ones:

```javascript
/**
 * Find similar image in database
 * @param {string} prompt - Image generation prompt
 * @param {Object} options - Configuration options
 * @returns {Promise<Object|null>} Existing image or null
 */
async function findSimilarImage(prompt, options = {}) {
  const {
    category = 'scene',
    width,
    height,
    similarity = 0.85  // Threshold for similarity matching
  } = options;
  
  // Basic exact match (optimization)
  const exactMatch = await knex('images')
    .where('prompt', prompt)
    .where('category', category)
    .first();
    
  if (exactMatch) {
    return exactMatch;
  }
  
  // If no exact match, try advanced similarity search
  // This would typically use embeddings or keyword matching
  // Simplified example:
  const keywords = extractKeywords(prompt);
  
  const similarImages = await knex('images')
    .where('category', category)
    .whereRaw(`
      prompt LIKE ? OR 
      prompt LIKE ? OR 
      prompt LIKE ?
    `, [
      `%${keywords[0]}%`,
      `%${keywords[1]}%`,
      `%${keywords[2]}%`
    ])
    .orderBy('created_at', 'desc')
    .limit(10);
    
  // Size constraints
  if (width && height) {
    const sizeMatches = similarImages.filter(img => 
      img.width === width && img.height === height
    );
    
    if (sizeMatches.length > 0) {
      return sizeMatches[0];
    }
  }
  
  // Return best match if exists, or null
  return similarImages.length > 0 ? similarImages[0] : null;
}
```

## Fallback Mechanisms

Implement fallbacks for when APIs are unavailable:

```javascript
/**
 * Get base64 placeholder image
 * @param {string} type - Type of placeholder
 * @returns {string} Base64 encoded image data
 */
function getPlaceholderImage(type = 'scene') {
  // Return appropriate placeholder based on type
  // These should be small, base64-encoded images
  
  const placeholders = {
    scene: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA...',
    portrait: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA...',
    item: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA...'
  };
  
  return placeholders[type] || placeholders.scene;
}

/**
 * Generate image with comprehensive fallbacks
 * @param {string} prompt - Image generation prompt
 * @param {Object} options - Configuration options
 * @returns {Promise<string>} URL or base64 of image
 */
async function generateImageWithFallbacks(prompt, options = {}) {
  try {
    // Try database first
    const existingImage = await findSimilarImage(prompt, options);
    if (existingImage) {
      return existingImage.url || existingImage.binary_data;
    }
    
    // Try Dzine
    try {
      return await generateDzineImage(prompt, options);
    } catch (dzineError) {
      console.warn('Dzine generation failed, falling back to DALL-E:', dzineError);
      
      // Try DALL-E
      try {
        return await generateImage(prompt, options);
      } catch (dalleError) {
        console.warn('DALL-E generation failed, using placeholder:', dalleError);
        
        // Last resort: placeholder
        return getPlaceholderImage(options.category);
      }
    }
  } catch (error) {
    console.error('All image generation methods failed:', error);
    return getPlaceholderImage(options.category);
  }
}
```

## API Service Design

Encapsulate API interactions in dedicated services:

```javascript
// Example service class for image generation
class ImageGenerationService {
  constructor(options = {}) {
    this.openaiKey = process.env.OPENAI_API_KEY;
    this.dzineKey = process.env.DZINE_API_KEY;
    this.databaseService = options.databaseService;
    this.imageCache = new Map(); // In-memory cache
  }
  
  async generateImage(prompt, options = {}) {
    // Implementation that uses the methods described above
  }
  
  async getDzineImage(prompt, options = {}) {
    // Implementation that uses Dzine specific methods
  }
  
  async getDalleImage(prompt, options = {}) {
    // Implementation that uses DALL-E specific methods
  }
}
```

## Rate Limiting Management

Implement token counting and rate limiting for OpenAI:

```javascript
// Example token counter using GPT-3 Tokenizer
const tokenizer = require('gpt-3-encoder');

/**
 * Count tokens in text for rate limiting
 * @param {string} text - Text to count tokens for
 * @returns {number} Token count
 */
function countTokens(text) {
  return tokenizer.encode(text).length;
}

/**
 * Track API usage for rate limiting
 */
class ApiUsageTracker {
  constructor() {
    this.usage = {
      openai: {
        tokens: 0,
        requests: 0,
        lastReset: Date.now()
      },
      dzine: {
        requests: 0,
        lastReset: Date.now()
      }
    };
    
    // Reset counters daily
    setInterval(() => this.resetCounters(), 24 * 60 * 60 * 1000);
  }
  
  trackOpenAiTokens(tokenCount) {
    this.usage.openai.tokens += tokenCount;
    this.usage.openai.requests++;
  }
  
  trackDzineRequest() {
    this.usage.dzine.requests++;
  }
  
  resetCounters() {
    this.usage.openai.tokens = 0;
    this.usage.openai.requests = 0;
    this.usage.openai.lastReset = Date.now();
    
    this.usage.dzine.requests = 0;
    this.usage.dzine.lastReset = Date.now();
  }
  
  getUsage() {
    return {...this.usage};
  }
}
```

## Testing API Integration

Sample test strategy for API integration:

```javascript
// Example Jest tests for API integration
describe('API Integration', () => {
  describe('OpenAI API', () => {
    it('should generate text successfully', async () => {
      // Test implementation
    });
    
    it('should handle rate limiting', async () => {
      // Test implementation
    });
    
    it('should generate images successfully', async () => {
      // Test implementation
    });
  });
  
  describe('Dzine API', () => {
    it('should create tasks successfully', async () => {
      // Test implementation
    });
    
    it('should poll tasks successfully', async () => {
      // Test implementation
    });
    
    it('should handle task failures gracefully', async () => {
      // Test implementation
    });
  });
  
  describe('Fallback Mechanisms', () => {
    it('should fallback to DALL-E when Dzine fails', async () => {
      // Test implementation
    });
    
    it('should fallback to placeholders when all APIs fail', async () => {
      // Test implementation
    });
  });
});
```

## API Status Monitoring

Implement API status monitoring:

```javascript
/**
 * Check API health
 * @returns {Promise<Object>} Status of each API
 */
async function checkApiStatus() {
  const status = {
    openai: {
      operational: false,
      latency: 0,
      error: null
    },
    dzine: {
      operational: false,
      latency: 0,
      error: null
    }
  };
  
  // Check OpenAI
  try {
    const start = Date.now();
    // Quick health check using models endpoint
    const response = await fetch('https://api.openai.com/v1/models', {
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      }
    });
    status.openai.latency = Date.now() - start;
    status.openai.operational = response.ok;
    
    if (!response.ok) {
      const data = await response.json();
      status.openai.error = data.error?.message || response.statusText;
    }
  } catch (error) {
    status.openai.error = error.message;
  }
  
  // Check Dzine (using minimal task creation)
  try {
    const start = Date.now();
    const response = await fetch('https://papi.dzine.ai/openapi/v1/create_task_txt2img', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': process.env.DZINE_API_KEY
      },
      body: JSON.stringify({
        prompt: 'Test health check',
        target_w: 64, // Minimal size to save resources
        target_h: 64,
        style_intensity: 0.5,
        quality_mode: 0,
        generate_slots: [1,0,0,0]
      })
    });
    status.dzine.latency = Date.now() - start;
    status.dzine.operational = response.ok;
    
    if (!response.ok) {
      const data = await response.json();
      status.dzine.error = data.message || response.statusText;
    }
  } catch (error) {
    status.dzine.error = error.message;
  }
  
  return status;
}
```

## API Keys Validation

Validate API keys before using them:

```javascript
/**
 * Validate OpenAI API key
 * @param {string} apiKey - OpenAI API key to validate
 * @returns {Promise<boolean>} Whether key is valid
 */
async function validateOpenAiKey(apiKey) {
  try {
    const response = await fetch('https://api.openai.com/v1/models', {
      headers: {
        'Authorization': `Bearer ${apiKey}`
      }
    });
    return response.ok;
  } catch (error) {
    return false;
  }
}

/**
 * Validate Dzine API key
 * @param {string} apiKey - Dzine API key to validate
 * @returns {Promise<boolean>} Whether key is valid
 */
async function validateDzineKey(apiKey) {
  try {
    // Small task creation with minimal resource usage
    const response = await fetch('https://papi.dzine.ai/openapi/v1/create_task_txt2img', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': apiKey
      },
      body: JSON.stringify({
        prompt: 'Key validation test',
        target_w: 64,
        target_h: 64,
        style_intensity: 0.5,
        quality_mode: 0,
        generate_slots: [1,0,0,0]
      })
    });
    return response.ok;
  } catch (error) {
    return false;
  }
}
```

## Conclusion

This API integration documentation provides a comprehensive guide to working with OpenAI and Dzine APIs in the Warped Speed project. By following these patterns and best practices, you can ensure reliable integration with graceful fallbacks, efficient usage of resources, and proper error handling.

Remember to:
1. Always check the database before generating new content
2. Implement proper polling for Dzine with timeouts
3. Use fallback mechanisms for reliability
4. Track API usage for rate limiting
5. Store and validate API keys securely 