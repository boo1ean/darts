-- Configuration
local Config = {
    DOT_SIZE = 10,
    DOT_SPEED = 500,
    CIRCLE_RADIUS = 100,
    CIRCLE_DURATION = 3,
    LINE_DURATION = 2,
    TRANSITION_DURATION = 0.5,
    PULSE_SPEED = 0.3,  -- Pulses per second
    PULSE_MIN_RATIO = 0.1,  -- Minimum size as ratio of default (0.1 = 10% of default)
    CIRCLE_WEIGHT = 0.7,  -- How much circular movement influences (0-1)
    LINE_WEIGHT = 0.3    -- How much linear movement influences (0-1)
}

-- Game state
local GameState = {
    windowWidth = 0,
    windowHeight = 0,
    imageX = 0,
    imageY = 0,
    scaledWidth = 0,
    scaledHeight = 0,
    scale = 1,
    time = 0  -- Global time for pulsing
}

-- Dot state
local Dot = {
    x = 0,
    y = 0,
    targetX = 0,
    targetY = 0,
    centerX = 0,
    centerY = 0,
    angle = 0,
    moveTime = 0,
    moveDuration = 0,
    transitionTime = 0,
    currentSize = 0,  -- Current pulsing size
    -- Combined movement parameters
    circleX = 0,
    circleY = 0,
    lineX = 0,
    lineY = 0,
    -- Smooth transition parameters
    oldCenterX = 0,
    oldCenterY = 0,
    oldTargetX = 0,
    oldTargetY = 0,
    oldAngle = 0,
    transitionProgress = 0
}

-- Assets
local Assets = {
    image = nil
}

function love.load()
    loadAssets()
    calculateDimensions()
    initializeDot()
end

function loadAssets()
    Assets.image = love.graphics.newImage("assets/board.png")
end

function calculateDimensions()
    -- Get window dimensions
    GameState.windowWidth = love.graphics.getWidth()
    GameState.windowHeight = love.graphics.getHeight()
    
    -- Get image dimensions
    local imageWidth = Assets.image:getWidth()
    local imageHeight = Assets.image:getHeight()
    
    -- Calculate scale to fit image within window while maintaining aspect ratio
    local scaleX = GameState.windowWidth / imageWidth
    local scaleY = GameState.windowHeight / imageHeight
    GameState.scale = math.min(scaleX, scaleY)
    
    -- Calculate centered position
    GameState.scaledWidth = imageWidth * GameState.scale
    GameState.scaledHeight = imageHeight * GameState.scale
    GameState.imageX = (GameState.windowWidth - GameState.scaledWidth) / 2
    GameState.imageY = (GameState.windowHeight - GameState.scaledHeight) / 2
end

function initializeDot()
    -- Set dot center to image center
    Dot.centerX = GameState.imageX + GameState.scaledWidth / 2
    Dot.centerY = GameState.imageY + GameState.scaledHeight / 2
    Dot.x = Dot.centerX
    Dot.y = Dot.centerY
    Dot.targetX = Dot.x
    Dot.targetY = Dot.y
    Dot.angle = 0
    Dot.moveTime = 0
    Dot.moveDuration = Config.CIRCLE_DURATION
    Dot.transitionTime = 0
    Dot.currentSize = Config.DOT_SIZE
    
    -- Initialize combined movement positions
    Dot.circleX = Dot.x
    Dot.circleY = Dot.y
    Dot.lineX = Dot.x
    Dot.lineY = Dot.y
    
    -- Initialize transition parameters
    Dot.oldCenterX = Dot.centerX
    Dot.oldCenterY = Dot.centerY
    Dot.oldTargetX = Dot.targetX
    Dot.oldTargetY = Dot.targetY
    Dot.oldAngle = Dot.angle
    Dot.transitionProgress = 0
    
    -- Set initial targets
    generateNewTargets()
end

function love.update(dt)
    GameState.time = GameState.time + dt
    updateDotMovement(dt)
    updateDotPulse(dt)
end

function updateDotPulse(dt)
    -- Calculate pulsing size using sine wave
    local pulseValue = math.sin(GameState.time * Config.PULSE_SPEED * math.pi * 2)
    local pulseRatio = (pulseValue + 1) / 2  -- Convert from [-1,1] to [0,1]
    
    -- Interpolate between minimum and maximum size
    local minSize = Config.DOT_SIZE * Config.PULSE_MIN_RATIO
    Dot.currentSize = minSize + (Config.DOT_SIZE - minSize) * pulseRatio
end

function updateDotMovement(dt)
    Dot.moveTime = Dot.moveTime + dt
    
    -- Check if current movement phase is complete
    if Dot.moveTime >= Dot.moveDuration then
        startNewTargetTransition()
        Dot.moveTime = 0
    end
    
    -- Update transition progress
    if Dot.transitionProgress < 1 then
        Dot.transitionProgress = Dot.transitionProgress + dt / Config.TRANSITION_DURATION
        if Dot.transitionProgress > 1 then
            Dot.transitionProgress = 1
        end
    end
    
    -- Update both circular and linear components
    updateCircularComponent(dt)
    updateLinearComponent(dt)
    
    -- Combine the movements
    combineMovements()
