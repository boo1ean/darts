-- Test for ECS Entity
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Entity", function()
    local entity
    
    before_each(function()
        entity = Entity.new(1)
    end)
    
    describe("initialization", function()
        it("creates entity with correct ID and active state", function()
            assert.are.equal(1, entity.id)
            assert.is_true(entity.active)
            assert.are.equal(0, entity:getComponentCount())
        end)
    end)
    
    describe("component management", function()
        it("adds and retrieves components", function()
            local transform = Components.Transform.new(5, 10)
            entity:addComponent("Transform", transform)
            
            assert.is_true(entity:hasComponent("Transform"))
            local retrieved = entity:getComponent("Transform")
            assert.are.equal(5, retrieved.x)
            assert.are.equal(10, retrieved.y)
        end)
        
        it("removes components", function()
            local render = Components.Render.new({1, 1, 1, 1}, 15)
            entity:addComponent("Render", render)
            
            assert.is_true(entity:hasComponent("Render"))
            entity:removeComponent("Render")
            assert.is_false(entity:hasComponent("Render"))
        end)
        
        it("counts components correctly", function()
            assert.are.equal(0, entity:getComponentCount())
            
            entity:addComponent("Transform", Components.Transform.new(0, 0))
            assert.are.equal(1, entity:getComponentCount())
            
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 10))
            assert.are.equal(2, entity:getComponentCount())
        end)
        
        it("checks for multiple components", function()
            entity:addComponent("Transform", Components.Transform.new(0, 0))
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 10))
            
            assert.is_true(entity:hasComponents({"Transform", "Render"}))
            assert.is_false(entity:hasComponents({"Transform", "Movement"}))
        end)
    end)
    
    describe("entity state", function()
        it("deactivates and reactivates entities", function()
            assert.is_true(entity.active)
            
            entity:deactivate()
            assert.is_false(entity.active)
            
            entity:activate()
            assert.is_true(entity.active)
        end)
        
        it("destroys entity clearing components and deactivating", function()
            entity:addComponent("Transform", Components.Transform.new(5, 10))
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 10))
            assert.are.equal(2, entity:getComponentCount())
            assert.is_true(entity.active)
            
            entity:destroy()
            
            assert.is_false(entity.active)
            assert.are.equal(0, entity:getComponentCount())
            assert.is_nil(entity:getComponent("Transform"))
            assert.is_nil(entity:getComponent("Render"))
        end)
    end)
    
    describe("edge cases", function()
        it("handles nil component gracefully", function()
            assert.has_no.errors(function()
                entity:addComponent("NilComponent", nil)
            end)
            assert.is_nil(entity:getComponent("NilComponent"))
        end)
        
        it("supports method chaining with addComponent", function()
            local result = entity:addComponent("Transform", Components.Transform.new(1, 2))
                                :addComponent("Render", Components.Render.new({1, 1, 1, 1}, 5))
            
            assert.are.equal(entity, result)
            assert.is_true(entity:hasComponent("Transform"))
            assert.is_true(entity:hasComponent("Render"))
        end)
        
        it("hasComponents returns true for empty component list", function()
            assert.is_true(entity:hasComponents({}))
        end)
        
        it("getComponent returns nil for non-existent component", function()
            assert.is_nil(entity:getComponent("NonExistent"))
        end)
        
        it("removeComponent is idempotent", function()
            entity:addComponent("Transform", Components.Transform.new(0, 0))
            entity:removeComponent("Transform")
            assert.has_no.errors(function()
                entity:removeComponent("Transform")
            end)
            assert.is_false(entity:hasComponent("Transform"))
        end)
    end)
end)