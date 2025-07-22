# Code Conventions

## Lua Style Guide

### Naming Conventions
- **Files**: snake_case (e.g., `movement_system.lua`)
- **Classes/Modules**: PascalCase (e.g., `MovementSystem`)
- **Functions**: camelCase (e.g., `getComponent`)
- **Variables**: snake_case (e.g., `player_health`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_SPEED`)

### Code Formatting
- **Indentation**: 4 spaces (no tabs)
- **Line length**: Max 100 characters
- **Blank lines**: Single blank line between functions
- **Comments**: Use `--` for single line, avoid block comments

### Module Structure
```lua
-- =============================================================================
-- MODULE NAME - Brief description
-- =============================================================================

local Dependencies = require('path.to.dependency')

local ModuleName = {}
ModuleName.__index = ModuleName

-- =============================================================================
-- CONSTRUCTOR
-- =============================================================================
function ModuleName.new(params)
    local self = setmetatable({}, ModuleName)
    -- Initialize
    return self
end

-- =============================================================================
-- PUBLIC METHODS
-- =============================================================================
function ModuleName:publicMethod()
    -- Implementation
end

-- =============================================================================
-- PRIVATE METHODS (if needed)
-- =============================================================================
local function privateHelper()
    -- Implementation
end

return ModuleName
```

## ECS Conventions

### Component Rules
1. Components contain ONLY data, no methods (except constructor)
2. All components extend BaseComponent
3. Component files named: `<name>_component.lua`
4. Constructor accepts single `data` table parameter

### System Rules
1. Systems contain ONLY logic, no persistent state
2. All systems extend BaseSystem
3. System files named: `<name>_system.lua`
4. Define required components in constructor
5. Use `init()` for world reference
6. Process entities in `update(dt)` or `render()`

### Entity Rules
1. Entities are created through factories
2. Never create entities directly in systems
3. Prefer tag components for triggering complex actions

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

## Error Handling
- Use assertions for programmer errors
- Return nil, error_message for expected failures
- Never use global error handlers
- Log errors during development only

## Performance Guidelines
- Avoid creating tables in update loops
- Cache component lookups when used multiple times
- Batch similar operations
- Profile before optimizing

## Testing Conventions
- Test files mirror source structure
- Test files named: `<name>_test.lua`
- One test file per module
- Use descriptive test names

## Documentation
- Document complex algorithms
- Add header comments to files
- Document component properties
- Keep comments concise and relevant

## Version Control
- Commit messages: "verb noun" (e.g., "Add health system")
- One feature per commit
- Run tests before committing
- Never commit debug prints