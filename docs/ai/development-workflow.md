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
1. `CLAUDE.md` - Quick reference, scripts, and validation rules
2. `docs/ai/architecture.md` - Complete ECS patterns and implementation guide
3. `docs/ai/context.md` - Game mechanics and domain knowledge
4. `docs/ai/troubleshooting.md` - Common issues (as needed)

## Development Cycle

### Phase 1: Planning

#### 1. Gather Complete Requirements
**CRITICAL**: AI agents MUST ask clarifying questions before implementing any functionality. Never assume or guess requirements.

**Standard Clarification Process:**
Ask questions until you have clear understanding of:
- **Exact behavior** - What should happen step by step?
- **Visual appearance** - How should it look to the user?
- **Interaction patterns** - How does user interact with it?
- **Integration points** - How does it fit with existing systems?
- **Edge cases** - What happens in unusual situations?
- **Performance requirements** - Any speed/memory constraints?

**Required Questions for New Features:**
```
I need to understand the exact requirements before implementing [feature name].

Please clarify:
1. **Behavior**: What should happen when [specific action occurs]?
2. **Visuals**: How should this appear on screen? (colors, size, position, animations)
3. **User interaction**: How does the user trigger/control this feature?
4. **Integration**: How should this work with existing [relevant systems]?
5. **Edge cases**: What should happen if [specific scenario]?
6. **Success criteria**: How will you know this is working correctly?
```

**Feature-Specific Question Templates:**

*Visual Effects:*
- What colors, size, and position?
- Should it animate? If so, how (fade, slide, bounce)?
- How long should it be visible?
- Should it block other interactions?

*Game Mechanics:*
- What triggers the behavior?
- What are the exact rules or calculations?
- How does it affect scoring or gameplay?
- Should it be configurable?

*UI Elements:*
- Where should it appear on screen?
- What information should it display?
- How should users interact with it?
- Should it be persistent or temporary?

*Movement/Physics:*
- What type of movement pattern?
- Speed and direction parameters?
- Should it respond to collisions?
- Any constraints or boundaries?

#### Examples of Good Clarification Conversations

**Example 1: Vague Request**
```
User: "Add power-ups to the game"
Agent: "I need to understand the exact requirements before implementing power-ups.

Please clarify:
1. **Behavior**: What should power-ups do when collected? (speed boost, extra points, etc.)
2. **Visuals**: How should they appear? (shapes, colors, size, glow effects?)
3. **User interaction**: How does the player collect them? (dart hits them, automatic on proximity?)
4. **Integration**: Should they spawn randomly or at specific times/locations?
5. **Edge cases**: What if multiple power-ups are collected at once?
6. **Success criteria**: How will you know this is working correctly?"
```

**Example 2: Implementation Detail Questions**
```
User: "Make the dartboard shake when hit"
Agent: "I can add dartboard shake on hit. To implement this correctly:

1. **Behavior**: Should shake intensity vary based on hit strength or dart type?
2. **Visuals**: How intense should the shake be (subtle vibration vs dramatic shake)?
3. **Duration**: How long should the shake last?
4. **Integration**: Should it affect dart physics while shaking, or just visual?
5. **Edge cases**: What if multiple darts hit during the shake?
6. **Success criteria**: Should it shake for every hit or only certain scoring areas?"
```

**Example 3: Follow-up Questions**
```
User: "Add a scoring multiplier effect"
Agent: "I need more details about the multiplier effect:

1. **Trigger**: What activates the multiplier? (consecutive hits, specific targets, time-based?)
2. **Visual feedback**: How should players know multiplier is active? (text, color changes, animations?)
3. **Multiplier value**: What's the multiplication factor? (2x, 3x, variable?)
4. **Duration**: How long does it last?
5. **Stacking**: Can multiple multipliers stack or do they reset each other?
6. **Integration**: Does it apply to all scoring or specific dart types?"

User: "Consecutive hits in the bullseye, 2x multiplier, shows golden glow around dartboard"
Agent: "Thanks! A few more details:

1. How many consecutive bullseye hits trigger it?
2. How long should the golden glow last?
3. Should the multiplier reset after one non-bullseye hit?
4. Should there be a sound effect when activated?"
```

**Key Principles:**
- **Never assume** - Always ask rather than guess
- **Be specific** - Ask about exact behavior, not general concepts
- **Think edge cases** - Consider unusual situations
- **Ask for success criteria** - How will you know it's working?
- **Iterate** - Ask follow-up questions as needed

#### 2. Understand the requirement
   - Read user request carefully
   - **Ask clarifying questions** until all ambiguity is resolved
   - Identify scope and complexity
   - Determine if it's a feature, bug fix, or refactor

#### 3. Research existing code
   - Search for similar implementations
   - Identify affected systems/components
   - Check for existing patterns to follow

#### 4. Plan approach
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
**Use `./scripts/validate-all.sh` for comprehensive validation, or run individual steps:**

1. **Test suite**: `./scripts/test.sh` (must pass completely)
2. **Code quality**: `./scripts/lint.sh --fix` (auto-format and check)
3. **Game functionality**: `./scripts/validate-game.sh` (automated validation)
4. **Documentation**: `./scripts/validate-docs.sh` (if docs were modified)

**Architecture Compliance Check:**
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
- [ ] **ALL clarifying questions have been asked and answered**
- [ ] Understanding of requirement is clear and specific
- [ ] Relevant documentation has been read
- [ ] Success criteria are defined

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

### Manual Verification Process

**When to Request Manual Verification:**
- Visual/gameplay changes that cannot be fully tested via automated scripts
- Complex behavioral changes where automated tests may miss edge cases
- User experience improvements requiring subjective evaluation

**Manual Verification Steps:**
1. Start game: `./scripts/run-for-verification.sh`
2. Provide clear testing instructions to user
3. Wait for user feedback before proceeding
4. Stop game: `./scripts/stop-verification.sh`

**Request Format:**
```
Manual verification needed for [specific change].

Starting game for verification...

Please test: [specific behaviors to verify]
Expected: [what should happen]
```

### Completion Verification
- Confirm all quality gates passed
- Verify game functionality works as expected
- Document any assumptions or limitations