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

## AI Agent Error Handling
- Never ignore test failures - fix or ask for guidance
- If scripts fail, check dependencies before proceeding
- When unsure about ECS patterns, reference architecture.md first
- Always validate component/system integration after creation
- Update documentation concurrently with code changes

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