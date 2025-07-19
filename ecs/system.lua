-- =============================================================================
-- SYSTEM BASE CLASS
-- =============================================================================
local System = {}
System.__index = System

function System.new(systemType, requiredComponents)
    local self = setmetatable({}, System)
    self.type = systemType
    self.requiredComponents = requiredComponents or {}
    self.entities = {}
    return self
end

function System:addEntity(entity)
    if self:canProcessEntity(entity) then
        table.insert(self.entities, entity)
    end
end

function System:removeEntity(entity)
    for i, e in ipairs(self.entities) do
        if e.id == entity.id then
            table.remove(self.entities, i)
            break
        end
    end
end

function System:canProcessEntity(entity)
    for _, componentType in ipairs(self.requiredComponents) do
        if not entity:hasComponent(componentType) then
            return false
        end
    end
    return true
end

function System:update(dt)
    -- Override in subclasses
end

-- =============================================================================
-- SPECIFIC SYSTEMS
-- =============================================================================

-- Movement System
local MovementSystem = System.new("MovementSystem", {"Transform", "Movement"})
function MovementSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local movement = entity:getComponent("Movement")
            
            movement.moveTime = movement.moveTime + dt
            
            if movement.moveTime >= movement.moveDuration then
                self:generateNewTarget(entity)
                movement.moveTime = 0
            end
            
            self:updateMovement(entity, dt)
        end
    end
end

function MovementSystem:generateNewTarget(entity)
    local movement = entity:getComponent("Movement")
    local transform = entity:getComponent("Transform")
    
    -- Store previous target for smooth transition
    movement.previousTargetX = movement.targetX
    movement.previousTargetY = movement.targetY
    
    -- Generate new random target
    movement.targetX = math.random() * 800
    movement.targetY = math.random() * 600
    movement.moveDuration = 3 + (math.random() - 0.5) * 1
end

function MovementSystem:updateMovement(entity, dt)
    local transform = entity:getComponent("Transform")
    local movement = entity:getComponent("Movement")
    
    -- Smooth movement toward target
    local dx = movement.targetX - transform.x
    local dy = movement.targetY - transform.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance > 0 then
        local speed = movement.speed * dt
        transform.x = transform.x + (dx / distance) * speed
        transform.y = transform.y + (dy / distance) * speed
    end
end

-- Pulse System
local PulseSystem = System.new("PulseSystem", {"Render", "Pulse"})
function PulseSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local render = entity:getComponent("Render")
            local pulse = entity:getComponent("Pulse")
            
            -- Safety check: only process if both components exist
            if render and pulse then
                pulse.time = pulse.time + dt
                
                -- Calculate pulsing size using sine wave
                local pulseValue = math.sin(pulse.time * pulse.speed * math.pi * 2)
                local pulseRatio = (pulseValue + 1) / 2  -- Convert from [-1,1] to [0,1]
                
                -- Interpolate between minimum and maximum size
                local minSize = pulse.maxSize * pulse.minRatio
                render.size = minSize + (pulse.maxSize - minSize) * pulseRatio
            end
        end
    end
end

-- Circular Movement System
local CircularMovementSystem = System.new("CircularMovementSystem", {"Transform", "CircularMovement"})
function CircularMovementSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local circular = entity:getComponent("CircularMovement")
            
            -- Update angle
            circular.angle = circular.angle + dt * 2
            
            -- Calculate position
            transform.x = circular.centerX + math.cos(circular.angle) * circular.radius
            transform.y = circular.centerY + math.sin(circular.angle) * circular.radius
        end
    end
end

-- Target Generation System
local TargetGenerationSystem = System.new("TargetGenerationSystem", {"Movement", "CircularMovement", "LinearMovement"})
function TargetGenerationSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local movement = entity:getComponent("Movement")
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            
            -- Safety check: only process if all components exist
            if movement and circular and linear then
                movement.moveTime = movement.moveTime + dt
                
                if movement.moveTime >= movement.moveDuration then
                    self:generateNewTargets(entity)
                    movement.moveTime = 0
                end
            end
        end
    end
end

function TargetGenerationSystem:generateNewTargets(entity)
    local circular = entity:getComponent("CircularMovement")
    local linear = entity:getComponent("LinearMovement")
    local movement = entity:getComponent("Movement")
    
    -- Store previous values
    circular.previousCenterX = circular.centerX
    circular.previousCenterY = circular.centerY
    circular.previousAngle = circular.angle
    linear.previousTargetX = linear.targetX
    linear.previousTargetY = linear.targetY
    
    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Calculate image bounds (assuming image is centered and scaled)
    local imageWidth = 800  -- Approximate image width
    local imageHeight = 600 -- Approximate image height
    local scaleX = windowWidth / imageWidth
    local scaleY = windowHeight / imageHeight
    local scale = math.min(scaleX, scaleY)
    
    local scaledWidth = imageWidth * scale
    local scaledHeight = imageHeight * scale
    local imageX = (windowWidth - scaledWidth) / 2
    local imageY = (windowHeight - scaledHeight) / 2
    
    -- Constrain movement to image area with some margin
    local margin = 50
    local minX = imageX + margin
    local maxX = imageX + scaledWidth - margin
    local minY = imageY + margin
    local maxY = imageY + scaledHeight - margin
    
    -- Generate new targets within image bounds
    circular.centerX = minX + math.random() * (maxX - minX)
    circular.centerY = minY + math.random() * (maxY - minY)
    circular.angle = math.random() * math.pi * 2
    
    linear.targetX = minX + math.random() * (maxX - minX)
    linear.targetY = minY + math.random() * (maxY - minY)
    
    movement.moveDuration = 3 + (math.random() - 0.5) * 1
    movement.transitionProgress = 0
