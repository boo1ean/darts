# Architecture Overview

## Core Design: Entity-Component-System (ECS)

This project follows a pure ECS architecture where:
- **Entities** are just IDs
- **Components** contain only data (no logic)
- **Systems** contain only logic (no data)
- **Behaviors** orchestrate high-level game actions

## Key Architectural Decisions

### 1. Pure ECS Implementation
- No logic in components - they are pure data containers
- Systems process entities with specific component combinations
- World manages entity lifecycle and component storage

### 2. Component Design Principles
- Each component has a single responsibility
- Components are composable (entities can have multiple)
- No dependencies between components
- All components extend `BaseComponent` for consistent interface

### 3. System Processing Order
Systems are added to the world in a specific order:
1. `TargetGenerationSystem` - Creates new targets
2. `CombinedMovementSystem` - Handles all movement types
3. `PulseSystem` - Visual pulsing effects
4. `TimerSystem` - Delayed actions
5. `ScoringSystem` - Hit detection and scoring
6. `ShakeSystem` - Visual feedback
7. `RenderSystem` - Draw entities
8. `TextSystem` - Draw text (last for top layer)

### 4. Movement Architecture
Movement is handled through multiple component types:
- `MovementComponent` - Base movement state
- `LinearMovementComponent` - Straight line movement
- `CircularMovementComponent` - Orbital movement
- `CosineMovementComponent` - Wave patterns

The `CombinedMovementSystem` processes all movement types together.

### 5. Factory Pattern
Factories create pre-configured entities:
- `dartboard_factory` - Creates the game board
- `dot_factory` - Creates moving targets
- `text_factory` - Creates score text


## Adding New Features

### To Add a New Component:
1. Create file in `components/` extending `BaseComponent`
2. Define data fields in `new()` method
3. No methods except constructor

### To Add a New System:
1. Create file in `systems/` extending `BaseSystem`
2. Define component requirements in `new()`
3. Implement `process()` for logic
4. Add to world in correct order in `main.lua`

### To Add Visual Effects:
1. Create component for effect data
2. Create system for effect logic
3. Ensure render order is correct

## Performance Considerations
- Systems process only entities with required components
- Batch similar operations in single systems
- Minimize component lookups in hot paths
- Use timers for delayed actions vs polling

## Testing Strategy
- Test components as data structures
- Test systems with mock entities
- Test behaviors with integration tests
- Use `scripts/test.sh` for full validation