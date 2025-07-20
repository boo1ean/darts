-- =============================================================================
-- SYSTEM BASE CLASS
-- =============================================================================
local System = {}
System.__index = System

function System.new(systemType, requiredComponents)
    local self = setmetatable({}, System)
    self.type = systemType
    self.requiredComponents = requiredComponents or {}
    self.entities = {}
    return self
end

function System:addEntity(entity)
    if self:canProcessEntity(entity) then
        -- Check if entity is already in the system to avoid duplicates
        for _, e in ipairs(self.entities) do
            if e.id == entity.id then
                return  -- Entity already exists, don't add again
            end
        end
        table.insert(self.entities, entity)
    end
end

function System:removeEntity(entity)
    for i, e in ipairs(self.entities) do
        if e.id == entity.id then
            table.remove(self.entities, i)
            break
        end
    end
end

function System:canProcessEntity(entity)
    for _, componentType in ipairs(self.requiredComponents) do
        if not entity:hasComponent(componentType) then
            return false
        end
    end
    return true
end

function System:update(dt)
    -- Override in subclasses
end

return System 
