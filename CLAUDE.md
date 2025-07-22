# AI Agent Instructions for Love2D Darts Game

## Project Overview
ECS-based dartboard game built with Love2D. Features moving targets with complex movement patterns, physics-based dartboard reactions, and animated scoring system.

## Essential Reading Order
1. `docs/ai/architecture.md` - Understand the ECS design and core patterns
2. `docs/ai/conventions.md` - Follow project code standards
3. `docs/ai/tools.md` - Available scripts and automation
4. `docs/ai/context.md` - Game mechanics and domain knowledge
5. `docs/ai/troubleshooting.md` - Common issues and solutions
6. `docs/ai/development-workflow.md` - Complete development process
7. `docs/ai/common-tasks.md` - Task-specific guidance and examples
8. `docs/ai/documentation-maintenance.md` - Keeping docs up-to-date

## Quick Reference
### Common Commands
- Test: `./scripts/test.sh`
- Lint: `./scripts/lint.sh`  
- Validate game: `./scripts/validate-game.sh` (silent, for AI agents)
- Run game: `./scripts/run.sh` (verbose, for development)
- Start for verification: `./scripts/run-for-verification.sh` (silent, for manual testing)
- Stop verification: `./scripts/stop-verification.sh`
- New component: `./scripts/new-component.sh <name>`
- New system: `./scripts/new-system.sh <name>`

### Critical Files (Read First)
- `docs/ai/architecture.md` - ECS patterns
- `docs/ai/conventions.md` - Code standards
- `main.lua` - System registration order

## Mandatory Validation Steps
1. **Before any changes**: Run `./scripts/test.sh` to establish baseline
2. **After implementation**: Run full test suite and fix all failures
3. **Code quality**: Run `./scripts/lint.sh` and address all issues
4. **Game functionality**: Run `./scripts/validate-game.sh` to verify game works
5. **Architecture compliance**: Verify ECS patterns are followed
6. **Documentation**: Run `./scripts/validate-docs.sh` and update affected docs

## Documentation Maintenance Rules
AI agents MUST update relevant documentation when making these changes:
- **Architecture changes** → Update `docs/ai/architecture.md`
- **Code patterns** → Update `docs/ai/conventions.md`
- **New scripts/tools** → Update `docs/ai/tools.md`
- **Game mechanics** → Update `docs/ai/context.md`
- **New issues/solutions** → Update `docs/ai/troubleshooting.md`
- **Task workflows** → Update `docs/ai/common-tasks.md`

See `docs/ai/documentation-maintenance.md` for complete guidelines.

## AI Agent Requirements - Architectural Excellence

### MANDATORY: Requirements Exploration Phase
Before ANY non-trivial implementation, AI agents MUST:

#### Clarification Questions (Always Ask)
1. **Scope & Growth**: "Will you likely need similar/related functionality in the future?"
2. **Variability**: "Should different instances have different behaviors/configurations?"
3. **Maintenance**: "Who will maintain/extend this? Should it be easy to modify?"
4. **Integration**: "How does this fit with existing patterns in the codebase?"
5. **Constraints**: "Are there performance, scalability, or architectural constraints I should know about?"

#### Architecture-First Approach
- **Never start coding immediately** for multi-component features
- **Always propose 2-3 architectural approaches** with trade-offs
- **Explain SOLID implications** of each approach
- **Get explicit approval** on architectural direction before implementation

#### Communication Template
```
Before implementing [feature], let me understand the broader context:

1. Context: How does this fit with existing [domain] functionality?
2. Growth: Are you likely to need similar features in the future?
3. Variation: Will different instances need different behaviors?
4. Architecture: I see two approaches... [present options with trade-offs]
5. Testing: What edge cases should I consider?

Which approach aligns best with your goals?
```

### SOLID Principle Validation (Required)
For every component/system/module, verify:
- **S**: Single Responsibility - "What's the ONE reason this would change?"
- **O**: Open/Closed - "How would someone extend this without modifying it?"
- **L**: Liskov Substitution - "Can instances be swapped without breaking things?"
- **I**: Interface Segregation - "Does this force users to depend on things they don't need?"
- **D**: Dependency Inversion - "Does this depend on abstractions, not concretions?"

### Extensibility Test (Always Apply)
Before finalizing any design, ask:
- "How would we add one more of these?"
- "What if requirements change slightly?"
- "How would someone unfamiliar extend this?"

### Implementation Quality Gates

#### Test-Driven Architecture
- **Architecture tests first**: Validate design decisions with tests
- **Edge case identification**: Think through error conditions upfront
- **Integration validation**: Test how components work together
- **Document test strategy** before implementing

