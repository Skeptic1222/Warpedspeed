# Warped Speed - Project Restart Overview

## Introduction

This document outlines the plan for restarting the Warped Speed project from scratch, with a focus on a cleaner, more modular architecture and a database-driven approach. The goal is to create a solid foundation that can support all the features of the original project while being more maintainable, extensible, and easier to develop.

## Key Differences from Current Implementation

### 1. Database-First Approach

**Current:** Content and configuration are often hardcoded in files, making changes require code modifications.

**New:** All content, configuration, and game rules will be stored in databases, allowing for modification without code changes. This includes:
- Game mechanics and rules
- UI configuration and styling
- Prompt templates and variables
- Character options and stats
- Action button definitions

### 2. Modular Architecture

**Current:** Large monolithic files (e.g., warped_script.js) that are difficult to maintain and extend.

**New:** Small, focused files with clear responsibilities:
- Maximum file size of 300 lines
- Clear separation of concerns
- Modular component structure
- Shared services architecture

### 3. Image Generation Workflow

**Current:** Inconsistent handling of image generation and caching.

**New:** Systematic approach to images:
1. Always check database for existing images first
2. Generate only if no suitable image exists
3. Store all generated images with metadata
4. Categorize images for efficient retrieval
5. Implement fallback chain for reliability

### 4. Prompt Engineering

**Current:** Prompts embedded in code with limited standardization.

**New:** Database-driven prompt system:
- All prompts stored in database
- Standardized variable substitution
- Clear output formats
- Role-specific prompts
- Version control for prompts

### 5. Phased Implementation

**Current:** Trying to implement many features simultaneously.

**New:** Strictly phased approach:
- Phase 1: Core text-based gameplay
- Phase 2: Visual elements and extended UI
- Phase 3: Advanced features and refinements

### 6. TypeScript and Modern Practices

**Current:** Mostly JavaScript with inconsistent typing.

**New:** TypeScript with modern best practices:
- Strong typing for all components
- React functional components with hooks
- Consistent error handling
- Comprehensive documentation
- Test-driven development

## Benefits of New Approach

### 1. Maintainability

- Smaller, more focused files are easier to understand and maintain
- Clear separation of concerns makes debugging easier
- Consistent patterns and practices across the codebase
- Comprehensive documentation for all systems

### 2. Flexibility

- Database-driven configuration allows for changes without code modifications
- Prompt-first approach enables content changes without developer involvement
- Modular architecture makes feature additions cleaner
- Genre adaptation possible by changing database content

### 3. Scalability

- Services architecture supports growing complexity
- Caching at multiple levels improves performance
- Database indices optimize common queries
- Asset reuse reduces API calls and improves load times

### 4. Better Developer Experience

- Clearer code organization
- Consistent patterns
- More focused files
- Better tooling support
- Automated testing
- Cursor AI integration

### 5. Improved User Experience

- Faster load times through efficient caching
- More responsive UI
- Consistent styling
- Better error handling
- Graceful degradation

## Implementation Plan

### Phase 1: Core Functionality

1. Setup project structure and tooling
2. Implement database schema and migrations
3. Create core services (database, API integration)
4. Implement basic UI components
5. Develop prompting system
6. Create the narrative engine
7. Implement action button system
8. Add combat mechanics
9. Implement basic character system
10. Develop save/load functionality

### Phase 2: Visual Enhancement

1. Add scene image generation
2. Implement character portraits
3. Create inventory UI
4. Develop character sheet UI
5. Add NPC portrait system
6. Implement map system
7. Enhance narrative with visual elements
8. Add visual effects and transitions

### Phase 3: Advanced Features

1. Implement music and sound
2. Add social login
3. Develop image-to-video generation
4. Create minigames
5. Implement advanced combat features
6. Add multiplayer capabilities
7. Enhance with additional AI integrations

## Migration Strategy

1. **Database Migration**
   - Export existing content to JSON
   - Transform to new schema
   - Import into new database

2. **Asset Preservation**
   - Extract and categorize existing images
   - Transform metadata to new format
   - Import into image database

3. **Prompt Migration**
   - Extract existing prompts
   - Reformat to template format
   - Add to prompt database

## Success Criteria

The project restart will be considered successful if:

1. Phase 1 is completed with a working text-based game
2. Code quality metrics show improvement over original
3. Performance is equal or better than original
4. Database-driven approach is fully implemented
5. Cursor AI can effectively maintain and extend the codebase

## Conclusion

This restart represents a significant investment but will create a more solid foundation for the future of Warped Speed. By addressing the architectural issues of the current implementation and embracing a fully database-driven approach, we can create a more maintainable, extensible, and enjoyable game that can easily evolve over time.

The initial focus on core functionality without images (Phase 1) will ensure we have a solid foundation before adding visual elements. This approach minimizes risk and allows for iterative improvement. 