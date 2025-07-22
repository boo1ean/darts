-- Integration test for Game Behavior
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local GameBehavior = require("behaviors.game_behavior")
local DartBoardBehavior = require("behaviors.dartboard_behavior")
local EntityFactory = require("factories")

describe("GameBehavior Integration", function()
    local world, dartBoard

    before_each(function()
        world = test_helper.create_test_world()
        -- Create a mock image for the dartboard
        local mockImage = love.graphics.newImage("assets/board.png")
        dartBoard = EntityFactory.createDartBoard(world, mockImage)
    end)

    describe("dart throwing", function()
        it("handles dart throw with no moving dots", function()
            local stoppedCount = GameBehavior.throwDart(world, dartBoard)

            assert.are.equal(0, stoppedCount)
            assert.is_true(DartBoardBehavior.isShaking(dartBoard))
        end)

        it("spawns new dot after creating one", function()
            -- First spawn a dot
            GameBehavior.spawnNewDot(world)
            local initialCount = #world.entities

            -- Throw dart (should stop the dot and spawn a new one)
            local stoppedCount = GameBehavior.throwDart(world, dartBoard)

            -- Should have stopped 1 dot and increased entity count by 1 (stopped dot stays + new dot)
            assert.are.equal(1, stoppedCount)
            assert.are.equal(initialCount + 1, #world.entities)
        end)
    end)

    describe("game statistics", function()
        it("returns correct game stats", function()
            GameBehavior.spawnNewDot(world)

            local stats = GameBehavior.getStats(world)

            assert.are.equal(1, stats.movingDots)
            assert.are.equal(0, stats.stoppedDots)
            assert.are.equal(1, stats.totalDots)
            assert.is_true(stats.dartBoard)
        end)

        it("tracks game state changes", function()
            -- Initial state
            assert.are.equal(0, world.gameState.totalScore)
            assert.are.equal(0, world.gameState.hitCount)

            -- Should not crash when printing stats
            assert.has_no.errors(function()
                GameBehavior.printStats(world)
            end)
        end)
    end)
end)
