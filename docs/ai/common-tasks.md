# Common Development Tasks

## Task Decision Tree

### Adding New Feature
1. **Understand requirement** → Read `docs/ai/context.md`
2. **Check existing systems** → Review relevant files in `systems/`
3. **Determine approach**:
   - New component needed? → Use component creation workflow
   - Modify existing system? → Read system's current logic first
   - New visual effect? → Create component + system + update render order
4. **Use factories** → Never create entities directly in systems

### Fixing Bug
1. **Run test.sh** → Establish current state
2. **Run lint.sh** → Fix any code quality issues first
3. **Identify affected systems** → Look for relevant component usage
4. **Test incrementally** → Make small changes, test frequently

### Modifying Movement
1. **Check CombinedMovementSystem** → Understand current movement processing
2. **Review movement components**:
   - LinearMovementComponent
   - CircularMovementComponent  
   - CosineMovementComponent
3. **Test movement changes** → Visual verification crucial

### Adding Visual Effect
1. **Create component** → Data only, extends BaseComponent
2. **Create system** → Logic only, extends BaseSystem
3. **Update render order** → Check system registration in main.lua
4. **Ensure proper layering** → RenderSystem before TextSystem

## Adding a New Component

1. **Create component file**:
   ```bash
   ./scripts/new-component.sh health
   ```

2. **Edit the component** (`components/health_component.lua`):
   ```lua
   function HealthComponent.new(data)
       local self = setmetatable(BaseComponent.new('health'), HealthComponent)
       self.current = data.current or 100
       self.max = data.max or 100
       return self
   end
   ```

3. **Register in component loader** (`ecs/component.lua`):
   ```lua
   Components.HealthComponent = require('components.health_component')
   ```

4. **Use in factory**:
   ```lua
   entity:addComponent(Components.HealthComponent.new({
       current = 50,
       max = 100
   }))
   ```

## Adding a New System

1. **Create system file**:
   ```bash
   ./scripts/new-system.sh damage
   ```

2. **Define component requirements**:
   ```lua
   function DamageSystem:new()
       local system = BaseSystem.new(self, {'health', 'hit'})
       return system
   end
   ```

3. **Add system logic**:
   ```lua
   function DamageSystem:update(dt)
       for _, entity in ipairs(self.entities) do
           local health = entity:getComponent('health')
           local hit = entity:getComponent('hit')
           
           health.current = health.current - hit.damage
           entity:removeComponent('hit')  -- Process once
       end
   end
   ```

4. **Register in main.lua**:
   ```lua
   Systems.DamageSystem:init(gameWorld)
   gameWorld:addSystem(Systems.DamageSystem)
   ```

## Adding Visual Effects

### Particle Effect Example:
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
```

## Modifying Game Physics

### Change Target Movement Speed:
```lua
-- In factories/dot_factory.lua
entity:addComponent(Components.MovementComponent.new({
    speed = 150,  -- Adjust this value (pixels/second)
    target_x = 400,
    target_y = 300
}))
```

### Adjust Dartboard Shake:
```lua
-- In behaviors/dartboard_behavior.lua
dartBoardEntity:addComponent(Components.ShakeComponent.new({
    intensity = 15,  -- Shake distance in pixels
    duration = 0.5,  -- Shake duration in seconds
    decay_rate = 5
}))
```

## Debugging Techniques

### 1. Add Debug Rendering:
```lua
-- In any render system
function MySystem:render()
    if DEBUG_MODE then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.circle('line', entity.x, entity.y, 50)
    end
end
```

### 2. Entity Inspector:
```lua
-- Debug helper function
function inspectEntity(entity)
    print("Entity ID:", entity.id)
    for name, component in pairs(entity.components) do
        print("  Component:", name)
        for k, v in pairs(component) do
            if k ~= "type" then
                print("    ", k, "=", v)
            end
        end
    end
end
```

### 3. System Performance Tracking:
```lua
-- Wrap system update
local start_time = love.timer.getTime()
system:update(dt)
local elapsed = love.timer.getTime() - start_time
if elapsed > 0.001 then  -- Log if > 1ms
    print("Slow system:", system.name, elapsed * 1000, "ms")
end
```

## Testing Patterns

### Component Test:
```lua
-- tests/components/health_test.lua
local HealthComponent = require('components.health_component')

-- Test initialization
local health = HealthComponent.new({current = 50, max = 100})
assert(health.current == 50, "Current health should be 50")
assert(health.max == 100, "Max health should be 100")

-- Test defaults
local default_health = HealthComponent.new({})
assert(default_health.current == 100, "Default current should be 100")
```

### System Test:
```lua
-- tests/systems/damage_test.lua
local World = require('ecs.world')
local DamageSystem = require('systems.damage_system')

-- Setup
local world = World.new()
local system = DamageSystem:new()
system:init(world)

-- Create test entity
local entity = world:createEntity()
entity:addComponent(HealthComponent.new({current = 100}))
entity:addComponent(HitComponent.new({damage = 25}))

-- Process
system:update(0.016)

-- Verify
local health = entity:getComponent('health')
assert(health.current == 75, "Health should be reduced to 75")
```

## Performance Optimization

### 1. Component Pooling:
```lua
-- Create a pool for frequently created/destroyed components
local TextComponentPool = {}
function TextComponentPool:get(data)
    local component = table.remove(self) or TextComponent.new({})
    -- Reset component with new data
    return component
end

function TextComponentPool:release(component)
    -- Clear component data
    table.insert(self, component)
end
```

### 2. Spatial Indexing:
```lua
-- For collision detection with many entities
local grid = {}  -- Spatial hash grid
local CELL_SIZE = 100

function addToGrid(entity, x, y)
    local cellX = math.floor(x / CELL_SIZE)
    local cellY = math.floor(y / CELL_SIZE)
    local key = cellX .. "," .. cellY
    
    grid[key] = grid[key] or {}
    table.insert(grid[key], entity)
end
```