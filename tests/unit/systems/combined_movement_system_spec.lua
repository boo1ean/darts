-- Test for Combined Movement System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

-- Mock DartBoardBehavior
local mockDartBoard = {
    getCenterFromWorld = function() return 400, 300 end,
    getCenter = function() return 400, 300 end,
    findDartBoard = function() return { id = "dartboard" } end,
    getBounds = function() return { minX = 100, maxX = 700, minY = 100, maxY = 500 } end,
    checkCenterPass = function() end
}
package.loaded["behaviors.dartboard_behavior"] = mockDartBoard

local CombinedMovementSystem = require("systems.combined_movement_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")
local World = require("ecs.world")

describe("Combined Movement System", function()
    local system
    local world
    local entity
    
    before_each(function()
        system = CombinedMovementSystem
        world = World.new()
        system:init(world)
        
        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(200, 200))
        entity:addComponent("CircularMovement", Components.CircularMovement.new(50, 400, 300, 0))
        entity:addComponent("LinearMovement", Components.LinearMovement.new(500, 400))
        entity:addComponent("CosineMovement", Components.CosineMovement.new())
        entity:addComponent("Movement", Components.Movement.new())
        
        system.entities = {}
        system:addEntity(entity)
    end)
    
    after_each(function()
        system.entities = {}
    end)
    
    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("CombinedMovementSystem", system.type)
            local expected = { "Transform", "CircularMovement", "LinearMovement", "CosineMovement", "Movement" }
            assert.are.same(expected, system.requiredComponents)
        end)
        
        it("stores world reference", function()
            assert.are.equal(world, system.world)
        end)
    end)
    
    describe("update", function()
        it("updates transition progress over time", function()
            local movement = entity:getComponent("Movement")
            assert.are.equal(0, movement.transitionProgress)
            
            system:update(0.1)
            
            assert.is_true(movement.transitionProgress > 0)
        end)
        
        it("skips entities with stopped movement", function()
            local movement = entity:getComponent("Movement")
            movement.stopped = true
            
            local transform = entity:getComponent("Transform")
            local originalX = transform.x
            local originalY = transform.y
            
            system:update(0.1)
            
            assert.are.equal(originalX, transform.x)
            assert.are.equal(originalY, transform.y)
        end)
        
        it("skips inactive entities", function()
            entity:deactivate()
            
            local transform = entity:getComponent("Transform")
            local originalX = transform.x
            local originalY = transform.y
            
            system:update(0.1)
            
            assert.are.equal(originalX, transform.x)
            assert.are.equal(originalY, transform.y)
        end)
        
        it("processes entities with all required components", function()
            local transform = entity:getComponent("Transform")
            local originalX = transform.x
            
            system:update(0.1)
            
            -- Position should change due to combined movement
            assert.are_not.equal(originalX, transform.x)
        end)
    end)
    
    describe("generateNewTargets", function()
        it("stores previous values", function()
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            
            circular.centerX = 300
            circular.centerY = 250
            circular.angle = 1.5
            linear.targetX = 450
            linear.targetY = 350
            
            system:generateNewTargets(entity)
            
            assert.are.equal(300, circular.previousCenterX)
            assert.are.equal(250, circular.previousCenterY)
            assert.are.equal(1.5, circular.previousAngle)
            assert.are.equal(450, linear.previousTargetX)
            assert.are.equal(350, linear.previousTargetY)
        end)
        
        it("generates new random targets within bounds", function()
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            
            system:generateNewTargets(entity)
            
            -- Check targets are within dart board bounds (100-700 x, 100-500 y)
            assert.is_true(circular.centerX >= 100 and circular.centerX <= 700)
            assert.is_true(circular.centerY >= 100 and circular.centerY <= 500)
            assert.is_true(linear.targetX >= 100 and linear.targetX <= 700)
            assert.is_true(linear.targetY >= 100 and linear.targetY <= 500)
        end)
        
        it("resets movement parameters", function()
            local movement = entity:getComponent("Movement")
            local cosine = entity:getComponent("CosineMovement")
            
            movement.transitionProgress = 0.5
            movement.startX = 100
            movement.startY = 150
            cosine.time = 2.5
            
            system:generateNewTargets(entity)
            
            assert.are.equal(0, movement.transitionProgress)
            assert.is_nil(movement.startX)
            assert.is_nil(movement.startY)
            assert.are.equal(0, cosine.time)
        end)
        
        it("sets random movement duration", function()
            local movement = entity:getComponent("Movement")
            
            system:generateNewTargets(entity)
            
            assert.is_true(movement.moveDuration >= 1 and movement.moveDuration <= 2)
        end)
    end)
    
    describe("updateCombinedMovement", function()
        it("stores start position on first update", function()
            local transform = entity:getComponent("Transform")
            local movement = entity:getComponent("Movement")
            
            transform.x = 250
            transform.y = 275
            
            system:updateCombinedMovement(entity, 0.1)
            
            assert.are.equal(250, movement.startX)
            assert.are.equal(275, movement.startY)
        end)
        
        it("updates cosine time", function()
            local cosine = entity:getComponent("CosineMovement")
            local initialTime = cosine.time
            
            system:updateCombinedMovement(entity, 0.1)
            
            assert.are.equal(initialTime + 0.1, cosine.time)
        end)
        
        it("calculates movement progress correctly", function()
            local movement = entity:getComponent("Movement")
            movement.moveTime = 0.5
            movement.moveDuration = 2.0
            
            local transform = entity:getComponent("Transform")
            local originalX = transform.x
            
            system:updateCombinedMovement(entity, 0)
            
            -- At 25% progress, position should be different from start
            assert.are_not.equal(originalX, transform.x)
        end)
        
        it("applies screen bounds clamping", function()
            local transform = entity:getComponent("Transform")
            
            -- Force position to be calculated outside bounds
            transform.x = -50  -- Below minimum
            transform.y = 1000 -- Above maximum
            
            system:updateCombinedMovement(entity, 0.1)
            
            -- Should be clamped to screen bounds with margin
            assert.is_true(transform.x >= 15)
            assert.is_true(transform.y <= love.graphics.getHeight() - 15)
        end)
    end)
    
    describe("component integration", function()
        it("handles missing components gracefully", function()
            entity:removeComponent("CircularMovement")
            
            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)
        
        it("works with transition progress values", function()
            local movement = entity:getComponent("Movement")
            movement.transitionProgress = 0.75
            
            local transform = entity:getComponent("Transform")
            local originalX = transform.x
            
            system:updateCombinedMovement(entity, 0.1)
            
            -- Should still update position
            assert.are_not.equal(originalX, transform.x)
        end)
    end)
end)