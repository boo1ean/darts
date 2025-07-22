# Documentation Maintenance Guide

## Overview
This guide ensures AI agents keep documentation up-to-date as the project evolves.

## When to Update Documentation

### Mandatory Updates
AI agents MUST update documentation when making these changes:

#### Architecture Changes → Update `architecture.md`
- Adding new component types or design patterns
- Modifying system processing order in main.lua
- Changing ECS design principles or rules
- Adding new factory patterns or entity creation methods
- Modifying component-system relationships

#### Code Standards → Update `conventions.md`
- Introducing new naming conventions
- Modifying module structure templates
- Changing error handling patterns
- Adding new testing patterns or requirements
- Updating code formatting rules

#### Tooling Changes → Update `tools.md`
- Adding new scripts to scripts/ directory
- Modifying existing script behavior or parameters
- Adding new development commands or workflows
- Changing build, test, or deployment processes
- Adding new dependencies or requirements

#### Game Mechanics → Update `context.md`
- Adding new gameplay features or mechanics
- Modifying scoring system or rules
- Changing movement patterns or physics
- Adding new visual effects or rendering
- Modifying input handling or controls

#### Problem Solutions → Update `troubleshooting.md`
- Encountering new error patterns
- Finding solutions to recurring problems
- Discovering new debugging techniques
- Identifying performance optimization opportunities
- Resolving integration or compatibility issues

#### Task Patterns → Update `common-tasks.md`
- Adding new development task types
- Changing existing task workflows
- Discovering better implementation patterns
- Adding new code generation or automation
- Updating testing or validation procedures

## Documentation Update Workflow

### Step 1: Identify Documentation Impact
Before making code changes, assess:
- Which documentation files will be affected?
- What new patterns or concepts are being introduced?
- Are existing examples still accurate?
- Do any existing guidelines need updating?

### Step 2: Update Documentation Concurrently
- Update docs DURING implementation, not after
- Keep examples aligned with actual code
- Update decision trees and workflows
- Add new troubleshooting entries for issues encountered

### Step 3: Validate Documentation Changes
```bash
# Run documentation validation
./scripts/validate-docs.sh

# Check for broken links and outdated examples
grep -r "TODO\|FIXME" docs/ai/
```

### Step 4: Cross-Reference Updates
- Ensure consistent terminology across all docs
- Update cross-references between documents
- Verify examples match current code patterns
- Check that new content fits existing structure

## Specific Update Patterns

### Adding New Component
1. **Update architecture.md**:
   - Add to component list and description
   - Document data fields and purpose
   - Update system processing order if needed

2. **Update common-tasks.md**:
   - Add component to examples if relevant
   - Update factory usage patterns
   - Add testing examples

3. **Update conventions.md**:
   - Add component naming if new pattern
   - Update module structure if changed

### Adding New System
1. **Update architecture.md**:
   - Add to system processing order
   - Document component requirements
   - Explain system's role and logic

2. **Update common-tasks.md**:
   - Add system creation example
   - Update integration patterns
   - Add testing examples

### Modifying Game Mechanics
1. **Update context.md**:
   - Revise gameplay descriptions
   - Update scoring or physics explanations
   - Modify technical constraints if changed

2. **Update troubleshooting.md**:
   - Add new error patterns if discovered
   - Update performance considerations
   - Revise debugging techniques

### Adding New Scripts
1. **Update tools.md**:
   - Add script description and usage
   - Update available scripts list
   - Add to usage examples section

2. **Update development-workflow.md**:
   - Integrate script into workflow phases
   - Update quality gates if script affects validation
   - Add to best practices if relevant

## Documentation Quality Standards

### Content Requirements
- **Accuracy**: All examples must work with current code
- **Completeness**: Cover all major use cases and patterns
- **Clarity**: Use clear, concise language
- **Consistency**: Maintain consistent terminology and structure

### Example Standards
- Code examples must be syntactically correct
- Examples should reflect current project structure
- Include both basic and advanced usage patterns
- Show integration between components/systems

### Link Maintenance
- All internal links must be valid
- External links should be checked periodically
- File path references must be accurate
- Cross-references should be bidirectional where relevant

## Automation Integration

### Test Integration
Add documentation validation to test.sh:
```bash
# In scripts/test.sh, add after linting
if [ -x "./scripts/validate-docs.sh" ]; then
    echo -n "Validating documentation... "
    if ./scripts/validate-docs.sh > /dev/null 2>&1; then
        echo "✅"
    else
        echo "❌"
        echo "  Run './scripts/validate-docs.sh' to see documentation issues"
        FAILED=1
    fi
fi
```

### Pre-commit Hooks
Consider adding documentation checks to git hooks:
```bash
# .git/hooks/pre-commit
#!/bin/bash
if [ -x "scripts/validate-docs.sh" ]; then
    scripts/validate-docs.sh
fi
```

## Documentation Debt Management

### Identifying Technical Debt
- TODO/FIXME comments in documentation
- Outdated examples that no longer work
- Missing documentation for new features
- Inconsistent terminology across files

### Debt Resolution Process
1. **Prioritize**: Focus on user-facing documentation first
2. **Batch updates**: Group related changes together
3. **Validate**: Ensure all changes maintain consistency
4. **Review**: Check that updates improve clarity

### Prevention Strategies
- Make documentation updates part of feature development
- Use documentation validation in CI/CD pipeline
- Regular documentation review cycles
- Clear ownership of documentation sections

## Metrics and Monitoring

### Documentation Health Indicators
- Documentation validation script success rate
- Number of TODO/FIXME items in docs
- Frequency of documentation updates
- User feedback on documentation clarity

### Regular Maintenance Tasks
- **Weekly**: Run validation script and fix issues
- **Monthly**: Review TODO items and outdated examples
- **Quarterly**: Full documentation review and cleanup
- **Per release**: Comprehensive accuracy check

## Best Practices for AI Agents

### Documentation-First Approach
- Update documentation before implementing changes
- Use documentation as design specification
- Validate implementation against updated docs

### Incremental Updates
- Make small, focused documentation changes
- Update related sections together
- Maintain consistency across updates

### Quality Gates
- Documentation must pass validation before completion
- Examples must be tested and verified
- Cross-references must be accurate and useful