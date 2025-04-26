# Warped Speed - Game Mechanics

## Overview

This document details the game mechanics and systems in Warped Speed, providing a reference for developers implementing the system. All game mechanics should be database-driven, allowing for modification without code changes.

## Core Game Loop

The fundamental gameplay loop consists of:

1. **Narrative Presentation** - The system presents story text to the player
2. **Action Selection** - The player chooses an action from available options
3. **Action Processing** - The system processes the action
4. **State Update** - The game state is updated based on the action
5. **Narrative Generation** - New narrative is generated based on the updated state
6. **Return to Step 1**

## Action System

### Action Types

Actions are color-coded by type:

1. **Green Actions** (Always Available)
   - Core utility actions always accessible
   - Example: Look Around, Inventory, Talk, Rest
   - Stored in the `action_buttons` table with `button_type = 'green'`

2. **Yellow Actions** (Context-Sensitive)
   - Actions specific to the current scene
   - Generated dynamically based on context
   - Example: Examine Console, Pick Lock, Hide Behind Crate
   - Stored in the `action_buttons` table with `button_type = 'yellow'`

3. **Orange Actions** (High-Risk/Urgent)
   - Major decision points or time-sensitive actions
   - Significant story consequences
   - Example: Override Protocol, Sacrifice Crew Member, Detonate Explosive
   - Stored in the `action_buttons` table with `button_type = 'orange'`

4. **Red Actions** (Combat-Only)
   - Only available during combat sequences
   - Related to combat mechanics
   - Example: Attack, Defend, Use Item, Flee
   - Stored in the `action_buttons` table with `button_type = 'red'`

5. **Blue Actions** (Conversation)
   - Dialogue-specific interactions
   - Available during NPC conversations
   - Example: Persuade, Intimidate, Flatter, Reveal Truth
   - Stored in the `action_buttons` table with `button_type = 'blue'`

### Action Button Implementation

Action buttons are implemented as follows:

```javascript
/**
 * Get available actions for current game state
 * @param {Object} gameState Current game state
 * @returns {Promise<Object>} Object containing arrays of actions by type
 */
async function getAvailableActions(gameState) {
  // Get static green actions from database
  const greenActions = await db.query(`
    SELECT * FROM action_buttons 
    WHERE button_type = 'green' 
    AND is_active = 1
    ORDER BY ui_order
  `);
  
  // Get static red combat actions if in combat
  const redActions = gameState.inCombat 
    ? await db.query(`
        SELECT * FROM action_buttons 
        WHERE button_type = 'red' 
        AND is_active = 1
        ORDER BY ui_order
      `)
    : [];
    
  // Dynamic actions are generated based on context
  // Yellow (context) and Orange (urgent) actions
  let dynamicActions = await generateDynamicActions(gameState);
  
  // Blue conversation actions if in conversation
  const blueActions = gameState.inConversation
    ? await generateConversationActions(gameState)
    : [];
  
  return {
    green: greenActions.map(a => a.button_text),
    yellow: dynamicActions.yellow.map(a => a.button_text),
    orange: dynamicActions.orange.map(a => a.button_text),
    red: redActions.map(a => a.button_text),
    blue: blueActions.map(a => a.button_text)
  };
}
```

### Dynamic Action Generation

Dynamic actions (yellow, orange) are generated using GPT:

```javascript
/**
 * Generate dynamic actions based on game state
 * @param {Object} gameState Current game state
 * @returns {Promise<Object>} Yellow and orange actions
 */
async function generateDynamicActions(gameState) {
  // Get appropriate prompt template
  const prompt = await db.query(`
    SELECT * FROM prompts 
    WHERE purpose = 'action_generation' 
    AND is_active = 1
  `);
  
  if (!prompt.length) {
    return { yellow: [], orange: [] };
  }
  
  // Format prompt with game state
  const formattedPrompt = formatPromptWithVariables(
    prompt[0].template,
    {
      location: gameState.location,
      description: gameState.locationDescription,
      inventory: gameState.inventory,
      characters: gameState.characters,
      quest_status: gameState.quests
    }
  );
  
  // Call GPT with the formatted prompt
  const response = await gptService.generateText([
    { role: "system", content: formattedPrompt },
    { role: "user", content: "Generate contextual actions for the current game state." }
  ], {
    model: prompt[0].model,
    temperature: prompt[0].temperature
  });
  
  // Parse JSON response
  try {
    const actions = JSON.parse(response);
    return {
      yellow: Array.isArray(actions.yellow) ? actions.yellow : [],
      orange: Array.isArray(actions.orange) ? actions.orange : []
    };
  } catch (error) {
    console.error("Failed to parse dynamic actions:", error);
    return { yellow: [], orange: [] };
  }
}
```

