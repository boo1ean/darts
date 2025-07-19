-- =============================================================================
-- INITIALIZATION
-- =============================================================================
local Config = require('config')
local Utils = require('utils')
local TargetGenerator = require('targetGenerator')

local Initializer = {}

function Initializer.loadAssets(assets)
    assets.image = love.graphics.newImage("assets/board.png")
end

function Initializer.calculateDimensions(gameState, assets)
    -- Get window dimensions
    gameState.window.width = love.graphics.getWidth()
    gameState.window.height = love.graphics.getHeight()
    
    -- Get image dimensions
    local imageWidth = assets.image:getWidth()
    local imageHeight = assets.image:getHeight()
    
    -- Calculate scale to fit image within window while maintaining aspect ratio
    local scaleX = gameState.window.width / imageWidth
    local scaleY = gameState.window.height / imageHeight
    gameState.image.scale = math.min(scaleX, scaleY)
    
    -- Calculate centered position and scaled dimensions
    gameState.image.width = imageWidth * gameState.image.scale
    gameState.image.height = imageHeight * gameState.image.scale
    gameState.image.x = (gameState.window.width - gameState.image.width) / 2
    gameState.image.y = (gameState.window.height - gameState.image.height) / 2
end

function Initializer.initializeDot(dot, gameState)
    local center = Utils.getImageCenter(gameState)
    
    -- Set initial position to image center
    dot.x = center.x
    dot.y = center.y
    dot.size = Config.DOT_SIZE
    
    -- Initialize movement components
    dot.circle.x = center.x
    dot.circle.y = center.y
    dot.circle.centerX = center.x
    dot.circle.centerY = center.y
    
    dot.line.x = center.x
    dot.line.y = center.y
    dot.line.targetX = center.x
    dot.line.targetY = center.y
    
    -- Initialize animation state
    dot.moveTime = 0
    dot.moveDuration = Config.CIRCLE_DURATION
    dot.transitionProgress = 0
    
    -- Initialize previous state
    dot.previous.centerX = center.x
    dot.previous.centerY = center.y
    dot.previous.targetX = center.x
    dot.previous.targetY = center.y
    dot.previous.angle = 0
    
    -- Generate initial targets
    TargetGenerator.generateNewTargets(dot, gameState)
end

return Initializer 
