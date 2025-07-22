-- Test for StatDisplay System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local StatDisplaySystem = require("systems.stat_display_system")
local Entity = require("ecs.entity")
local StatDisplayComponent = require("components.stat_display_component")
local TransformComponent = require("components.transform_component")

describe("StatDisplay System", function()
    local system
    local entity
    local mockWorld
    
    before_each(function()
        system = StatDisplaySystem
        entity = Entity.new(1)
        
        -- Create a mock world with game state
        mockWorld = {
            gameState = {
                totalScore = 150,
                hitCount = 5,
            }
        }
        
        system:init(mockWorld)
        system.entities = {}
    end)
    
    after_each(function()
        system.entities = {}
        system.world = nil
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("StatDisplaySystem", system.type)
            assert.are.same({"StatDisplay", "Transform"}, system.requiredComponents)
        end)

        it("stores world reference when initialized", function()
            assert.are.equal(mockWorld, system.world)
        end)
    end)

    describe("update", function()
        it("updates target values from game state for totalScore", function()
            local statDisplay = StatDisplayComponent.new("Total Score", "totalScore")
            local transform = TransformComponent.new(0, 0)
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            system:update(0.016) -- One frame
            
            assert.are.equal(150, statDisplay.targetValue)
        end)

        it("updates target values from game state for hitCount", function()
            local statDisplay = StatDisplayComponent.new("Hit Count", "hitCount")
            local transform = TransformComponent.new(0, 0)
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            system:update(0.016) -- One frame
            
            assert.are.equal(5, statDisplay.targetValue)
        end)

        it("calculates average score correctly", function()
            local statDisplay = StatDisplayComponent.new("Average Score", "averageScore")
            local transform = TransformComponent.new(0, 0)
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            system:update(0.016) -- One frame
            
            assert.are.equal(30, statDisplay.targetValue) -- 150/5 = 30
        end)

        it("handles zero hitCount for average score", function()
            mockWorld.gameState.hitCount = 0
            local statDisplay = StatDisplayComponent.new("Average Score", "averageScore")
            local transform = TransformComponent.new(0, 0)
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            system:update(0.016) -- One frame
            
            assert.are.equal(0, statDisplay.targetValue)
        end)

        it("interpolates displayed value toward target", function()
            local statDisplay = StatDisplayComponent.new("Score", "totalScore")
            local transform = TransformComponent.new(0, 0)
            statDisplay.displayedValue = 0
            statDisplay.interpolationSpeed = 2.0
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            -- Call update to set target from game state (150)
            system:update(0.016)
            -- Now manually set displayed value back to 0 after target is set
            statDisplay.displayedValue = 0
            
            -- Call interpolate directly to test interpolation without updating target
            system:interpolateValue(statDisplay, 0.016) -- Small dt to see partial interpolation
            
            -- Should be closer to target but not equal (exponential interpolation)
            assert.is_true(statDisplay.displayedValue > 0)
            assert.is_true(statDisplay.displayedValue < 150) -- Target is 150 from game state
        end)

        it("sets displayed value equal to target when very close", function()
            -- Set a custom valueKey that won't be updated by the game state
            local statDisplay = StatDisplayComponent.new("Score", "customValue")
            local transform = TransformComponent.new(0, 0)
            statDisplay.targetValue = 100
            statDisplay.displayedValue = 99.995 -- Very close
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            system:update(0.016) -- One frame
            
            assert.are.equal(100, statDisplay.displayedValue)
        end)

        it("skips inactive entities", function()
            local statDisplay = StatDisplayComponent.new("Score", "totalScore")
            statDisplay.displayedValue = 50
            entity:addComponent("StatDisplay", statDisplay)
            entity.active = false
            system:addEntity(entity)
            
            system:update(0.016)
            
            -- Should not have updated target from game state
            assert.are.equal(0, statDisplay.targetValue)
        end)
    end)

    describe("formatValue", function()
        it("formats integer values correctly", function()
            local result = system:formatValue(42.8, "integer")
            assert.are.equal("42", result)
        end)

        it("formats decimal values with default precision", function()
            local result = system:formatValue(42.567, "decimal", 1)
            assert.are.equal("42.6", result)
        end)

        it("formats decimal values with custom precision", function()
            local result = system:formatValue(42.567, "decimal", 3)
            assert.are.equal("42.567", result)
        end)

        it("formats float values", function()
            local result = system:formatValue(42.567, "float", 2)
            assert.are.equal("42.57", result)
        end)

        it("handles unknown format types", function()
            local result = system:formatValue(42.567, "unknown")
            assert.are.equal("42.567", result)
        end)
    end)

    describe("render", function()
        before_each(function()
            -- Mock Love2D graphics functions for render tests
            love.graphics.getFont = function() return "mockFont" end
            love.graphics.newFont = function() return "newMockFont" end
            love.graphics.setFont = function() end
            love.graphics.setColor = function() end
            love.graphics.print = function() end
        end)

        it("renders stat display with correct formatting", function()
            local statDisplay = StatDisplayComponent.new("Test Score", "totalScore", 10, 20, 16, "integer")
            statDisplay.displayedValue = 123.7
            local transform = TransformComponent.new(10, 20)
            
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            system:addEntity(entity)
            
            -- Mock print function to capture output
            local printedText, printedX, printedY
            love.graphics.print = function(text, x, y)
                printedText = text
                printedX = x
                printedY = y
            end
            
            system:render()
            
            assert.are.equal("Test Score: 123", printedText)
            assert.are.equal(10, printedX)
            assert.are.equal(20, printedY)
        end)

        it("skips entities without required components", function()
            local statDisplay = StatDisplayComponent.new("Test", "test")
            entity:addComponent("StatDisplay", statDisplay)
            -- Missing Transform component
            system:addEntity(entity)
            
            local printCalled = false
            love.graphics.print = function() printCalled = true end
            
            system:render()
            
            assert.is_false(printCalled)
        end)

        it("skips inactive entities during render", function()
            local statDisplay = StatDisplayComponent.new("Test", "test")
            local transform = TransformComponent.new(0, 0)
            entity:addComponent("StatDisplay", statDisplay)
            entity:addComponent("Transform", transform)
            entity.active = false
            system:addEntity(entity)
            
            local printCalled = false
            love.graphics.print = function() printCalled = true end
            
            system:render()
            
            assert.is_false(printCalled)
        end)
    end)

    describe("multiple entities", function()
        it("processes multiple stat entities independently", function()
            local entity1 = Entity.new(1)
            local entity2 = Entity.new(2)
            
            local stat1 = StatDisplayComponent.new("Score 1", "totalScore")
            local stat2 = StatDisplayComponent.new("Score 2", "hitCount")
            local transform1 = TransformComponent.new(0, 0)
            local transform2 = TransformComponent.new(0, 20)
            
            entity1:addComponent("StatDisplay", stat1)
            entity1:addComponent("Transform", transform1)
            entity2:addComponent("StatDisplay", stat2)
            entity2:addComponent("Transform", transform2)
            
            system:addEntity(entity1)
            system:addEntity(entity2)
            
            system:update(0.016)
            
            assert.are.equal(150, stat1.targetValue) -- totalScore
            assert.are.equal(5, stat2.targetValue)   -- hitCount
        end)
    end)
end)