## Character System

### Character Creation

Character creation follows these steps:

1. **Gender Selection** - Male, Female, Nonbinary
2. **Orientation Selection** - Straight, Gay, Bisexual, Pansexual, etc.
3. **Species Selection** - Human, Andron, Xenon, Vorta
4. **Role Selection** - Engineer, Pilot, Soldier, Scientist
5. **Name Selection** - Custom input or AI-generated

All options are stored in the database:

```sql
-- Example query for species options
SELECT * FROM character_options WHERE option_type = 'species' AND is_active = 1;

-- Example query for role options
SELECT * FROM character_options WHERE option_type = 'role' AND is_active = 1;
```

### Character Stats

Characters have the following core stats:

1. **HP (Health Points)** - Physical health; reaching 0 means defeat
2. **SP (Stamina Points)** - Used for physical actions; regenerates over time
3. **MP (Mental Points)** - Used for technical/special abilities
4. **XP (Experience Points)** - Accumulated through gameplay; drives leveling

Stats are calculated based on role, species, and equipment:

```javascript
/**
 * Calculate character stats based on base stats, role, species, and equipment
 * @param {Object} character Character data
 * @returns {Object} Calculated stats
 */
function calculateStats(character) {
  // Get base stats from database
  const baseStats = await db.query(`
    SELECT * FROM character_base_stats 
    WHERE role = @role AND species = @species
  `, {
    role: character.role,
    species: character.species
  });
  
  // Calculate equipment bonuses
  const equipmentBonuses = calculateEquipmentBonuses(character.equipment);
  
  // Calculate level bonuses
  const levelBonuses = calculateLevelBonuses(character.level);
  
  // Return combined stats
  return {
    hp: baseStats.hp + equipmentBonuses.hp + levelBonuses.hp,
    sp: baseStats.sp + equipmentBonuses.sp + levelBonuses.sp,
    mp: baseStats.mp + equipmentBonuses.mp + levelBonuses.mp,
    attack: baseStats.attack + equipmentBonuses.attack + levelBonuses.attack,
    defense: baseStats.defense + equipmentBonuses.defense + levelBonuses.defense,
    // Additional stats...
  };
}
```

## Inventory System

### Item Types

Items are categorized into types:

1. **Weapons** - Used in combat
2. **Armor** - Provides defense
3. **Consumables** - One-time use items
4. **Tools** - Used for specific actions
5. **Key Items** - Story-related items
6. **Miscellaneous** - Other items

### Inventory Management

Players can:
- View inventory items
- Equip/unequip items
- Use consumable items
- Examine items for details
- Sort items by type, rarity, etc.

```javascript
/**
 * Use an item from inventory
 * @param {Object} gameState Current game state
 * @param {string} itemId ID of the item to use
 * @returns {Promise<Object>} Updated game state and result message
 */
async function useItem(gameState, itemId) {
  // Find item in inventory
  const item = gameState.inventory.find(i => i.item_id === itemId);
  
  if (!item) {
    return {
      gameState,
      message: "Item not found in inventory."
    };
  }
  
  // Get item effects from database
  const itemEffects = await db.query(`
    SELECT * FROM item_effects WHERE item_id = @itemId
  `, {
    itemId
  });
  
  // Apply effects
  let updatedState = {...gameState};
  let resultMessage = `Used ${item.name}.`;
  
  for (const effect of itemEffects) {
    switch (effect.effect_type) {
      case 'heal':
        updatedState.player.hp = Math.min(
          updatedState.player.hp + effect.value,
          updatedState.player.maxHp
        );
        resultMessage += ` Restored ${effect.value} HP.`;
        break;
      case 'stamina':
        updatedState.player.sp = Math.min(
          updatedState.player.sp + effect.value,
          updatedState.player.maxSp
        );
        resultMessage += ` Restored ${effect.value} SP.`;
        break;
      // Other effect types...
    }
  }
  
  // Remove consumable item if applicable
  if (item.category === 'consumable') {
    updatedState.inventory = updatedState.inventory.filter(
      i => i.item_id !== itemId
    );
  }
  
  return {
    gameState: updatedState,
    message: resultMessage
  };
}
```

