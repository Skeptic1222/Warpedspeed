# Warped Speed - UI Specifications

## Overview

The Warped Speed UI is designed to be responsive, intuitive, and immersive, supporting both mobile and desktop experiences. This document outlines the UI components, layout, and styling guidelines for the application.

## Core Layout

The main game interface consists of these key sections:

```
┌─────────────────────────────────────────────────┐
│                   HEADER BAR                    │
├─────────────────────────────────────────────────┤
│                                                 │
│                  SCENE AREA                     │
│                (Phase 2 only)                   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│                 TEXT WINDOW                     │
│                                                 │
├─────────────────────────────────────────────────┤
│                 ACTION BUTTONS                  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Header Bar

- Contains game logo/title
- Settings button
- Save/load functionality
- Player status indicators (Phase 2)

### Scene Area (Phase 2)

- Displays the current scene image
- Player character portrait (right side)
- NPC portraits (when present)
- Visual indicators for location and context

### Text Window

- Scrollable narrative text area
- Automatic scrolling to new content
- Rich text formatting
- Tap/click to pause auto-scroll

### Action Buttons

- Multiple rows of action buttons, color-coded by type
- Each row is collapsible/expandable
- Left-aligned buttons for better reachability

## Action Button System

The action buttons are organized in color-coded rows:

### Green Actions (Always Available)

- Core utility actions
- Always visible
- Examples: Look, Inventory, Talk, Rest
- Styled with green background

### Yellow Actions (Context-Sensitive)

- Actions specific to the current context
- Generated dynamically
- Examples: Examine Terminal, Pick Lock
- Styled with yellow background

### Orange Actions (High-Risk)

- Significant or dangerous actions
- Appear when relevant
- Examples: Override Security, Sacrifice Crew
- Styled with orange background

### Red Actions (Combat)

- Only visible during combat
- Combat-specific actions
- Examples: Attack, Defend, Use Item, Flee
- Styled with red background

### Blue Actions (Conversation)

- Only visible during conversations
- Dialogue-specific actions
- Examples: Persuade, Threaten, Joke
- Styled with blue background

## Expandable Panels

All action rows are expandable/collapsible:

```
┌────────────────────────────────────────────┐
│ ▼ Combat Actions                           │
├────────────────────────────────────────────┤
│ [Attack] [Defend] [Use Item] [Flee]        │
└────────────────────────────────────────────┘
```

When collapsed:

```
┌────────────────────────────────────────────┐
│ ▶ Combat Actions                           │
└────────────────────────────────────────────┘
```

## Phase 2 UI Additions

### Player Status Panel

Located in the top-right corner:

```
┌────────────────────┐
│  [Player Portrait] │
│  HP: ████████      │
│  SP: ██████        │
│  MP: ███████       │
└────────────────────┘
```

Clicking expands to full character panel.

### NPC Status Panels

Located to the right of the player panel when NPCs are present:

```
┌────────────────┐
│ [NPC Portrait] │
│ HP: ████       │
└────────────────┘
```

### Inventory Panel

Full-screen overlay that slides in from left:

```
┌─────────────────────────────────────────────────┐
│ INVENTORY            [X]                        │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Item] [Item] [Item] [Item] [Item] [Item]      │
│  [Item] [Item] [Item] [Item] [Item] [Item]      │
│                                                 │
├─────────────────────────────────────────────────┤
│ Selected: Laser Pistol                          │
│ A standard-issue sidearm with adjustable power  │
│ settings.                                       │
│                                                 │
│ [Use] [Equip] [Drop]                            │
└─────────────────────────────────────────────────┘
```

### Character Sheet

Full-screen overlay that slides in from the right:

```
┌─────────────────────────────────────────────────┐
│ CHARACTER             [X]                       │
├─────────────────────────────────────────────────┤
│ [Portrait]  Name: Alex Chen                     │
│             Species: Human                      │
│             Role: Pilot                         │
│                                                 │
│ STATS                  EQUIPMENT                │
│ HP: 45/50             Weapon: Laser Pistol      │
│ SP: 30/30             Armor: Flight Suit        │
│ MP: 25/25             Accessory: Neural Link    │
│                                                 │
│ SKILLS                                          │
│ Piloting: ●●●●○                                 │
│ Combat: ●●○○○                                   │
│ Tech: ●●●○○                                     │
└─────────────────────────────────────────────────┘
```

## Responsive Design

The UI adapts to different screen sizes and orientations:

### Mobile Portrait

- Text window takes up more vertical space
- Action buttons stacked but still grouped by color
- Slide-in panels for inventory and character sheet

### Mobile Landscape

- Scene and text shown side by side
- Action buttons in a single row per type
- More horizontal space for multiple buttons

### Desktop

- Larger scene display
- More text visible at once
- Multiple rows of action buttons visible simultaneously

## Button Styling

The action buttons follow this styling:

```css
/* Base button style */
.action-button {
  border-radius: 6px;
  padding: 10px 16px;
  font-size: 16px;
  font-weight: 600;
  min-width: 44px;
  min-height: 44px;
  margin: 4px;
  transition: transform 0.1s, background-color 0.2s;
}

