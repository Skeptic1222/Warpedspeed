# Warped Speed - Database Schema

This document outlines the database schema for the Warped Speed project. The database is designed to support a modular, content-driven approach to game mechanics and storytelling.

## Database Overview

The Warped Speed database is organized into several logical sections:

1. **Core Game Data** - Essential game mechanics and content
2. **User Data** - Player information and progress
3. **Content Management** - Game content and narrative elements
4. **System Configuration** - Application settings and configuration
5. **UI Configuration** - Interface layout and components
6. **Asset Management** - Image, audio, and video resources
7. **Analytics** - Usage data and player behavior

## Schema Diagrams

### Core Schema Relationships

```
[Users] --1:N--> [Characters] --1:N--> [InventoryItems]
                     |
                     +--1:N--> [CharacterStats]
                     |
                     +--1:N--> [CharacterSkills]
                     |
                     +--1:N--> [CharacterProgression]

[Locations] --1:N--> [Scenes] --1:N--> [SceneTransitions]
                       |
                       +--1:N--> [SceneObjects]
                       |
                       +--1:N--> [SceneNPCs]
                       |
                       +--1:N--> [SceneActions]

[NPCs] --1:N--> [NPCDialogue]
        |
        +--1:N--> [NPCStats]
        |
        +--1:N--> [NPCBehaviors]

[Quests] --1:N--> [QuestSteps] --1:N--> [QuestTriggers]
                     |
                     +--1:N--> [QuestRewards]

[Items] --1:N--> [ItemEffects]
         |
         +--1:N--> [ItemRecipes]

[GameEvents] --1:N--> [EventTriggers]
              |
              +--1:N--> [EventActions]
```

## Table Definitions

### User Management

#### Users

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| username | VARCHAR(50) | Unique username |
| email | VARCHAR(100) | User email |
| password_hash | VARCHAR(255) | Hashed password |
| created_at | DATETIME | Account creation timestamp |
| last_login | DATETIME | Last login timestamp |
| is_active | BOOLEAN | Account status |
| role | VARCHAR(20) | User role (player, admin, etc.) |

#### UserPreferences

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| user_id | INT | Foreign key to Users |
| theme | VARCHAR(20) | UI theme preference |
| text_speed | INT | Text display speed |
| audio_volume | FLOAT | Audio volume setting |
| notification_settings | JSON | Notification preferences |

### Character System

#### Characters

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| user_id | INT | Foreign key to Users |
| name | VARCHAR(50) | Character name |
| species | VARCHAR(50) | Character species |
| background | VARCHAR(50) | Character background |
| created_at | DATETIME | Character creation timestamp |
| last_played | DATETIME | Last played timestamp |
| current_location_id | INT | Foreign key to Locations |
| portrait_image_id | INT | Foreign key to Assets |
| character_state | JSON | Current character state |

#### CharacterStats

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| character_id | INT | Foreign key to Characters |
| stat_type_id | INT | Foreign key to StatTypes |
| base_value | INT | Base stat value |
| current_value | INT | Current stat value (after modifiers) |
| max_value | INT | Maximum possible value |

#### StatTypes

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(50) | Stat name (Strength, Intelligence, etc.) |
| description | TEXT | Stat description |
| icon_id | INT | Foreign key to Assets |
| category | VARCHAR(50) | Stat category |

#### CharacterSkills

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| character_id | INT | Foreign key to Characters |
| skill_id | INT | Foreign key to Skills |
| level | INT | Skill level |
| experience | INT | Experience points in this skill |

#### Skills

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(50) | Skill name |
| description | TEXT | Skill description |
| icon_id | INT | Foreign key to Assets |
| category | VARCHAR(50) | Skill category |
| requirements | JSON | Requirements to acquire skill |

#### InventoryItems

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| character_id | INT | Foreign key to Characters |
| item_id | INT | Foreign key to Items |
| quantity | INT | Item quantity |
| condition | FLOAT | Item condition (0.0-1.0) |
| is_equipped | BOOLEAN | Whether item is equipped |
| slot | VARCHAR(50) | Equipment slot (if equipped) |
| custom_properties | JSON | Item instance properties |

### Game Content

#### Locations

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Location name |
| description | TEXT | Location description |
| category | VARCHAR(50) | Location category |
| parent_location_id | INT | Foreign key to parent Location |
| map_coordinates | JSON | Coordinates on game map |
| danger_level | INT | Location danger rating |
| discovery_requirements | JSON | Requirements to discover location |
| background_image_id | INT | Foreign key to Assets |

