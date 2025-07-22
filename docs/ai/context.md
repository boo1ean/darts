# Game Context & Domain Knowledge

## Game Overview
Love2D Darts is an arcade-style dartboard game where players aim at moving targets that travel in complex patterns across a dartboard. The game emphasizes timing, precision, and pattern recognition.

## Core Gameplay Loop
1. **Target Movement**: Red pulsing dots move across the dartboard in combined patterns
2. **Player Action**: Press SPACE to "throw dart" - instantly freezes all moving targets
3. **Scoring**: Each frozen target is scored based on distance from center
4. **Feedback**: Visual effects show score (popup text) and impact (board shake)
5. **Continuation**: New moving target spawns for next round

## Movement Mechanics
Targets combine three movement types:
- **Linear**: Direct path between random points
- **Circular**: Orbital motion around shifting centers
- **Cosine**: Wave-based oscillation

The `TargetGenerationSystem` ensures paths cross the center zone for scoring opportunities.

## Scoring System
Distance-based scoring rewards precision:
- Bullseye (≤15px): 100 points (gold)
- Inner rings (≤30px): 75 points (green)
- Middle rings (≤50px): 50 points (green)
- Outer rings (≤80px): 25 points (orange)
- Edge (≤120px): 10 points (white)
- Near miss (≤150px): 5 points (white)
- Complete miss (>150px): 0 points (gray)

## Visual Design
- **Dartboard**: Realistic texture with tilt/shake physics
- **Targets**: Red pulsing dots with size animation
- **Hit State**: Darker, semi-transparent when frozen
- **Score Text**: Animated upward float with color coding
- **Screen Effects**: Impact shake for game feel

## Technical Constraints
- Love2D 11.x framework
- 60 FPS target
- Resolution independent
- Pure ECS architecture
- No external physics engine

## Performance Considerations
- Batch render operations
- Limit active entities
- Efficient collision detection (distance-based)
- Component pooling for frequent creates/destroys

## Future Expansion Points
The ECS architecture supports:
- Multiple dart types
- Power-ups or special targets
- Multiplayer modes
- Different board layouts
- Combo systems
- Difficulty progression

## Key Game Feel Elements
1. **Responsiveness**: Instant target freeze on spacebar
2. **Feedback**: Clear visual/motion feedback
3. **Fairness**: Predictable scoring zones
4. **Challenge**: Complex movement patterns
5. **Satisfaction**: Impactful hit effects

## Common Pitfalls to Avoid
- Don't add logic to components
- Don't create entities in systems
- Don't store world references in components
- Don't mix rendering with game logic
- Don't poll for input in systems (use callbacks)