end

-- Combined Movement System (circular + linear) - Now only handles movement
local CombinedMovementSystem = System.new("CombinedMovementSystem", {"Transform", "CircularMovement", "LinearMovement", "Movement"})
function CombinedMovementSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            local movement = entity:getComponent("Movement")
            
            -- Safety check: only process if all components exist
            if transform and circular and linear and movement then
                -- Update transition progress
                if movement.transitionProgress < 1 then
                    movement.transitionProgress = movement.transitionProgress + dt / 0.5
                    movement.transitionProgress = math.min(movement.transitionProgress, 1)
                end
                
                self:updateCombinedMovement(entity, dt)
            end
        end
    end
end

function CombinedMovementSystem:generateNewTargets(entity)
    local circular = entity:getComponent("CircularMovement")
    local linear = entity:getComponent("LinearMovement")
    local movement = entity:getComponent("Movement")
    
    -- Store previous values
    circular.previousCenterX = circular.centerX
    circular.previousCenterY = circular.centerY
    circular.previousAngle = circular.angle
    linear.previousTargetX = linear.targetX
    linear.previousTargetY = linear.targetY
    
    -- Get window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Calculate image bounds (assuming image is centered and scaled)
    local imageWidth = 800  -- Approximate image width
    local imageHeight = 600 -- Approximate image height
    local scaleX = windowWidth / imageWidth
    local scaleY = windowHeight / imageHeight
    local scale = math.min(scaleX, scaleY)
    
    local scaledWidth = imageWidth * scale
    local scaledHeight = imageHeight * scale
    local imageX = (windowWidth - scaledWidth) / 2
    local imageY = (windowHeight - scaledHeight) / 2
    
    -- Constrain movement to image area with some margin
    local margin = 50
    local minX = imageX + margin
    local maxX = imageX + scaledWidth - margin
    local minY = imageY + margin
    local maxY = imageY + scaledHeight - margin
    
    -- Generate new targets within image bounds
    circular.centerX = minX + math.random() * (maxX - minX)
    circular.centerY = minY + math.random() * (maxY - minY)
    circular.angle = math.random() * math.pi * 2
    
    linear.targetX = minX + math.random() * (maxX - minX)
    linear.targetY = minY + math.random() * (maxY - minY)
    
    movement.moveDuration = 3 + (math.random() - 0.5) * 1
    movement.transitionProgress = 0
end

function CombinedMovementSystem:updateCombinedMovement(entity, dt)
    local transform = entity:getComponent("Transform")
    local circular = entity:getComponent("CircularMovement")
    local linear = entity:getComponent("LinearMovement")
    local movement = entity:getComponent("Movement")
    
    -- Interpolate circular center
    local currentCenterX = circular.previousCenterX + (circular.centerX - circular.previousCenterX) * movement.transitionProgress
    local currentCenterY = circular.previousCenterY + (circular.centerY - circular.previousCenterY) * movement.transitionProgress
    
    -- Interpolate angle
    local currentAngle = circular.previousAngle + (circular.angle - circular.previousAngle) * movement.transitionProgress
    local finalAngle = currentAngle + (movement.moveTime / movement.moveDuration) * math.pi * 2
    
    -- Calculate circular position
    local circleX = currentCenterX + math.cos(finalAngle) * circular.radius
    local circleY = currentCenterY + math.sin(finalAngle) * circular.radius
    
    -- Interpolate linear target
    local currentTargetX = linear.previousTargetX + (linear.targetX - linear.previousTargetX) * movement.transitionProgress
    local currentTargetY = linear.previousTargetY + (linear.targetY - linear.previousTargetY) * movement.transitionProgress
    
    -- Move linear component toward target
    local linearX = linear.previousTargetX + (currentTargetX - linear.previousTargetX) * (dt * movement.speed / 100)
    local linearY = linear.previousTargetY + (currentTargetY - linear.previousTargetY) * (dt * movement.speed / 100)
    
    -- Combine movements (70% circular, 30% linear)
    transform.x = circleX * 0.7 + linearX * 0.3
    transform.y = circleY * 0.7 + linearY * 0.3
end

-- Timer System (for delayed actions)
local TimerSystem = System.new("TimerSystem", {"Timer"})
function TimerSystem:init(world)
    self.world = world  -- Store reference to world for adding components
end

function TimerSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local timer = entity:getComponent("Timer")
            
            if timer and not timer.triggered then
                timer.time = timer.time + dt
                
                -- Debug: Print timer progress every 0.5 seconds
                if math.floor(timer.time * 2) > math.floor((timer.time - dt) * 2) then
                    print("Timer for entity", entity.id, ":", timer.time, "/", timer.delay, "->", timer.componentType)
                end
                
                if timer.time >= timer.delay then
                    print("Timer completed for entity", entity.id, "- adding component:", timer.componentType)
                    
                    -- Add the component directly
                    if timer.component and timer.componentType then
                        if self.world then
                            self.world:addComponentToEntity(entity, timer.componentType, timer.component)
                            print("Timer added", timer.componentType, "component to entity", entity.id, "via world")
                        else
                            entity:addComponent(timer.componentType, timer.component)
                            print("Timer added", timer.componentType, "component to entity", entity.id, "direct")
                        end
                        
                        -- Verify the component was added
                        if entity:hasComponent(timer.componentType) then
                            print(timer.componentType, "component successfully added to entity", entity.id)
                        else
                            print("ERROR:", timer.componentType, "component NOT added to entity", entity.id)
                        end
                    else
                        print("ERROR: Invalid component or componentType in timer for entity", entity.id)
                    end
                    
                    -- Mark as triggered and remove timer
                    timer.triggered = true
                    if self.world then
                        self.world:removeComponentFromEntity(entity, "Timer")
                    else
                        entity:removeComponent("Timer")
                    end
                end
            end
        end
    end
end

-- Per-Entity Shake System
local ShakeSystem = System.new("ShakeSystem", {"Transform", "Shake"})
function ShakeSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local shake = entity:getComponent("Shake")
            
            if transform and shake then
                if shake.time > 0 then
                    -- Store original position if not already stored
                    if shake.originalX == nil then
                        shake.originalX = transform.x
                        shake.originalY = transform.y
                    end
                    
                    shake.time = shake.time - dt
                    
                    -- Calculate shake intensity based on remaining time (fade out)
                    local intensity = (shake.time / shake.duration) * shake.intensity
                    
                    -- Random shake offset
                    shake.shakeX = (math.random() - 0.5) * 2 * intensity
                    shake.shakeY = (math.random() - 0.5) * 2 * intensity
                    
                    -- Apply shake to transform
                    transform.x = shake.originalX + shake.shakeX
                    transform.y = shake.originalY + shake.shakeY
                    
                    -- Stop shaking and restore original position when time is up
                    if shake.time <= 0 then
                        transform.x = shake.originalX
                        transform.y = shake.originalY
                        -- Remove the shake component when done
                        entity:removeComponent("Shake")
                    end
                end
            end
        end
    end
end

-- Screen Shake System (for global screen shake)
local ScreenShakeSystem = System.new("ScreenShakeSystem", {})
function ScreenShakeSystem:init()
    self.shakeTime = 0
    self.shakeDuration = 0.15
    self.shakeIntensity = 5
    self.shakeX = 0
    self.shakeY = 0
end

function ScreenShakeSystem:update(dt)
    if self.shakeTime > 0 then
        self.shakeTime = self.shakeTime - dt
        
        -- Calculate shake intensity based on remaining time (fade out)
        local intensity = (self.shakeTime / self.shakeDuration) * self.shakeIntensity
        
        -- Random shake offset
        self.shakeX = (math.random() - 0.5) * 2 * intensity
        self.shakeY = (math.random() - 0.5) * 2 * intensity
        
        -- Stop shaking when time is up
        if self.shakeTime <= 0 then
            self.shakeX = 0
            self.shakeY = 0
        end
    end
end

function ScreenShakeSystem:triggerShake()
    self.shakeTime = self.shakeDuration
end

function ScreenShakeSystem:getShakeOffset()
    return self.shakeX, self.shakeY
end

-- Initialize the shake system
ScreenShakeSystem:init()

-- Render System
local RenderSystem = System.new("RenderSystem", {"Transform", "Render"})
function RenderSystem:update(dt)
    -- Render system doesn't need update logic, just rendering
end

function RenderSystem:render()
    print("RenderSystem:render() called with", #self.entities, "entities")
    
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local render = entity:getComponent("Render")
            
            print("Rendering entity", entity.id, "at", transform.x, transform.y, "size:", render.size)
            
            love.graphics.setColor(render.color[1], render.color[2], render.color[3], render.color[4])
            
            if render.shape == "circle" then
                love.graphics.circle("fill", transform.x, transform.y, render.size)
                print("Drew circle at", transform.x, transform.y, "with size", render.size)
            elseif render.shape == "rectangle" then
                love.graphics.rectangle("fill", transform.x - render.size, transform.y - render.size, render.size * 2, render.size * 2)
            end
            
            love.graphics.setColor(1, 1, 1, 1)  -- Reset color
        end
    end
end

return {
    MovementSystem = MovementSystem,
    PulseSystem = PulseSystem,
    CircularMovementSystem = CircularMovementSystem,
    CombinedMovementSystem = CombinedMovementSystem,
    TargetGenerationSystem = TargetGenerationSystem,
    TimerSystem = TimerSystem,
    ShakeSystem = ShakeSystem,
    ScreenShakeSystem = ScreenShakeSystem,
    RenderSystem = RenderSystem
} 
