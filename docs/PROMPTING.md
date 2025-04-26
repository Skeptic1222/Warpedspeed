# Warped Speed - Prompt Engineering Guide

## Overview

Warped Speed uses a "prompt-first" development approach where the majority of game content is generated through AI prompts. This document outlines the prompt engineering principles, database structure, and implementation details for the prompt system.

## Core Principles

1. **Database-Driven Prompts**
   - All prompt templates stored in database
   - Centralized management and versioning
   - Easy modification without code changes

2. **Dynamic Variable Substitution**
   - Templates include variables
   - Variables populated from game state
   - Contextualized prompts for better generation

3. **Layered Prompting Strategy**
   - System context provides game rules and tone
   - State context provides current game situation
   - Action context provides player's input
   - Memory context provides relevant history

4. **Separation of Concerns**
   - Different prompt types for different content
   - Specialized models for different tasks
   - Clear output formats for reliable parsing

## Database Schema

Prompt templates are stored in the `prompts` table:

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
    output_format VARCHAR(50) NOT NULL,           -- Expected output format (text, json, etc.)
    created_at DATETIME DEFAULT GETDATE(),        -- Creation timestamp
    updated_at DATETIME DEFAULT GETDATE(),        -- Last update timestamp
    CONSTRAINT UQ_prompt_id UNIQUE (prompt_id)
);
```

Variables are documented in the `prompt_variables` table:

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

## Prompt Types

### 1. Narrative Generation Prompts

Used to generate story text in response to player actions.

```sql
-- Example narrative prompt
INSERT INTO prompts (prompt_id, title, template, purpose, model, temperature, output_format)
VALUES (
    'explore_narrative',
    'Exploration Narrative',
    'You are the narrator of a science fiction adventure game called Warped Speed.
    
    GAME STATE:
    Location: {{location}}
    Description: {{description}}
    Player Character: {{player}}
    Inventory: {{inventory}}
    Nearby NPCs: {{characters}}
    Active Quests: {{quest_status}}
    
    RECENT HISTORY:
    {{history}}
    
    PLAYER ACTION:
    {{action}}
    
    Your task is to narrate what happens when the player performs this action. Write 2-4 paragraphs of vivid, engaging sci-fi narrative. Focus on sensory details and atmosphere. If appropriate, introduce minor discoveries, clues, or plot developments.
    
    Return response as a JSON object with the following format:
    {
      "narrative": "Your narrative text here...",
      "stateChanges": {
        // Optional changes to game state, if any
        // Example: "newItem": {"name": "Keycard", "description": "A security keycard"}
      }
    }',
    'exploration_narrative',
    'gpt-4',
    0.7,
    'json'
);
```

### 2. Combat Prompts

Used to generate combat narration and determine outcomes.

```sql
-- Example combat prompt
INSERT INTO prompts (prompt_id, title, template, purpose, model, temperature, output_format)
VALUES (
    'combat_narrative',
    'Combat Narrative',
    'You are narrating a combat scene in a science fiction adventure game called Warped Speed.
    
    GAME STATE:
    Player: {{player}}
    Enemies: {{enemies}}
    Combat Round: {{combat_round}}
    Environment: {{location}}
    
    PLAYER ACTION:
    {{action}}
    
    COMBAT RULES:
    - Damage calculation: Base damage + random variation (±20%)
    - Critical hits occur with 10% chance and deal 1.5x damage
    - Defend action reduces incoming damage by 50%
    
    Describe the combat action in vivid detail. Focus on the drama and tension of the moment. Describe impacts, effects, and environmental interactions. Keep it exciting and dynamic.
    
    Return response as a JSON object with the following format:
    {
      "narrative": "Your narrative text here...",
      "combatResult": {
        "damage": [number or null],
        "target": "[enemy id or player]",
        "isCritical": [boolean],
        "statusEffects": []
      }
    }',
    'combat_narrative',
    'gpt-3.5-turbo',
    0.5,
    'json'
);
```

### 3. Dialogue Prompts

Used to generate NPC dialogue and responses.

```sql
-- Example dialogue prompt
INSERT INTO prompts (prompt_id, title, template, purpose, model, temperature, output_format)
VALUES (
    'npc_dialogue',
    'NPC Dialogue Generation',
    'You are role-playing as an NPC in a science fiction adventure game called Warped Speed.
    
    NPC INFORMATION:
    Name: {{npc.name}}
    Species: {{npc.species}}
    Role: {{npc.role}}
    Personality: {{npc.personality}}
    Knowledge: {{npc.knowledge}}
    Relationship with player: {{npc.relationship}} (0-100 scale, higher is more positive)
    
    PLAYER CHARACTER:
    Name: {{player.name}}
    Species: {{player.species}}
    Role: {{player.role}}
    
    CONVERSATION HISTORY:
    {{conversation_history}}
    
    PLAYER SAYS:
    {{player_dialogue}}
    
    Respond in character as {{npc.name}}. Match their personality and speaking style. Their response should reflect their relationship with the player and their knowledge. If the player asks something the NPC doesn''t know, they should say so or deflect appropriately.
    
    Return response as a JSON object with the following format:
    {
      "dialogue": "The NPC''s response here...",
      "emotion": "One word describing their emotional state",
      "relationship_change": [number between -5 and +5 or 0 if unchanged]
    }',
    'dialogue',
    'gpt-4',
    0.7,
    'json'
);
```

### 4. Action Generation Prompts

Used to generate context-sensitive actions.

```sql
-- Example action generation prompt
INSERT INTO prompts (prompt_id, title, template, purpose, model, temperature, output_format)
VALUES (
    'context_actions',
    'Contextual Action Generation',
    'You are the action generator for a science fiction adventure game called Warped Speed.
    
    GAME STATE:
    Location: {{location}}
    Description: {{description}}
    Player Character: {{player}}
    Inventory: {{inventory}}
    Nearby NPCs: {{characters}}
    
    Based on this context, generate appropriate actions the player could take. Return:
    1. Yellow actions: 3-5 context-sensitive normal actions appropriate to the situation
    2. Orange actions: 0-2 high-risk or narratively significant actions that could have major consequences
    
    Return the actions as a JSON object with the following format:
    {
      "yellow": ["Action 1", "Action 2", "Action 3"],
      "orange": ["Risky Action 1"]
    }
    
    Actions should be concise (1-4 words) and start with a verb. Be creative but appropriate to the context.',
    'action_generation',
    'gpt-3.5-turbo',
    0.6,
    'json'
);
```

### 5. Description Prompts

Used to generate descriptions for locations, items, etc.

```sql
-- Example description prompt
INSERT INTO prompts (prompt_id, title, template, purpose, model, temperature, output_format)
VALUES (
    'location_description',
    'Location Description Generation',
    'You are the environment designer for a science fiction adventure game called Warped Speed.
    
    LOCATION INFORMATION:
    Name: {{location.name}}
    Type: {{location.type}}
    Features: {{location.features}}
    Atmosphere: {{location.atmosphere}}
    
    Generate a vivid, detailed description of this location. Focus on sensory details - what the player sees, hears, smells, and feels. Include details about technology, architecture, and inhabitants appropriate to a sci-fi setting. The description should be 2-3 paragraphs.
    
    Return the description as plain text.',
    'description',
    'gpt-4',
    0.7,
    'text'
);
```

## Variable Substitution System

The system uses a template engine to replace variables in prompt templates:

```javascript
/**
 * Format prompt template by substituting variables
 * @param {string} template Prompt template with variables
 * @param {Object} variables Object containing variable values
 * @returns {string} Formatted prompt
 */
