# AI Agent Instructions for Love2D Darts Game

## Project Overview
ECS-based dartboard game built with Love2D. Features moving targets with complex movement patterns, physics-based dartboard reactions, and animated scoring system.

## Essential Reading Order
1. `.ai/architecture.md` - Understand the ECS design and core patterns
2. `.ai/conventions.md` - Follow project code standards
3. `.ai/tools.md` - Available scripts and automation
4. `.ai/context.md` - Game mechanics and domain knowledge

## Before Making Changes
- Read relevant files in `.ai/` directory
- Run `./scripts/test.sh` to ensure baseline
- Follow ECS patterns described in `.ai/architecture.md`
- Use scripts in `scripts/` directory for all operations

## Project Structure
- `main.lua` - Entry point and Love2D callbacks
- `ecs/` - Core Entity-Component-System framework
- `components/` - Data-only components
- `systems/` - Logic-only systems
- `behaviors/` - High-level game logic
- `factories/` - Entity creation helpers
- `scripts/` - Automation and development tools
- `.ai/` - AI agent documentation