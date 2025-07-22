#!/bin/bash

# Comprehensive validation script that runs all project validation checks
# This script implements the "Mandatory Validation Steps" from CLAUDE.md

set -e  # Exit on any error

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validation step counter
STEP=1

# Function to print step headers
print_step() {
    echo
    echo -e "${BLUE}=== Step $STEP: $1 ===${NC}"
    ((STEP++))
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to print error and exit
print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Parse command line arguments
SKIP_TESTS=false
SKIP_GAME=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-game)
            SKIP_GAME=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Comprehensive validation script that runs all project validation checks."
            echo "Implements the 'Mandatory Validation Steps' from CLAUDE.md."
            echo ""
            echo "Options:"
            echo "  --skip-tests    Skip running the test suite (useful for quick validation)"
            echo "  --skip-game     Skip game functionality validation (useful for headless environments)"
            echo "  --verbose, -v   Show detailed output from each validation step"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Validation Steps Performed:"
            echo "  1. Test Suite         - ./scripts/test.sh"
            echo "  2. Code Quality       - ./scripts/lint.sh"
            echo "  3. Game Functionality - ./scripts/validate-game.sh"
            echo "  4. Documentation      - ./scripts/validate-docs.sh"
            echo "  5. Architecture       - ECS pattern compliance check"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🎯 Darts Game - Comprehensive Validation${NC}"
echo "Running all mandatory validation steps from CLAUDE.md"

# Step 1: Test Suite (includes lint as pre-check)
if [ "$SKIP_TESTS" = false ]; then
    print_step "Test Suite & Code Quality"
    if [ "$VERBOSE" = true ]; then
        ./scripts/test.sh
    else
        if ./scripts/test.sh > .tmp/validation-tests.log 2>&1; then
            print_success "All tests passed"
        else
            print_error "Tests failed. Run './scripts/test.sh' for details."
        fi
    fi
else
    print_step "Code Quality (Tests Skipped)"
    if [ "$VERBOSE" = true ]; then
        ./scripts/lint.sh
    else
        if ./scripts/lint.sh > .tmp/validation-lint.log 2>&1; then
            print_success "Code quality checks passed"
        else
            print_error "Linting failed. Run './scripts/lint.sh' for details."
        fi
    fi
fi

# Step 2: Game Functionality
if [ "$SKIP_GAME" = false ]; then
    print_step "Game Functionality"
    if [ "$VERBOSE" = true ]; then
        ./scripts/validate-game.sh
    else
        if ./scripts/validate-game.sh > .tmp/validation-game.log 2>&1; then
            print_success "Game starts and runs correctly"
        else
            print_error "Game validation failed. Run './scripts/validate-game.sh' for details."
        fi
    fi
else
    print_warning "Game functionality validation skipped"
fi

# Step 3: Documentation Consistency
print_step "Documentation Consistency"
if [ "$VERBOSE" = true ]; then
    ./scripts/validate-docs.sh || print_warning "Documentation issues found (see output above)"
else
    if ./scripts/validate-docs.sh > .tmp/validation-docs.log 2>&1; then
        print_success "Documentation is consistent and up-to-date"
    else
        print_warning "Documentation issues found. Run './scripts/validate-docs.sh' for details."
        # Don't fail on documentation issues, just warn
    fi
fi

# Step 4: Architecture Compliance
print_step "ECS Architecture Compliance"

