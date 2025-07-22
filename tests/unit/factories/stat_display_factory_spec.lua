-- Test for StatDisplay Factory
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local StatDisplayFactory = require("factories.stat_display_factory")
local World = require("ecs.world")

describe("StatDisplay Factory", function()
    local world
    
    before_each(function()
        world = World.new()
    end)

    describe("createStatDisplay", function()
        it("creates entity with StatDisplay and Transform components", function()
            local entity = StatDisplayFactory.createStatDisplay(
                world, "Test Stat", "testValue", 100, 200, 18, "decimal"
            )
            
            assert.is_not_nil(entity)
            assert.is_true(entity:hasComponent("StatDisplay"))
            assert.is_true(entity:hasComponent("Transform"))
            
            local statDisplay = entity:getComponent("StatDisplay")
            assert.are.equal("Test Stat", statDisplay.label)
            assert.are.equal("testValue", statDisplay.valueKey)
            assert.are.equal(100, statDisplay.x)
            assert.are.equal(200, statDisplay.y)
            assert.are.equal(18, statDisplay.fontSize)
            assert.are.equal("decimal", statDisplay.format)
            
            local transform = entity:getComponent("Transform")
            assert.are.equal(100, transform.x)
            assert.are.equal(200, transform.y)
        end)

        it("creates entity with default values when parameters omitted", function()
            local entity = StatDisplayFactory.createStatDisplay(world)
            
            local statDisplay = entity:getComponent("StatDisplay")
            assert.are.equal("Stat", statDisplay.label)
            assert.are.equal("value", statDisplay.valueKey)
            assert.are.equal(0, statDisplay.x)
            assert.are.equal(0, statDisplay.y)
            assert.are.equal(16, statDisplay.fontSize)
            assert.are.equal("integer", statDisplay.format)
        end)

        it("adds entity to world", function()
            local initialCount = #world.entities
            local entity = StatDisplayFactory.createStatDisplay(world, "Test", "test")
            
            assert.are.equal(initialCount + 1, #world.entities)
            
            -- Verify entity is in world
            local found = false
            for _, worldEntity in ipairs(world.entities) do
                if worldEntity.id == entity.id then
                    found = true
                    break
                end
            end
            assert.is_true(found)
        end)
    end)

    describe("convenience factory functions", function()
        it("createTotalScoreDisplay creates correct stat entity", function()
            local entity = StatDisplayFactory.createTotalScoreDisplay(world, 50, 100, 20)
            
            local statDisplay = entity:getComponent("StatDisplay")
            assert.are.equal("Total Score", statDisplay.label)
            assert.are.equal("totalScore", statDisplay.valueKey)
            assert.are.equal(50, statDisplay.x)
            assert.are.equal(100, statDisplay.y)
            assert.are.equal(20, statDisplay.fontSize)
            assert.are.equal("integer", statDisplay.format)
            
            local transform = entity:getComponent("Transform")
            assert.are.equal(50, transform.x)
            assert.are.equal(100, transform.y)
        end)

        it("createHitCountDisplay creates correct stat entity", function()
            local entity = StatDisplayFactory.createHitCountDisplay(world, 25, 75, 14)
            
            local statDisplay = entity:getComponent("StatDisplay")
            assert.are.equal("Hit Count", statDisplay.label)
            assert.are.equal("hitCount", statDisplay.valueKey)
            assert.are.equal(25, statDisplay.x)
            assert.are.equal(75, statDisplay.y)
            assert.are.equal(14, statDisplay.fontSize)
            assert.are.equal("integer", statDisplay.format)
        end)

        it("createAverageScoreDisplay creates correct stat entity", function()
            local entity = StatDisplayFactory.createAverageScoreDisplay(world, 10, 30, 16)
            
            local statDisplay = entity:getComponent("StatDisplay")
            assert.are.equal("Average Score", statDisplay.label)
            assert.are.equal("averageScore", statDisplay.valueKey)
            assert.are.equal(10, statDisplay.x)
            assert.are.equal(30, statDisplay.y)
            assert.are.equal(16, statDisplay.fontSize)
            assert.are.equal("decimal", statDisplay.format)
        end)

        it("convenience functions use default font size when not specified", function()
            local totalScoreEntity = StatDisplayFactory.createTotalScoreDisplay(world, 0, 0)
            local hitCountEntity = StatDisplayFactory.createHitCountDisplay(world, 0, 20)
            local averageEntity = StatDisplayFactory.createAverageScoreDisplay(world, 0, 40)
            
            -- All should use default font size when not specified
            assert.are.equal(16, totalScoreEntity:getComponent("StatDisplay").fontSize)
            assert.are.equal(16, hitCountEntity:getComponent("StatDisplay").fontSize)
            assert.are.equal(16, averageEntity:getComponent("StatDisplay").fontSize)
        end)
    end)

    describe("entity integration", function()
        it("creates entities with unique IDs", function()
            local entity1 = StatDisplayFactory.createTotalScoreDisplay(world, 0, 0)
            local entity2 = StatDisplayFactory.createHitCountDisplay(world, 0, 20)
            local entity3 = StatDisplayFactory.createAverageScoreDisplay(world, 0, 40)
            
            assert.are_not.equal(entity1.id, entity2.id)
            assert.are_not.equal(entity1.id, entity3.id)
            assert.are_not.equal(entity2.id, entity3.id)
        end)

        it("creates active entities", function()
            local entity = StatDisplayFactory.createStatDisplay(world, "Test", "test")
            assert.is_true(entity.active)
        end)
    end)
end)