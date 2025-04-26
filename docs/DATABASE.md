# Warped Speed - Database Schema Documentation

## Overview

The Warped Speed database is the foundation of the entire system, designed to support a fully database-driven architecture where game content, mechanics, and presentation can all be controlled through data rather than code. This document details the complete database schema, providing a reference for developers implementing the system.

The database is organized into logical groups:
1. Game Content - core game entities
2. Media Assets - images and other media
3. User Data - player information and saves
4. System Configuration - game rules and settings
5. Prompt Templates - AI generation templates

## Database Setup

### Connection Configuration

Credentials and connection strings should be stored in environment variables, never hardcoded:

```
DB_SERVER=your_server_address
DB_NAME=warped
DB_USER=warped_user
DB_PASSWORD=your_secure_password
```

### Database Creation

SQL Server is used as the primary database. Initial setup script:

```sql
-- Run once to create database and user
USE master;
GO

-- Create database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'warped')
BEGIN
    CREATE DATABASE warped
    COLLATE SQL_Latin1_General_CP1_CI_AS;
END
GO

USE warped;
GO

-- Create application user
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'warped_user')
BEGIN
    CREATE LOGIN warped_user WITH PASSWORD = 'your_secure_password';
END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'warped_user')
BEGIN
    CREATE USER warped_user FOR LOGIN warped_user;
    ALTER ROLE db_datareader ADD MEMBER warped_user;
    ALTER ROLE db_datawriter ADD MEMBER warped_user;
END
GO
```

## Game Content Schema

### characters

Stores both player characters and NPCs.

```sql
CREATE TABLE characters (
    id INT IDENTITY(1,1) PRIMARY KEY,
    character_id VARCHAR(50) NOT NULL,            -- Unique identifier
    name NVARCHAR(100) NOT NULL,                  -- Character name
    type VARCHAR(20) NOT NULL,                    -- 'player' or 'npc'
    species VARCHAR(50) NOT NULL,                 -- Character species
    role VARCHAR(50),                             -- Role/class
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data (stats, traits, etc.)
    portrait_url NVARCHAR(MAX),                   -- URL to portrait image
    full_body_url NVARCHAR(MAX),                  -- URL to full body image
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_character_id UNIQUE (character_id)
);

CREATE INDEX IDX_characters_name ON characters(name);
CREATE INDEX IDX_characters_type ON characters(type);
```

### locations

Stores game world locations.

```sql
CREATE TABLE locations (
    id INT IDENTITY(1,1) PRIMARY KEY,
    location_id VARCHAR(50) NOT NULL,             -- Unique identifier
    name NVARCHAR(100) NOT NULL,                  -- Location name
    type VARCHAR(50) NOT NULL,                    -- Location type (city, dungeon, etc.)
    coordinates NVARCHAR(50),                     -- Coordinates in world map
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data (description, features, etc.)
    image_url NVARCHAR(MAX),                      -- URL to location image
    parent_location_id VARCHAR(50),               -- For hierarchical locations
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_location_id UNIQUE (location_id)
);

CREATE INDEX IDX_locations_name ON locations(name);
CREATE INDEX IDX_locations_type ON locations(type);
CREATE INDEX IDX_locations_parent ON locations(parent_location_id);
```

### items

Stores game items.

```sql
CREATE TABLE items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    item_id VARCHAR(50) NOT NULL,                 -- Unique identifier
    name NVARCHAR(100) NOT NULL,                  -- Item name
    category VARCHAR(50) NOT NULL,                -- Item category (weapon, armor, etc.)
    rarity VARCHAR(50) NOT NULL,                  -- Item rarity (common, rare, etc.)
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data (stats, effects, etc.)
    image_url NVARCHAR(MAX),                      -- URL to item image
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_item_id UNIQUE (item_id)
);

CREATE INDEX IDX_items_name ON items(name);
CREATE INDEX IDX_items_category ON items(category);
CREATE INDEX IDX_items_rarity ON items(rarity);
```

### quests

Stores game quests and missions.

