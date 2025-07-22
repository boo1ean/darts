# Development Workflow

## Overview
This document describes the complete development workflow for AI agents working on the Love2D Darts project.

## Pre-Development Setup

### 1. Environment Verification
```bash
# Verify all tools are available
./scripts/setup.sh

# Check current project state
./scripts/test.sh
```

### 2. Understanding the Codebase
**Read in this order**:
1. `CLAUDE.md` - Quick reference and validation rules
2. `docs/ai/architecture.md` - ECS patterns and design principles
3. `docs/ai/conventions.md` - Code standards and style guide
4. `docs/ai/context.md` - Game mechanics and domain knowledge

## Development Cycle

### Phase 1: Planning
1. **Understand the requirement**
   - Read user request carefully
   - Identify scope and complexity
   - Determine if it's a feature, bug fix, or refactor

2. **Research existing code**
   - Search for similar implementations
   - Identify affected systems/components
   - Check for existing patterns to follow

3. **Plan approach**
   - Determine if new components/systems are needed
   - Identify integration points
   - Consider testing strategy

### Phase 2: Implementation
1. **Establish baseline**
   ```bash
   ./scripts/test.sh  # Must pass before starting
   ```

2. **Make incremental changes**
   - Follow ECS architecture patterns
   - Use existing components/systems when possible
   - Create new components/systems only when necessary

3. **Test frequently**
   ```bash
   ./scripts/test.sh  # After each significant change
   ```

4. **Follow code conventions**
   - Use proper naming (snake_case, PascalCase)
   - Follow module structure patterns
   - Add appropriate comments

### Phase 3: Validation
1. **Run full test suite**
   ```bash
   ./scripts/test.sh  # Must pass completely
   ```

2. **Check code quality**
   ```bash
   ./scripts/lint.sh  # Must pass without errors
   ```

3. **Verify game functionality**
   ```bash
   ./scripts/run.sh   # Manual verification
   ```

4. **Architecture compliance check**
   - Components contain only data + helper methods
   - Systems contain only logic, no persistent state
   - Entities created through factories
   - Proper system registration order

### Phase 4: Documentation
1. **Update relevant documentation** (if needed)
   - Add new components to architecture overview
   - Document breaking changes
   - Update troubleshooting guide with new patterns

2. **Add appropriate comments**
   - Complex algorithms
   - Non-obvious design decisions
   - Integration points

## Error Handling Protocol

### When Tests Fail
1. **Don't ignore failures** - Fix or ask for guidance
2. **Check linting first** - Many failures are code quality issues
3. **Isolate the problem** - Run specific test files
4. **Understand the failure** - Read error messages carefully

### When Scripts Fail
1. **Check dependencies** - Run `./scripts/setup.sh`
2. **Verify permissions** - Scripts should be executable
3. **Check PATH** - Lua tools must be available

### When Unsure About ECS Patterns
1. **Reference architecture.md** - Contains all design patterns
2. **Look at existing code** - Follow established patterns
3. **Ask for clarification** - Better than guessing

## Quality Gates

### Before Starting Work
- [ ] All tests pass (`./scripts/test.sh`)
- [ ] No linting errors (`./scripts/lint.sh`)
- [ ] Understanding of requirement is clear
- [ ] Relevant documentation has been read

### During Development
- [ ] Changes follow ECS architecture
- [ ] Code follows established conventions
- [ ] Tests pass after each major change
- [ ] Components extend BaseComponent
- [ ] Systems extend BaseSystem

### Before Completing Task
- [ ] Full test suite passes
- [ ] No linting errors
- [ ] Game runs without errors
- [ ] Manual verification successful
- [ ] Architecture patterns maintained

## Common Workflow Patterns

### Adding New Game Feature
1. Read `docs/ai/context.md` for game mechanics
2. Check existing systems for similar functionality
3. Create component(s) for data storage
4. Create system(s) for logic processing
5. Use factory to create entities
6. Register system in correct order in `main.lua`
7. Test integration with existing systems

### Fixing Bug
1. Reproduce the bug
2. Run tests to isolate the problem
3. Identify affected components/systems
4. Make minimal changes to fix issue
5. Verify fix doesn't break other functionality
6. Add regression test if appropriate

### Performance Optimization
1. Profile to identify bottlenecks
2. Review system processing order
3. Minimize component lookups in hot paths
4. Consider spatial indexing for collision detection
5. Benchmark improvements

### Refactoring
1. Ensure full test coverage of affected code
2. Make changes incrementally
3. Maintain ECS architecture principles
4. Run tests after each step
5. Verify no functionality regression

## Best Practices

### Code Organization
- Keep components simple and data-focused
- Make systems stateless and logic-focused
- Use factories for complex entity creation
- Group related functionality in behaviors

### Testing Strategy
- Test components as data structures
- Test systems with mock entities
- Use integration tests for complex interactions
- Test edge cases and error conditions

### Performance Considerations
- Process only entities with required components
- Batch similar operations in single systems
- Use timers for delayed actions vs polling
- Profile before optimizing

## Emergency Procedures

### Project Won't Build
1. Check for syntax errors in recent changes
2. Verify all require() paths are correct
3. Run `./scripts/lint.sh` for detailed errors
4. Consider reverting recent changes

### Tests Completely Broken
1. Backup current work: `git stash`
2. Reset to known good state
3. Run baseline tests
4. Apply changes incrementally

### Unknown Error Patterns
1. Check `docs/ai/troubleshooting.md`
2. Enable debug mode in config.lua
3. Add debug prints to isolate issue
4. Create minimal reproduction case

## Communication Protocol

### Status Updates
- Report progress on complex tasks
- Flag blockers early
- Ask questions when patterns are unclear

### Error Reporting
- Include exact error messages
- Provide steps to reproduce
- Share current git state
- Include output of test and lint scripts

### Completion Verification
- Confirm all quality gates passed
- Verify game functionality works as expected
- Document any assumptions or limitations