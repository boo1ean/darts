-- =============================================================================
-- TARGET GENERATION SYSTEM
-- =============================================================================
local System = require('ecs.base_system')
local DartBoardBehavior = require('behaviors.dartboard_behavior')

-- Target Generation System
local TargetGenerationSystem = System.new("TargetGenerationSystem", {"Movement", "CircularMovement", "LinearMovement", "CosineMovement"})

function TargetGenerationSystem:init(world)
    self.world = world  -- Store reference to world for accessing dart board
end

function TargetGenerationSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local movement = entity:getComponent("Movement")
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            local cosine = entity:getComponent("CosineMovement")
            
            -- Safety check: only process if all components exist and movement is not stopped
            if movement and circular and linear and cosine and not movement.stopped then
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
    local cosine = entity:getComponent("CosineMovement")
    local movement = entity:getComponent("Movement")
    
    -- Store previous values
    circular.previousCenterX = circular.centerX
    circular.previousCenterY = circular.centerY
    circular.previousAngle = circular.angle
    linear.previousTargetX = linear.targetX
    linear.previousTargetY = linear.targetY
    
    -- Randomize cosine movement parameters for variety
    cosine:randomizeParameters()
    
    -- Get dart board center and bounds for movement targets
    local dartBoard = DartBoardBehavior.findDartBoard(self.world)
    local bounds = DartBoardBehavior.getBounds(dartBoard)
    local centerX, centerY = DartBoardBehavior.getCenter(dartBoard)
    
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minY = bounds.minY
    local maxY = bounds.maxY
    
    -- Generate random targets within board bounds
    -- Center passage is now guaranteed by the movement system itself
    circular.centerX = minX + math.random() * (maxX - minX)
    circular.centerY = minY + math.random() * (maxY - minY)
    circular.angle = math.random() * math.pi * 2
    
    linear.targetX = minX + math.random() * (maxX - minX)
    linear.targetY = minY + math.random() * (maxY - minY)
    
    print("Entity", entity.id, "- new random targets generated with cosine wave (center passage guaranteed by movement)")
    
    movement.moveDuration = 3 + (math.random() - 0.5) * 1
    movement.transitionProgress = 0
    
    -- Reset start position for new movement cycle
    movement.startX = nil
    movement.startY = nil
    
    -- Reset cosine time for new wave cycle
    cosine.time = 0
end

return TargetGenerationSystem 