## Combat System

### Combat Flow

Combat follows this flow:

1. **Initiation** - Combat begins, setting `gameState.inCombat = true`
2. **Turn Order** - Determine who acts first based on initiative
3. **Action Selection** - Player selects from red combat actions
4. **Action Resolution** - System calculates outcomes
5. **Enemy Actions** - AI determines and executes enemy actions
6. **State Update** - HP, SP, MP, and status effects updated
7. **Victory/Defeat Check** - Check if combat should end
8. **Repeat from Step 3** until combat ends

### Combat Calculations

```javascript
/**
 * Calculate attack damage
 * @param {Object} attacker Attacking character
 * @param {Object} defender Defending character
 * @param {Object} weapon Weapon used
 * @returns {Object} Damage result
 */
function calculateDamage(attacker, defender, weapon) {
  // Base damage from weapon
  let baseDamage = weapon.damage;
  
  // Add attacker's attack stat
  baseDamage += attacker.attack;
  
  // Apply random variation (±20%)
  const variation = 0.8 + Math.random() * 0.4; // 0.8 to 1.2
  baseDamage = Math.round(baseDamage * variation);
  
  // Calculate defense reduction
  const defenseReduction = defender.defense * 0.5;
  
  // Final damage (minimum 1)
  const finalDamage = Math.max(1, Math.round(baseDamage - defenseReduction));
  
  // Critical hit check (10% chance)
  const isCritical = Math.random() < 0.1;
  
  // Apply critical multiplier if applicable
  const totalDamage = isCritical ? Math.round(finalDamage * 1.5) : finalDamage;
  
  return {
    damage: totalDamage,
    isCritical
  };
}
```

### Enemy AI

Enemy actions are determined by a combination of predefined behavior patterns and GPT-assisted decision making:

```javascript
/**
 * Determine enemy action in combat
 * @param {Object} enemy Enemy character
 * @param {Object} gameState Current game state
 * @returns {Promise<Object>} Selected action
 */
async function determineEnemyAction(enemy, gameState) {
  // Check if enemy has predefined behavior pattern
  if (enemy.ai_pattern) {
    return executeAIPattern(enemy, gameState);
  }
  
  // Use GPT for more dynamic behavior
  const prompt = await db.query(`
    SELECT * FROM prompts 
    WHERE purpose = 'enemy_ai' 
    AND is_active = 1
  `);
  
  if (!prompt.length) {
    // Fallback to basic attack
    return {
      action: 'attack',
      target: 'player',
      weapon: enemy.equipped_weapon
    };
  }
  
  // Format prompt with game state and enemy data
  const formattedPrompt = formatPromptWithVariables(
    prompt[0].template,
    {
      enemy: enemy,
      player: gameState.player,
      combat_round: gameState.combatRound,
      player_last_action: gameState.lastPlayerAction
    }
  );
  
  // Call GPT with the formatted prompt
  const response = await gptService.generateText([
    { role: "system", content: formattedPrompt },
    { role: "user", content: "Determine the most strategic action for this enemy." }
  ], {
    model: 'gpt-3.5-turbo', // Use faster model for combat
    temperature: 0.3 // Low randomness for more predictable behavior
  });
  
  // Parse JSON response
  try {
    return JSON.parse(response);
  } catch (error) {
    console.error("Failed to parse enemy action:", error);
    // Fallback to basic attack
    return {
      action: 'attack',
      target: 'player',
      weapon: enemy.equipped_weapon
    };
  }
}
```

