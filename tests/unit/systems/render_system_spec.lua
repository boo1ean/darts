-- Test for Render System
local love_mock = require("tests.helpers.love_mock")
local test_helper = require("tests.helpers.test_helper")

-- Setup
love_mock.setup()
test_helper.setup_path()

local RenderSystem = require("systems.render_system")
local Entity = require("ecs.entity")
local Components = require("ecs.component")

describe("Render System", function()
    local system
    local entity
    
    before_each(function()
        system = RenderSystem
        entity = Entity.new(1)
        entity:addComponent("Transform", Components.Transform.new(100, 150))
        
        system.entities = {}
    end)
    
    after_each(function()
        system.entities = {}
    end)
    
    describe("initialization", function()
        it("has correct type and base required components", function()
            assert.are.equal("RenderSystem", system.type)
            assert.are.same({"Transform"}, system.requiredComponents)
        end)
    end)
    
    describe("canProcessEntity", function()
        it("accepts entities with Transform and Render components", function()
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 20, "circle"))
            
            assert.is_true(system:canProcessEntity(entity))
        end)
        
        it("accepts entities with Transform and Image components", function()
            entity:addComponent("Image", Components.Image.new(nil, 64, 64))
            
            assert.is_true(system:canProcessEntity(entity))
        end)
        
        it("rejects entities with only Transform", function()
            assert.is_false(system:canProcessEntity(entity))
        end)
        
        it("rejects entities without Transform", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 20, "circle"))
            
            assert.is_false(system:canProcessEntity(entity2))
        end)
        
        it("accepts entities with Transform, Render, and Image", function()
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 20, "circle"))
            entity:addComponent("Image", Components.Image.new(nil, 32, 32))
            
            assert.is_true(system:canProcessEntity(entity))
        end)
    end)
    
    describe("update", function()
        it("update method exists and can be called", function()
            assert.has_no.errors(function()
                system:update(0.016)
            end)
        end)
    end)
    
    describe("render", function()
        it("handles rendering without errors", function()
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 15, "circle"))
            system:addEntity(entity)
            
            assert.has_no.errors(function()
                system:render()
            end)
        end)
        
        it("renders circle shapes correctly", function()
            local render = Components.Render.new({0.8, 0.2, 0.1, 1}, 25, "circle")
            entity:addComponent("Render", render)
            system:addEntity(entity)
            
            -- Mock love.graphics to track calls
            local circleDrawn = false
            local originalCircle = love.graphics.circle
            love.graphics.circle = function(mode, x, y, radius)
                circleDrawn = true
                assert.are.equal("fill", mode)
                assert.are.equal(100, x)
                assert.are.equal(150, y)
                assert.are.equal(25, radius)
            end
            
            system:render()
            
            assert.is_true(circleDrawn)
            love.graphics.circle = originalCircle
        end)
        
        it("renders rectangle shapes correctly", function()
            local render = Components.Render.new({0.2, 0.8, 0.1, 1}, 30, "rectangle")
            entity:addComponent("Render", render)
            system:addEntity(entity)
            
            -- Mock love.graphics to track calls
            local rectDrawn = false
            local originalRectangle = love.graphics.rectangle
            love.graphics.rectangle = function(mode, x, y, width, height)
                rectDrawn = true
                assert.are.equal("fill", mode)
                assert.are.equal(70, x) -- 100 - 30
                assert.are.equal(120, y) -- 150 - 30
                assert.are.equal(60, width) -- 30 * 2
                assert.are.equal(60, height) -- 30 * 2
            end
            
            system:render()
            
            assert.is_true(rectDrawn)
            love.graphics.rectangle = originalRectangle
        end)
        
        it("renders images correctly", function()
            local mockImage = { type = "Image" }
            local image = Components.Image.new(mockImage, 64, 64)
            image.scaleX = 1.5  -- Set scale after creation
            image.scaleY = 2.0
            entity:addComponent("Image", image)
            system:addEntity(entity)
            
            -- Mock love.graphics.draw to track calls
            local imageDrawn = false
            local originalDraw = love.graphics.draw
            love.graphics.draw = function(img, x, y, rotation, scaleX, scaleY, offsetX, offsetY)
                imageDrawn = true
                assert.are.equal(mockImage, img)
                assert.are.equal(100, x)
                assert.are.equal(150, y)
                assert.are.equal(0, rotation or 0)
                -- The mock passes nil for these parameters in the love mock
                if scaleX then assert.are.equal(1.5, scaleX) end
                if scaleY then assert.are.equal(2.0, scaleY) end  
                if offsetX then assert.are.equal(32, offsetX) end -- width / 2
                if offsetY then assert.are.equal(32, offsetY) end -- height / 2
            end
            
            system:render()
            
            assert.is_true(imageDrawn)
            love.graphics.draw = originalDraw
        end)
        
        it("handles rotation for images", function()
            local transform = entity:getComponent("Transform")
            transform.rotation = math.pi / 4 -- 45 degrees
            
            local mockImage = { type = "Image" }
            local image = Components.Image.new(mockImage, 32, 32)
            entity:addComponent("Image", image)
            system:addEntity(entity)
            
            local rotationPassed = false
            local originalDraw = love.graphics.draw
            love.graphics.draw = function(img, x, y, rotation)
                rotationPassed = (rotation == math.pi / 4)
            end
            
            system:render()
            
            assert.is_true(rotationPassed)
            love.graphics.draw = originalDraw
        end)
        
        it("skips inactive entities", function()
            entity:addComponent("Render", Components.Render.new({1, 1, 1, 1}, 10, "circle"))
            entity:deactivate()
            system:addEntity(entity)
            
            local circleDrawn = false
            local originalCircle = love.graphics.circle
            love.graphics.circle = function() circleDrawn = true end
            
            system:render()
            
            assert.is_false(circleDrawn)
            love.graphics.circle = originalCircle
        end)
        
        it("handles entities with both render and image components", function()
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 10, "circle"))
            entity:addComponent("Image", Components.Image.new({type = "Image"}, 32, 32))
            system:addEntity(entity)
            
            -- Should render the Render component (circles have priority)
            local circleDrawn = false
            local imageDrawn = false
            local originalCircle = love.graphics.circle
            local originalDraw = love.graphics.draw
            
            love.graphics.circle = function() circleDrawn = true end
            love.graphics.draw = function() imageDrawn = true end
            
            system:render()
            
            assert.is_true(circleDrawn)
            assert.is_false(imageDrawn) -- Image should not be drawn when Render exists
            
            love.graphics.circle = originalCircle
            love.graphics.draw = originalDraw
        end)
        
        it("handles missing image data gracefully", function()
            local image = Components.Image.new(nil, 32, 32) -- nil image
            entity:addComponent("Image", image)
            system:addEntity(entity)
            
            assert.has_no.errors(function()
                system:render()
            end)
        end)
    end)
    
    describe("multiple entities", function()
        it("renders multiple entities independently", function()
            local entity2 = Entity.new(2)
            entity2:addComponent("Transform", Components.Transform.new(200, 250))
            entity2:addComponent("Render", Components.Render.new({0, 1, 0, 1}, 15, "rectangle"))
            
            entity:addComponent("Render", Components.Render.new({1, 0, 0, 1}, 20, "circle"))
            
            system:addEntity(entity)
            system:addEntity(entity2)
            
            local circleCount = 0
            local rectCount = 0
            
            local originalCircle = love.graphics.circle
            local originalRectangle = love.graphics.rectangle
            
            love.graphics.circle = function() circleCount = circleCount + 1 end
            love.graphics.rectangle = function() rectCount = rectCount + 1 end
            
            system:render()
            
            assert.are.equal(1, circleCount)
            assert.are.equal(1, rectCount)
            
            love.graphics.circle = originalCircle
            love.graphics.rectangle = originalRectangle
        end)
    end)
end)