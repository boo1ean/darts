-- =============================================================================
-- COMBINED MOVEMENT SYSTEM
-- =============================================================================
local System = require('ecs.base_system')

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
                -- Update transition progress - SMOOTH TRANSITIONS
                if movement.transitionProgress < 1 then
                    movement.transitionProgress = movement.transitionProgress + dt / 0.4   -- Smooth 0.4s transitions
                    movement.transitionProgress = math.min(movement.transitionProgress, 1)
                end
                
                -- Smooth and stable movement timing
                self:updateCombinedMovement(entity, dt)
                
                -- Debug: Check if entity is passing through center
                self:checkCenterPass(entity)
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
    
    -- Randomize cosine movement parameters for variety (ECS compliant - logic in system)
    self:randomizeCosineParameters(cosine)
    
    -- Get dart board center and bounds for movement targets
    local dartBoard = self:findDartBoard()
    local bounds = self:getDartBoardBounds(dartBoard)
    local centerX, centerY = self:getDartBoardCenter(dartBoard)
    
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
    
    movement.moveDuration = 1 + math.random() * 1  -- Random 1-2 seconds (was 2.5-3.5)
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
    local centerX, centerY = self:getDartBoardCenter(self:findDartBoard())
    
    -- Calculate movement progress (0 to 1)
    local progress = movement.moveTime / movement.moveDuration
    
    -- Update cosine time for wave calculations - SMOOTH AND STABLE
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
    
    -- GUARANTEE center passage with two-phase movement + CHAOS:
    -- Phase 1 (0.0 to 0.5): Start → Center (with chaos)
    -- Phase 2 (0.5 to 1.0): Center → End (with chaos)
    local baseX, baseY
    
    -- Calculate cosine factor first for use in path calculations
    local currentFactor = cosine.previousFactor + (cosine.factor - cosine.previousFactor) * movement.transitionProgress
    
    -- Add AGGRESSIVE curves for dramatic, organic paths with FACTOR influence
    local baseCurveIntensity = 5   -- Increased base curve intensity (was 3)
    local factorCurveIntensity = baseCurveIntensity * currentFactor  -- Make curve intensity factor-dependent
    local curveX = math.sin(progress * math.pi * 2) * factorCurveIntensity  -- X curve HEAVILY affected by factor
    local curveY = math.cos(progress * math.pi * 1.5) * factorCurveIntensity * 0.6  -- Y curve also affected but less
    
    if progress <= 0.5 then
        -- First half: interpolate from start to center with smooth curves
        local phase1Progress = progress * 2  -- 0 to 1
        -- Add smooth easing for fluid motion
        local easedProgress = phase1Progress * phase1Progress * (3.0 - 2.0 * phase1Progress)  -- Smoothstep
        baseX = movement.startX + (centerX - movement.startX) * easedProgress + curveX
        baseY = movement.startY + (centerY - movement.startY) * easedProgress + curveY
    else
        -- Second half: interpolate from center to end with smooth curves
        local phase2Progress = (progress - 0.5) * 2  -- 0 to 1
        -- Add smooth acceleration for fluid movement
        local easedProgress = phase2Progress * phase2Progress * (3.0 - 2.0 * phase2Progress)  -- Smoothstep
        baseX = centerX + (endX - centerX) * easedProgress + curveX
        baseY = centerY + (endY - centerY) * easedProgress + curveY
    end
    
    -- Apply AGGRESSIVE factor to X coordinate path for EXTREME movement patterns
    -- Factor 0.1 = ultra-narrow paths (-54px deviation), Factor 3.0 = ultra-wide paths (+120px deviation)
    local pathFactorInfluence = 60  -- AGGRESSIVE X deviation (was 20) - 3x more intense!
    local factorXOffset = (currentFactor - 1.0) * pathFactorInfluence * math.sin(progress * math.pi)
    baseX = baseX + factorXOffset  -- Modify X path coordinate directly
    
    -- Calculate cosine wave offsets with interpolated parameters
    local currentAmplitudeX = cosine.previousAmplitudeX + (cosine.amplitudeX - cosine.previousAmplitudeX) * movement.transitionProgress
    local currentAmplitudeY = cosine.previousAmplitudeY + (cosine.amplitudeY - cosine.previousAmplitudeY) * movement.transitionProgress
    local currentFrequencyX = cosine.previousFrequencyX + (cosine.frequencyX - cosine.previousFrequencyX) * movement.transitionProgress
    local currentFrequencyY = cosine.previousFrequencyY + (cosine.frequencyY - cosine.previousFrequencyY) * movement.transitionProgress
    local currentPhaseX = cosine.previousPhaseX + (cosine.phaseX - cosine.previousPhaseX) * movement.transitionProgress
    local currentPhaseY = cosine.previousPhaseY + (cosine.phaseY - cosine.previousPhaseY) * movement.transitionProgress
    
    -- Apply SMOOTH cosine wave modulation for fluid movement with FACTOR
    local cosOffsetX = math.cos(cosine.time * currentFrequencyX + currentPhaseX) * currentAmplitudeX * currentFactor
    local cosOffsetY = math.sin(cosine.time * currentFrequencyY + currentPhaseY) * currentAmplitudeY * currentFactor
    
    -- Apply final position with cosine wave modulation
    local finalX = baseX + cosOffsetX
    local finalY = baseY + cosOffsetY
    
    -- CLAMP to screen bounds to prevent invisibility
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local margin = 15  -- Keep dots slightly away from edges
    
    local clampedX = math.max(margin, math.min(screenWidth - margin, finalX))
    local clampedY = math.max(margin, math.min(screenHeight - margin, finalY))
    
    -- Debug: Log when clamping occurs (rarely)
    if (math.abs(clampedX - finalX) > 5 or math.abs(clampedY - finalY) > 5) and math.random() < 0.005 then
        print("Entity", entity.id, "clamped - smooth boundaries maintained")
    end
    
    transform.x = clampedX
    transform.y = clampedY
