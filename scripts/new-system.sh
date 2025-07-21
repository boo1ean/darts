#!/bin/bash

# Create a new system from template
# Usage: ./scripts/new-system.sh <system_name>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <system_name>"
    echo "Example: $0 health"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Convert to snake_case
SYSTEM_NAME=$(echo "$1" | sed 's/[A-Z]/_&/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')
SYSTEM_FILE="systems/${SYSTEM_NAME}_system.lua"

# Check if system already exists
if [ -f "$SYSTEM_FILE" ]; then
    echo "❌ System already exists: $SYSTEM_FILE"
    exit 1
fi

# Create system file
cat > "$SYSTEM_FILE" << EOF
-- =============================================================================
-- ${SYSTEM_NAME^^} SYSTEM
-- =============================================================================

local BaseSystem = require('ecs.base_system')

local ${SYSTEM_NAME^}System = BaseSystem:new()

function ${SYSTEM_NAME^}System:new()
    local system = BaseSystem.new(self, {
        -- TODO: Add required components here
        -- Example: 'transform', 'health'
    })
    
    -- System-specific initialization
    
    return system
end

-- =============================================================================
-- SYSTEM LIFECYCLE
-- =============================================================================

function ${SYSTEM_NAME^}System:init(world)
    self.world = world
    -- TODO: Add initialization logic
end

function ${SYSTEM_NAME^}System:update(dt)
    -- Process each entity with required components
    for _, entity in ipairs(self.entities) do
        -- TODO: Add update logic here
        -- Example:
        -- local health = entity:getComponent('health')
        -- if health.value <= 0 then
        --     self.world:removeEntity(entity)
        -- end
    end
end

-- Optional: Add render method if this system needs to draw
-- function ${SYSTEM_NAME^}System:render()
--     for _, entity in ipairs(self.entities) do
--         -- TODO: Add render logic
--     end
-- end

return ${SYSTEM_NAME^}System
EOF

echo "✅ Created system: $SYSTEM_FILE"
echo ""
echo "Next steps:"
echo "1. Edit $SYSTEM_FILE to add logic"
echo "2. Add required components in the constructor"
echo "3. Add to system loader in ecs/system.lua"
echo "4. Add to world in main.lua"
echo "5. Create tests in tests/systems/${SYSTEM_NAME}_test.lua"