# Development Tools & Scripts

All project interactions should be done through scripts in the `scripts/` directory.

## Available Scripts

### Core Operations
- `./scripts/run.sh` - Run the game (interactive, verbose output)
- `./scripts/validate-game.sh` - Silent game validation for AI agents
- `./scripts/run-for-verification.sh` - Start game silently for manual verification
- `./scripts/stop-verification.sh` - Stop verification game
- `./scripts/test.sh` - Run all tests and checks
- `./scripts/lint.sh` - Static code analysis
- `./scripts/setup.sh` - Install dependencies
- `./scripts/validate-docs.sh` - Validate AI documentation is up-to-date

### Development Helpers
- `./scripts/watch.sh` - Run game with auto-reload
- `./scripts/debug.sh` - Run with debug mode enabled

### Code Generation
- `./scripts/new-component.sh <name>` - Create new component
- `./scripts/new-system.sh <name>` - Create new system

## Script Descriptions

### run.sh
Basic game execution. Checks if Love2D is installed and runs the game.
**Note**: Produces verbose debug output - use validate-game.sh for AI validation.

### validate-game.sh
Silent game validation designed for AI agents:
1. Starts Love2D game in background
2. Monitors for startup errors and crashes
3. Validates game stability for 5 seconds
4. Automatically terminates game process
5. Returns clean exit codes without debug pollution
**Output**: Minimal status messages only, no debug logs

### run-for-verification.sh
Start game silently for manual verification by AI agents:
1. Redirects all game output to `.tmp/verification_game.log`
2. Stores process ID in `.tmp/verification_game.pid`
3. Performs basic startup validation
4. Leaves game running for user interaction
5. Minimal output to avoid polluting agent context
**Use case**: When AI agents need users to manually test game functionality

### stop-verification.sh
Stop verification game cleanly:
1. Reads PID from `.tmp/verification_game.pid`
2. Gracefully terminates game process
3. Force kills if necessary
4. Cleans up temporary files
**Use case**: AI agents call this after manual verification is complete

### test.sh
Comprehensive testing pipeline:
1. Checks Love2D installation
2. Runs static analysis (if luacheck available)
3. Runs unit tests (if test framework available)
4. Performs quick game startup test
5. Reports results

### validate-docs.sh
Documentation validation pipeline:
1. Checks component documentation coverage
2. Verifies system documentation alignment
3. Validates script documentation completeness
4. Scans for TODO/FIXME items
5. Checks for broken internal links

### lint.sh
Code quality checks:
- **Stylua formatting** (use `--fix` to auto-format)
- Lua syntax validation with luacheck
- Undefined variable detection
- Code style consistency
- Debug print statement detection

**Options**:
- `./scripts/lint.sh` - Check formatting and code quality
- `./scripts/lint.sh --fix` - Auto-format with stylua and check code quality

**AI Agent Usage**: Always use `--fix` option to maintain consistent code formatting

### setup.sh
Environment setup:
- Installs Love2D (if possible)
- Sets up Lua tooling
- Creates necessary directories
- Initializes test framework

## Usage Examples

```bash
# Start development
./scripts/setup.sh

# Run game
./scripts/run.sh

# Before committing
./scripts/lint.sh --fix
./scripts/test.sh

# Create new component
./scripts/new-component.sh "health"

# Debug an issue
./scripts/debug.sh
```

## Exit Codes
- 0: Success
- 1: General failure
- 2: Missing dependencies
- 3: Test failures

## Adding New Scripts
1. Create script in `scripts/` directory
2. Make it executable: `chmod +x scripts/new-script.sh`
3. Add documentation here
4. Follow existing patterns for consistency