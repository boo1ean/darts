-- =============================================================================
-- PER-ENTITY SHAKE SYSTEM
-- =============================================================================
local System = require("ecs.base_system")

-- Per-Entity Shake System
local ShakeSystem = System.new("ShakeSystem", { "Transform", "Shake" })

function ShakeSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local shake = entity:getComponent("Shake")
            local movement = entity:getComponent("Movement")

            -- Only shake if entity doesn't have movement OR movement is stopped
            local shouldShake = not movement or movement.stopped

            if transform and shake and shouldShake then
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

return ShakeSystem
