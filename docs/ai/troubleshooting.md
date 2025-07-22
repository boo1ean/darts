# Troubleshooting Guide

## Common Issues

### "Component not found" Error
**Symptoms**: System can't find component, entity:getComponent() returns nil
**Solutions**:
1. Check component is registered in `ecs/component.lua`
2. Verify component name matches exactly (case-sensitive)
3. Ensure component was added to entity before system processes it
4. Check factory creates component correctly

**Example Fix**:
```lua
-- In ecs/component.lua
Components.HealthComponent = require('components.health_component')

-- In factory
entity:addComponent(Components.HealthComponent.new({current = 100}))
```

### "System not processing entities"
**Symptoms**: System:update() called but entities array is empty
**Solutions**:
1. Verify system is added to world in `main.lua`
2. Check system's required components match entity's components
3. Ensure system:init(world) was called
4. Verify entities have ALL required components

**Example Fix**:
```lua
-- System requires both components
function DamageSystem:new()
    return BaseSystem.new(self, {'health', 'hit'})
end

-- Entity must have both
entity:addComponent(Components.HealthComponent.new({}))
entity:addComponent(Components.HitComponent.new({}))
```

### "Visual glitches or rendering issues"
**Symptoms**: Entities not visible, wrong render order, flickering
**Solutions**:
1. Check system processing order in `main.lua`
2. Verify RenderSystem runs after logic systems
3. Ensure TextSystem runs last for UI overlay
4. Check Love2D coordinate system (0,0 is top-left)

**System Order**:
```lua
-- Correct order in main.lua
world:addSystem(Systems.TargetGenerationSystem)
world:addSystem(Systems.CombinedMovementSystem)
-- ... other logic systems ...
world:addSystem(Systems.RenderSystem)  -- Near end
world:addSystem(Systems.TextSystem)    -- Last
```

### "Tests failing"
**Symptoms**: `./scripts/test.sh` reports failures
**Solutions**:
1. Run `./scripts/lint.sh` first - fix all linting errors
2. Check test setup in `tests/helpers/test_helper.lua`
3. Verify Love2D mock in `tests/helpers/love_mock.lua`
4. Ensure test isolation (no global state leaks)

**Debug Steps**:
```bash
# Run specific test file
busted tests/unit/components/health_component_spec.lua

# Run with verbose output
busted --verbose

# Check linting first
./scripts/lint.sh
```

### "Script execution failures"
**Symptoms**: `./scripts/*.sh` commands fail
**Solutions**:
1. Check script permissions: `chmod +x scripts/*.sh`
2. Verify dependencies installed (Love2D, luacheck, busted)
3. Run `./scripts/setup.sh` to install dependencies
4. Check PATH includes Lua tools

**Dependency Check**:
```bash
# Check if tools are installed
which love
which luacheck
which busted
which luarocks
```

## Development Workflow Issues

### "Breaking ECS patterns"
**Symptoms**: Components contain logic, systems store state
**Solutions**:
1. Move all logic from components to systems
2. Remove persistent state from systems
3. Use world reference only in system:init()
4. Store data only in components

**Wrong**:
```lua
-- DON'T: Logic in component
function HealthComponent:takeDamage(amount)
    self.current = self.current - amount
end

-- DON'T: State in system
function DamageSystem:new()
    self.totalDamage = 0  -- State storage
end
```

**Right**:
```lua
-- DO: Logic in system
function DamageSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        local health = entity:getComponent('health')
        local hit = entity:getComponent('hit')
        health.current = health.current - hit.damage
    end
end
```

### "Entity creation in wrong places"
**Symptoms**: Entities created in systems, performance issues
**Solutions**:
1. Use factories for all entity creation
2. Create entities in behaviors, not systems
3. Use tag components to trigger entity creation
4. Batch entity operations

**Pattern**:
```lua
-- In behavior or main loop
local newEntity = DotFactory.createMovingDot(x, y)
world:addEntity(newEntity)

-- NOT in systems during update()
```

### "Performance problems"
**Symptoms**: FPS drops, slow system execution
**Solutions**:
1. Profile systems: wrap update() with timer
2. Minimize component lookups in loops
3. Use spatial indexing for collision detection
4. Pool frequently created/destroyed entities

**Profiling**:
```lua
local start = love.timer.getTime()
system:update(dt)
local elapsed = love.timer.getTime() - start
if elapsed > 0.001 then
    print("Slow system:", system.name, elapsed * 1000, "ms")
end
```

## Emergency Procedures

### "Game won't start"
1. Check `main.lua` for syntax errors
2. Verify all require() paths are correct
3. Run `love --version` to check Love2D installation
4. Check console output for error messages

### "Tests completely broken"
1. Backup current changes: `git stash`
2. Reset to working state: `git checkout HEAD~1`
3. Run `./scripts/test.sh` to verify baseline
4. Apply changes incrementally

### "Unknown error patterns"
1. Enable debug mode: `DEBUG_MODE = true` in `config.lua`
2. Add debug prints: `print("Debug:", entity.id, component)`
3. Use entity inspector: create `inspectEntity(entity)` function
4. Isolate issue: create minimal reproduction case

## Getting Help

### Before Asking for Help
1. Run through this troubleshooting guide
2. Check `docs/ai/` documentation
3. Verify you followed architecture patterns
4. Test with minimal reproduction case

### Information to Provide
- Exact error message
- Steps to reproduce
- Output of `./scripts/test.sh`
- Output of `./scripts/lint.sh`
- Recent changes made
- Current git commit hash