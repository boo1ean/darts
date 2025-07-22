-- Test for Transform Component
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local Components = require("ecs.component")

describe("TransformComponent", function()
    describe("initialization", function()
        it("creates transform with default values", function()
            local transform = Components.Transform.new()

            assert.are.equal(0, transform.x)
            assert.are.equal(0, transform.y)
            assert.are.equal(0, transform.rotation)
            assert.are.equal(1, transform.scale)
            assert.are.equal("Transform", transform.type)
        end)

        it("creates transform with specified values", function()
            local transform = Components.Transform.new(10, 20, 1.5, 2)

            assert.are.equal(10, transform.x)
            assert.are.equal(20, transform.y)
            assert.are.equal(1.5, transform.rotation)
            assert.are.equal(2, transform.scale)
        end)
    end)

    describe("component properties", function()
        it("has correct component type", function()
            local transform = Components.Transform.new(5, 5)
            assert.are.equal("Transform", transform.type)
        end)

        it("allows modification of position", function()
            local transform = Components.Transform.new(0, 0)

            transform.x = 100
            transform.y = 200

            assert.are.equal(100, transform.x)
            assert.are.equal(200, transform.y)
        end)
    end)
end)
