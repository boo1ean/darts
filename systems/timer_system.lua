-- =============================================================================
-- TIMER SYSTEM
-- =============================================================================
local System = require('ecs.base_system')

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

return TimerSystem 