/* Color variants */
.green-btn {
  background-color: #2ecc71;
  color: white;
}

.yellow-btn {
  background-color: #f1c40f;
  color: #333;
}

.orange-btn {
  background-color: #e67e22;
  color: white;
}

.red-btn {
  background-color: #e74c3c;
  color: white;
}

.blue-btn {
  background-color: #3498db;
  color: white;
}

/* Hover/active states */
.action-button:hover {
  transform: scale(1.05);
}

.action-button:active {
  transform: scale(0.95);
}
```

## Text Styling

The narrative text follows these styling guidelines:

```css
.narrative-text {
  font-family: 'Roboto', sans-serif;
  font-size: 18px;
  line-height: 1.5;
  color: #f0f0f0;
  padding: 16px;
}

/* Dialog text */
.dialog-text {
  font-style: italic;
  color: #a8e6cf;
}

/* System messages */
.system-text {
  color: #dcc7aa;
  font-size: 16px;
}

/* Combat text */
.combat-text {
  color: #ff928b;
  font-weight: 500;
}
```

## Color Palette

The UI uses a consistent color palette stored in the database:

| Name | Hex | Usage |
|------|-----|-------|
| Primary | #3498db | Primary UI elements, headers |
| Secondary | #2ecc71 | Success indicators, green buttons |
| Accent | #e67e22 | Highlights, important elements |
| Background | #121212 | Main background |
| Surface | #222222 | Card backgrounds, panels |
| Text Primary | #f0f0f0 | Main text color |
| Text Secondary | #aaaaaa | Secondary text, descriptions |
| Danger | #e74c3c | Errors, warnings, red buttons |

## Loading States

All UI elements that load data should display clear loading states:

- Spinner animation for buttons during action processing
- Pulsing placeholder for images during loading
- Text shimmer effect for loading narrative text

## Dialog Windows

Dialogs for important interactions:

```
┌─────────────────────────────────────────┐
│ CONFIRM ACTION                  [X]     │
├─────────────────────────────────────────┤
│                                         │
│  Are you sure you want to detonate the  │
│  reactor core? This action cannot be    │
│  undone and will affect the story.      │
│                                         │
├─────────────────────────────────────────┤
│      [CANCEL]          [CONFIRM]        │
└─────────────────────────────────────────┘
```

## Database-Driven UI

The UI elements should be configurable through the database:

```sql
-- Example UI configuration entry
INSERT INTO ui_config (config_key, config_value, scope, component)
VALUES (
    'button_colors',
    '{"green":"#2ecc71","yellow":"#f1c40f","orange":"#e67e22","red":"#e74c3c","blue":"#3498db"}',
    'global',
    'action_buttons'
);
```

This allows for changing UI properties without code modifications.

## Accessibility Guidelines

The UI should follow these accessibility guidelines:

1. **Color Contrast** - All text should have sufficient contrast
2. **Touch Targets** - Buttons minimum 44x44px
3. **Text Size** - Scalable text, minimum 16px
4. **Keyboard Navigation** - Support for tab navigation
5. **Screen Reader Support** - Proper ARIA attributes

## Implementation Notes

1. Use React components for UI elements
2. Implement CSS variables for theme values
3. Store UI configuration in the database
4. Use responsive units (rem, %, vh/vw) for sizing
5. Implement reducers for UI state management

## Example Component Structure

```
/src
  /components
    /ui
      /buttons
        ActionButton.tsx
        ButtonRow.tsx
      /panels
        TextPanel.tsx
        InventoryPanel.tsx
        CharacterPanel.tsx
      /layout
        GameLayout.tsx
        HeaderBar.tsx
      /common
        LoadingSpinner.tsx
        Modal.tsx
```

## Phase 1 Implementation

For Phase 1, focus on implementing:

1. Basic layout structure
2. Text window component
3. All action button types
4. Expandable/collapsible rows
5. Mobile responsiveness

Defer the following to Phase 2:

1. Scene image display
2. Character portraits
3. Inventory panel
4. Character sheet
5. NPC status displays

## Conclusion

This UI specification provides guidelines for implementing the Warped Speed interface. Following these specifications will ensure a consistent, responsive, and accessible user experience that can be easily modified through database configuration. 