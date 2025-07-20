-- =============================================================================
-- MOVEMENT SYSTEM
-- =============================================================================
local System = require('ecs.base_system')

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

return MovementSystem 