```sql
CREATE TABLE quests (
    id INT IDENTITY(1,1) PRIMARY KEY,
    quest_id VARCHAR(50) NOT NULL,                -- Unique identifier
    title NVARCHAR(100) NOT NULL,                 -- Quest title
    type VARCHAR(50) NOT NULL,                    -- Quest type (main, side, etc.)
    difficulty INT NOT NULL,                      -- Quest difficulty (1-10)
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data (description, objectives, rewards)
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_quest_id UNIQUE (quest_id)
);

CREATE INDEX IDX_quests_type ON quests(type);
CREATE INDEX IDX_quests_difficulty ON quests(difficulty);
```

### lore

Stores game world lore and backstory.

```sql
CREATE TABLE lore (
    id INT IDENTITY(1,1) PRIMARY KEY,
    lore_id VARCHAR(50) NOT NULL,                 -- Unique identifier
    title NVARCHAR(100) NOT NULL,                 -- Lore entry title
    content NVARCHAR(MAX) NOT NULL,               -- Lore content
    category VARCHAR(50) NOT NULL,                -- Category (history, faction, etc.)
    importance INT NOT NULL DEFAULT 1,            -- Importance level (1-10)
    tags NVARCHAR(MAX),                           -- JSON array of tags
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_lore_id UNIQUE (lore_id)
);

CREATE INDEX IDX_lore_category ON lore(category);
CREATE INDEX IDX_lore_importance ON lore(importance);
```

### world_state

Stores the current state of the game world.

```sql
CREATE TABLE world_state (
    id INT IDENTITY(1,1) PRIMARY KEY,
    state_id VARCHAR(50) NOT NULL,                -- Unique identifier
    category VARCHAR(50) NOT NULL,                -- State category
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data of state
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_state_id UNIQUE (state_id)
);

CREATE INDEX IDX_world_state_category ON world_state(category);
```

## Media Assets Schema

### images

Stores all generated images with metadata for retrieval.

```sql
CREATE TABLE images (
    id INT IDENTITY(1,1) PRIMARY KEY,
    image_id VARCHAR(50) NOT NULL,                -- Unique identifier
    category VARCHAR(50) NOT NULL,                -- Image category (portrait, scene, item, etc.)
    subcategory VARCHAR(50),                      -- Image subcategory (optional)
    prompt NVARCHAR(MAX) NOT NULL,                -- Original generation prompt
    tags NVARCHAR(MAX),                           -- JSON array of tags for searching
    width INT NOT NULL,                           -- Image width in pixels
    height INT NOT NULL,                          -- Image height in pixels
    url NVARCHAR(MAX),                            -- URL to image (if stored externally)
    binary_data VARBINARY(MAX),                   -- Binary image data (if stored in DB)
    file_path NVARCHAR(MAX),                      -- Path if stored in file system
    api_source VARCHAR(50) NOT NULL,              -- Source API (dzine, dalle, etc.)
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_image_id UNIQUE (image_id)
);

CREATE INDEX IDX_images_category ON images(category);
CREATE INDEX IDX_images_created ON images(created_at);
```

### image_mapping

Maps images to game entities for quick lookups.

```sql
CREATE TABLE image_mapping (
    id INT IDENTITY(1,1) PRIMARY KEY,
    image_id VARCHAR(50) NOT NULL,                -- Reference to images.image_id
    entity_type VARCHAR(50) NOT NULL,             -- Entity type (character, location, item)
    entity_id VARCHAR(50) NOT NULL,               -- ID of the referenced entity
    context VARCHAR(100),                         -- Additional context (e.g., "portrait", "battle")
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT FK_image_mapping_image FOREIGN KEY (image_id)
        REFERENCES images(image_id)
);

CREATE INDEX IDX_image_mapping_entity ON image_mapping(entity_type, entity_id);
```

### audio

Stores audio assets (for Phase 3).

