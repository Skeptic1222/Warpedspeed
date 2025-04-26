# Warped Speed - Prompt Templates Guide

This document outlines the prompt-first development approach for the Warped Speed project, including templates, best practices, and implementation guidelines.

## Prompt-First Development Philosophy

Warped Speed adopts a prompt-first development approach where game content is generated dynamically using AI models rather than being hardcoded. This approach offers several advantages:

1. **Content Scalability** - Generate virtually unlimited unique content
2. **Dynamic Storytelling** - Create responsive narratives that adapt to player choices
3. **Reduced Development Time** - Focus on systems rather than content creation
4. **Consistent Content Quality** - Templated approach ensures quality standards
5. **Easy Iteration** - Refine content generation without code changes

## Prompt Template Structure

Each prompt template follows a consistent structure to ensure reliability and quality:

```json
{
  "name": "template_name",
  "description": "Purpose and usage of this template",
  "category": "scene|character|dialogue|combat|item|quest",
  "template_text": "The actual prompt with {{variable}} placeholders",
  "model": "gpt-4-turbo",
  "max_tokens": 500,
  "temperature": 0.7,
  "top_p": 1.0,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0,
  "variables": {
    "variable1": {
      "description": "What this variable represents",
      "type": "string|number|boolean|array|object",
      "required": true,
      "default": "default value if any",
      "validation": "regex pattern or validation rules"
    }
  },
  "example_output": "Example of expected output format",
  "failure_fallback": "Content to use if generation fails"
}
```

## Variable Interpolation

Variables are defined using double curly braces: `{{variable_name}}`. The system will replace these with actual values before sending the prompt to the AI model.

### Variable Types

- **Game State Variables** - Character stats, inventory, location, etc.
- **Player History Variables** - Past choices, completed quests, etc.
- **Content Reference Variables** - IDs or references to other content
- **System Variables** - Date, time, session ID, etc.

### Example:

```
{{character_name}} enters the {{location_name}} and sees {{object_count}} objects around the room.
```

## Core Template Categories

### 1. Scene Description Templates

Used to generate dynamic descriptions of game locations and environments.

**Example: `scene_description`**
```
Generate a detailed description of {{location_name}}, a {{location_type}} located in {{region_name}}. 
The location has the following features: {{location_features}}.
The current time is {{time_of_day}} and the weather is {{weather_condition}}.
{{if has_visited}}This is not the first time the character has been here, so mention some familiarity.{{endif}}
{{if danger_level > 3}}Emphasize the dangerous aspects of this location.{{endif}}

The description should be 2-3 paragraphs long, engaging, and evocative. Focus on sensory details and atmosphere.
Do not include any dialogue. Do not mention any NPCs unless they are part of {{fixed_objects}}.
```

### 2. Character Interaction Templates

Used for NPC dialogue and responses.

**Example: `npc_greeting`**
```
You are {{npc_name}}, a {{npc_occupation}} in the world of Warped Speed.

Your personality traits are: {{npc_personality_traits}}.
Your current emotional state is: {{npc_emotional_state}}.
Your relationship with the player character ({{character_name}}) is: {{npc_relationship_to_player}}.

Generate a greeting when the player character approaches you. Your greeting should:
1. Reflect your personality and emotional state
2. Acknowledge the current setting ({{location_name}})
3. Reference any relevant past interactions {{if has_met_before}}especially your previous meeting{{endif}}
4. {{if has_quest_available}}Hint at the quest you have available{{endif}}

Keep your response under 3 sentences and in a conversational tone.
```

### 3. Combat Narration Templates

Used to generate dynamic combat descriptions.

**Example: `combat_action_description`**
```
Describe a combat action where {{attacker_name}} uses {{action_name}} against {{target_name}}.

Attacker details:
- Species: {{attacker_species}}
- Weapon: {{attacker_weapon}}
- Special abilities: {{attacker_abilities}}

Target details:
- Species: {{target_species}}
- Armor/Protection: {{target_protection}}

Action result:
- Hit success: {{action_success}}
- Damage dealt: {{damage_amount}}
- Critical hit: {{is_critical}}
- Special effects: {{special_effects}}

Create a vivid, action-oriented description of this combat action. Emphasize the {{if is_critical}}spectacular{{else}}characteristic{{endif}} nature of the attack. The description should be 1-2 sentences long.
```

### 4. Item Description Templates

Used to generate descriptions for items, weapons, and artifacts.

**Example: `item_description`**
```
Generate a description for {{item_name}}, a {{item_rarity}} {{item_type}}.

Physical attributes:
- Material: {{item_material}}
- Size: {{item_size}}
- Weight: {{item_weight}}
- Appearance: {{item_appearance}}

Functional attributes:
- Primary use: {{item_function}}
- Effects: {{item_effects}}
- Value: {{item_value}}
- Required skill: {{item_required_skill}}

History and lore (optional):
{{if has_lore}}
- Origin: {{item_origin}}
- Age: {{item_age}}
- Previous owners: {{item_previous_owners}}
{{endif}}

The description should be 1-2 paragraphs long, focusing on both appearance and function. If the item is magical or technological, emphasize its special properties. If it has historical significance, briefly mention its past.
```

### 5. Quest Description Templates

Used to generate quest descriptions and objectives.

**Example: `quest_description`**
```
Generate a quest description for a mission called "{{quest_name}}".

Context:
- Quest giver: {{quest_giver_name}}, a {{quest_giver_occupation}}
- Location: {{quest_location}}
- Difficulty level: {{quest_difficulty}}
- Quest type: {{quest_type}}

Core elements:
- Primary objective: {{quest_objective}}
- Reason/motivation: {{quest_motivation}}
- Stakes/consequences: {{quest_stakes}}
- Time constraints: {{quest_time_limit}}

The description should have two parts:
1. A brief introduction paragraph explaining what the quest is about and who is giving it
2. A clear statement of the objectives, written in a way that would appear in a quest journal

Maintain a {{quest_tone}} tone appropriate for the quest's nature.
```