#### Scenes

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| location_id | INT | Foreign key to Locations |
| name | VARCHAR(100) | Scene name |
| description | TEXT | Scene description |
| scene_type | VARCHAR(50) | Type of scene |
| entry_text | TEXT | Text displayed on scene entry |
| exit_text | TEXT | Text displayed on scene exit |
| background_image_id | INT | Foreign key to Assets |
| ambient_sound_id | INT | Foreign key to Assets |
| scene_prompt | TEXT | Prompt for generating scene description |
| scene_state | JSON | Dynamic scene state properties |

#### SceneTransitions

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| from_scene_id | INT | Foreign key to source Scene |
| to_scene_id | INT | Foreign key to destination Scene |
| transition_text | TEXT | Text shown during transition |
| requirements | JSON | Requirements to use transition |
| transition_type | VARCHAR(50) | Type of transition |
| is_hidden | BOOLEAN | Whether transition is initially hidden |

#### SceneActions

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| scene_id | INT | Foreign key to Scenes |
| action_type_id | INT | Foreign key to ActionTypes |
| button_text | VARCHAR(100) | Text on action button |
| action_text | TEXT | Text shown when action is taken |
| requirements | JSON | Requirements to see/use action |
| consequences | JSON | Effects of taking action |
| cooldown | INT | Cooldown before action can be used again |
| button_category | VARCHAR(20) | Button color category |
| execution_order | INT | Order of execution relative to other actions |

#### ActionTypes

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(50) | Action type name |
| description | TEXT | Action type description |
| icon_id | INT | Foreign key to Assets |
| default_button_category | VARCHAR(20) | Default button color category |
| handler_function | VARCHAR(100) | Function to handle this action type |

#### NPCs

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | NPC name |
| description | TEXT | NPC description |
| npc_type | VARCHAR(50) | Type of NPC |
| portrait_image_id | INT | Foreign key to Assets |
| default_attitude | VARCHAR(50) | Default attitude toward player |
| behavior_pattern_id | INT | Foreign key to BehaviorPatterns |
| dialogue_table_id | INT | Foreign key to DialogueTables |
| stats | JSON | NPC statistics |
| loot_table_id | INT | Foreign key to LootTables |

#### SceneNPCs

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| scene_id | INT | Foreign key to Scenes |
| npc_id | INT | Foreign key to NPCs |
| spawn_condition | JSON | Conditions for NPC to appear |
| spawn_probability | FLOAT | Probability of spawning if conditions met |
| position | JSON | Position in scene |
| initial_dialogue_id | INT | Foreign key to DialogueEntries |
| custom_behavior | JSON | Scene-specific behavior overrides |

#### DialogueTables

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Table name |
| description | TEXT | Table description |
| default_fallback_dialogue_id | INT | Foreign key to default DialogueEntry |

#### DialogueEntries

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| dialogue_table_id | INT | Foreign key to DialogueTables |
| text | TEXT | Dialogue text |
| conditions | JSON | Conditions for dialogue to be available |
| speaker | VARCHAR(100) | Name of speaker |
| emotion | VARCHAR(50) | Emotional tone of dialogue |
| prompt_template_id | INT | Foreign key to PromptTemplates |
| generation_variables | JSON | Variables for prompt generation |
| audio_id | INT | Foreign key to Assets (voice) |

#### DialogueResponses

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| dialogue_entry_id | INT | Foreign key to parent DialogueEntry |
| response_text | TEXT | Player response text |
| next_dialogue_id | INT | Foreign key to next DialogueEntry |
| requirements | JSON | Requirements to see/use response |
| consequences | JSON | Effects of selecting response |

### Items and Equipment

#### Items

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Item name |
| description | TEXT | Item description |
| item_type | VARCHAR(50) | Type of item |
| rarity | VARCHAR(50) | Item rarity |
| base_value | INT | Base monetary value |
| weight | FLOAT | Item weight |
| image_id | INT | Foreign key to Assets |
| usable | BOOLEAN | Whether item can be used |
| equippable | BOOLEAN | Whether item can be equipped |
| equipment_slot | VARCHAR(50) | Slot item can be equipped to |
| stats | JSON | Item statistics |
| durability | INT | Maximum durability |
| prompt_template_id | INT | Foreign key for item description generation |

#### ItemEffects

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| item_id | INT | Foreign key to Items |
| effect_type | VARCHAR(50) | Type of effect |
| effect_value | JSON | Effect values and parameters |
| duration | INT | Effect duration (if applicable) |
| conditions | JSON | Conditions for effect to apply |