```sql
CREATE TABLE audio (
    id INT IDENTITY(1,1) PRIMARY KEY,
    audio_id VARCHAR(50) NOT NULL,                -- Unique identifier
    category VARCHAR(50) NOT NULL,                -- Audio category (music, sfx, etc.)
    name NVARCHAR(100) NOT NULL,                  -- Audio name
    url NVARCHAR(MAX),                            -- URL to audio file
    binary_data VARBINARY(MAX),                   -- Binary audio data (if stored in DB)
    file_path NVARCHAR(MAX),                      -- Path if stored in file system
    duration INT,                                 -- Duration in seconds
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_audio_id UNIQUE (audio_id)
);

CREATE INDEX IDX_audio_category ON audio(category);
```

### videos

Stores video assets (for Phase 3).

```sql
CREATE TABLE videos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    video_id VARCHAR(50) NOT NULL,                -- Unique identifier
    category VARCHAR(50) NOT NULL,                -- Video category (cutscene, etc.)
    name NVARCHAR(100) NOT NULL,                  -- Video name
    url NVARCHAR(MAX),                            -- URL to video file
    file_path NVARCHAR(MAX),                      -- Path if stored in file system
    duration INT,                                 -- Duration in seconds
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_video_id UNIQUE (video_id)
);

CREATE INDEX IDX_video_category ON videos(category);
```

## User Data Schema

### users

Stores user account information.

```sql
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,                 -- Unique identifier
    username NVARCHAR(50) NOT NULL,               -- Username
    email NVARCHAR(100),                          -- Email address
    password_hash NVARCHAR(100),                  -- Hashed password
    oauth_provider VARCHAR(50),                   -- OAuth provider if applicable
    oauth_id VARCHAR(100),                        -- OAuth ID if applicable
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    last_login DATETIME,                          -- Last login timestamp
    CONSTRAINT UQ_user_id UNIQUE (user_id),
    CONSTRAINT UQ_username UNIQUE (username),
    CONSTRAINT UQ_email UNIQUE (email)
);
```

### player_saves

Stores saved game states.

```sql
CREATE TABLE player_saves (
    id INT IDENTITY(1,1) PRIMARY KEY,
    save_id VARCHAR(50) NOT NULL,                 -- Unique identifier
    user_id VARCHAR(50) NOT NULL,                 -- Reference to users.user_id
    character_id VARCHAR(50) NOT NULL,            -- Reference to characters.character_id
    save_name NVARCHAR(100) NOT NULL,             -- Save name
    game_state NVARCHAR(MAX) NOT NULL,            -- JSON data of full game state
    screenshot_image_id VARCHAR(50),              -- Reference to screenshot
    playtime_seconds INT NOT NULL DEFAULT 0,      -- Total playtime in seconds
    created_at DATETIME DEFAULT GETDATE(),        -- Save creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_save_id UNIQUE (save_id)
);

CREATE INDEX IDX_player_saves_user ON player_saves(user_id);
CREATE INDEX IDX_player_saves_character ON player_saves(character_id);
```

### user_preferences

Stores user preferences and settings.

```sql
CREATE TABLE user_preferences (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,                 -- Reference to users.user_id
    preference_key VARCHAR(50) NOT NULL,          -- Preference key
    preference_value NVARCHAR(MAX) NOT NULL,      -- Preference value (JSON or string)
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_user_preference UNIQUE (user_id, preference_key)
);
```

## System Configuration Schema

### settings

Stores system-wide settings.

```sql
CREATE TABLE settings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL,             -- Setting key
    setting_value NVARCHAR(MAX) NOT NULL,         -- Setting value (JSON or string)
    category VARCHAR(50) NOT NULL,                -- Setting category
    description NVARCHAR(255),                    -- Setting description
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_setting_key UNIQUE (setting_key)
);
```

### ui_config

Stores UI configuration (colors, layouts, etc.).

```sql
CREATE TABLE ui_config (
    id INT IDENTITY(1,1) PRIMARY KEY,
    config_key VARCHAR(50) NOT NULL,              -- Configuration key
    config_value NVARCHAR(MAX) NOT NULL,          -- Configuration value (JSON)
    scope VARCHAR(50) NOT NULL,                   -- Scope (global, component, etc.)
    component VARCHAR(50),                        -- Component name if applicable
    description NVARCHAR(255),                    -- Configuration description
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_ui_config_key UNIQUE (config_key, scope, component)
);
```