### 6. Story Event Templates

Used to generate narrative events and plot developments.

**Example: `random_event`**
```
Generate a random event that occurs while the character is traveling from {{origin_location}} to {{destination_location}}.

Character details:
- Name: {{character_name}}
- Species: {{character_species}}
- Class/Occupation: {{character_class}}
- Key abilities: {{character_abilities}}

Journey context:
- Travel method: {{travel_method}}
- Time of day: {{time_of_day}}
- Weather: {{weather_condition}}
- Terrain: {{terrain_type}}
- Danger level: {{danger_level}}

The event should:
1. Be appropriate for the terrain and danger level
2. Present the character with a clear choice or challenge
3. Have potential consequences for the character's journey
4. Take no more than 5 minutes of gameplay to resolve
5. Be described in 2-3 paragraphs

Include a title for the event, the main description, and 2-4 options for how the player might respond.
```

## Implementation Guidelines

### 1. Template Versioning

All templates should include a version number to track changes:

```json
{
  "name": "scene_description",
  "version": "1.2",
  // rest of template
}
```

When updating templates, increment the version number and document changes.

### 2. Template Testing

Before deploying new templates to production:

1. Test with multiple variable combinations
2. Verify output meets quality standards
3. Check for edge cases and failure modes
4. Conduct performance testing for token usage and response time

### 3. Error Handling

Implement robust error handling for AI generation:

1. Always provide fallback content in case of API failures
2. Implement retry logic with exponential backoff
3. Monitor and log generation errors
4. Cache successful generations to reduce API calls

### 4. Content Moderation

Implement content filtering to ensure appropriate output:

1. Pre-filter prompts to remove potential issues
2. Post-filter generated content
3. Implement keyword and pattern blacklists
4. Use AI-based content moderation when available

### 5. Caching Strategy

To optimize performance and reduce costs:

1. Cache generated content by template+variables hash
2. Implement TTL (time-to-live) based on content type
3. Use layered caching (memory → local storage → database)
4. Implement background refreshing for critical content

## Example Implementation

```javascript
class PromptManager {
  async generateContent(templateName, variables) {
    try {
      // 1. Fetch template from database
      const template = await this.getTemplate(templateName);
      
      // 2. Validate variables against template schema
      this.validateVariables(template, variables);
      
      // 3. Build cache key
      const cacheKey = this.buildCacheKey(templateName, variables);
      
      // 4. Check cache first
      const cachedContent = await this.checkCache(cacheKey);
      if (cachedContent) return cachedContent;
      
      // 5. Interpolate variables
      const prompt = this.interpolateVariables(template.template_text, variables);
      
      // 6. Call AI API
      const generatedContent = await this.callAIAPI({
        prompt,
        model: template.model,
        max_tokens: template.max_tokens,
        temperature: template.temperature,
        top_p: template.top_p,
        frequency_penalty: template.frequency_penalty,
        presence_penalty: template.presence_penalty
      });
      
      // 7. Validate & filter response
      const validatedContent = await this.validateAndFilterContent(generatedContent);
      
      // 8. Cache result
      await this.cacheResult(cacheKey, validatedContent, template.cache_ttl);
      
      // 9. Return generated content
      return validatedContent;
    } catch (error) {
      // Log error and return fallback content
      console.error(`Error generating content for template ${templateName}:`, error);
      return this.getFallbackContent(templateName);
    }
  }
  
  // Other methods...
}
```

## Best Practices

### Writing Effective Prompts

1. **Be Specific** - Clearly describe the desired output format and constraints
2. **Use Examples** - Include examples of good outputs in the prompt
3. **Control Randomness** - Adjust temperature based on desired creativity vs. consistency
4. **Layer Instructions** - Start with general context, then add specific requirements
5. **Include Formatting Instructions** - Specify exactly how the output should be structured
6. **Test and Iterate** - Continuously refine prompts based on output quality

### Managing Token Usage

1. **Optimize Prompt Length** - Keep prompts concise without sacrificing quality
2. **Variable Preprocessing** - Clean and format variables before interpolation
3. **Use the Right Model** - Match model capabilities to content requirements
4. **Batch Related Generations** - Generate related content in a single request when possible
5. **Monitor Token Usage** - Track token consumption by template

### Performance Optimization

1. **Pregenerate Content** - Generate predictable content in advance
2. **Background Generation** - Use worker processes for non-blocking generation
3. **Progressive Loading** - Show instantly available content while generating more
4. **Prioritize Critical Paths** - Ensure core gameplay content generates quickly

## Template Library

The Warped Speed project maintains a comprehensive library of prompt templates for various content needs. These templates are stored in the database and can be managed through the admin interface.

The following template categories are available:

1. **Environment Templates**
   - Scene descriptions
   - Weather effects
   - Environmental hazards

2. **Character Templates**
   - NPC personalities
   - Character backgrounds
   - Character appearances

3. **Narrative Templates**
   - Story events
   - Plot twists
   - Flashbacks

4. **Gameplay Templates**
   - Combat encounters
   - Puzzle challenges
   - Stealth scenarios

5. **Item Templates**
   - Weapon descriptions
   - Armor descriptions
   - Artifact lore

## Conclusion

The prompt-first development approach enables Warped Speed to create rich, dynamic content that adapts to player choices while maintaining consistent quality. By following these guidelines and using well-designed templates, the game can deliver a virtually limitless experience that feels handcrafted for each player.

Remember that prompt engineering is both an art and a science - continuous testing and refinement are essential to achieving the best results. 