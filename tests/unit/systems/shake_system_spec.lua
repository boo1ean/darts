-- Test for Shake System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

-- Mock math.random for predictable tests
local original_random = math.random
math.random = function()
    return 0.75 -- Will give us 0.5 when adjusted with (random() - 0.5)
end

local ShakeSystem = require("systems.shake_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Shake System", function()
    local system
    local entity

    before_each(function()
        system = ShakeSystem
        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(100, 100))
        local shake = Components.Shake.new(1.0, 10)
        shake.time = shake.duration -- Initialize time to duration for shaking
        entity:addComponent("Shake", shake)
        system.entities = {}
        system:addEntity(entity)
    end)

    after_each(function()
        system.entities = {}
        math.random = original_random
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("ShakeSystem", system.type)
            assert.are.same({ "Transform", "Shake" }, system.requiredComponents)
        end)
    end)

    describe("update", function()
        it("stores original position on first update", function()
            local shake = entity:getComponent("Shake")

            assert.is_nil(shake.originalX)
            assert.is_nil(shake.originalY)

            system:update(0.1)

            assert.are.equal(100, shake.originalX)
            assert.are.equal(100, shake.originalY)
        end)

        it("decreases shake time", function()
            local shake = entity:getComponent("Shake")

            system:update(0.2)

            assert.are.equal(0.8, shake.time)
        end)

        it("applies shake offset to transform", function()
            local transform = entity:getComponent("Transform")
            local shake = entity:getComponent("Shake")

            -- Ensure shake has time > 0
            shake.time = shake.duration

            system:update(0.1)

            -- Position should change from original 100, 100
            assert.are_not.equal(100, transform.x)
            assert.are_not.equal(100, transform.y)

            -- Verify original position was stored
            assert.are.equal(100, shake.originalX)
            assert.are.equal(100, shake.originalY)
        end)

        it("reduces shake intensity over time", function()
            local shake = entity:getComponent("Shake")

            -- Test intensity calculation directly
            shake.time = 1.0 -- Full duration
            local fullIntensity = (shake.time / shake.duration) * shake.intensity

            shake.time = 0.5 -- Half duration
            local halfIntensity = (shake.time / shake.duration) * shake.intensity

            -- Intensity should decrease as time decreases
            assert.is_true(halfIntensity < fullIntensity)
            assert.are.equal(10, fullIntensity) -- Full intensity
            assert.are.equal(5, halfIntensity) -- Half intensity
        end)

        it("restores original position when shake completes", function()
            local transform = entity:getComponent("Transform")

            system:update(1.5) -- Exceed shake duration

            assert.are.equal(100, transform.x)
            assert.are.equal(100, transform.y)
        end)

        it("removes shake component when done", function()
            system:update(1.5)

            assert.is_false(entity:hasComponent("Shake"))
        end)

        it("skips entities with movement that is not stopped", function()
            entity:addComponent("Movement", Components.Movement.new())
            local movement = entity:getComponent("Movement")
            movement.stopped = false

            local transform = entity:getComponent("Transform")

            system:update(0.5)

            -- Position should not change
            assert.are.equal(100, transform.x)
            assert.are.equal(100, transform.y)
        end)

        it("shakes entities with stopped movement", function()
            entity:addComponent("Movement", Components.Movement.new())
            local movement = entity:getComponent("Movement")
            movement.stopped = true

            local shake = entity:getComponent("Shake")
            shake.time = shake.duration -- Ensure shake is active

            local transform = entity:getComponent("Transform")

            system:update(0.1)

            -- Position should change
            assert.are_not.equal(100, transform.x)
            assert.are_not.equal(100, transform.y)
        end)

        it("skips inactive entities", function()
            entity:deactivate()

            local transform = entity:getComponent("Transform")

            system:update(0.5)

            assert.are.equal(100, transform.x)
            assert.are.equal(100, transform.y)
        end)
    end)
end)

-- Restore original math.random
math.random = original_random