### game_rules

Stores game mechanics rules.

```sql
CREATE TABLE game_rules (
    id INT IDENTITY(1,1) PRIMARY KEY,
    rule_id VARCHAR(50) NOT NULL,                 -- Unique identifier
    title NVARCHAR(100) NOT NULL,                 -- Rule title
    category VARCHAR(50) NOT NULL,                -- Rule category
    data NVARCHAR(MAX) NOT NULL,                  -- JSON data of rule
    is_active BIT NOT NULL DEFAULT 1,             -- Whether rule is active
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_rule_id UNIQUE (rule_id)
);

CREATE INDEX IDX_game_rules_category ON game_rules(category);
CREATE INDEX IDX_game_rules_active ON game_rules(is_active);
```

### action_buttons

Stores action button configurations.

```sql
CREATE TABLE action_buttons (
    id INT IDENTITY(1,1) PRIMARY KEY,
    button_id VARCHAR(50) NOT NULL,               -- Unique identifier
    button_text NVARCHAR(100) NOT NULL,           -- Button display text
    button_type VARCHAR(20) NOT NULL,             -- Button type (green, yellow, orange, red, blue)
    action VARCHAR(50) NOT NULL,                  -- Action identifier
    context_rules NVARCHAR(MAX),                  -- JSON rules for when button appears
    ui_order INT NOT NULL DEFAULT 0,              -- Display order
    is_active BIT NOT NULL DEFAULT 1,             -- Whether button is active
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_button_id UNIQUE (button_id)
);

CREATE INDEX IDX_action_buttons_type ON action_buttons(button_type);
```

## Prompt Templates Schema

### prompts

Stores AI prompt templates.

```sql
CREATE TABLE prompts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    prompt_id VARCHAR(50) NOT NULL,               -- Unique identifier
    title NVARCHAR(100) NOT NULL,                 -- Prompt title
    template NVARCHAR(MAX) NOT NULL,              -- Prompt template text with variables
    purpose VARCHAR(50) NOT NULL,                 -- Purpose/usage
    model VARCHAR(50) NOT NULL,                   -- Target model (gpt-4, gpt-3.5-turbo, etc.)
    temperature FLOAT NOT NULL DEFAULT 0.7,       -- Temperature parameter
    max_tokens INT,                               -- Max tokens (null for model default)
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_prompt_id UNIQUE (prompt_id)
);

CREATE INDEX IDX_prompts_purpose ON prompts(purpose);
CREATE INDEX IDX_prompts_model ON prompts(model);
```

### prompt_variables

Stores variables used in prompt templates.

```sql
CREATE TABLE prompt_variables (
    id INT IDENTITY(1,1) PRIMARY KEY,
    variable_name VARCHAR(50) NOT NULL,           -- Variable name
    description NVARCHAR(255) NOT NULL,           -- Description of what the variable represents
    default_value NVARCHAR(MAX),                  -- Default value if not provided
    data_type VARCHAR(20) NOT NULL,               -- Data type (text, number, boolean, json)
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_variable_name UNIQUE (variable_name)
);
```

### prompt_categories

Organizes prompts into categories.

```sql
CREATE TABLE prompt_categories (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,           -- Category name
    description NVARCHAR(255) NOT NULL,           -- Category description
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_category_name UNIQUE (category_name)
);
```

### prompt_mappings

Maps prompts to categories.

```sql
CREATE TABLE prompt_mappings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    prompt_id VARCHAR(50) NOT NULL,               -- Reference to prompts.prompt_id
    category_name VARCHAR(50) NOT NULL,           -- Reference to prompt_categories.category_name
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    CONSTRAINT UQ_prompt_mapping UNIQUE (prompt_id, category_name)
);
```

## Database Access Patterns

### Repository Interfaces

