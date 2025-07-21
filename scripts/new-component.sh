#!/bin/bash

# Create a new component from template
# Usage: ./scripts/new-component.sh <component_name>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <component_name>"
    echo "Example: $0 health"
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Convert to snake_case
COMPONENT_NAME=$(echo "$1" | sed 's/[A-Z]/_&/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')
COMPONENT_FILE="components/${COMPONENT_NAME}_component.lua"

# Check if component already exists
if [ -f "$COMPONENT_FILE" ]; then
    echo "❌ Component already exists: $COMPONENT_FILE"
    exit 1
fi

# Create component file
cat > "$COMPONENT_FILE" << EOF
-- =============================================================================
-- ${COMPONENT_NAME^^} COMPONENT
-- =============================================================================

local BaseComponent = require('components.base_component')

local ${COMPONENT_NAME^}Component = {}
${COMPONENT_NAME^}Component.__index = ${COMPONENT_NAME^}Component
setmetatable(${COMPONENT_NAME^}Component, {__index = BaseComponent})

-- =============================================================================
-- CONSTRUCTOR
-- =============================================================================
function ${COMPONENT_NAME^}Component.new(data)
    local self = setmetatable(BaseComponent.new('${COMPONENT_NAME}'), ${COMPONENT_NAME^}Component)
    
    -- TODO: Add component properties here
    -- Example:
    -- self.value = data.value or 0
    -- self.max_value = data.max_value or 100
    
    return self
end

return ${COMPONENT_NAME^}Component
EOF

echo "✅ Created component: $COMPONENT_FILE"
echo ""
echo "Next steps:"
echo "1. Edit $COMPONENT_FILE to add properties"
echo "2. Add to component loader in ecs/component.lua"
echo "3. Create a system to process this component"
echo "4. Create tests in tests/components/${COMPONENT_NAME}_test.lua"