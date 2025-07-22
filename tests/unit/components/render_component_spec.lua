-- Test for Render Component
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local RenderComponent = require("components.render_component")

describe("Render Component", function()
    describe("initialization", function()
        it("creates component with default values", function()
            local render = RenderComponent.new()

            assert.are.equal("Render", render.type)
            assert.are.same({ 1, 1, 1, 1 }, render.color)
            assert.are.equal(10, render.size)
            assert.are.equal("circle", render.shape)
        end)

        it("creates component with custom color", function()
            local render = RenderComponent.new({ 1, 0, 0, 0.5 })

            assert.are.same({ 1, 0, 0, 0.5 }, render.color)
            assert.are.equal(10, render.size)
            assert.are.equal("circle", render.shape)
        end)

        it("creates component with custom color and size", function()
            local render = RenderComponent.new({ 0, 1, 0, 1 }, 20)

            assert.are.same({ 0, 1, 0, 1 }, render.color)
            assert.are.equal(20, render.size)
            assert.are.equal("circle", render.shape)
        end)

        it("creates component with all parameters", function()
            local render = RenderComponent.new({ 0.5, 0.5, 0.5, 1 }, 15, "square")

            assert.are.same({ 0.5, 0.5, 0.5, 1 }, render.color)
            assert.are.equal(15, render.size)
            assert.are.equal("square", render.shape)
        end)
    end)

    describe("properties", function()
        it("allows property modification", function()
            local render = RenderComponent.new()

            render.color = { 0, 0, 1, 0.5 }
            render.size = 25
            render.shape = "triangle"

            assert.are.same({ 0, 0, 1, 0.5 }, render.color)
            assert.are.equal(25, render.size)
            assert.are.equal("triangle", render.shape)
        end)
    end)
end)
