-- Test for Target Generation System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

-- Mock DartBoardBehavior
local mockDartBoard = {
    findDartBoard = function() return { id = "dartboard" } end,
    getBounds = function() return { minX = 50, maxX = 750, minY = 50, maxY = 550 } end
}
package.loaded["behaviors.dartboard_behavior"] = mockDartBoard

local TargetGenerationSystem = require("systems.target_generation_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")
local World = require("ecs.world")

describe("Target Generation System", function()
    local system
    local world
    local entity
    
    before_each(function()
        system = TargetGenerationSystem
        world = World.new()
        system:init(world)
        
        entity = Entity.new(1)
        entity:addComponent("Movement", Components.Movement.new())
        entity:addComponent("CircularMovement", Components.CircularMovement.new(30, 200, 200, 0))
        entity:addComponent("LinearMovement", Components.LinearMovement.new(400, 300))
        entity:addComponent("CosineMovement", Components.CosineMovement.new())
        
        system.entities = {}
        system:addEntity(entity)
    end)
    
    after_each(function()
        system.entities = {}
    end)
    
    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("TargetGenerationSystem", system.type)
            local expected = { "Movement", "CircularMovement", "LinearMovement", "CosineMovement" }
            assert.are.same(expected, system.requiredComponents)
        end)
        
        it("stores world reference", function()
            assert.are.equal(world, system.world)
        end)
    end)
    
    describe("update", function()
        it("updates movement time", function()
            local movement = entity:getComponent("Movement")
            local initialTime = movement.moveTime
            
            system:update(0.2)
            
            assert.are.equal(initialTime + 0.2, movement.moveTime)
        end)
        
        it("generates new targets when duration exceeded", function()
            local movement = entity:getComponent("Movement")
            local circular = entity:getComponent("CircularMovement")
            
            movement.moveDuration = 1.0
            movement.moveTime = 0.8
            local oldCenterX = circular.centerX
            
            system:update(0.3) -- Total time becomes 1.1, exceeding duration
            
            -- Should generate new targets
            assert.are_not.equal(oldCenterX, circular.centerX)
            assert.are.equal(0, movement.moveTime) -- Reset to 0
        end)
        
        it("skips entities with stopped movement", function()
            local movement = entity:getComponent("Movement")
            movement.stopped = true
            local initialTime = movement.moveTime
            
            system:update(0.1)
            
            assert.are.equal(initialTime, movement.moveTime)
        end)
        
        it("skips inactive entities", function()
            entity:deactivate()
            local movement = entity:getComponent("Movement")
            local initialTime = movement.moveTime
            
            system:update(0.1)
            
            assert.are.equal(initialTime, movement.moveTime)
        end)
        
        it("handles missing components gracefully", function()
            entity:removeComponent("CircularMovement")
            
            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)
    end)
    
    describe("generateNewTargets", function()
        it("stores previous movement values", function()
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
        
        it("generates targets within dart board bounds", function()
            local circular = entity:getComponent("CircularMovement")
            local linear = entity:getComponent("LinearMovement")
            
            system:generateNewTargets(entity)
            
            -- Check bounds (50-750 x, 50-550 y)
            assert.is_true(circular.centerX >= 50 and circular.centerX <= 750)
            assert.is_true(circular.centerY >= 50 and circular.centerY <= 550)
            assert.is_true(linear.targetX >= 50 and linear.targetX <= 750)
            assert.is_true(linear.targetY >= 50 and linear.targetY <= 550)
        end)
        
        it("sets random circular angle", function()
            local circular = entity:getComponent("CircularMovement")
            
            system:generateNewTargets(entity)
            
            assert.is_true(circular.angle >= 0 and circular.angle <= math.pi * 2)
        end)
        
        it("sets random movement duration", function()
            local movement = entity:getComponent("Movement")
            
            system:generateNewTargets(entity)
            
            assert.is_true(movement.moveDuration >= 1 and movement.moveDuration <= 2)
        end)
        
        it("resets movement state", function()
            local movement = entity:getComponent("Movement")
            local cosine = entity:getComponent("CosineMovement")
            
            movement.transitionProgress = 0.7
            movement.startX = 150
            movement.startY = 200
            cosine.time = 3.5
            
            system:generateNewTargets(entity)
            
            assert.are.equal(0, movement.transitionProgress)
            assert.is_nil(movement.startX)
            assert.is_nil(movement.startY)
            assert.are.equal(0, cosine.time)
        end)
        
        it("randomizes cosine parameters", function()
            local cosine = entity:getComponent("CosineMovement")
            
            system:generateNewTargets(entity)
            
            -- Parameters should be within expected ranges
            -- At minimum, randomizeParameters should have been called
            assert.is_not_nil(cosine.amplitudeX)
            assert.is_not_nil(cosine.frequencyX)
        end)
    end)
    
    describe("system integration", function()
        it("processes multiple entities independently", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Movement", Components.Movement.new())
            entity2:addComponent("CircularMovement", Components.CircularMovement.new(25, 150, 150, math.pi))
            entity2:addComponent("LinearMovement", Components.LinearMovement.new(350, 250))
            entity2:addComponent("CosineMovement", Components.CosineMovement.new())
            system:addEntity(entity2)
            
            local movement1 = entity:getComponent("Movement")
            local movement2 = entity2:getComponent("Movement")
            
            system:update(0.1)
            
            -- Both should have updated times
            assert.are.equal(0.1, movement1.moveTime)
            assert.are.equal(0.1, movement2.moveTime)
        end)
        
        it("handles entity with partial components", function()
            local entity3 = Entity.new(3)
            entity3:addComponent("Movement", Components.Movement.new())
            entity3:addComponent("CircularMovement", Components.CircularMovement.new(20, 100, 100, 0))
            -- Missing LinearMovement and CosineMovement
            system:addEntity(entity3)
            
            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)
    end)
end)