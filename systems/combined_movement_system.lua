-- =============================================================================
-- COMBINED MOVEMENT SYSTEM
-- =============================================================================
local System = require('ecs.base_system')
local DartBoardBehavior = require('behaviors.dartboard_behavior')

-- Combined Movement System (circular + linear + cosine) - Now only handles movement
local CombinedMovementSystem = System.new("CombinedMovementSystem", {"Transform", "CircularMovement", "LinearMovement", "CosineMovement", "Movement"})

function CombinedMovementSystem:init(world)
    self.world = world  -- Store reference to world for accessing dart board
end

function CombinedMovementSystem:update(dt)
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            local movement = entity:getComponent("Movement")
            
            local cosine = entity:getComponent("CosineMovement")
            
            -- Safety check: only process if all components exist and movement is not stopped
            if transform and circular and linear and cosine and movement and not movement.stopped then
                -- Update transition progress
                if movement.transitionProgress < 1 then
                    movement.transitionProgress = movement.transitionProgress + dt / 0.5
                    movement.transitionProgress = math.min(movement.transitionProgress, 1)
                end
                
                self:updateCombinedMovement(entity, dt)
                
                -- Debug: Check if entity is passing through center
                DartBoardBehavior.checkCenterPass(self.world, entity)
            end
        end
    end
end

function CombinedMovementSystem:generateNewTargets(entity)
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
    
    movement.moveDuration = 3 + (math.random() - 0.5) * 1
    movement.transitionProgress = 0
    
    -- Reset start position for new movement cycle
    movement.startX = nil
    movement.startY = nil
    
    -- Reset cosine time for new wave cycle
    cosine.time = 0
end

function CombinedMovementSystem:updateCombinedMovement(entity, dt)
    local transform = entity:getComponent("Transform")
    local circular = entity:getComponent("CircularMovement")
    local linear = entity:getComponent("LinearMovement")
    local cosine = entity:getComponent("CosineMovement")
    local movement = entity:getComponent("Movement")
    
    -- Get center position
    local centerX, centerY = DartBoardBehavior.getCenter(DartBoardBehavior.findDartBoard(self.world))
    
    -- Calculate movement progress (0 to 1)
    local progress = movement.moveTime / movement.moveDuration
    
    -- Update cosine time for wave calculations
    cosine.time = cosine.time + dt
    
    -- Store the starting position when movement begins
    if not movement.startX then
        movement.startX = transform.x
        movement.startY = transform.y
    end
    
    -- Calculate end position by blending circular and linear targets
    local endX, endY
    local currentTargetX = linear.previousTargetX + (linear.targetX - linear.previousTargetX) * movement.transitionProgress
    local currentTargetY = linear.previousTargetY + (linear.targetY - linear.previousTargetY) * movement.transitionProgress
    
    local currentCenterX = circular.previousCenterX + (circular.centerX - circular.previousCenterX) * movement.transitionProgress
    local currentCenterY = circular.previousCenterY + (circular.centerY - circular.previousCenterY) * movement.transitionProgress
    local currentAngle = circular.previousAngle + (circular.angle - circular.previousAngle) * movement.transitionProgress
    local endAngle = currentAngle + math.pi * 2  -- Complete one rotation
    local circularEndX = currentCenterX + math.cos(endAngle) * circular.radius
    local circularEndY = currentCenterY + math.sin(endAngle) * circular.radius
    
    -- Blend the two end positions
    endX = circularEndX * 0.5 + currentTargetX * 0.5
    endY = circularEndY * 0.5 + currentTargetY * 0.5
    
    -- GUARANTEE center passage with two-phase movement:
    -- Phase 1 (0.0 to 0.5): Start → Center
    -- Phase 2 (0.5 to 1.0): Center → End
    local baseX, baseY
    if progress <= 0.5 then
        -- First half: interpolate from start to center
        local phase1Progress = progress * 2  -- 0 to 1
        baseX = movement.startX + (centerX - movement.startX) * phase1Progress
        baseY = movement.startY + (centerY - movement.startY) * phase1Progress
    else
        -- Second half: interpolate from center to end
        local phase2Progress = (progress - 0.5) * 2  -- 0 to 1
        baseX = centerX + (endX - centerX) * phase2Progress
        baseY = centerY + (endY - centerY) * phase2Progress
    end
    
    -- Calculate cosine wave offsets with interpolated parameters
    local currentAmplitudeX = cosine.previousAmplitudeX + (cosine.amplitudeX - cosine.previousAmplitudeX) * movement.transitionProgress
    local currentAmplitudeY = cosine.previousAmplitudeY + (cosine.amplitudeY - cosine.previousAmplitudeY) * movement.transitionProgress
    local currentFrequencyX = cosine.previousFrequencyX + (cosine.frequencyX - cosine.previousFrequencyX) * movement.transitionProgress
    local currentFrequencyY = cosine.previousFrequencyY + (cosine.frequencyY - cosine.previousFrequencyY) * movement.transitionProgress
    local currentPhaseX = cosine.previousPhaseX + (cosine.phaseX - cosine.previousPhaseX) * movement.transitionProgress
    local currentPhaseY = cosine.previousPhaseY + (cosine.phaseY - cosine.previousPhaseY) * movement.transitionProgress
    
    -- Apply cosine wave modulation
    local cosOffsetX = math.cos(cosine.time * currentFrequencyX + currentPhaseX) * currentAmplitudeX
    local cosOffsetY = math.sin(cosine.time * currentFrequencyY + currentPhaseY) * currentAmplitudeY  -- Use sin for Y to create varied patterns
    
    -- Apply final position with cosine wave modulation
    transform.x = baseX + cosOffsetX
    transform.y = baseY + cosOffsetY
end

return CombinedMovementSystem 
