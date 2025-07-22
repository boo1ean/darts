-- Test for Movement Component
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local MovementComponent = require("components.movement_component")

describe("Movement Component", function()
    describe("initialization", function()
        it("creates component with default values", function()
            local movement = MovementComponent.new()
            
            assert.are.equal("Movement", movement.type)
            assert.are.equal(100, movement.speed)
            assert.are.equal("linear", movement.movementType)
            assert.are.equal(0, movement.targetX)
            assert.are.equal(0, movement.targetY)
            assert.are.equal(0, movement.moveTime)
            assert.are.equal(1.5, movement.moveDuration)
            assert.are.equal(0, movement.transitionProgress)
            assert.is_false(movement.stopped)
            assert.is_nil(movement.startX)
            assert.is_nil(movement.startY)
        end)
        
        it("creates component with custom speed", function()
            local movement = MovementComponent.new(200)
            
            assert.are.equal(200, movement.speed)
            assert.are.equal("linear", movement.movementType)
        end)
        
        it("creates component with custom speed and movement type", function()
            local movement = MovementComponent.new(150, "circular")
            
            assert.are.equal(150, movement.speed)
            assert.are.equal("circular", movement.movementType)
        end)
    end)
    
    describe("properties", function()
        it("allows property modification", function()
            local movement = MovementComponent.new()
            
            movement.targetX = 50
            movement.targetY = 100
            movement.moveTime = 0.5
            movement.moveDuration = 2.0
            movement.transitionProgress = 0.3
            movement.stopped = true
            movement.startX = 10
            movement.startY = 20
            
            assert.are.equal(50, movement.targetX)
            assert.are.equal(100, movement.targetY)
            assert.are.equal(0.5, movement.moveTime)
            assert.are.equal(2.0, movement.moveDuration)
            assert.are.equal(0.3, movement.transitionProgress)
            assert.is_true(movement.stopped)
            assert.are.equal(10, movement.startX)
            assert.are.equal(20, movement.startY)
        end)
    end)
end)