function formatPromptWithVariables(template, variables) {
  // Create a copy of variables with defaults for missing values
  const variablesWithDefaults = { ...variables };
  
  // Find all variables in the template using regex
  const variablePattern = /{{([^{}]+)}}/g;
  const matches = [...template.matchAll(variablePattern)];
  
  // Get default values for missing variables
  const missingVariables = matches
    .map(match => match[1].trim())
    .filter(varName => !(varName in variablesWithDefaults));
  
  if (missingVariables.length > 0) {
    // Load defaults from database
    const defaults = await db.query(`
      SELECT variable_name, default_value 
      FROM prompt_variables 
      WHERE variable_name IN (@variables)
    `, {
      variables: missingVariables
    });
    
    // Apply defaults
    for (const { variable_name, default_value } of defaults) {
      variablesWithDefaults[variable_name] = default_value;
    }
  }
  
  // Replace variables in template
  let formattedPrompt = template;
  for (const [placeholder, varName] of matches) {
    const value = variablesWithDefaults[varName.trim()] ?? '';
    
    // Replace with string representation of value
    const stringValue = typeof value === 'object' 
      ? JSON.stringify(value) 
      : String(value);
    
    formattedPrompt = formattedPrompt.replace(placeholder, stringValue);
  }
  
  return formattedPrompt;
}
```

## Prompt Service

The prompt service manages retrieving and using prompts:

```javascript
/**
 * Get a prompt template by purpose
 * @param {string} purpose Purpose of the prompt
 * @returns {Promise<Object|null>} Prompt template or null if not found
 */