#### Code Review Self-Check
Before presenting implementation:
1. **Reusability**: Could this be generalized for other use cases?
2. **Composition**: Am I favoring composition over inheritance/monoliths?
3. **Configuration**: Are behaviors parameterized rather than hard-coded?
4. **Separation**: Are concerns properly separated?
5. **Future-proofing**: Will this design handle likely changes gracefully?

### Anti-Patterns to Avoid

#### Implementation Anti-Patterns
- **"Just get it working" mentality** → Always consider maintainability
- **Single-use components** → Design for reusability from the start
- **Hard-coded behaviors** → Parameterize and configure
- **Monolithic solutions** → Favor composition and modularity
- **Custom logic over patterns** → Use established patterns when available

#### Process Anti-Patterns
- **Assumption-based development** → Always clarify and confirm
- **Implementation-first design** → Architecture discussion must come first
- **Feature-focused thinking** → Think in terms of systems and patterns
- **Current-requirement optimization** → Design for evolution
- **Test-as-afterthought** → Tests inform and validate architecture

### Success Metrics & Red Flags

#### Success Metrics
- **Zero major refactoring** needed after initial feedback
- **Easy extension** when new requirements emerge
- **High test coverage** from day one
- **Positive maintainability** feedback
- **Reusable components** created

#### Red Flags (Stop and Redesign)
- User says "actually, we need to change this significantly"
- Adding one more feature requires modifying existing code
- Tests are hard to write or maintain
- Code has multiple responsibilities mixed together
- Similar functionality exists elsewhere with different patterns

### ECS-Specific Architectural Guidelines

#### Component Design Patterns
- **One responsibility per component**: Each component should represent a single data concern
- **Generic over specific**: Design `StatDisplayComponent(label, valueKey)` not `TotalScoreComponent`
- **Data-only components**: Components should contain no logic, only data
- **Composition over monoliths**: Multiple small entities > One large entity with many components

#### System Design Patterns  
- **Single-concern systems**: Each system handles one specific behavior (rendering, movement, etc.)
- **Generic processing**: Systems should work with any entity having required components
- **No cross-system dependencies**: Systems should be independently testable

#### Entity Creation Patterns
- **Factory pattern required**: Always use factories for entity creation
- **Parameterized factories**: Support customization without creating specific factories
- **Multiple entities over complex entities**: Prefer many simple entities to few complex ones

#### Example: UI Feature Architecture Decision
```
❌ BAD: "I'll create a UserStatsComponent that displays three stats"

✅ GOOD: "I see you need to display user stats. Two approaches:

1. **Single Component Approach**: One component handles all stats
   - Pros: Simple, fewer files
   - Cons: Hard to extend, violates Single Responsibility, not ECS-compliant
   
2. **Modular Entity Approach**: Each stat is its own entity with StatDisplayComponent
   - Pros: Extensible, SOLID-compliant, ECS-compliant, testable
   - Cons: More initial setup, more entities
   
For ECS architecture, approach #2 aligns better with component composition principles. 
Does this match your extensibility needs?"
```

### Core Requirements (Enhanced)
- **CRITICAL**: Ask clarifying questions AND architectural direction before implementing ANY functionality
- Never assume or guess requirements - always ask for specifics including future needs
- Get clear answers on behavior, visuals, interactions, edge cases, AND extensibility
- Never ignore test failures - fix or ask for guidance
- If scripts fail, check dependencies before proceeding
- When unsure about ECS patterns, reference architecture.md first
- Always validate component/system integration after creation
- Update documentation concurrently with code changes
- **NEW**: Always propose architectural alternatives with SOLID principle analysis
- **NEW**: Design for extension from the start - assume requirements will grow
- **NEW**: Validate designs with the extensibility test: "How would we add one more?"

## File Modification Rules
- NEVER modify files in ecs/ directory without explicit instruction
- Components must extend BaseComponent - no exceptions
- Systems must extend BaseSystem - no exceptions
- Always use factories for entity creation

## Before Making Changes
- Read relevant files in `docs/ai/` directory
- Run `./scripts/test.sh` to ensure baseline
- Follow ECS patterns described in `docs/ai/architecture.md`
- Use scripts in `scripts/` directory for all operations

## Project Structure
- `main.lua` - Entry point and Love2D callbacks
- `ecs/` - Core Entity-Component-System framework
- `components/` - Data-only components
- `systems/` - Logic-only systems
- `behaviors/` - High-level game logic
- `factories/` - Entity creation helpers
- `scripts/` - Automation and development tools
- `docs/ai/` - AI agent documentation