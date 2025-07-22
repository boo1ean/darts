-- Test helper utilities
local test_helper = {}

-- Set up the Lua path to find project modules
function test_helper.setup_path()
    local project_root = "."
    package.path = project_root .. "/?.lua;" .. project_root .. "/?/init.lua;" .. package.path
end

-- Create a simple entity for testing
function test_helper.create_test_entity(world, components)
    local entity = world:createEntity()

    if components then
        for componentType, componentData in pairs(components) do
            world:addComponentToEntity(entity, componentType, componentData)
        end
    end

    return entity
end

-- Assert that an entity has specific components
function test_helper.assert_has_components(entity, componentTypes)
    for _, componentType in ipairs(componentTypes) do
        assert.is_not_nil(entity:getComponent(componentType), "Entity should have " .. componentType .. " component")
    end
end

-- Create a minimal world for testing
function test_helper.create_test_world()
    local World = require("ecs.world")
    return World.new()
end

return test_helper