# Check that components extend BaseComponent
COMPONENT_ISSUES=0
echo "Checking component architecture..."
for component_file in components/*.lua; do
    if [ -f "$component_file" ]; then
        filename=$(basename "$component_file" .lua)
        # Skip test files and base components
        if [[ ! "$filename" =~ _spec$ ]] && [[ "$filename" != "base_component" ]]; then
            # Check for proper BaseComponent extension pattern
            if ! grep -q "setmetatable.*BaseComponent" "$component_file"; then
                echo -e "${YELLOW}  ⚠ $filename may not properly extend BaseComponent${NC}"
                ((COMPONENT_ISSUES++))
            fi
        fi
    fi
done

# Check that systems extend BaseSystem  
SYSTEM_ISSUES=0
echo "Checking system architecture..."
for system_file in systems/*.lua; do
    if [ -f "$system_file" ]; then
        filename=$(basename "$system_file" .lua)
        # Skip test files and base systems
        if [[ ! "$filename" =~ _spec$ ]] && [[ "$filename" != "base_system" ]]; then
            # Check for proper BaseSystem extension pattern
            if ! grep -q "setmetatable.*BaseSystem" "$system_file"; then
                echo -e "${YELLOW}  ⚠ $filename may not properly extend BaseSystem${NC}"
                ((SYSTEM_ISSUES++))
            fi
        fi
    fi
done

# Check main.lua for proper system registration
echo "Checking system registration in main.lua..."
if [ -f "main.lua" ]; then
    # Look for world:addSystem or world:registerSystem patterns
    if grep -q -E "(addSystem|registerSystem)" main.lua; then
        print_success "Systems are properly registered"
    else
        echo -e "${YELLOW}  ⚠ No system registration found in main.lua${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ main.lua not found${NC}"
fi

if [ $COMPONENT_ISSUES -eq 0 ] && [ $SYSTEM_ISSUES -eq 0 ]; then
    print_success "ECS architecture compliance verified"
else
    print_warning "Architecture compliance issues found ($COMPONENT_ISSUES component, $SYSTEM_ISSUES system issues)"
fi

# Step 5: Final Summary
echo
echo -e "${BLUE}=== Validation Summary ===${NC}"

# Create .tmp directory if it doesn't exist
mkdir -p .tmp

# Check if any validation logs contain errors
TOTAL_ISSUES=0

if [ "$SKIP_TESTS" = false ]; then
    if [ -f ".tmp/validation-tests.log" ]; then
        # Look for test failures, not log messages that contain "error"
        TEST_FAILURES=$(grep -c "FAILED\|failures:" .tmp/validation-tests.log 2>/dev/null || echo 0)
        # Check the final status line for failure indicators
        if grep -q "✗\|failures\|FAILED" .tmp/validation-tests.log 2>/dev/null; then
            ((TOTAL_ISSUES += 1))
        fi
    fi
else
    if [ -f ".tmp/validation-lint.log" ]; then
        LINT_ERRORS=$(grep -c "warning\|error" .tmp/validation-lint.log 2>/dev/null || echo 0)
        if [ "$LINT_ERRORS" -gt 0 ]; then
            ((TOTAL_ISSUES += LINT_ERRORS))
        fi
    fi
fi

if [ "$SKIP_GAME" = false ] && [ -f ".tmp/validation-game.log" ]; then
    GAME_ERRORS=$(grep -c "Error\|FAILED" .tmp/validation-game.log 2>/dev/null || echo 0)
    if [ "$GAME_ERRORS" -gt 0 ]; then
        ((TOTAL_ISSUES += GAME_ERRORS))
    fi
fi

DOC_WARNINGS=$((COMPONENT_ISSUES + SYSTEM_ISSUES))

# Architecture issues are warnings, not critical failures for this legacy codebase
if [ $TOTAL_ISSUES -eq 0 ]; then
    print_success "All critical validations passed!"
    if [ $DOC_WARNINGS -gt 0 ]; then
        print_warning "$DOC_WARNINGS architecture/documentation warnings found"
        echo -e "${YELLOW}Consider updating legacy components to extend BaseComponent${NC}"
        echo -e "${YELLOW}Run individual validation scripts for more details${NC}"
    fi
    echo -e "${GREEN}✓ Project is ready for commit/deployment${NC}"
    exit 0
else
    print_error "$TOTAL_ISSUES critical validation failures found"
    echo -e "${RED}Please fix issues before committing changes.${NC}"
    echo -e "${YELLOW}Architecture warnings ($DOC_WARNINGS) are not blocking deployment${NC}"
    exit 1
fi