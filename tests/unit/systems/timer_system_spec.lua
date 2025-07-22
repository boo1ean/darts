-- Test for Timer System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local TimerSystem = require("systems.timer_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Timer System", function()
    local system
    local entity
    local mockWorld
    
    before_each(function()
        system = TimerSystem
        entity = Entity.new(1)
        
        -- Create a mock world
        mockWorld = {
            addComponentToEntity = function(self, ent, componentType, component)
                ent:addComponent(componentType, component)
            end,
            removeComponentFromEntity = function(self, ent, componentType)
                ent:removeComponent(componentType)
            end
        }
        
        -- Initialize system with mock world
        system:init(mockWorld)
        
        system.entities = {}
    end)
    
    after_each(function()
        system.entities = {}
        system.world = nil
    end)
    
    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("TimerSystem", system.type)
            assert.are.same({"Timer"}, system.requiredComponents)
        end)
        
        it("stores world reference when initialized", function()
            assert.are.equal(mockWorld, system.world)
        end)
    end)
    
    describe("update", function()
        it("updates timer time", function()
            local shakeComponent = Components.Shake.new(1.0, 5)
            entity:addComponent("Timer", Components.Timer.new(2.0, "Shake", shakeComponent))
            system:addEntity(entity)
            
            local timer = entity:getComponent("Timer")
            
            system:update(0.5)
            
            assert.are.equal(0.5, timer.time)
            assert.is_false(timer.triggered)
        end)
        
        it("triggers timer when delay is reached", function()
            local shakeComponent = Components.Shake.new(1.0, 5)
            entity:addComponent("Timer", Components.Timer.new(1.0, "Shake", shakeComponent))
            system:addEntity(entity)
            
            system:update(1.1)
            
            assert.is_true(entity:hasComponent("Shake"))
            assert.is_false(entity:hasComponent("Timer"))
        end)
        
        it("adds correct component when timer triggers", function()
            local pulseComponent = Components.Pulse.new(2, 0.5, 10) -- speed, minRatio, maxSize
            entity:addComponent("Timer", Components.Timer.new(0.5, "Pulse", pulseComponent))
            system:addEntity(entity)
            
            system:update(0.6)
            
            local pulse = entity:getComponent("Pulse")
            assert.is_not_nil(pulse)
            assert.are.equal(2, pulse.speed)
            assert.are.equal(0.5, pulse.minRatio)
            assert.are.equal(10, pulse.maxSize)
        end)
        
        it("marks timer as triggered", function()
            local shakeComponent = Components.Shake.new(1.0, 5)
            local timer = Components.Timer.new(0.1, "Shake", shakeComponent)
            entity:addComponent("Timer", timer)
            system:addEntity(entity)
            
            system:update(0.2)
            
            assert.is_true(timer.triggered)
        end)
        
        it("removes timer component after triggering", function()
            local shakeComponent = Components.Shake.new(1.0, 5)
            entity:addComponent("Timer", Components.Timer.new(0.1, "Shake", shakeComponent))
            system:addEntity(entity)
            
            assert.is_true(entity:hasComponent("Timer"))
            
            system:update(0.2)
            
            assert.is_false(entity:hasComponent("Timer"))
        end)
        
        it("skips already triggered timers", function()
            local timer = Components.Timer.new(1.0, "Shake", Components.Shake.new(1.0, 5))
            timer.triggered = true
            entity:addComponent("Timer", timer)
            system:addEntity(entity)
            
            system:update(0.5)
            
            assert.is_false(entity:hasComponent("Shake"))
        end)
        
        it("skips inactive entities", function()
            entity:addComponent("Timer", Components.Timer.new(0.1, "Shake", Components.Shake.new(1.0, 5)))
            system:addEntity(entity)
            entity:deactivate()
            
            system:update(0.2)
            
            assert.is_false(entity:hasComponent("Shake"))
            assert.is_true(entity:hasComponent("Timer"))
        end)
        
        it("handles missing component data gracefully", function()
            entity:addComponent("Timer", Components.Timer.new(0.1, nil, nil))
            system:addEntity(entity)
            
            assert.has_no.errors(function()
                system:update(0.2)
            end)
        end)
        
        it("works without world reference", function()
            system.world = nil
            
            local shakeComponent = Components.Shake.new(1.0, 5)
            entity:addComponent("Timer", Components.Timer.new(0.1, "Shake", shakeComponent))
            system:addEntity(entity)
            
            system:update(0.2)
            
            assert.is_true(entity:hasComponent("Shake"))
            assert.is_false(entity:hasComponent("Timer"))
        end)
    end)
end)