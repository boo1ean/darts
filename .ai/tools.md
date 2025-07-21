# Development Tools & Scripts

All project interactions should be done through scripts in the `scripts/` directory.

## Available Scripts

### Core Operations
- `./scripts/run.sh` - Run the game
- `./scripts/test.sh` - Run all tests and checks
- `./scripts/lint.sh` - Static code analysis
- `./scripts/setup.sh` - Install dependencies

### Development Helpers
- `./scripts/watch.sh` - Run game with auto-reload
- `./scripts/debug.sh` - Run with debug mode enabled
- `./scripts/profile.sh` - Run with performance profiling

### Code Generation
- `./scripts/new-component.sh <name>` - Create new component
- `./scripts/new-system.sh <name>` - Create new system
- `./scripts/new-test.sh <name>` - Create new test file

## Script Descriptions

### run.sh
Basic game execution. Checks if Love2D is installed and runs the game.

### test.sh
Comprehensive testing pipeline:
1. Checks Love2D installation
2. Runs static analysis (if luacheck available)
3. Runs unit tests (if test framework available)
4. Performs quick game startup test
5. Reports results

### lint.sh
Code quality checks:
- Lua syntax validation
- Undefined variable detection
- Code style consistency

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