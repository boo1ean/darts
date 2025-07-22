-- Test for StatDisplay Component
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local StatDisplayComponent = require("components.stat_display_component")

describe("StatDisplay Component", function()
    describe("initialization", function()
        it("creates component with default values", function()
            local statDisplay = StatDisplayComponent.new()

            assert.are.equal("StatDisplay", statDisplay.type)
            assert.are.equal("Stat", statDisplay.label)
            assert.are.equal("value", statDisplay.valueKey)
            assert.are.equal(0, statDisplay.x)
            assert.are.equal(0, statDisplay.y)
            assert.are.equal(16, statDisplay.fontSize)
            assert.are.same({ 1, 1, 1, 1 }, statDisplay.color)
            assert.are.equal("integer", statDisplay.format)
            assert.are.equal(1, statDisplay.decimalPlaces)
            assert.are.equal(0, statDisplay.displayedValue)
            assert.are.equal(0, statDisplay.targetValue)
            assert.are.equal(5.0, statDisplay.interpolationSpeed)
        end)

        it("creates component with custom label and valueKey", function()
            local statDisplay = StatDisplayComponent.new("Total Score", "totalScore")

            assert.are.equal("Total Score", statDisplay.label)
            assert.are.equal("totalScore", statDisplay.valueKey)
        end)

        it("creates component with custom position", function()
            local statDisplay = StatDisplayComponent.new("Hit Count", "hitCount", 100, 200)

            assert.are.equal(100, statDisplay.x)
            assert.are.equal(200, statDisplay.y)
        end)

        it("creates component with custom font size", function()
            local statDisplay = StatDisplayComponent.new("Average", "avg", 0, 0, 24)

            assert.are.equal(24, statDisplay.fontSize)
        end)

        it("creates component with custom format", function()
            local statDisplay = StatDisplayComponent.new("Average", "avg", 0, 0, 16, "decimal")

            assert.are.equal("decimal", statDisplay.format)
        end)
    end)

    describe("properties", function()
        it("allows property modification", function()
            local statDisplay = StatDisplayComponent.new()

            statDisplay.label = "Modified Label"
            statDisplay.displayedValue = 42
            statDisplay.targetValue = 100
            statDisplay.interpolationSpeed = 10.0

            assert.are.equal("Modified Label", statDisplay.label)
            assert.are.equal(42, statDisplay.displayedValue)
            assert.are.equal(100, statDisplay.targetValue)
            assert.are.equal(10.0, statDisplay.interpolationSpeed)
        end)

        it("has correct component type", function()
            local statDisplay = StatDisplayComponent.new()
            assert.are.equal("StatDisplay", statDisplay.type)
        end)
    end)

    describe("value formatting", function()
        it("supports integer format", function()
            local statDisplay = StatDisplayComponent.new("Score", "score", 0, 0, 16, "integer")
            assert.are.equal("integer", statDisplay.format)
        end)

        it("supports decimal format", function()
            local statDisplay = StatDisplayComponent.new("Average", "avg", 0, 0, 16, "decimal")
            assert.are.equal("decimal", statDisplay.format)
        end)

        it("supports custom decimal places", function()
            local statDisplay = StatDisplayComponent.new("Precision", "prec", 0, 0, 16, "decimal")
            statDisplay.decimalPlaces = 3
            assert.are.equal(3, statDisplay.decimalPlaces)
        end)
    end)
end)
