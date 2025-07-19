-- =============================================================================
-- MAIN GAME FILE
-- =============================================================================

-- Load all modules
local Config = require('config')
local GameState = require('gameState')
local Dot = require('dot')
local Assets = require('assets')
local Initializer = require('initializer')
local MovementSystem = require('movementSystem')
local PulseSystem = require('pulseSystem')
local Renderer = require('renderer')

-- =============================================================================
-- LOVE2D CALLBACKS
-- =============================================================================
function love.load()
    Initializer.loadAssets(Assets)
    Initializer.calculateDimensions(GameState, Assets)
    Initializer.initializeDot(Dot, GameState)
end

function love.update(dt)
    GameState.time = GameState.time + dt
    MovementSystem.update(Dot, GameState, dt)
    PulseSystem.update(Dot, GameState, dt)
end

function love.draw()
    Renderer.drawImage(Assets, GameState)
    Renderer.drawDot(Dot)
end
