# Warped Speed - Master Documentation

## Project Overview
Warped Speed is an immersive text-based adventure game with procedurally generated content powered by AI. The game combines narrative storytelling with RPG mechanics in a sci-fi universe. This document serves as the central reference for the complete rebuild of the project with a database-driven architecture.

## Phases of Development

### Phase 1: Core Functionality
- Database-driven text adventure system
- Action buttons (green, yellow, orange, red, blue)
- GPT-powered narrative generation
- Basic player interaction without images
- Text-only core gameplay loop

### Phase 2: Visual Enhancement
- Scene image generation
- Player portrait system
- NPC portrait system
- Inventory system with item images
- Map system (100x100 persistent world)

### Phase 3: Advanced Features
- Ship combat
- Music integration
- Google login
- Image-to-video generation for cutscenes
- Animated portraits
- Minigames

## Core Architecture Principles

1. **Database-Driven Everything**
   - All content stored in and retrieved from databases
   - No hardcoded content or structure
   - Game content, mechanics, and styling all driven by database

2. **Image Generation with Database Caching**
   - Search database before generating new images
   - Store all generated images for future use
   - Categorize images by type, tags, and context

3. **Prompt-First Development**
   - Code is thin, prompts are rich
   - Game logic encoded as high-level rules and contextual data
   - Let AI create prose, dialogue, and branching outcomes

4. **Modular Architecture**
   - Small, focused files with clear responsibilities
   - Clear separation between UI, logic, and data
   - No monolithic files (max 300 lines per file)

5. **Multiple AI Specialization**
   - GPT-4 for narrative and complex interactions
   - GPT-3.5 for simpler, faster responses
   - Specialized AI roles (combat, conversation, world-building)

## Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| Frontend | React + TypeScript | UI components and interactions |
| Backend | Node.js + Express | API and server functionality |
| Database | SQL Server | Data persistence |
| AI | OpenAI GPT-4/3.5 | Text generation |
| Image | DALL-E 3, Dzine | Image generation |
| Testing | Jest, Playwright | Automated testing |
| Automation | Cursor AI | Development assistance |

## Database Structure Overview

The database is structured to support all aspects of the game:

1. **Content Database**
   - Character data
   - Location data
   - Item data
   - Quest data
   - Lore/world data

2. **Image Database**
   - Categorized by type (portrait, scene, item, etc.)
   - Includes metadata (prompt, tags, dimensions)
   - Searchable by characteristics and context

3. **Prompt Database**
   - Templates for different types of generation
   - Context parameters and variables
   - Categorized by purpose

4. **User Database**
   - Player accounts
   - Save states
   - Preferences

5. **Configuration Database**
   - UI settings (colors, layouts, fonts)
   - Game rules and parameters
   - Action button definitions

## API Integration

The project relies on several external APIs:

1. **OpenAI GPT-4/3.5**
   - Narrative generation
   - Character dialogue
   - World building
   - Action generation

2. **Dzine API**
   - High-quality image generation
   - Requires special polling mechanism
   - Fallback to DALL-E when unavailable

3. **DALL-E API**
   - Alternative image generation
   - Direct part of OpenAI API
   - Used as fallback

Detailed API integration instructions are in [API_INTEGRATION.md](./API_INTEGRATION.md).

## Core Game Mechanics

Detailed in [MECHANICS.md](./MECHANICS.md), the game features:

1. **Action System**
   - Green buttons: Always available core actions
   - Yellow buttons: Contextual actions for current scene
   - Orange buttons: High-risk or urgent actions
   - Red buttons: Combat-specific actions
   - Blue buttons: Conversation/dialogue actions

2. **Character System**
   - Stats: HP, SP, MP
   - Skills and abilities
   - Inventory and equipment
   - Relationships with NPCs

3. **World Interaction**
   - Exploration of procedurally generated locations
   - Quest system
   - Combat encounters
   - NPC interactions

## User Interface Structure

1. **Core UI Components**
   - Text window for narrative
   - Action buttons (color-coded)
   - Player status panel
   - Scene image display (Phase 2)

2. **Expandable Panels**
   - Inventory/equipment
   - Character sheet
   - Quest log
   - Map display

3. **Mobile-First Design**
   - Portrait and landscape orientations
   - Touch-friendly interface
   - Responsive layout

## File Structure Overview

```
warped/
├── src/
│   ├── components/         # UI components
│   ├── services/           # Business logic services
│   │   ├── api/            # API integration
│   │   ├── database/       # Database interaction
│   │   ├── gpt/            # GPT prompt handling
│   │   ├── image/          # Image generation
│   ├── hooks/              # React hooks
│   ├── utils/              # Utility functions
│   ├── types/              # TypeScript interfaces
│   ├── context/            # React context providers
│   ├── styles/             # CSS modules
├── public/                 # Static assets
├── scripts/                # Utility scripts
├── server/                 # Backend code
│   ├── routes/             # API routes
│   ├── controllers/        # Request handlers
│   ├── models/             # Data models
│   ├── database/           # DB migrations/seeds
├── docs/                   # Documentation
├── tests/                  # Test files
```

## Development Workflow

1. **Database-First**
   - Define database schema before implementing features
   - Create migrations for all schema changes
   - Seed with initial data for testing

2. **Test-Driven**
   - Write tests before implementation
   - Test DB interactions and API endpoints
   - Use Playwright for UI testing

3. **Phased Implementation**
   - Follow the phase guidelines strictly
   - Get each phase fully functional before moving to next
   - Prioritize stability over features

4. **Code Quality Standards**
   - TypeScript for all new code
   - React functional components with hooks
   - Max 300 lines per file
   - Comprehensive comments

## Development Rules

1. **Documentation**
   - Document all database schema changes
   - Include JSDoc comments for functions
   - Update relevant .md files with changes

2. **Testing**
   - Unit tests for all services
   - Integration tests for API endpoints
   - E2E tests for critical user flows

3. **Security**
   - Never hardcode API keys
   - Use environment variables for secrets
   - Validate all user input

4. **Performance**
   - Cache expensive operations
   - Lazy load components
   - Optimize database queries

## Conclusion

This rebuild aims to create a solid, maintainable foundation for Warped Speed that can evolve over time while maintaining high quality standards. The database-driven architecture ensures flexibility to change game content, mechanics, and presentation without requiring code changes.

Focus on building Phase 1 completely and correctly before moving on. Each phase should be thoroughly tested and functioning before proceeding to the next. 