## Narrative System

### Narrative Generation

The narrative system uses GPT to generate story text based on the current game state:

```javascript
/**
 * Generate narrative text
 * @param {Object} gameState Current game state
 * @param {string} action Player's selected action
 * @returns {Promise<Object>} Generated narrative and updated state
 */
async function generateNarrative(gameState, action) {
  // Get appropriate prompt template
  const promptType = gameState.inCombat ? 'combat_narrative' : 
                    (gameState.inConversation ? 'conversation_narrative' : 
                    'exploration_narrative');
  
  const prompt = await db.query(`
    SELECT * FROM prompts 
    WHERE purpose = @promptType 
    AND is_active = 1
  `, {
    promptType
  });
  
  if (!prompt.length) {
    return {
      narrative: "The system encountered an error generating the narrative.",
      gameState
    };
  }
  
  // Format prompt with game state and action
  const formattedPrompt = formatPromptWithVariables(
    prompt[0].template,
    {
      location: gameState.location,
      description: gameState.locationDescription,
      player: gameState.player,
      inventory: gameState.inventory,
      characters: gameState.characters,
      quest_status: gameState.quests,
      action: action,
      history: getRecentHistory(gameState, 5) // Last 5 narrative events
    }
  );
  
  // Call GPT with the formatted prompt
  const response = await gptService.generateText([
    { role: "system", content: formattedPrompt },
    { role: "user", content: `I ${action}.` }
  ], {
    model: prompt[0].model,
    temperature: prompt[0].temperature
  });
  
  // Parse response to extract narrative and state changes
  try {
    // If response is JSON, parse it
    if (response.trim().startsWith('{') && response.trim().endsWith('}')) {
      const parsed = JSON.parse(response);
      return {
        narrative: parsed.narrative,
        gameState: applyStateChanges(gameState, parsed.stateChanges || {})
      };
    }
    
    // Otherwise, treat the whole response as narrative
    return {
      narrative: response,
      gameState
    };
  } catch (error) {
    console.error("Failed to parse narrative response:", error);
    return {
      narrative: response, // Use raw response
      gameState
    };
  }
}
```

### Narrative Memory

The system maintains a history of narrative events to provide context for future generations:

```javascript
/**
 * Get recent narrative history
 * @param {Object} gameState Current game state
 * @param {number} count Number of recent events to retrieve
 * @returns {Array} Recent narrative events
 */
function getRecentHistory(gameState, count = 5) {
  return (gameState.narrativeHistory || []).slice(-count);
}

/**
 * Add event to narrative history
 * @param {Object} gameState Current game state
 * @param {string} narrative New narrative text
 * @param {string} action Action that triggered the narrative
 * @returns {Object} Updated game state
 */
function addToNarrativeHistory(gameState, narrative, action) {
  const updatedState = {...gameState};
  
  // Initialize history array if it doesn't exist
  if (!updatedState.narrativeHistory) {
    updatedState.narrativeHistory = [];
  }
  
  // Add new event
  updatedState.narrativeHistory.push({
    timestamp: new Date().toISOString(),
    narrative,
    action,
    location: gameState.location
  });
  
  // Limit history size (e.g., keep last 50 events)
  if (updatedState.narrativeHistory.length > 50) {
    updatedState.narrativeHistory = updatedState.narrativeHistory.slice(-50);
  }
  
  return updatedState;
}
```

## Relationship System

### NPC Relationships

The game tracks player relationships with NPCs:

```javascript
/**
 * Update relationship with NPC
 * @param {Object} gameState Current game state
 * @param {string} npcId ID of the NPC
 * @param {number} change Amount to change relationship (-100 to +100)
 * @returns {Object} Updated game state
 */
function updateNPCRelationship(gameState, npcId, change) {
  const updatedState = {...gameState};
  
  // Initialize relationships object if it doesn't exist
  if (!updatedState.relationships) {
    updatedState.relationships = {};
  }
  
  // Initialize NPC relationship if it doesn't exist
  if (!updatedState.relationships[npcId]) {
    updatedState.relationships[npcId] = {
      value: 0, // Neutral starting point
      events: []
    };
  }
  
  // Apply change
  updatedState.relationships[npcId].value = Math.max(
    -100,
    Math.min(100, updatedState.relationships[npcId].value + change)
  );
  
  // Record event
  updatedState.relationships[npcId].events.push({
    timestamp: new Date().toISOString(),
    change,
    value: updatedState.relationships[npcId].value
  });
  
  return updatedState;
}
```