end

-- Find the dart board entity
function CombinedMovementSystem:findDartBoard()
    for _, entity in ipairs(self.world.entities) do
        if entity:hasComponent("Image") then
            return entity  -- Assuming only dart board has Image component
        end
    end
    return nil
end

-- Get dart board boundaries
function CombinedMovementSystem:getDartBoardBounds(dartBoard)
    if not dartBoard then
        -- Fallback to window bounds if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100
        }
    end
    
    local transform = dartBoard:getComponent("Transform")
    local image = dartBoard:getComponent("Image")
    
    if not transform or not image then
        -- Fallback if components missing
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return {
            minX = 100,
            maxX = windowWidth - 100,
            minY = 100,
            maxY = windowHeight - 100
        }
    end
    
    -- Calculate dart board bounds
    local scaledWidth = image.width * image.scaleX
    local scaledHeight = image.height * image.scaleY
    local halfWidth = scaledWidth / 2
    local halfHeight = scaledHeight / 2
    
    -- Add some margin to keep dots within the board area
    local margin = 50
    
    return {
        minX = transform.x - halfWidth + margin,
        maxX = transform.x + halfWidth - margin,
        minY = transform.y - halfHeight + margin,
        maxY = transform.y + halfHeight - margin
    }
end

-- Get the center position of the dart board
function CombinedMovementSystem:getDartBoardCenter(dartBoard)
    if not dartBoard then
        -- Fallback to window center if no dart board
        local windowWidth = love.graphics.getWidth()
        local windowHeight = love.graphics.getHeight()
        return windowWidth / 2, windowHeight / 2
    end
    
    local transform = dartBoard:getComponent("Transform")
    if transform then
        return transform.x, transform.y
    end
    
    -- Fallback to window center
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    return windowWidth / 2, windowHeight / 2
end

-- Check if a position is near the center (within threshold distance)
function CombinedMovementSystem:isNearCenter(x, y, threshold)
    threshold = threshold or 30  -- Default threshold of 30 pixels
    local centerX, centerY = self:getDartBoardCenter(self:findDartBoard())
    local distance = math.sqrt((x - centerX)^2 + (y - centerY)^2)
    return distance <= threshold
end

-- Debug function to track when entities pass through center
function CombinedMovementSystem:checkCenterPass(entity)
    local transform = entity:getComponent("Transform")
    local movement = entity:getComponent("Movement")
    if not transform or not movement then return false end
    
    -- Check if we're exactly at the center (50% progress)
    local progress = movement.moveTime / movement.moveDuration
    local isAtCenterPhase = math.abs(progress - 0.5) < 0.02  -- Within 2% of halfway point
    
    if isAtCenterPhase and self:isNearCenter(transform.x, transform.y, 15) then
        print("Entity", entity.id, "PASSING THROUGH CENTER at", math.floor(transform.x), math.floor(transform.y), "progress:", math.floor(progress * 100) .. "%")
        return true
    end
    return false
end

-- Randomize cosine movement parameters (ECS compliant - system contains logic)
function CombinedMovementSystem:randomizeCosineParameters(cosine)
    -- Store current as previous
    cosine.previousFactor = cosine.factor
    cosine.previousAmplitudeX = cosine.amplitudeX
    cosine.previousAmplitudeY = cosine.amplitudeY
    cosine.previousFrequencyX = cosine.frequencyX
    cosine.previousFrequencyY = cosine.frequencyY
    cosine.previousPhaseX = cosine.phaseX
    cosine.previousPhaseY = cosine.phaseY
    
    -- Generate new random parameters - AGGRESSIVE FACTOR RANGE
    cosine.factor = 0.1 + math.random() * 2.9     -- Random 0.1-3.0 (EXTREME intensity control)
    cosine.amplitudeX = 5 + math.random() * 25    -- Random 5-30 (AGGRESSIVE oscillation range)
    cosine.amplitudeY = 5 + math.random() * 25    -- Random 5-30 (AGGRESSIVE oscillation range)
    cosine.frequencyX = 0.5 + math.random() * 2.5 -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    cosine.frequencyY = 0.5 + math.random() * 2.5 -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    cosine.phaseX = math.random() * math.pi * 2
    cosine.phaseY = math.random() * math.pi * 2
    
    print("  AGGRESSIVE wave: Factor(" .. string.format("%.1f", cosine.factor) .. ") affects PATH+WAVES Amp(" .. math.floor(cosine.amplitudeX) .. "," .. math.floor(cosine.amplitudeY) .. ") Freq(" .. string.format("%.1f", cosine.frequencyX) .. "," .. string.format("%.1f", cosine.frequencyY) .. ") - EXTREME & FAST!")
end

return CombinedMovementSystem 
