# Architecture Overview

## Core Design: Entity-Component-System (ECS)

This project follows an ECS architecture where:
- **Entities** are just IDs
- **Components** primarily contain data but may include helper methods
- **Systems** contain only logic (no data)
- **Behaviors** orchestrate high-level game actions

## Key Architectural Decisions

### 1. Pure ECS Implementation
- Components primarily store data but may include helper methods
- Systems process entities with specific component combinations
- World manages entity lifecycle and component storage

### 2. Component Design Principles
**Core Rules:**
- Components contain ONLY data and helper methods (no game logic)
- All components extend `BaseComponent` for consistent interface
- Each component has a single responsibility
- Components are composable (entities can have multiple)
- No dependencies between components

**Helper Methods Guidelines:**
- Helper methods should only work with the component's own data
- Methods for initialization, mutation, and computed properties are allowed
- No external dependencies or side effects in component methods

**File Structure:**
- Component files named: `<name>_component.lua`
- Constructor accepts single `data` table parameter
- Use PascalCase for class names (e.g., `MovementComponent`)
- Use snake_case for file names (e.g., `movement_component.lua`)

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

### 4. Component Reference
All game data is stored in components:

**Core Components:**
- `BaseComponent` - Base class for all components (provides type field)
- `TransformComponent` - Position, rotation, and scale
- `RenderComponent` - Visual appearance (color, size, shape)
- `ImageComponent` - Image-based rendering

**Movement Components:**
- `MovementComponent` - Base movement state and speed
- `LinearMovementComponent` - Straight line movement to target
- `CircularMovementComponent` - Orbital movement around center
- `CosineMovementComponent` - Wave-based movement patterns

**Visual Effect Components:**
- `PulseComponent` - Size pulsing animation
- `ShakeComponent` - Position shaking effects
- `TextComponent` - Animated text display with fade/popup
- `StatDisplayComponent` - Generic stat display with interpolation

**Game Logic Components:**
- `ScoreComponent` - Score data (points, distance, position)
- `HitComponent` - Marks entities for hit processing
- `TimerComponent` - Delayed component addition/removal

The `CombinedMovementSystem` processes all movement types together.

### 5. Factory Pattern
Factories create pre-configured entities:
- `dart_board_factory` - Creates the game board
- `dot_factory` - Creates moving targets
- `text_factory` - Creates score text


## ECS Implementation Rules

### Component Rules
1. Components contain ONLY data, no methods (except constructor and helpers)
2. All components extend BaseComponent
3. Component files named: `<name>_component.lua`
4. Constructor accepts single `data` table parameter
5. Use helper methods only for data manipulation within the component

**Component Creation Example:**
```lua
-- components/health_component.lua
local BaseComponent = require('ecs.base_component')
local HealthComponent = {}
HealthComponent.__index = HealthComponent
setmetatable(HealthComponent, BaseComponent)

function HealthComponent.new(data)
    local self = setmetatable(BaseComponent.new('health'), HealthComponent)
    self.current = data.current or 100
    self.max = data.max or 100
    return self
end

-- Helper method example - data manipulation only
function HealthComponent:getPercentage()
    return self.current / self.max
end

return HealthComponent
```

### System Rules
1. Systems contain ONLY logic, no persistent state
2. All systems extend BaseSystem
3. System files named: `<name>_system.lua`
4. Define required components in constructor
5. Use `init()` for world reference
6. Process entities in `update(dt)` or `render()`

**System Creation Example:**
```lua
-- systems/damage_system.lua
local BaseSystem = require('ecs.base_system')
local DamageSystem = {}
DamageSystem.__index = DamageSystem
setmetatable(DamageSystem, BaseSystem)

function DamageSystem.new()
    local system = BaseSystem.new(DamageSystem, {'health', 'hit'})
    return system
end

function DamageSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        local health = entity:getComponent('health')
        local hit = entity:getComponent('hit')
        
        health.current = health.current - hit.damage
        entity:removeComponent('hit')  -- Process once
    end
end

return DamageSystem
```

### Entity Rules
1. Entities are created through factories
2. Never create entities directly in systems
3. Prefer tag components for triggering complex actions

**Factory Pattern:**
```lua
-- factories/player_factory.lua
local PlayerFactory = {}

function PlayerFactory.createPlayer(x, y)
    local entity = world:createEntity()
    entity:addComponent(Components.TransformComponent.new({x = x, y = y}))
    entity:addComponent(Components.HealthComponent.new({current = 100, max = 100}))
    entity:addComponent(Components.RenderComponent.new({color = {0, 1, 0, 1}}))
    return entity
end

return PlayerFactory
```

### Event Handling (Pure ECS Approach)
1. Use tag components to trigger system chains
2. Systems should process based on component presence
3. Remove event/tag components after processing
4. Example patterns:
   - `DartThrowEvent` component triggers throw sequence
   - `NeedsScoring` component triggers score calculation
   - `PendingDestroy` component triggers entity cleanup

Note: The current codebase uses behavior modules for pragmatic reasons,
but pure ECS would use tag components and system chains instead.

## Common Implementation Patterns

### Adding Visual Effects
```lua
-- 1. Create particle component
-- components/particle_component.lua
function ParticleComponent.new(data)
    local self = setmetatable(BaseComponent.new('particle'), ParticleComponent)
    self.lifetime = data.lifetime or 1.0
    self.velocity = data.velocity or {x = 0, y = 0}
    self.color = data.color or {1, 1, 1, 1}
    return self
end

-- 2. Create particle system
-- systems/particle_system.lua
function ParticleSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        local particle = entity:getComponent('particle')
        local transform = entity:getComponent('transform')
        
        -- Update position
        transform.x = transform.x + particle.velocity.x * dt
        transform.y = transform.y + particle.velocity.y * dt
        
        -- Update lifetime
        particle.lifetime = particle.lifetime - dt
        if particle.lifetime <= 0 then
            self.world:removeEntity(entity)
        end
    end
end

-- 3. Register system in correct order (main.lua)
world:addSystem(Systems.ParticleSystem)  -- Before RenderSystem
```

### Modifying Game Physics
```lua
-- Change target movement speed in factories/dot_factory.lua
entity:addComponent(Components.MovementComponent.new({
    speed = 150,  -- Adjust this value (pixels/second)
    target_x = 400,
    target_y = 300
}))

-- Adjust dartboard shake in behaviors/dartboard_behavior.lua
dartBoardEntity:addComponent(Components.ShakeComponent.new({
    intensity = 15,  -- Shake distance in pixels
    duration = 0.5,  -- Shake duration in seconds
    decay_rate = 5
}))
```

### Registration and Integration
1. **Register component** in `ecs/component.lua`:
   ```lua
   Components.YourComponent = require('components.your_component')
   ```

2. **Register system** in `main.lua` in correct processing order:
   ```lua
   Systems.YourSystem:init(gameWorld)
   gameWorld:addSystem(Systems.YourSystem)
   ```

3. **Use in factories** for entity creation:
   ```lua
   entity:addComponent(Components.YourComponent.new({param = value}))
   ```

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