## Quest System

### Quest Structure

Quests have the following components:

1. **Title** - Descriptive name
2. **Description** - Quest details
3. **Objectives** - Specific tasks to complete
4. **Rewards** - Items, XP, relationships, etc.
5. **Status** - Offered, Active, Completed, Failed

```javascript
/**
 * Check quest objective completion
 * @param {Object} gameState Current game state
 * @returns {Object} Updated game state with completed objectives
 */
function checkQuestObjectives(gameState) {
  const updatedState = {...gameState};
  
  // For each active quest
  updatedState.quests.forEach(quest => {
    if (quest.status !== 'active') return;
    
    // Check each objective
    quest.objectives.forEach(objective => {
      if (objective.completed) return;
      
      // Check completion based on objective type
      switch (objective.type) {
        case 'kill':
          // Check if target was killed
          if (gameState.kills && gameState.kills[objective.target] >= objective.count) {
            objective.completed = true;
          }
          break;
        case 'collect':
          // Check if item is in inventory
          const itemCount = gameState.inventory.filter(
            item => item.id === objective.item_id
          ).length;
          if (itemCount >= objective.count) {
            objective.completed = true;
          }
          break;
        case 'visit':
          // Check if location was visited
          if (gameState.location === objective.location_id) {
            objective.completed = true;
          }
          break;
        // Other objective types...
      }
    });
    
    // Check if all objectives are completed
    if (quest.objectives.every(obj => obj.completed)) {
      quest.status = 'completed';
      // Apply rewards
      updatedState = applyQuestRewards(updatedState, quest);
    }
  });
  
  return updatedState;
}
```

## Database-Driven Design

All mechanics should be configurable through database tables:

1. **Character Options** - Species, roles, starting stats
2. **Item Templates** - Base item definitions
3. **Action Buttons** - Available actions by type
4. **Combat Rules** - Formula parameters, status effects
5. **Narrative Prompts** - Templates for different narrative contexts

## Phase 1 Implementation Focus

For Phase 1, focus on these core mechanics:

1. **Basic Narrative System** - Text generation and display
2. **Action System** - All button types functional
3. **Simple Character Stats** - Basic HP, SP, MP system
4. **Minimal Combat** - Turn-based combat with basic actions
5. **Simple Inventory** - View and use items

Defer these systems to Phase 2:

1. **Character Portraits** - Use placeholders in Phase 1
2. **Location Images** - Use text descriptions only in Phase 1
3. **Detailed Equipment System** - Use simplified version in Phase 1
4. **Advanced Combat Features** - Special abilities, status effects

## Best Practices

1. **Database First**
   - Store all game rules and mechanics in the database
   - Code should read rules from database, not hardcode them

2. **State Management**
   - Keep all game state in a central object
   - Apply immutable update patterns (create new copies)
   - Persist state regularly to allow saving/loading

3. **Error Handling**
   - Implement fallbacks for all AI-dependent mechanics
   - Log errors comprehensively for debugging
   - Never crash the game due to failed AI generation

4. **Performance**
   - Cache expensive operations
   - Batch database queries
   - Use faster AI models for time-sensitive mechanics (combat)

5. **Testing**
   - Create unit tests for core mechanical formulas
   - Test edge cases in combat and stat calculations
   - Create automation tests for common gameplay flows

## Conclusion

This mechanics documentation provides a comprehensive guide to implementing the core game systems for Warped Speed. By following these patterns and guidelines, the system will be modular, maintainable, and fully database-driven.

Remember that Phase 1 focuses on getting the core text-based gameplay working before adding visual elements in Phase 2. This approach ensures a solid foundation for the game mechanics. 