#### Recipes

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| result_item_id | INT | Foreign key to resulting Item |
| result_quantity | INT | Quantity produced |
| skill_id | INT | Foreign key to required Skill |
| min_skill_level | INT | Minimum skill level required |
| difficulty | INT | Recipe difficulty |
| time_required | INT | Time to craft (seconds) |
| learned_by_default | BOOLEAN | Whether known by default |

#### RecipeIngredients

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| recipe_id | INT | Foreign key to Recipes |
| item_id | INT | Foreign key to required Item |
| quantity | INT | Quantity required |
| consumed | BOOLEAN | Whether consumed in crafting |

### Quest System

#### Quests

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Quest name |
| description | TEXT | Quest description |
| quest_type | VARCHAR(50) | Type of quest |
| difficulty | INT | Quest difficulty |
| is_main_story | BOOLEAN | Whether part of main storyline |
| prerequisite_quest_id | INT | Foreign key to prerequisite Quest |
| recommended_level | INT | Recommended character level |
| time_limit | INT | Time limit (if applicable) |
| start_dialogue_id | INT | Foreign key to starting DialogueEntry |
| completion_dialogue_id | INT | Foreign key to completion DialogueEntry |
| icon_id | INT | Foreign key to Assets |
| prompt_template_id | INT | Foreign key for quest text generation |

#### QuestSteps

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| quest_id | INT | Foreign key to Quests |
| step_number | INT | Step sequence number |
| name | VARCHAR(100) | Step name |
| description | TEXT | Step description |
| objective_type | VARCHAR(50) | Type of objective |
| objective_parameters | JSON | Parameters for objective |
| completion_trigger | JSON | Trigger for step completion |
| is_optional | BOOLEAN | Whether step is optional |
| next_step_id | INT | Foreign key to next QuestStep |

#### QuestRewards

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| quest_id | INT | Foreign key to Quests |
| reward_type | VARCHAR(50) | Type of reward |
| item_id | INT | Foreign key to item reward (if applicable) |
| item_quantity | INT | Quantity of item reward |
| currency_amount | INT | Amount of currency reward |
| experience_amount | INT | Amount of experience reward |
| skill_id | INT | Foreign key to skill for experience (if applicable) |
| reputation_faction_id | INT | Foreign key to faction for reputation (if applicable) |
| reputation_change | INT | Amount of reputation change |

### Combat System

#### CombatEncounters

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| scene_id | INT | Foreign key to Scenes |
| encounter_type | VARCHAR(50) | Type of encounter |
| difficulty | INT | Encounter difficulty |
| trigger_conditions | JSON | Conditions to trigger encounter |
| intro_text | TEXT | Text shown at start of encounter |
| victory_text | TEXT | Text shown on victory |
| defeat_text | TEXT | Text shown on defeat |
| escape_difficulty | INT | Difficulty to escape encounter |
| loot_table_id | INT | Foreign key to LootTables |
| prompt_template_id | INT | Foreign key for combat description generation |

#### CombatEncounterEnemies

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| combat_encounter_id | INT | Foreign key to CombatEncounters |
| enemy_id | INT | Foreign key to NPCs |
| quantity | INT | Number of this enemy type |
| is_boss | BOOLEAN | Whether enemy is a boss |
| spawn_trigger | JSON | Trigger for enemy to spawn |
| spawn_message | TEXT | Message shown when enemy spawns |
| ai_strategy_id | INT | Foreign key to AIStrategies |

#### CombatActions

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Action name |
| description | TEXT | Action description |
| action_type | VARCHAR(50) | Type of action |
| energy_cost | INT | Energy cost to use |
| cooldown | INT | Cooldown before action can be used again |
| targeting_type | VARCHAR(50) | How action targets (self, single, area, etc.) |
| effect_type | VARCHAR(50) | Type of effect |
| effect_value | JSON | Effect values and parameters |
| requirements | JSON | Requirements to use action |
| animation_id | INT | Foreign key to Assets (animation) |
| sound_effect_id | INT | Foreign key to Assets (sound) |
| icon_id | INT | Foreign key to Assets (icon) |
| button_category | VARCHAR(20) | Button color category |

### Asset Management

