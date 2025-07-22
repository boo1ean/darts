#!/bin/bash

# Validate AI documentation is up-to-date
# Usage: ./scripts/validate-docs.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📚 Validating AI documentation..."
echo "================================="

FAILED=0

# Check if all components are documented in architecture.md
echo -n "Checking component documentation... "
COMPONENTS=$(find components/ -name "*_component.lua" | wc -l)
ARCH_COMPONENTS=$(grep -c "Component" docs/ai/architecture.md || true)

if [ "$COMPONENTS" -gt "$ARCH_COMPONENTS" ]; then
    echo "❌"
    echo "  Found $COMPONENTS components but only $ARCH_COMPONENTS documented"
    FAILED=1
else
    echo "✅"
fi

# Check if all systems are documented in architecture.md
echo -n "Checking system documentation... "
SYSTEMS=$(find systems/ -name "*_system.lua" | wc -l)
ARCH_SYSTEMS=$(grep -c "System" docs/ai/architecture.md || true)

if [ "$SYSTEMS" -gt "$ARCH_SYSTEMS" ]; then
    echo "❌"
    echo "  Found $SYSTEMS systems but only $ARCH_SYSTEMS documented"
    FAILED=1
else
    echo "✅"
fi

# Check if all scripts are documented in CLAUDE.md
echo -n "Checking script documentation... "
SCRIPTS=$(find scripts/ -name "*.sh" | wc -l)
CLAUDE_SCRIPTS=$(grep -c "scripts/.*\.sh" CLAUDE.md || true)

if [ "$SCRIPTS" -gt "$CLAUDE_SCRIPTS" ]; then
    echo "❌"
    echo "  Found $SCRIPTS scripts but only $CLAUDE_SCRIPTS documented in CLAUDE.md"
    FAILED=1
else
    echo "✅"
fi

# Check for TODO comments in documentation
echo -n "Checking for TODO items in docs... "
TODO_COUNT=$(grep -r "TODO\|FIXME\|XXX" docs/ai/ | wc -l || true)

if [ "$TODO_COUNT" -gt 0 ]; then
    echo "⚠️"
    echo "  Found $TODO_COUNT TODO items in documentation"
    grep -r "TODO\|FIXME\|XXX" docs/ai/ || true
else
    echo "✅"
fi

# Check for broken internal links
echo -n "Checking internal documentation links... "
BROKEN_LINKS=0

for file in docs/ai/*.md; do
    # Extract markdown links to other docs
    grep -o '\[.*\](docs/ai/.*\.md)' "$file" 2>/dev/null | while read -r link; do
        target=$(echo "$link" | sed 's/.*(\(.*\)).*/\1/')
        if [ ! -f "$target" ]; then
            echo "❌ Broken link in $file: $target"
            BROKEN_LINKS=$((BROKEN_LINKS + 1))
        fi
    done 2>/dev/null || true
done

if [ "$BROKEN_LINKS" -eq 0 ]; then
    echo "✅"
else
    echo "❌"
    FAILED=1
fi

echo ""
echo "================================="

# Report results
if [ $FAILED -eq 0 ]; then
    echo "✅ Documentation validation passed!"
    exit 0
else
    echo "❌ Documentation needs updates!"
    echo ""
    echo "To fix:"
    echo "1. Update relevant docs in docs/ai/"
    echo "2. Add missing component/system documentation"
    echo "3. Document new scripts in CLAUDE.md"
    echo "4. Resolve TODO items"
    exit 1
fi