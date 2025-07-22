-- Simple test for ECS World without Love2D dependencies
local test_helper = require("tests.helpers.test_helper")
test_helper.setup_path()

local World = require("ecs.world")

describe("World (Simple)", function()
    local world
    
    before_each(function()
        world = World.new()
    end)
    
    describe("basic functionality", function()
        it("creates a new world with empty collections", function()
            assert.are.equal(0, #world.entities)
            assert.are.equal(0, #world.systems)
            assert.are.equal(1, world.nextEntityId)
        end)
        
        it("initializes game state correctly", function()
            assert.is_not_nil(world.gameState)
            assert.are.equal(0, world.gameState.totalScore)
            assert.are.equal(0, world.gameState.hitCount)
        end)
        
        it("creates entities with unique IDs", function()
            local entity1 = world:createEntity()
            local entity2 = world:createEntity()
            
            assert.are.equal(1, entity1.id)
            assert.are.equal(2, entity2.id)
            assert.are.equal(2, #world.entities)
        end)
        
        it("removes entities from world", function()
            local entity = world:createEntity()
            assert.are.equal(1, #world.entities)
            
            world:removeEntity(entity)
            assert.are.equal(0, #world.entities)
        end)
        
        it("clears all entities and systems", function()
            world:createEntity()
            world:createEntity()
            assert.are.equal(2, #world.entities)
            
            world:clear()
            assert.are.equal(0, #world.entities)
        end)
    end)
end)