#### Assets

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| filename | VARCHAR(255) | Asset filename |
| asset_type | VARCHAR(50) | Type of asset (image, audio, video) |
| content_type | VARCHAR(100) | MIME type |
| path | VARCHAR(255) | Path to asset file |
| width | INT | Width (for images) |
| height | INT | Height (for images) |
| duration | INT | Duration (for audio/video) |
| created_at | DATETIME | Asset creation timestamp |
| creator | VARCHAR(100) | Asset creator |
| tags | JSON | Asset tags |
| is_generated | BOOLEAN | Whether asset was AI-generated |
| generation_prompt | TEXT | Prompt used for generation (if applicable) |
| generation_parameters | JSON | Parameters used for generation |
| alt_text | TEXT | Accessibility description |

#### AssetCollections

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Collection name |
| description | TEXT | Collection description |
| collection_type | VARCHAR(50) | Type of collection |

#### AssetCollectionItems

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| collection_id | INT | Foreign key to AssetCollections |
| asset_id | INT | Foreign key to Assets |
| sort_order | INT | Display order in collection |

### Prompt Management

#### PromptTemplates

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Template name |
| description | TEXT | Template description |
| category | VARCHAR(50) | Template category |
| template_text | TEXT | Template with variables |
| model | VARCHAR(50) | AI model to use |
| max_tokens | INT | Maximum tokens for response |
| temperature | FLOAT | Generation temperature |
| top_p | FLOAT | Top-p sampling value |
| frequency_penalty | FLOAT | Frequency penalty |
| presence_penalty | FLOAT | Presence penalty |
| example_output | TEXT | Example of expected output |
| variable_definitions | JSON | Definitions of variables in template |
| failure_fallback | TEXT | Text to use if generation fails |

#### PromptHistory

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| prompt_template_id | INT | Foreign key to PromptTemplates |
| variables_used | JSON | Variables used in prompt |
| full_prompt | TEXT | Complete assembled prompt |
| response | TEXT | AI response |
| success | BOOLEAN | Whether generation was successful |
| created_at | DATETIME | Timestamp |
| user_id | INT | Foreign key to Users (if applicable) |
| character_id | INT | Foreign key to Characters (if applicable) |
| rating | INT | User rating of response (if applicable) |
| tokens_used | INT | Tokens consumed |

### UI Configuration

#### UILayouts

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| name | VARCHAR(100) | Layout name |
| description | TEXT | Layout description |
| screen_type | VARCHAR(50) | Type of screen |
| layout_data | JSON | Layout configuration |
| is_active | BOOLEAN | Whether layout is active |
| created_at | DATETIME | Creation timestamp |
| modified_at | DATETIME | Last modified timestamp |
| responsive_breakpoints | JSON | Responsive design breakpoints |

#### UIComponents

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| component_type | VARCHAR(50) | Type of component |
| name | VARCHAR(100) | Component name |
| description | TEXT | Component description |
| default_properties | JSON | Default component properties |
| stylesheet | TEXT | Component CSS |
| icon_id | INT | Foreign key to Assets (icon) |

#### UILayoutComponents

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| layout_id | INT | Foreign key to UILayouts |
| component_id | INT | Foreign key to UIComponents |
| instance_id | VARCHAR(100) | Unique ID for this instance |
| properties | JSON | Component instance properties |
| position | JSON | Position in layout |
| visibility_conditions | JSON | Conditions for visibility |
| event_handlers | JSON | Event handler configuration |

### Game State and Progression

#### GameSaves

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| user_id | INT | Foreign key to Users |
| character_id | INT | Foreign key to Characters |
| save_name | VARCHAR(100) | Save name |
| save_description | TEXT | Save description |
| created_at | DATETIME | Creation timestamp |
| screenshot_id | INT | Foreign key to Assets (screenshot) |
| game_version | VARCHAR(50) | Game version at save time |
| play_time | INT | Total play time (seconds) |
| save_data | JSON | Complete save data |

#### CharacterProgression

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| character_id | INT | Foreign key to Characters |
| experience | INT | Total experience points |
| level | INT | Character level |
| skill_points | INT | Available skill points |
| stat_points | INT | Available stat points |
| completed_quests | JSON | IDs of completed quests |
| discovered_locations | JSON | IDs of discovered locations |
| reputation | JSON | Reputation with factions |

#### GameFlags

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| character_id | INT | Foreign key to Characters |
| flag_key | VARCHAR(100) | Flag identifier |
| flag_value | VARCHAR(255) | Flag value |
| set_timestamp | DATETIME | When flag was set |

### System Configuration

