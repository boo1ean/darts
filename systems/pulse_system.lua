-- =============================================================================
-- PULSE SYSTEM
-- =============================================================================
local System = require("ecs.base_system")

-- Pulse System
local PulseSystem = System.new("PulseSystem", { "Render", "Pulse" })

function PulseSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local render = entity:getComponent("Render")
            local pulse = entity:getComponent("Pulse")
            local movement = entity:getComponent("Movement")

            -- Safety check: only process if both components exist and movement is not stopped
            if render and pulse and (not movement or not movement.stopped) then
                pulse.time = pulse.time + dt

                -- Calculate pulsing size using sine wave
                local pulseValue = math.sin(pulse.time * pulse.speed * math.pi * 2)
                local pulseRatio = (pulseValue + 1) / 2 -- Convert from [-1,1] to [0,1]

                -- Interpolate between minimum and maximum size
                local minSize = pulse.maxSize * pulse.minRatio
                render.size = minSize + (pulse.maxSize - minSize) * pulseRatio
            end
        end
    end
end

return PulseSystem
