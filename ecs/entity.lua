-- =============================================================================
-- ENTITY CLASS
-- =============================================================================
local Entity = {}
Entity.__index = Entity

function Entity.new(id)
    local self = setmetatable({}, Entity)
    self.id = id
    self.components = {}
    self.active = true
    return self
end

function Entity:addComponent(componentType, component)
    self.components[componentType] = component
    return self
end

function Entity:getComponent(componentType)
    return self.components[componentType]
end

function Entity:hasComponent(componentType)
    return self.components[componentType] ~= nil
end

function Entity:removeComponent(componentType)
    self.components[componentType] = nil
end

function Entity:destroy()
    self.active = false
    self.components = {}
end

return Entity
