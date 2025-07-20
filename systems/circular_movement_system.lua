-- =============================================================================
-- CIRCULAR MOVEMENT SYSTEM
-- =============================================================================
local System = require('ecs.base_system')

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

return CircularMovementSystem 
