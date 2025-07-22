-- Test for Scoring System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local ScoringSystem = require("systems.scoring_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")
local World = require("ecs.world")

-- Mock DartBoardBehavior
package.loaded["behaviors.dartboard_behavior"] = {
    getCenterFromWorld = function()
        return 400, 300 -- Mock center position
    end,
}

describe("Scoring System", function()
    local system
    local world
    local entity

    before_each(function()
        system = ScoringSystem
        world = World.new()
        system:init(world)

        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(400, 300))
        entity:addComponent("Hit", Components.Hit.new())

        system.entities = {}
        system:addEntity(entity)
    end)

    after_each(function()
        system.entities = {}
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("ScoringSystem", system.type)
            assert.are.same({ "Transform", "Hit" }, system.requiredComponents)
        end)

        it("stores world reference", function()
            assert.are.equal(world, system.world)
        end)
    end)

    describe("calculatePoints", function()
        it("returns 100 points for bullseye (within 15 pixels)", function()
            assert.are.equal(100, system:calculatePoints(10))
            assert.are.equal(100, system:calculatePoints(15))
        end)

        it("returns 75 points for very close shots (16-30 pixels)", function()
            assert.are.equal(75, system:calculatePoints(20))
            assert.are.equal(75, system:calculatePoints(30))
        end)

        it("returns 50 points for close shots (31-50 pixels)", function()
            assert.are.equal(50, system:calculatePoints(40))
            assert.are.equal(50, system:calculatePoints(50))
        end)

        it("returns 25 points for medium shots (51-80 pixels)", function()
            assert.are.equal(25, system:calculatePoints(60))
            assert.are.equal(25, system:calculatePoints(80))
        end)

        it("returns 10 points for far shots (81-120 pixels)", function()
            assert.are.equal(10, system:calculatePoints(100))
            assert.are.equal(10, system:calculatePoints(120))
        end)

        it("returns 5 points for very far shots (121-150 pixels)", function()
            assert.are.equal(5, system:calculatePoints(130))
            assert.are.equal(5, system:calculatePoints(150))
        end)

        it("returns 0 points for shots beyond 150 pixels", function()
            assert.are.equal(0, system:calculatePoints(151))
            assert.are.equal(0, system:calculatePoints(200))
        end)
    end)

    describe("update", function()
        it("processes unprocessed hits", function()
            local hit = entity:getComponent("Hit")
            assert.is_false(hit.processed or false)

            system:update(0.1)

            assert.is_true(hit.processed)
        end)

        it("removes Hit component after processing", function()
            assert.is_true(entity:hasComponent("Hit"))

            system:update(0.1)

            assert.is_false(entity:hasComponent("Hit"))
        end)

        it("skips already processed hits", function()
            local hit = entity:getComponent("Hit")
            hit.processed = true

            local initialScore = world.gameState.totalScore

            system:update(0.1)

            assert.are.equal(initialScore, world.gameState.totalScore)
        end)

        it("skips inactive entities", function()
            entity:deactivate()

            local initialScore = world.gameState.totalScore

            system:update(0.1)

            assert.are.equal(initialScore, world.gameState.totalScore)
        end)
    end)

    describe("processHit", function()
        it("calculates score based on distance from center", function()
            -- Hit at center (400, 300)
            local scoreEntity = system:processHit(entity, 400, 300)
            assert.is_not_nil(scoreEntity)

            local score = scoreEntity:getComponent("Score")
            assert.is_not_nil(score)
            assert.are.equal(100, score.points) -- Bullseye
            assert.is_near(0, score.distanceFromCenter, 0.01)
        end)

        it("creates score text entity with correct components", function()
            local scoreEntity = system:processHit(entity, 430, 300)

            assert.is_true(scoreEntity:hasComponent("Transform"))
            assert.is_true(scoreEntity:hasComponent("Text"))
            assert.is_true(scoreEntity:hasComponent("Score"))

            local text = scoreEntity:getComponent("Text")
            assert.are.equal("+75", text.text) -- 30 pixels from center = 75 points
        end)

        it("shows MISS for zero point hits", function()
            local scoreEntity = system:processHit(entity, 600, 300)

            local text = scoreEntity:getComponent("Text")
            assert.are.equal("MISS", text.text)
        end)
    end)

    describe("createScoreText", function()
        it("uses gold color for bullseye", function()
            local scoreEntity = system:createScoreText(400, 300, 100, 0)
            local text = scoreEntity:getComponent("Text")
            assert.are.same({ 1, 1, 0, 1 }, text.color)
        end)

        it("uses green color for good shots", function()
            local scoreEntity = system:createScoreText(400, 300, 50, 40)
            local text = scoreEntity:getComponent("Text")
            assert.are.same({ 0, 1, 0, 1 }, text.color)
        end)

        it("updates world game state", function()
            local initialScore = world.gameState.totalScore
            local initialHits = world.gameState.hitCount

            system:createScoreText(400, 300, 50, 40)

            assert.are.equal(initialScore + 50, world.gameState.totalScore)
            assert.are.equal(initialHits + 1, world.gameState.hitCount)
        end)

        it("does not update stats for misses", function()
            local initialScore = world.gameState.totalScore
            local initialHits = world.gameState.hitCount

            system:createScoreText(600, 300, 0, 200)

            assert.are.equal(initialScore, world.gameState.totalScore)
            assert.are.equal(initialHits, world.gameState.hitCount)
        end)
    end)

    describe("getStats", function()
        it("returns current scoring statistics", function()
            world.gameState.totalScore = 150
            world.gameState.hitCount = 3

            local stats = system:getStats()

            assert.are.equal(150, stats.totalScore)
            assert.are.equal(3, stats.hitCount)
            assert.are.equal(50, stats.averageScore)
        end)

        it("handles zero hits correctly", function()
            local stats = system:getStats()

            assert.are.equal(0, stats.totalScore)
            assert.are.equal(0, stats.hitCount)
            assert.are.equal(0, stats.averageScore)
        end)
    end)

    describe("reset", function()
        it("resets scoring statistics", function()
            world.gameState.totalScore = 100
            world.gameState.hitCount = 2

            system:reset()

            assert.are.equal(0, world.gameState.totalScore)
            assert.are.equal(0, world.gameState.hitCount)
        end)
    end)
end)