end

function startNewTargetTransition()
    -- Store old positions for smooth transition
    Dot.oldCenterX = Dot.centerX
    Dot.oldCenterY = Dot.centerY
    Dot.oldTargetX = Dot.targetX
    Dot.oldTargetY = Dot.targetY
    Dot.oldAngle = Dot.angle
    
    -- Generate new targets
    generateNewTargets()
    
    -- Reset transition
    Dot.transitionProgress = 0
end

function generateNewTargets()
    -- Get image center
    local imageCenterX = GameState.imageX + GameState.scaledWidth / 2
    local imageCenterY = GameState.imageY + GameState.scaledHeight / 2
    
    -- Generate new circular center that will make the circle pass through image center
    -- Calculate a position that, when combined with the circle radius, will include the center
    local angle = math.random() * math.pi * 2
    local distance = math.random() * (Config.CIRCLE_RADIUS * 0.8)  -- Keep within 80% of radius
    Dot.centerX = imageCenterX + math.cos(angle) * distance
    Dot.centerY = imageCenterY + math.sin(angle) * distance
    Dot.angle = math.random() * math.pi * 2
    
    -- Generate new linear target that will pass through image center
    -- Calculate a target on the opposite side of the center from current position
    local currentX = Dot.x
    local currentY = Dot.y
    
    -- Calculate direction from current position to center
    local dirX = imageCenterX - currentX
    local dirY = imageCenterY - currentY
    local length = math.sqrt(dirX * dirX + dirY * dirY)
    
    if length > 0 then
        -- Normalize direction
        dirX = dirX / length
        dirY = dirY / length
        
        -- Place target on the opposite side of center, within image bounds
        local targetDistance = math.random() * (GameState.scaledWidth * 0.3) + 50
        Dot.targetX = imageCenterX + dirX * targetDistance
        Dot.targetY = imageCenterY + dirY * targetDistance
        
        -- Ensure target stays within image bounds
        Dot.targetX = math.max(GameState.imageX, math.min(GameState.imageX + GameState.scaledWidth, Dot.targetX))
        Dot.targetY = math.max(GameState.imageY, math.min(GameState.imageY + GameState.scaledHeight, Dot.targetY))
    else
        -- Fallback if current position is at center
        Dot.targetX = GameState.imageX + math.random() * GameState.scaledWidth
        Dot.targetY = GameState.imageY + math.random() * GameState.scaledHeight
    end
    
    -- Randomize duration slightly
    Dot.moveDuration = Config.CIRCLE_DURATION + (math.random() - 0.5) * 1
end

function updateCircularComponent(dt)
    local progress = Dot.moveTime / Dot.moveDuration
    
    -- Interpolate between old and new center during transition
    local currentCenterX = Dot.oldCenterX + (Dot.centerX - Dot.oldCenterX) * Dot.transitionProgress
    local currentCenterY = Dot.oldCenterY + (Dot.centerY - Dot.oldCenterY) * Dot.transitionProgress
    
    -- Interpolate angle smoothly
    local currentAngle = Dot.oldAngle + (Dot.angle - Dot.oldAngle) * Dot.transitionProgress
    local finalAngle = currentAngle + progress * math.pi * 2
    
    Dot.circleX = currentCenterX + math.cos(finalAngle) * Config.CIRCLE_RADIUS
    Dot.circleY = currentCenterY + math.sin(finalAngle) * Config.CIRCLE_RADIUS
end

function updateLinearComponent(dt)
    -- Interpolate between old and new target during transition
    local currentTargetX = Dot.oldTargetX + (Dot.targetX - Dot.oldTargetX) * Dot.transitionProgress
    local currentTargetY = Dot.oldTargetY + (Dot.targetY - Dot.oldTargetY) * Dot.transitionProgress
    
    -- Move linear component toward interpolated target
    Dot.lineX = Dot.lineX + (currentTargetX - Dot.lineX) * (dt * Config.DOT_SPEED / 100)
    Dot.lineY = Dot.lineY + (currentTargetY - Dot.lineY) * (dt * Config.DOT_SPEED / 100)
end

function combineMovements()
    -- Combine circular and linear movements using weighted average
    Dot.x = Dot.circleX * Config.CIRCLE_WEIGHT + Dot.lineX * Config.LINE_WEIGHT
    Dot.y = Dot.circleY * Config.CIRCLE_WEIGHT + Dot.lineY * Config.LINE_WEIGHT
end

function love.draw()
    drawImage()
    drawDot()
end

function drawImage()
    love.graphics.draw(Assets.image, GameState.imageX, GameState.imageY, 0, GameState.scale, GameState.scale)
end

function drawDot()
    love.graphics.setColor(1, 0, 0, 1)  -- Red color
    love.graphics.circle("fill", Dot.x, Dot.y, Dot.currentSize)
    love.graphics.setColor(1, 1, 1, 1)  -- Reset to white
end
