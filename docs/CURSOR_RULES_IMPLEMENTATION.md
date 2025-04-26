# Warped Speed - CursorRules Implementation

This document explains how the Warped Speed project's `.cursorrules` have been implemented and how they enforce the project's development standards.

## Overview

The `.cursorrules` file has been set up to:

1. Enforce modular, small-file architecture
2. Prevent monolithic scripts through strict file size limits
3. Implement database-first design principles
4. Enable genre-swapping via database-driven configuration
5. Ensure code testability
6. Maintain proper documentation
7. Enforce Git-based version control practices

## Documentation Priority

All critical documentation is referenced in the `priority_docs` section of the `.cursorrules` file. This ensures that AI assistants and developers automatically consult these files before making changes:

- Project overview: `docs/MASTER.md`
- Bug tracking: `docs/BUGS_PROGRESS.md`
- Game mechanics: `docs/MECHANICS.md`
- Database structure: `docs/DATABASE.md`, `docs/DATABASE_SCHEMA.md`
- API integration: `docs/API_INTEGRATION.md`
- UI specifications: `docs/UI_SPEC.md`
- Development workflow: `docs/DEVELOPMENT_WORKFLOW.md`
- Image generation: `docs/IMAGES.md`
- AI prompting: `docs/PROMPTS.md`, `docs/PROMPT_TEMPLATES.md`, `docs/PROMPTING.md`

## Project Structure Enforcement

The `.cursorrules` file enforces a modular structure through:

### Directory Structure

```
warped/
├── src/
│   ├── modules/      # Core feature modules
│   ├── components/   # UI components
│   ├── services/     # Business logic
│   ├── hooks/        # React hooks
│   ├── utils/        # Utility functions
│   ├── types/        # TypeScript definitions
│   ├── context/      # React context
│   ├── styles/       # CSS modules
├── db/               # Database schema and migrations
├── assets/           # Static assets
├── docs/             # Documentation
├── tests/            # Test files
├── scripts/          # Utility scripts
```

### File Size Limits

- Maximum 300 lines per file
- Warning at 200 lines
- Maximum 250 code lines (non-comment)
- Files exceeding limits trigger an AI-led refactoring suggestion

### Modularity Controls

- Max 15 dependencies per file
- Max 10 exports per file
- Single responsibility principle enforced

## Database-First Architecture

The `.cursorrules` file enforces database-driven development by:

### Multiple Specialized Databases

- `ImageAssetsDB`: Image assets and metadata
- `GameContentDB`: Game content, narrative, and options
- `PlayerDataDB`: Player stats, inventory, and progress
- `NPCDataDB`: NPC data, dialogue, and relationships
- `SystemSettingsDB`: Game settings and configuration

### Migration Rules

- Migrations required for all schema changes
- Data preservation during migrations
- Pre-migration backups
- Migration testing before deployment

### Content Rules

- No hardcoded content in code
- All content loaded from database
- Prompt templates stored in database
- Configuration parameters in database

## Phase-Based Development

The `.cursorrules` file implements strict phase-based development:

### Phase 1: Core Text-Based Gameplay

```json
"allowed_directories": [
  "src/modules/core/",
  "src/components/core/",
  "src/services/core/",
  "db/core/"
]
```

Features limited to:
- Database-driven text adventure
- Action buttons (green, yellow, orange, red, blue)
- GPT-powered narrative generation
- Basic player interaction
- Text-only core gameplay loop

### Phase 2: Visual Enhancement

Only accessible after Phase 1 is complete. Features include:
- Scene image generation
- Player portrait system
- NPC portrait system
- Inventory system with item images
- Map system

### Phase 3: Advanced Features

Only accessible after Phase 2 is complete. Features include:
- Ship combat
- Music integration
- Google login
- Image-to-video generation
- Animated portraits
- Minigames

## Playwright Integration for Testing

Automated UI testing using Playwright:

- Auto-testing on UI changes
- Navigating through game scenes
- Testing all generated buttons
- Screenshot capture
- Console and network error logging
- Saved test results

## Image Generation Workflow

Image generation follows this controlled workflow:

1. Check database for existing matching images
2. If missing, generate new image
3. Save generated image with metadata
4. Store in `ImageAssetsDB`
5. Use variable-based prompts from database

## UI Rules

UI development is strictly phase-controlled:

### Phase 1 UI

- Text display only
- Left-aligned expandable button system
- Status bar
- Simple menu

### Phase 2 UI

- Scene images
- Player portraits
- NPC portraits
- Inventory system with images
- Map system

### Mobile-First Design

- Responsive breakpoints for mobile, tablet, desktop
- Portrait and landscape support
- Mobile-first approach to all UI elements

## Multi-Agent Simulation

The system implements multiple AI agent roles:

- Storyteller: Main narrative generation
- Critic: Reviews and improves generated content
- Combat: Handles combat scenarios
- Chaos: Introduces unpredictable elements

These work in a reflexion loop pattern with a quality threshold of 0.8.

## Content Preservation

Rules to ensure no content is lost:

- Backups before changes
- Existing data preservation
- Version control requirements
- Dedicated backup directory

## Error Handling

Comprehensive error handling for all systems:

- Graceful UI errors
- Error logging
- User-friendly error messages
- Network failure handling
- Missing asset handling
- Database connection handling
- Unexpected behavior handling

## Git Integration

Version control is mandatory with:

- Minimum 3 commits per day
- Meaningful commit messages required
- Automatic milestone backups
- Standardized branch naming: `phase{#}/feature/{feature-name}`
- Automated changelog generation
- Auto-update of `BUGS_PROGRESS.md` and `CURSOR_TODO.md`

## Macros and Automation

Automated processes with shell macros:

- `bb_check`: UI testing with screenshots and diffs
- `create_documentation`: Auto-generate documentation
- `db_backup`: Database backup script
- `run_all_tests`: Run all test suites

## File Triggers

Specific actions trigger automation:

- UI changes trigger Browserbase QA
- Database schema changes require migration
- API changes auto-update documentation
- Prompt template changes sync with database
- Commits auto-log to documentation

## How This System Prevents Previous Issues

1. **No More Monolithic Files**: The 300-line limit with automatic splitting prevents another `Warped_script.js` situation
2. **Database-First**: All content comes from databases, not hardcoding
3. **Modular Architecture**: Clear separation of concerns across directories
4. **Genre-Swappable**: Database-driven content allows easy theme/setting changes
5. **Testable Code**: Unit test requirements and automation
6. **Well-Documented**: Enforced comments and documentation
7. **Version-Controlled**: Git integration with commit standards

## Applying These Rules

These rules are applied through:

1. `.cursorrules` file in the `.cursor` directory
2. Documentation in the `docs` directory
3. Automated enforcement through file triggers
4. AI assistance guided by these rules

## Conclusion

The comprehensive `.cursorrules` system ensures the Warped Speed project follows best practices for modular development, database-driven architecture, and proper documentation, effectively preventing the issues encountered in previous iterations of the project. 