async function getPromptByPurpose(purpose) {
  const prompts = await db.query(`
    SELECT * FROM prompts 
    WHERE purpose = @purpose 
    AND is_active = 1
  `, {
    purpose
  });
  
  return prompts.length > 0 ? prompts[0] : null;
}

/**
 * Generate content using a prompt
 * @param {string} purpose Purpose of the prompt
 * @param {Object} variables Variables for template substitution
 * @param {Object} options Additional options
 * @returns {Promise<any>} Generated content
 */
async function generateWithPrompt(purpose, variables, options = {}) {
  // Get prompt template
  const prompt = await getPromptByPurpose(purpose);
  
  if (!prompt) {
    throw new Error(`No prompt found for purpose: ${purpose}`);
  }
  
  // Format prompt with variables
  const formattedPrompt = await formatPromptWithVariables(
    prompt.template,
    variables
  );
  
  // Determine user message based on options
  const userMessage = options.userMessage || options.action || "Proceed with the task.";
  
  // Call GPT with the formatted prompt
  const response = await gptService.generateText([
    { role: "system", content: formattedPrompt },
    { role: "user", content: userMessage }
  ], {
    model: prompt.model,
    temperature: prompt.temperature,
    max_tokens: prompt.max_tokens || undefined
  });
  
  // Process response based on expected format
  if (prompt.output_format === 'json') {
    try {
      return JSON.parse(response);
    } catch (error) {
      console.error("Failed to parse JSON response:", error);
      
      // Attempt to extract JSON from non-JSON response
      const jsonMatch = response.match(/```json\n([\s\S]*?)\n```/) || 
                        response.match(/{[\s\S]*}/);
      
      if (jsonMatch) {
        try {
          return JSON.parse(jsonMatch[1] || jsonMatch[0]);
        } catch (e) {
          // If extraction fails, return the raw response
          return { raw: response };
        }
      }
      
      return { raw: response };
    }
  }
  
  // For non-JSON formats, return as is
  return response;
}
```

## Common Variables

These variables should be well-defined and consistently used across prompts:

### Player Variables

- `player.name` - Player character's name
- `player.species` - Player character's species
- `player.role` - Player character's role/class
- `player.gender` - Player character's gender
- `player.hp` - Current health points
- `player.sp` - Current stamina points
- `player.mp` - Current mental points
- `player.level` - Current level
- `player.stats` - Object containing all player stats

### Location Variables

- `location.name` - Current location name
- `location.type` - Location type (ship, planet, station, etc.)
- `location.description` - Detailed description
- `location.features` - Array of notable features
- `location.atmosphere` - Environmental mood/tone

### NPC Variables

- `npc.name` - NPC's name
- `npc.species` - NPC's species
- `npc.role` - NPC's role/occupation
- `npc.relationship` - Relationship score with player
- `npc.personality` - Personality traits
- `npc.knowledge` - What the NPC knows about

### Game State Variables

- `inventory` - Array of player's inventory items
- `quests` - Array of active quests
- `history` - Recent narrative history
- `combat_round` - Current combat round (if in combat)
- `conversation_history` - Recent conversation (if in dialogue)

## Model Selection Guidelines

Choose the appropriate model based on the prompt purpose:

1. **GPT-4**
   - Complex narrative generation
   - Dialogue with important NPCs
   - Quest-critical interactions
   - Significant plot developments

2. **GPT-3.5 Turbo**
   - Action generation
   - Combat narration
   - Simple descriptions
   - Minor NPC dialogue
   - Interface text generation

## Output Formats

Define clear output formats for reliable parsing:

1. **Text**
   - Plain text output
   - Used for simple descriptions
   - No parsing required

2. **JSON**
   - Structured data output
   - Used for game state updates
   - Requires proper error handling for parsing

Example JSON format for narrative:

```json
{
  "narrative": "Text description of what happens",
  "stateChanges": {
    "newItem": {"id": "keycard-001", "name": "Keycard", "description": "A security access card"},
    "npcMoved": {"id": "guard-001", "location": "corridor"}
  },
  "suggestedActions": ["Examine Keycard", "Follow Guard"]
}
```

## Prompt Engineering Best Practices

### 1. Clarity and Specificity

- Be specific about what you want
- Provide clear instructions
- Define output format explicitly
- Include examples if necessary

### 2. Context Management

- Include relevant context
- Limit unnecessary details
- Structure context hierarchically
- Use memory effectively

### 3. Tone and Style Control

- Define the desired tone
- Provide style examples
- Specify genre conventions
- Maintain consistency

### 4. Error Handling

- Handle malformed responses
- Implement retry logic
- Have fallback prompts
- Log prompt/response pairs for debugging

### 5. Iterative Refinement

- Test prompts with various inputs
- Collect and analyze failures
- Refine prompts based on patterns
- A/B test different prompt structures

## Temperature Guidelines

Set temperature values based on the need for creativity vs. consistency:

- **0.2-0.4**: Predictable, consistent outputs (combat, game mechanics)
- **0.5-0.7**: Balanced outputs (standard narrative, dialogue)
- **0.7-0.9**: More creative, varied outputs (descriptions, unique events)

## Pre-Tested Prompt Examples

### Narrative Generation

```
You are the narrator for a science fiction adventure game called Warped Speed.

