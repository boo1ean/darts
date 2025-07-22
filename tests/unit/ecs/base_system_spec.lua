-- Test for ECS Base System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local System = require("ecs.base_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Base System", function()
    local system
    local entity1, entity2

    before_each(function()
        system = System.new("TestSystem", { "Transform", "Movement" })
        entity1 = Entity.new(1)
        entity2 = Entity.new(2)
    end)

    describe("initialization", function()
        it("creates system with correct type and requirements", function()
            assert.are.equal("TestSystem", system.type)
            assert.are.same({ "Transform", "Movement" }, system.requiredComponents)
            assert.are.equal(0, #system.entities)
        end)

        it("handles empty required components", function()
            local emptySystem = System.new("EmptySystem")
            assert.are.equal("EmptySystem", emptySystem.type)
            assert.are.same({}, emptySystem.requiredComponents)
        end)
    end)

    describe("entity management", function()
        it("adds entities with required components", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())

            system:addEntity(entity1)
            assert.are.equal(1, #system.entities)
            assert.are.equal(entity1, system.entities[1])
        end)

        it("rejects entities missing required components", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            -- Missing Movement component

            system:addEntity(entity1)
            assert.are.equal(0, #system.entities)
        end)

        it("prevents duplicate entities", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())

            system:addEntity(entity1)
            system:addEntity(entity1) -- Try to add again

            assert.are.equal(1, #system.entities)
        end)

        it("removes entities correctly", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())
            entity2:addComponent("Transform", Components.Transform.new(10, 10))
            entity2:addComponent("Movement", Components.Movement.new())

            system:addEntity(entity1)
            system:addEntity(entity2)
            assert.are.equal(2, #system.entities)

            system:removeEntity(entity1)
            assert.are.equal(1, #system.entities)
            assert.are.equal(entity2, system.entities[1])
        end)

        it("handles removing non-existent entity", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())

            system:addEntity(entity1)
            assert.are.equal(1, #system.entities)

            system:removeEntity(entity2) -- Entity not in system
            assert.are.equal(1, #system.entities)
        end)
    end)

    describe("canProcessEntity", function()
        it("returns true for entities with all required components", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())

            assert.is_true(system:canProcessEntity(entity1))
        end)

        it("returns false for entities missing any required component", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))

            assert.is_false(system:canProcessEntity(entity1))
        end)

        it("returns true for empty component requirements", function()
            local emptySystem = System.new("EmptySystem", {})
            assert.is_true(emptySystem:canProcessEntity(entity1))
        end)

        it("works with entities having extra components", function()
            entity1:addComponent("Transform", Components.Transform.new(0, 0))
            entity1:addComponent("Movement", Components.Movement.new())
            entity1:addComponent("Render", Components.Render.new({ 1, 1, 1, 1 }, 10))

            assert.is_true(system:canProcessEntity(entity1))
        end)
    end)

    describe("update method", function()
        it("has update method that can be called", function()
            assert.has_no.errors(function()
                system:update(0.016)
            end)
        end)
    end)
end)
