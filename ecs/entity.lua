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

function Entity:getComponentCount()
    local count = 0
    for _ in pairs(self.components) do
        count = count + 1
    end
    return count
end

function Entity:hasComponents(componentTypes)
    for _, componentType in ipairs(componentTypes) do
        if not self:hasComponent(componentType) then
            return false
        end
    end
    return true
end

function Entity:deactivate()
    self.active = false
end

function Entity:activate()
    self.active = true
end

function Entity:destroy()
    self.active = false
    self.components = {}
end

return Entity