GAME STATE:
Location: Maintenance Bay
Description: A cluttered workshop filled with tools, spare parts, and half-assembled machinery. The air smells of oil and ozone.
Player Character: Captain Alex Chen, Human Pilot
Inventory: Laser Pistol, Datapad, Medkit, Security Keycard
Nearby NPCs: Engineer Zora (Andron), Maintenance Droid K-12

PLAYER ACTION:
Examine the damaged engine core

Your task is to narrate what happens when the player examines the damaged engine core. Write 2-3 paragraphs of vivid, engaging sci-fi narrative that describes what they discover.

Focus on technical details that a pilot would notice, sensory information, and potential plot hooks. The tone should be tense but not overtly dangerous.

Return your response as a JSON object with the following format:
{
  "narrative": "Your narrative text here...",
  "discoveries": ["Any specific things discovered"],
  "suggestedActions": ["2-3 logical next actions"]
}
```

### Character Creation

```
You are the character generator for a science fiction adventure game called Warped Speed.

USER INPUT:
Species: Andron
Role: Engineer
Gender: Female
Name: Lyra Nova

Generate a brief but vivid description of this character, including:
1. Physical appearance (2-3 sentences)
2. Personality (2-3 traits)
3. Background (1-2 sentences)
4. Special skill or ability (1 sentence)

The description should be appropriate for a sci-fi setting, should match the species and role selected, and should be suitable for a protagonist.

Return your response as a JSON object with the following format:
{
  "description": "Physical description here",
  "personality": ["Trait 1", "Trait 2", "Trait 3"],
  "background": "Background here",
  "specialSkill": "Special skill description here",
  "suggestedPortraitPrompt": "A detailed prompt that could be used to generate this character's portrait"
}
```

## Conclusion

This prompt engineering guide provides a framework for creating and using database-driven prompts in Warped Speed. By following these guidelines, we can ensure consistent, high-quality content generation that enhances the player experience while maintaining flexibility for future changes.

Remember that prompts are the core of our game content, so they should be treated with the same care and attention as code. Regularly review, test, and refine prompts to improve the quality of generated content. 