-- Test for ECS World
local test_helper = require("tests.helpers.test_helper")

-- Setup path first
test_helper.setup_path()

-- Mock Love2D timer
_G.love = {
    timer = { getTime = function() return 1.0 end }
}

local World = require("ecs.world")
local Components = require("ecs.component")

describe("World", function()
    local world
    
    before_each(function()
        world = World.new()
    end)
    
    describe("initialization", function()
        it("creates a new world with empty entities and systems", function()
            assert.are.equal(0, #world.entities)
            assert.are.equal(0, #world.systems)
            assert.are.equal(1, world.nextEntityId)
        end)
        
        it("initializes game state", function()
            assert.is_not_nil(world.gameState)
            assert.are.equal(0, world.gameState.totalScore)
            assert.are.equal(0, world.gameState.hitCount)
        end)
    end)
    
    describe("entity management", function()
        it("creates entities with unique IDs", function()
            local entity1 = world:createEntity()
            local entity2 = world:createEntity()
            
            assert.are.equal(1, entity1.id)
            assert.are.equal(2, entity2.id)
            assert.are.equal(2, #world.entities)
        end)
        
        it("adds components to entities", function()
            local entity = world:createEntity()
            local transform = Components.Transform.new(10, 20)
            
            world:addComponentToEntity(entity, "Transform", transform)
            
            local retrievedTransform = entity:getComponent("Transform")
            assert.is_not_nil(retrievedTransform)
            assert.are.equal(10, retrievedTransform.x)
            assert.are.equal(20, retrievedTransform.y)
        end)
        
        it("removes entities from world", function()
            local entity = world:createEntity()
            assert.are.equal(1, #world.entities)
            
            world:removeEntity(entity)
            assert.are.equal(0, #world.entities)
        end)
    end)
    
    describe("component queries", function()
        it("finds entities with specific components", function()
            local entity1 = world:createEntity()
            local entity2 = world:createEntity()
            
            world:addComponentToEntity(entity1, "Transform", Components.Transform.new(0, 0))
            world:addComponentToEntity(entity2, "Render", Components.Render.new({1, 0, 0, 1}, 10))
            
            local transformEntities = world:getEntitiesWithComponent("Transform")
            local renderEntities = world:getEntitiesWithComponent("Render")
            
            assert.are.equal(1, #transformEntities)
            assert.are.equal(1, #renderEntities)
            assert.are.equal(entity1.id, transformEntities[1].id)
            assert.are.equal(entity2.id, renderEntities[1].id)
        end)
        
        it("returns empty array for non-existent component type", function()
            local entity = world:createEntity()
            world:addComponentToEntity(entity, "Transform", Components.Transform.new(0, 0))
            
            local result = world:getEntitiesWithComponent("NonExistent")
            assert.are.equal(0, #result)
        end)
    end)
    
    describe("system management", function()
        local mockSystem
        
        before_each(function()
            mockSystem = {
                entities = {},
                addEntity = function(self, entity) 
                    table.insert(self.entities, entity)
                end,
                removeEntity = function(self, entity)
                    for i, e in ipairs(self.entities) do
                        if e.id == entity.id then
                            table.remove(self.entities, i)
                            break
                        end
                    end
                end,
                update = function(self, dt) self.updateCalled = true; self.lastDt = dt end,
                render = function(self) self.renderCalled = true end
            }
        end)
        
        it("adds systems and connects existing entities", function()
            world:createEntity()
            world:createEntity()
            
            world:addSystem(mockSystem)
            
            assert.are.equal(1, #world.systems)
            assert.are.equal(2, #mockSystem.entities)
        end)
        
        it("updates all systems with delta time", function()
            world:addSystem(mockSystem)
            
            world:update(0.016)
            
            assert.is_true(mockSystem.updateCalled)
            assert.are.equal(0.016, mockSystem.lastDt)
        end)
        
        it("renders all systems with render method", function()
            world:addSystem(mockSystem)
            
            world:render()
            
            assert.is_true(mockSystem.renderCalled)
        end)
        
        it("skips systems without update method", function()
            local systemNoUpdate = { entities = {} }
            world:addSystem(systemNoUpdate)
            
            assert.has_no.errors(function()
                world:update(0.016)
            end)
        end)
        
        it("skips systems without render method", function()
            local systemNoRender = { entities = {} }
            world:addSystem(systemNoRender)
            
            assert.has_no.errors(function()
                world:render()
            end)
        end)
    end)
    
    describe("component removal", function()
        local mockSystem
        
        before_each(function()
            mockSystem = {
                entities = {},
                addEntity = function(self, entity) 
                    if not self.canProcessEntity or self:canProcessEntity(entity) then
                        table.insert(self.entities, entity)
                    end
                end,
                removeEntity = function(self, entity)
                    for i, e in ipairs(self.entities) do
                        if e.id == entity.id then
                            table.remove(self.entities, i)
                            break
                        end
                    end
                end,
                canProcessEntity = function(self, entity)
                    return entity:hasComponent("Transform")
                end
            }
        end)
        
        it("removes components and updates systems", function()
            local entity = world:createEntity()
            world:addComponentToEntity(entity, "Transform", Components.Transform.new(0, 0))
            world:addComponentToEntity(entity, "Render", Components.Render.new({1, 1, 1, 1}, 5))
            
            world:addSystem(mockSystem)
            assert.are.equal(1, #mockSystem.entities)
            
            world:removeComponentFromEntity(entity, "Transform")
            
            assert.is_false(entity:hasComponent("Transform"))
            assert.are.equal(0, #mockSystem.entities)
        end)
    end)
    
    describe("clear", function()
        it("clears all entities and system references", function()
            local entity1 = world:createEntity()
            local entity2 = world:createEntity()
            
            local mockSystem = {
                entities = {entity1, entity2},
                addEntity = function(self, entity) end
            }
            world:addSystem(mockSystem)
            
            assert.are.equal(2, #world.entities)
            assert.are.equal(2, #mockSystem.entities)
            
            world:clear()
            
            assert.are.equal(0, #world.entities)
            assert.are.equal(0, #mockSystem.entities)
        end)
    end)
end)