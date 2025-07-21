# Architecture Improvements for Darts Game

## 1. Event System Implementation

### Current Issue
Systems are tightly coupled and communicate through direct method calls.

### Proposed Solution
```lua
-- Centralized event dispatcher
EventBus = {
    listeners = {},
    emit = function(self, event, data)
        for _, listener in ipairs(self.listeners[event] or {}) do
            listener(data)
        end
    end,
    on = function(self, event, callback)
        self.listeners[event] = self.listeners[event] or {}
        table.insert(self.listeners[event], callback)
    end
}
```

### Benefits
- Decoupled systems
- Easier testing
- Plugin architecture support

## 2. Component Pool Pattern

### Current Issue
Components are created and garbage collected frequently, causing GC pressure.

### Proposed Solution
```lua
ComponentPool = {
    pools = {},
    get = function(self, componentType, ...)
        local pool = self.pools[componentType] or {}
        if #pool > 0 then
            local component = table.remove(pool)
            component:reset(...)
            return component
        end
        return componentType.new(...)
    end,
    release = function(self, component)
        table.insert(self.pools[component.type], component)
    end
}
```

## 3. System Priority and Execution Order

### Current Issue
System execution order is implicit based on addition order.

### Proposed Solution
```lua
SystemPriority = {
    Input = 100,
    Physics = 200,
    Movement = 300,
    Collision = 400,
    Scoring = 500,
    Animation = 600,
    Rendering = 700,
    UI = 800
}

-- Sort systems by priority
function World:sortSystems()
    table.sort(self.systems, function(a, b)
        return (a.priority or 999) < (b.priority or 999)
    end)
end
```

## 4. State Machine for Game Flow

### Current Issue
Game state is managed ad-hoc without clear transitions.

### Proposed Solution
```lua
GameStates = {
    MENU = "menu",
    PLAYING = "playing",
    PAUSED = "paused",
    GAME_OVER = "game_over"
}

StateMachine = {
    current = GameStates.MENU,
    transitions = {
        [GameStates.MENU] = {GameStates.PLAYING},
        [GameStates.PLAYING] = {GameStates.PAUSED, GameStates.GAME_OVER},
        [GameStates.PAUSED] = {GameStates.PLAYING, GameStates.MENU},
        [GameStates.GAME_OVER] = {GameStates.MENU, GameStates.PLAYING}
    },
    
    canTransition = function(self, to)
        local allowed = self.transitions[self.current]
        for _, state in ipairs(allowed or {}) do
            if state == to then return true end
        end
        return false
    end,
    
    transition = function(self, to)
        if self:canTransition(to) then
            self.current = to
            EventBus:emit("state_changed", {from = self.current, to = to})
        end
    end
}
```

## 5. Resource Manager

### Current Issue
Resources are loaded inline without caching or management.

### Proposed Solution
```lua
ResourceManager = {
    images = {},
    fonts = {},
    sounds = {},
    
    loadImage = function(self, path)
        if not self.images[path] then
            self.images[path] = love.graphics.newImage(path)
        end
        return self.images[path]
    end,
    
    getFont = function(self, size)
        local key = "default_" .. size
        if not self.fonts[key] then
            self.fonts[key] = love.graphics.newFont(size)
        end
        return self.fonts[key]
    end,
    
    unload = function(self, resourceType, key)
        if self[resourceType] and self[resourceType][key] then
            self[resourceType][key] = nil
        end
    end
}
```

## 6. Spatial Indexing for Efficient Queries

### Current Issue
Finding entities near a position requires checking all entities.

### Proposed Solution
```lua
SpatialIndex = {
    grid = {},
    cellSize = 50,
    
    getKey = function(self, x, y)
        local gx = math.floor(x / self.cellSize)
        local gy = math.floor(y / self.cellSize)
        return gx .. "," .. gy
    end,
    
    insert = function(self, entity, x, y)
        local key = self:getKey(x, y)
        self.grid[key] = self.grid[key] or {}
        table.insert(self.grid[key], entity)
    end,
    
    query = function(self, x, y, radius)
        local results = {}
        local cells = math.ceil(radius / self.cellSize)
        
        for dx = -cells, cells do
            for dy = -cells, cells do
                local key = self:getKey(x + dx * self.cellSize, y + dy * self.cellSize)
                for _, entity in ipairs(self.grid[key] or {}) do
                    table.insert(results, entity)
                end
            end
        end
        
        return results
    end
}
```

## 7. Component Dependencies and Validation

### Current Issue
No validation of component dependencies.

### Proposed Solution
```lua
ComponentDependencies = {
    Movement = {"Transform"},
    Render = {"Transform"},
    CircularMovement = {"Transform", "Movement"},
    LinearMovement = {"Transform", "Movement"},
    CosineMovement = {"Transform", "Movement"}
}

function Entity:validateComponents()
    for component, deps in pairs(ComponentDependencies) do
        if self:hasComponent(component) then
            for _, dep in ipairs(deps) do
                assert(self:hasComponent(dep), 
                    component .. " requires " .. dep)
            end
        end
    end
end

-- Call in world:addComponentToEntity
function World:addComponentToEntity(entity, componentType, component)
    entity:addComponent(componentType, component)
    entity:validateComponents()  -- Validate after adding
    -- ... rest of method
end
```

## 8. System Communication via Messages

### Current Issue
Systems directly access and modify world state.

