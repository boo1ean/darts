# 🎯 ECS Darts Game

A dynamic dartboard game built with **Entity-Component-System (ECS) architecture** using LÖVE2D. Features moving targets, physics-based dartboard reactions, and an animated scoring system.

## 🎮 Game Overview

This is an arcade-style darts game where players aim at **moving targets** that travel in complex, unpredictable patterns across a dartboard. When you "throw" a dart (press space), all moving targets stop instantly at their current positions and are scored based on distance from the center.

### Key Features

- **🌀 Dynamic Moving Targets**: Dots move in complex combined patterns (circular + linear + cosine wave motion)
- **🎯 Distance-Based Scoring**: Closer to center = higher points (up to 100 for bullseye)
- **✨ Animated Score Labels**: Pop-up text showing points with color-coded feedback
- **📐 Authentic Physics**: Dartboard tilts and rotates after each hit for realistic impact feel
- **👻 Visual Feedback**: Hit targets become darker and semi-transparent
- **🔄 Continuous Gameplay**: New moving target spawns after each successful hit

## 🕹️ Controls

| Key | Action |
|-----|--------|
| `Space` | Throw dart (stop all moving targets and score them) |

## 📊 Scoring System

Points are awarded based on **distance from dartboard center**:

| Distance Range | Points | Color |
|----------------|--------|-------|
| ≤ 15 pixels | **100** | 🏆 Gold (Bullseye) |
| ≤ 30 pixels | **75** | 🟢 Green |
| ≤ 50 pixels | **50** | 🟢 Green |
| ≤ 80 pixels | **25** | 🟠 Orange |
| ≤ 120 pixels | **10** | ⚪ White |
| ≤ 150 pixels | **5** | ⚪ White |
| > 150 pixels | **0** | ⚫ Gray (Miss) |

## 🎯 Gameplay Mechanics

1. **Moving Targets**: Red pulsing dots move in unpredictable patterns across the dartboard
2. **Dart Throw**: Press `Space` to instantly stop all moving targets
3. **Scoring**: Each stopped target is scored based on its distance from center
4. **Visual Effects**: 
   - Score labels pop up and fly upward with points
   - Dartboard shakes and tilts authentically  
   - Hit targets become dark and semi-transparent
5. **Continuation**: A new moving target spawns for the next round

## 🏗️ Technical Architecture

### Entity-Component-System (ECS) Design

The game follows **pure ECS principles** for maximum modularity and performance:

#### 📦 **Components** (Data Only)
```
components/
├── transform_component.lua      # Position, rotation, scale
├── render_component.lua         # Visual properties (color, size, shape)
├── movement_component.lua       # Movement state and targets
├── pulse_component.lua          # Pulsing animation data
├── circular_movement_component.lua  # Circular motion parameters
├── linear_movement_component.lua    # Linear motion targets
├── cosine_movement_component.lua    # Wave motion parameters
├── text_component.lua           # Text display and animation
├── score_component.lua          # Scoring information
├── hit_component.lua            # Hit marking for processing
├── shake_component.lua          # Screen shake effects
├── timer_component.lua          # Delayed actions
└── image_component.lua          # Image rendering data
```

#### ⚙️ **Systems** (Logic Only)
```
systems/
├── combined_movement_system.lua    # Complex multi-pattern movement
├── target_generation_system.lua    # Dynamic target path generation
├── pulse_system.lua               # Pulsing animations
├── shake_system.lua               # Impact shake effects
├── timer_system.lua               # Delayed component additions
├── text_system.lua                # Animated text rendering
├── scoring_system.lua             # Hit processing and score calculation
└── render_system.lua              # Graphics rendering
```

#### 🏭 **Factories** (Entity Creation)
```
factories/
├── dot_factory.lua                # Moving target entities
├── dart_board_factory.lua         # Dartboard entity creation
├── text_factory.lua               # Score text entities
└── init.lua                       # Factory aggregation
```

#### 🎭 **Behaviors** (High-Level Actions)
```
behaviors/
├── game_behavior.lua              # Game flow and dart throwing
├── dot_behavior.lua               # Target management
└── dartboard_behavior.lua         # Dartboard interactions
```

### ECS Benefits

- **🔧 Modularity**: Components are pure data, systems are pure logic
- **🔄 Reusability**: Mix and match components for different entity types  
- **⚡ Performance**: Systems process entities in batches efficiently
- **🧪 Testability**: Systems can be tested independently
- **📈 Scalability**: Easy to add new components and systems

## 🚀 Installation & Running

### Prerequisites
- [LÖVE2D](https://love2d.org/) game engine installed

### Running the Game
1. Clone this repository
2. Navigate to the project directory
3. Run with LÖVE2D:
   ```bash
   love .
   ```
   Or drag the folder onto the LÖVE2D executable.

## 📁 Project Structure

```
darts/
├── main.lua                    # Entry point and game loop
├── config.lua                  # Game configuration
├── utils.lua                   # Utility functions
├── assets/
│   └── board.png              # Dartboard image
├── ecs/                       # ECS Core Framework
│   ├── world.lua              # Entity manager and game state
│   ├── entity.lua             # Entity implementation
│   ├── component.lua          # Component loader
│   ├── system.lua             # System loader
│   └── base_system.lua        # System base class
├── components/                # Data Components
├── systems/                   # Logic Systems  
├── factories/                 # Entity Factories
└── behaviors/                 # High-Level Game Logic
```

## 🎨 Visual Features

### Movement Patterns
- **Circular Motion**: Dots orbit around dynamic center points
- **Linear Motion**: Straight-line movement to random targets  
- **Cosine Waves**: Oscillating motion with randomized parameters
- **Combined Motion**: All three patterns blend for unpredictable paths
- **Center Passage**: Guaranteed path through dartboard center

### Visual Effects
- **Pulsing Animation**: Targets pulse in size while moving
- **Impact Physics**: Dartboard tilts and shakes when hit
- **Score Popups**: Animated text labels with easing and transparency
- **Hit State**: Targets become darker and semi-transparent when stopped
- **Color Coding**: Score text colors indicate point values

## 🔧 Configuration

Key parameters can be adjusted in the respective component and system files:

- **Movement Speed**: `movement_component.lua` - target speed values
- **Scoring Distances**: `scoring_system.lua` - distance thresholds  
- **Visual Effects**: Component files for colors, sizes, durations
- **Physics**: `dartboard_behavior.lua` - tilt angles and shake intensity

## 🎯 Game Balance

The game is designed for **skill-based scoring** with **randomized challenge**:

- Targets move fast enough to require timing skill
- Multiple movement patterns prevent predictable strategies  
- Distance-based scoring rewards precision
- Visual feedback clearly shows performance
- Continuous spawning maintains game flow

## 🏆 Stats Tracking

The game tracks and displays:
- **Total Score**: Sum of all successful hits
- **Hit Count**: Number of targets successfully hit
- **Average Score**: Mean points per hit
- **Real-time Updates**: Stats printed every 2 seconds during play

---

Built with ❤️ using **Entity-Component-System architecture** and **LÖVE2D** 
