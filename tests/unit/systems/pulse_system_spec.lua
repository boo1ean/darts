-- Test for Pulse System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local PulseSystem = require("systems.pulse_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Pulse System", function()
    local system
    local entity
    
    before_each(function()
        system = PulseSystem
        entity = Entity.new(1)
        entity:addComponent("Render", Components.Render.new({1, 1, 1, 1}, 10))
        entity:addComponent("Pulse", Components.Pulse.new(1, 0.5, 20)) -- speed, minRatio, maxSize
        system.entities = {}
        system:addEntity(entity)
    end)
    
    after_each(function()
        system.entities = {}
    end)
    
    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("PulseSystem", system.type)
            assert.are.same({"Render", "Pulse"}, system.requiredComponents)
        end)
    end)
    
    describe("update", function()
        it("updates pulse time", function()
            local pulse = entity:getComponent("Pulse")
            local initialTime = pulse.time
            
            system:update(0.1)
            
            assert.are.equal(initialTime + 0.1, pulse.time)
        end)
        
        it("pulses render size between min and max", function()
            local render = entity:getComponent("Render")
            local pulse = entity:getComponent("Pulse")
            
            -- Test at different time points
            pulse.time = 0 -- sin(0) = 0, normalized to 0.5
            system:update(0)
            assert.is_near(15, render.size, 0.01) -- minSize=10, maxSize=20, ratio=0.5
            
            pulse.time = 0.25 / pulse.speed -- sin(π/2) = 1, normalized to 1
            system:update(0)
            assert.is_near(20, render.size, 0.01) -- maxSize
            
            pulse.time = 0.5 / pulse.speed -- sin(π) = 0, normalized to 0.5
            system:update(0)
            assert.is_near(15, render.size, 0.01) -- middle
            
            pulse.time = 0.75 / pulse.speed -- sin(3π/2) = -1, normalized to 0
            system:update(0)
            assert.is_near(10, render.size, 0.01) -- minSize
        end)
        
        it("skips inactive entities", function()
            local render = entity:getComponent("Render")
            render.size = 15
            
            entity:deactivate()
            
            system:update(1.0)
            
            assert.are.equal(15, render.size)
        end)
        
        it("skips entities with stopped movement", function()
            entity:addComponent("Movement", Components.Movement.new())
            local movement = entity:getComponent("Movement")
            movement.stopped = true
            
            local render = entity:getComponent("Render")
            render.size = 15
            
            system:update(1.0)
            
            assert.are.equal(15, render.size)
        end)
        
        it("processes entities without movement component", function()
            local render = entity:getComponent("Render")
            local pulse = entity:getComponent("Pulse")
            pulse.time = 0
            
            system:update(0.1)
            
            assert.are_not.equal(10, render.size) -- Size should have changed
        end)
        
        it("handles missing render component gracefully", function()
            entity:removeComponent("Render")
            
            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)
        
        it("handles missing pulse component gracefully", function()
            entity:removeComponent("Pulse")
            
            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)
    end)
end)