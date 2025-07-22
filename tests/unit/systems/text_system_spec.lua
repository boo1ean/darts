-- Test for Text System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local TextSystem = require("systems.text_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")
local World = require("ecs.world")

describe("Text System", function()
    local system
    local world
    local entity

    before_each(function()
        system = TextSystem
        world = World.new()
        system:init(world)

        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(200, 150))
        entity:addComponent("Text", Components.Text.new("Test", 24, { 1, 0, 0, 1 }, 2.0, "popup"))

        system.entities = {}
        system:addEntity(entity)
    end)

    after_each(function()
        system.entities = {}
    end)

    describe("initialization", function()
        it("has correct type and required components", function()
            assert.are.equal("TextSystem", system.type)
            assert.are.same({ "Transform", "Text" }, system.requiredComponents)
        end)

        it("stores world reference and creates font", function()
            assert.are.equal(world, system.world)
            assert.is_not_nil(system.font)
        end)
    end)

    describe("update", function()
        it("updates text time", function()
            local text = entity:getComponent("Text")
            local initialTime = text.time

            system:update(0.1)

            assert.are.equal(initialTime + 0.1, text.time)
        end)

        it("removes entity when animation completes", function()
            local text = entity:getComponent("Text")
            text.time = 1.9
            text.duration = 2.0

            assert.are.equal(1, #system.entities)

            system:update(0.2) -- Total time becomes 2.1, exceeding duration

            -- Entity should be removed from world
            assert.are.equal(0, #world.entities)
        end)

        it("updates popup animation correctly", function()
            local text = entity:getComponent("Text")
            text.animationType = "popup"

            system:update(0.1) -- 5% progress (0.1/2.0)

            -- Should be in growing phase
            assert.is_not_nil(text.scale)
            assert.is_not_nil(text.alpha)
            assert.is_not_nil(text.offsetY)
        end)

        it("updates fade animation correctly", function()
            local text = entity:getComponent("Text")
            text.animationType = "fade"

            system:update(0.5) -- 25% progress

            assert.are.equal(text.endScale, text.scale)
            assert.are.equal(0.75, text.alpha) -- 1.0 - 0.25
        end)

        it("skips entities missing components", function()
            entity:removeComponent("Text")

            assert.has_no.errors(function()
                system:update(0.1)
            end)
        end)

        it("skips inactive entities", function()
            entity:deactivate()
            local text = entity:getComponent("Text")
            local initialTime = text.time

            system:update(0.1)

            assert.are.equal(initialTime, text.time)
        end)
    end)

    describe("updatePopupAnimation", function()
        it("handles growing phase correctly", function()
            local text = entity:getComponent("Text")

            system:updatePopupAnimation(text, 0.1) -- 10% progress, in growing phase

            assert.is_true(text.scale > text.startScale)
            assert.is_true(text.scale < text.maxScale)
            assert.are.equal(0.5, text.alpha) -- scaleProgress = 0.1/0.2 = 0.5
        end)

        it("handles settling phase correctly", function()
            local text = entity:getComponent("Text")

            system:updatePopupAnimation(text, 0.35) -- 35% progress, in settling phase

            assert.is_true(text.scale > text.endScale)
            assert.is_true(text.scale <= text.maxScale)
            assert.are.equal(1.0, text.alpha)
        end)

        it("handles fade out phase correctly", function()
            local text = entity:getComponent("Text")

            system:updatePopupAnimation(text, 0.75) -- 75% progress, in fade out phase

            assert.are.equal(text.endScale, text.scale)
            assert.are.equal(0.5, text.alpha) -- fadeProgress = (0.75-0.5)/0.5 = 0.5
        end)

        it("calculates offset Y correctly", function()
            local text = entity:getComponent("Text")
            text.time = 0.5 * text.duration -- Set time to 50% progress

            system:update(0) -- This will calculate offsetY based on the set time

            -- easedProgress = 1 - (1 - 0.5) * (1 - 0.5) = 1 - 0.25 = 0.75
            -- offsetY = -80 * 0.75 = -60
            assert.are.equal(-60, text.offsetY)
        end)
    end)

    describe("updateFadeAnimation", function()
        it("sets correct scale and alpha", function()
            local text = entity:getComponent("Text")

            system:updateFadeAnimation(text, 0.3) -- 30% progress

            assert.are.equal(text.endScale, text.scale)
            assert.are.equal(0.7, text.alpha) -- 1.0 - 0.3
        end)
    end)

    describe("render", function()
        it("handles rendering without errors", function()
            assert.has_no.errors(function()
                system:render()
            end)
        end)

        it("skips entities without required components", function()
            entity:removeComponent("Transform")

            assert.has_no.errors(function()
                system:render()
            end)
        end)

        it("skips inactive entities during render", function()
            entity:deactivate()

            assert.has_no.errors(function()
                system:render()
            end)
        end)
    end)

    describe("multiple entities", function()
        it("processes multiple text entities independently", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Transform", Components.Transform.new(300, 200))
            entity2:addComponent("Text", Components.Text.new("Test2", 18, { 0, 1, 0, 1 }, 1.5, "fade"))
            system:addEntity(entity2)

            local text1 = entity:getComponent("Text")
            local text2 = entity2:getComponent("Text")

            system:update(0.1)

            assert.are.equal(0.1, text1.time)
            assert.are.equal(0.1, text2.time)
        end)

        it("removes completed entities while keeping others", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Transform", Components.Transform.new(300, 200))
            entity2:addComponent("Text", Components.Text.new("Test2", 18, { 0, 1, 0, 1 }, 3.0, "fade"))
            world.entities = { entity, entity2 } -- Add both entities to world
            -- Mock world:removeEntity to actually remove entities
            world.removeEntity = function(self, entityToRemove)
                for i = #self.entities, 1, -1 do
                    if self.entities[i] == entityToRemove then
                        table.remove(self.entities, i)
                        break
                    end
                end
            end
            system:addEntity(entity2)

            -- Make first entity complete
            local text1 = entity:getComponent("Text")
            text1.time = 1.9
            text1.duration = 2.0

            system:update(0.2) -- This should remove first entity from world

            -- First entity should be removed from world, second should remain
            assert.are.equal(1, #world.entities)
        end)
    end)
end)