Each major entity should have a corresponding repository interface:

```typescript
// Example of a character repository interface
interface ICharacterRepository {
  getById(id: string): Promise<Character>;
  getByName(name: string): Promise<Character[]>;
  create(character: CharacterCreateDTO): Promise<Character>;
  update(id: string, character: CharacterUpdateDTO): Promise<Character>;
  delete(id: string): Promise<boolean>;
}
```

### Query Builder Usage

Use parameterized queries to prevent SQL injection:

```typescript
// Example of a query builder function
async function getCharactersByRole(role: string): Promise<Character[]> {
  return await knex('characters')
    .where('role', role)
    .orderBy('name')
    .select('*');
}
```

### Stored Procedures

For complex operations, use stored procedures:

```sql
CREATE PROCEDURE SearchGameContent
    @searchTerm NVARCHAR(100)
AS
BEGIN
    -- Characters matching search term
    SELECT 'character' AS entity_type, character_id AS entity_id, name, data
    FROM characters 
    WHERE name LIKE '%' + @searchTerm + '%' OR 
          data LIKE '%' + @searchTerm + '%'
    
    UNION ALL
    
    -- Locations matching search term
    SELECT 'location' AS entity_type, location_id AS entity_id, name, data
    FROM locations 
    WHERE name LIKE '%' + @searchTerm + '%' OR 
          data LIKE '%' + @searchTerm + '%'
    
    UNION ALL
    
    -- Additional entity types...
    
    ORDER BY entity_type, name;
END
```

## Database Schema Migrations

Use a migration system to manage schema changes:

```typescript
// Example migration file
exports.up = function(knex) {
  return knex.schema.createTable('characters', function(table) {
    table.increments('id').primary();
    table.string('character_id', 50).notNullable().unique();
    table.string('name', 100).notNullable();
    table.string('type', 20).notNullable();
    table.string('species', 50).notNullable();
    table.string('role', 50);
    table.text('data').notNullable();
    table.text('portrait_url');
    table.text('full_body_url');
    table.timestamp('created_at').defaultTo(knex.fn.now());
    table.timestamp('updated_at').defaultTo(knex.fn.now());
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('characters');
};
```

## Database Seed Data

Provide seed data for initial development:

```typescript
// Example seed file
exports.seed = function(knex) {
  // Clear existing entries
  return knex('game_rules').del()
    .then(function () {
      // Insert seed entries
      return knex('game_rules').insert([
        {
          rule_id: 'combat-basic',
          title: 'Basic Combat Rules',
          category: 'combat',
          data: JSON.stringify({
            turnOrder: 'initiative',
            actionPointsPerTurn: 3,
            damageFormula: 'attack - defense',
            criticalHitChance: 0.1,
            criticalHitMultiplier: 2.0
          }),
          is_active: true
        },
        // Additional seed data...
      ]);
    });
};
```

## Database Access Permissions

Set up appropriate database permissions:

```sql
-- Grant execute permissions on stored procedures
GRANT EXECUTE ON SearchGameContent TO warped_user;

-- Grant table-specific permissions if needed
GRANT SELECT, INSERT, UPDATE ON characters TO warped_user;
GRANT SELECT, INSERT, UPDATE ON locations TO warped_user;
```

## Performance Considerations

1. **Indexing Strategy**
   - Indexes are created on frequently queried columns
   - Compound indexes for common query patterns
   - Consider query patterns when designing indexes

2. **Query Optimization**
   - Use appropriate joins rather than multiple queries
   - Limit result sets where possible
   - Use parameterized queries for security and performance

3. **Data Storage Strategy**
   - JSON data for flexibility
   - Normalize where appropriate for query performance
   - Consider binary storage options for large assets

## Conclusion

This database schema provides a solid foundation for the Warped Speed rebuild, emphasizing the database-driven architecture. By following this schema and the associated patterns, the system will be able to support dynamic game content, mechanics, and presentation through data rather than code.

The database should be considered the "source of truth" for all game content and configuration, enabling flexibility to modify the game experience without code changes. 