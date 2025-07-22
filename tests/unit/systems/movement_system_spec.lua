-- Test for Movement System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

-- Mock math.random for predictable tests
local original_random = math.random
math.random = function()
    return 0.5
end

local MovementSystem = require("systems.movement_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Movement System", function()
    local system
    local entity

    before_each(function()
        system = MovementSystem
        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(100, 100))
        entity:addComponent("Movement", Components.Movement.new())
        system.entities = {}
        system:addEntity(entity)
    end)

    after_each(function()
        system.entities = {}
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("MovementSystem", system.type)
            assert.are.same({ "Transform", "Movement" }, system.requiredComponents)
        end)
    end)

    describe("update", function()
        it("updates movement time", function()
            local movement = entity:getComponent("Movement")
            local initialTime = movement.moveTime

            system:update(0.1)

            assert.are.equal(initialTime + 0.1, movement.moveTime)
        end)

        it("generates new target when move duration exceeded", function()
            local movement = entity:getComponent("Movement")
            movement.moveDuration = 1
            movement.moveTime = 0.9

            system:update(0.2) -- Total time becomes 1.1, exceeding duration

            -- Random values are generated independently in the actual code
            assert.is_true(movement.targetX >= 0 and movement.targetX <= 800)
            assert.is_true(movement.targetY >= 0 and movement.targetY <= 600)
            assert.are.equal(0, movement.moveTime)
        end)

        it("skips inactive entities", function()
            entity:deactivate()
            local movement = entity:getComponent("Movement")
            local initialTime = movement.moveTime

            system:update(0.1)

            assert.are.equal(initialTime, movement.moveTime)
        end)

        it("moves entity toward target", function()
            local transform = entity:getComponent("Transform")
            local movement = entity:getComponent("Movement")

            transform.x = 0
            transform.y = 0
            movement.targetX = 100
            movement.targetY = 0
            movement.speed = 100

            system:update(0.5)

            -- Should move 50 units toward target
            assert.is_true(transform.x > 0)
            assert.is_true(transform.x <= 50)
            assert.are.equal(0, transform.y)
        end)
    end)

    describe("generateNewTarget", function()
        it("stores previous target values", function()
            local movement = entity:getComponent("Movement")
            movement.targetX = 200
            movement.targetY = 150

            system:generateNewTarget(entity)

            assert.are.equal(200, movement.previousTargetX)
            assert.are.equal(150, movement.previousTargetY)
        end)

        it("generates new random target within bounds", function()
            local movement = entity:getComponent("Movement")

            system:generateNewTarget(entity)

            -- Verify values are within valid bounds
            assert.is_true(movement.targetX >= 0 and movement.targetX <= 800)
            assert.is_true(movement.targetY >= 0 and movement.targetY <= 600)
            assert.is_true(movement.moveDuration >= 2.5 and movement.moveDuration <= 3.5)
        end)
    end)

    describe("updateMovement", function()
        it("moves entity toward target with correct speed", function()
            local transform = entity:getComponent("Transform")
            local movement = entity:getComponent("Movement")

            transform.x = 0
            transform.y = 0
            movement.targetX = 300
            movement.targetY = 400
            movement.speed = 100

            system:updateMovement(entity, 0.1)

            -- Distance to target is 500 (3-4-5 triangle)
            -- Speed is 100 * 0.1 = 10
            -- Movement should be 10/500 of the total distance
            local expectedX = 0 + (300 / 500) * 10
            local expectedY = 0 + (400 / 500) * 10

            assert.is_near(expectedX, transform.x, 0.01)
            assert.is_near(expectedY, transform.y, 0.01)
        end)

        it("handles zero distance to target", function()
            local transform = entity:getComponent("Transform")
            local movement = entity:getComponent("Movement")

            transform.x = 100
            transform.y = 100
            movement.targetX = 100
            movement.targetY = 100

            assert.has_no.errors(function()
                system:updateMovement(entity, 0.1)
            end)

            assert.are.equal(100, transform.x)
            assert.are.equal(100, transform.y)
        end)
    end)
end)

-- Restore original math.random
math.random = original_random