### Proposed Solution
```lua
SystemMessages = {
    ENTITY_HIT = "entity_hit",
    SCORE_CHANGED = "score_changed",
    DART_THROWN = "dart_thrown",
    POWER_UP_COLLECTED = "power_up_collected"
}

-- Example usage in ScoringSystem
function ScoringSystem:processHit(entity, x, y)
    local points = self:calculatePoints(distance)
    
    self.world:sendMessage(SystemMessages.SCORE_CHANGED, {
        entity = entity,
        score = points,
        position = {x = x, y = y},
        total = self.world.gameState.totalScore
    })
    
    -- Other systems can listen for this message
end
```

## 9. Entity Archetypes and Templates

### Current Issue
Entity creation involves repetitive component setup.

### Proposed Solution
```lua
Archetypes = {
    MovingDot = {
        components = {
            "Transform",
            "Movement",
            "CircularMovement",
            "LinearMovement",
            "CosineMovement",
            "Render",
            "Pulse"
        },
        defaults = {
            Movement = {speed = 500, movementType = "combined"},
            Render = {shape = "circle", size = 10, color = {1,0,0,1}},
            Pulse = {speed = 0.2, minRatio = 0.1}
        }
    },
    
    ScoreText = {
        components = {"Transform", "Text"},
        defaults = {
            Text = {fontSize = 24, duration = 1.3, animationType = "popup"}
        }
    }
}

function EntityFactory.createFromArchetype(world, archetypeName, overrides)
    local archetype = Archetypes[archetypeName]
    local entity = world:createEntity()
    
    for _, compName in ipairs(archetype.components) do
        local defaults = archetype.defaults[compName] or {}
        local overrideValues = overrides[compName] or {}
        
        -- Merge defaults with overrides
        local params = {}
        for k, v in pairs(defaults) do
            params[k] = overrideValues[k] or v
        end
        
        local component = Components[compName].new(params)
        world:addComponentToEntity(entity, compName, component)
    end
    
    return entity
end
```

## 10. Performance Monitoring and Optimization

### Current Issue
No visibility into system performance.

### Proposed Solution
```lua
PerformanceMonitor = {
    metrics = {},
    
    startTimer = function(self, name)
        self.metrics[name] = self.metrics[name] or {
            calls = 0,
            totalTime = 0,
            maxTime = 0
        }
        self.metrics[name].startTime = love.timer.getTime()
    end,
    
    endTimer = function(self, name)
        local metric = self.metrics[name]
        if metric and metric.startTime then
            local elapsed = love.timer.getTime() - metric.startTime
            metric.calls = metric.calls + 1
            metric.totalTime = metric.totalTime + elapsed
            metric.maxTime = math.max(metric.maxTime, elapsed)
            metric.avgTime = metric.totalTime / metric.calls
        end
    end,
    
    report = function(self)
        for name, metric in pairs(self.metrics) do
            print(string.format("%s: %.2fms avg, %.2fms max (%d calls)",
                name, metric.avgTime * 1000, metric.maxTime * 1000, metric.calls))
        end
    end
}

-- Usage in systems
function System:update(dt)
    PerformanceMonitor:startTimer(self.name)
    -- ... system logic ...
    PerformanceMonitor:endTimer(self.name)
end
```

## 11. Configuration Management

### Current Issue
Configuration values scattered throughout codebase.

### Proposed Solution
```lua
GameConfig = {
    movement = {
        dotSpeed = 500,
        circleRadius = 100,
        circleSpeed = 3,
        transitionDuration = 0.5,
        cosineAmplitude = 30,
        cosineFrequency = 2
    },
    
    scoring = {
        zones = {
            {radius = 15, points = 100, name = "bullseye"},
            {radius = 30, points = 75, name = "inner"},
            {radius = 50, points = 50, name = "middle"},
            {radius = 80, points = 25, name = "outer"},
            {radius = 120, points = 10, name = "edge"},
            {radius = 150, points = 5, name = "rim"}
        }
    },
    
    visual = {
        dotSize = 10,
        pulseSpeed = 0.2,
        pulseMinRatio = 0.1,
        shakeIntensity = 8,
        shakeDuration = 0.15
    },
    
    -- Load from file
    load = function(self, filepath)
        local file = io.open(filepath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local config = loadstring("return " .. content)()
            -- Merge with defaults
            self:merge(config)
        end
    end
}
```

## 12. Debug and Development Tools

### Current Issue
Limited debugging capabilities.

### Proposed Solution
```lua
DebugSystem = {
    enabled = false,
    overlays = {
        entityBounds = false,
        systemStats = false,
        spatialGrid = false,
        componentList = false
    },
    
    draw = function(self)
        if not self.enabled then return end
        
        if self.overlays.entityBounds then
            self:drawEntityBounds()
        end
        
        if self.overlays.systemStats then
            self:drawSystemStats()
        end
        
        -- ... other overlays
    end,
    
    drawEntityBounds = function(self)
        love.graphics.setColor(0, 1, 0, 0.3)
        for _, entity in ipairs(self.world.entities) do
            local transform = entity:getComponent("Transform")
            local render = entity:getComponent("Render")
            if transform and render then
                love.graphics.circle("line", transform.x, transform.y, render.size + 5)
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end,
    
    log = function(self, level, message)
        if self.enabled then
            print(string.format("[%s] %s: %s", os.date("%H:%M:%S"), level, message))
        end
    end
}
```

## Implementation Priority

1. **High Priority**
   - Resource Manager (fixes memory leak)
   - System Priority/Ordering
   - Component Dependencies

2. **Medium Priority**
   - Event System
   - State Machine
   - Configuration Management

3. **Low Priority**
   - Spatial Indexing
   - Performance Monitoring
   - Debug Tools

These improvements would significantly enhance code maintainability, performance, and extensibility while preserving the benefits of the ECS architecture.