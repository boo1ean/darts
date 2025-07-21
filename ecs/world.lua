-- =============================================================================
-- WORLD CLASS - ECS MANAGER
-- =============================================================================
local Entity = require("ecs.entity")

local World = {}
World.__index = World

function World.new()
    local self = setmetatable({}, World)
    self.entities = {}
    self.systems = {}
    self.nextEntityId = 1
    -- Global game state storage for ECS-compliant data access
    self.gameState = {
        totalScore = 0,
        hitCount = 0,
    }
    return self
end

function World:createEntity()
    local entity = Entity.new(self.nextEntityId)
    self.nextEntityId = self.nextEntityId + 1
    table.insert(self.entities, entity)

    -- Don't add to systems immediately - wait until components are added
    return entity
end

function World:addSystem(system)
    table.insert(self.systems, system)
    -- Add existing entities to the system
    for _, entity in ipairs(self.entities) do
        system:addEntity(entity)
    end
end

function World:addComponentToEntity(entity, componentType, component)
    entity:addComponent(componentType, component)

    -- Notify all systems about the component addition
    for _, system in ipairs(self.systems) do
        system:addEntity(entity)
    end
end

function World:removeComponentFromEntity(entity, componentType)
    entity:removeComponent(componentType)

    -- Update all systems - they will re-evaluate if entity matches their requirements
    for _, system in ipairs(self.systems) do
        system:removeEntity(entity) -- Remove first
        system:addEntity(entity) -- Re-add if it still matches
    end
end

function World:removeEntity(entity)
    -- Remove from all systems
    for _, system in ipairs(self.systems) do
        system:removeEntity(entity)
    end

    -- Remove from world
    for i, e in ipairs(self.entities) do
        if e.id == entity.id then
            table.remove(self.entities, i)
            break
        end
    end
end

function World:update(dt)
    for _, system in ipairs(self.systems) do
        if system.update then
            system:update(dt)
        end
    end
end

function World:render()
    for _, system in ipairs(self.systems) do
        if system.render then
            system:render()
        end
    end
end

function World:getEntitiesWithComponent(componentType)
    local result = {}
    for _, entity in ipairs(self.entities) do
        if entity:hasComponent(componentType) then
            table.insert(result, entity)
        end
    end
    return result
end

function World:clear()
    self.entities = {}
    for _, system in ipairs(self.systems) do
        system.entities = {}
    end
end

return World