#### SystemSettings

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| setting_key | VARCHAR(100) | Setting identifier |
| setting_value | TEXT | Setting value |
| setting_type | VARCHAR(50) | Data type of setting |
| category | VARCHAR(50) | Setting category |
| description | TEXT | Setting description |
| is_editable | BOOLEAN | Whether setting can be edited |
| constraints | JSON | Constraints on valid values |

#### APIKeys

| Column | Type | Description |
|--------|------|-------------|
| id | INT | Primary key |
| service | VARCHAR(100) | Service name |
| key | VARCHAR(255) | API key (encrypted) |
| is_active | BOOLEAN | Whether key is active |
| rate_limit | INT | Rate limit (calls per minute) |
| usage_count | INT | Number of times used |
| created_at | DATETIME | Creation timestamp |
| last_used | DATETIME | Last usage timestamp |
| expires_at | DATETIME | Expiration timestamp |

## Relationships and Foreign Keys

This section outlines the relationships between tables through foreign keys:

- **Users** → **Characters**: A user can have multiple characters
- **Characters** → **CharacterStats**: A character has multiple stats
- **Characters** → **CharacterSkills**: A character has multiple skills
- **Characters** → **InventoryItems**: A character has multiple inventory items
- **Characters** → **CharacterProgression**: A character has one progression record
- **Locations** → **Scenes**: A location contains multiple scenes
- **Scenes** → **SceneTransitions**: A scene has multiple transitions to other scenes
- **Scenes** → **SceneActions**: A scene has multiple possible actions
- **Scenes** → **SceneNPCs**: A scene can contain multiple NPCs
- **NPCs** → **DialogueTables**: An NPC has one dialogue table
- **DialogueTables** → **DialogueEntries**: A dialogue table contains multiple entries
- **DialogueEntries** → **DialogueResponses**: A dialogue entry has multiple possible player responses
- **Quests** → **QuestSteps**: A quest has multiple steps
- **Quests** → **QuestRewards**: A quest has multiple rewards
- **Items** → **ItemEffects**: An item has multiple effects
- **CombatEncounters** → **CombatEncounterEnemies**: A combat encounter has multiple enemies

## Migration Plan

1. **Phase 1: Core Schema**
   - Users
   - Characters
   - Locations
   - Scenes
   - Items
   - NPCs
   - Assets

2. **Phase 2: Game Mechanics**
   - Combat system
   - Inventory system
   - Quest system
   - Dialogue system

3. **Phase 3: AI Integration**
   - Prompt templates
   - Asset generation
   - Content generation

## Indexing Strategy

| Table | Column(s) | Index Type | Purpose |
|-------|-----------|------------|---------|
| Users | username | UNIQUE | Fast user lookup |
| Users | email | UNIQUE | Prevent duplicate emails |
| Characters | user_id | INDEX | Fast lookup of user's characters |
| Scenes | location_id | INDEX | Fast lookup of scenes in location |
| InventoryItems | character_id, item_id | INDEX | Fast item lookup in inventory |
| Assets | filename | INDEX | Fast asset lookup by filename |
| Assets | asset_type | INDEX | Fast asset lookup by type |
| GameFlags | character_id, flag_key | UNIQUE | Fast flag lookup |
| DialogueEntries | dialogue_table_id | INDEX | Fast dialogue lookup |

## Seeding Strategy

Initial database seeding will include:

1. **Core game content**
   - Starting locations and scenes
   - Basic items and NPCs
   - Initial quests
   - System settings

2. **UI configurations**
   - Default layouts for all screen types
   - Core UI components

3. **Prompt templates**
   - Scene description templates
   - Character interaction templates
   - Combat narration templates

## Performance Considerations

1. **Query Optimization**
   - Use appropriate indexes
   - Optimize JOIN operations
   - Use pagination for large result sets

2. **Caching Strategy**
   - Cache frequently accessed data
   - Implement query result caching
   - Use Redis for session data

3. **Data Archiving**
   - Archive old prompt history
   - Archive old game saves
   - Implement data retention policies

## Data Security

1. **Sensitive Data**
   - Encrypt user passwords
   - Encrypt API keys
   - Implement proper access controls

2. **Backup Strategy**
   - Daily automated backups
   - Point-in-time recovery
   - Offsite backup storage

## Conclusion

This database schema provides a flexible, scalable foundation for the Warped Speed project. The schema is designed to support a database-driven approach to game content and mechanics, allowing for easy modification and extension without code changes.

As development progresses, this schema may be refined and extended to support additional features and optimizations. 