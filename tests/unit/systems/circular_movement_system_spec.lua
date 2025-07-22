-- Test for Circular Movement System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local CircularMovementSystem = require("systems.circular_movement_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Circular Movement System", function()
    local system
    local entity

    before_each(function()
        system = CircularMovementSystem
        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(0, 0))
        -- radius, centerX, centerY, angle
        entity:addComponent("CircularMovement", Components.CircularMovement.new(50, 100, 100, 0))
        system.entities = {}
        system:addEntity(entity)
    end)

    after_each(function()
        system.entities = {}
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("CircularMovementSystem", system.type)
            assert.are.same({ "Transform", "CircularMovement" }, system.requiredComponents)
        end)
    end)

    describe("update", function()
        it("updates angle over time", function()
            local circular = entity:getComponent("CircularMovement")
            local initialAngle = circular.angle

            system:update(0.5)

            assert.are.equal(initialAngle + 1.0, circular.angle) -- 0.5 * 2
        end)

        it("moves entity in circular pattern", function()
            local transform = entity:getComponent("Transform")
            local circular = entity:getComponent("CircularMovement")

            -- Set initial angle to 0 for predictable position
            circular.angle = 0

            system:update(0)

            -- At angle 0, cos(0) = 1, sin(0) = 0
            assert.is_near(150, transform.x, 0.01) -- centerX + radius * cos(0) = 100 + 50 * 1
            assert.is_near(100, transform.y, 0.01) -- centerY + radius * sin(0) = 100 + 50 * 0

            -- Update to angle π/2
            circular.angle = math.pi / 2
            system:update(0)

            -- At angle π/2, cos(π/2) = 0, sin(π/2) = 1
            assert.is_near(100, transform.x, 0.01) -- centerX + radius * cos(π/2) = 100 + 50 * 0
            assert.is_near(150, transform.y, 0.01) -- centerY + radius * sin(π/2) = 100 + 50 * 1
        end)

        it("skips inactive entities", function()
            local transform = entity:getComponent("Transform")
            transform.x = 200
            transform.y = 200

            entity:deactivate()

            system:update(1.0)

            -- Position should not change
            assert.are.equal(200, transform.x)
            assert.are.equal(200, transform.y)
        end)

        it("handles multiple entities independently", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Transform", Components.Transform.new(0, 0))
            -- radius, centerX, centerY, angle
            entity2:addComponent("CircularMovement", Components.CircularMovement.new(30, 200, 200, math.pi))
            system:addEntity(entity2)

            system:update(0.25)

            local transform1 = entity:getComponent("Transform")
            local transform2 = entity2:getComponent("Transform")

            -- Both entities should be at different positions
            assert.are_not.equal(transform1.x, transform2.x)
            assert.are_not.equal(transform1.y, transform2.y)
        end)
    end)
end)
