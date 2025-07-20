-- =============================================================================
-- COMPONENT LOADER - LOADS ALL INDIVIDUAL COMPONENTS
-- =============================================================================

-- Load all component modules
local TransformComponent = require('components.transform_component')
local RenderComponent = require('components.render_component')
local MovementComponent = require('components.movement_component')
local PulseComponent = require('components.pulse_component')
local CircularMovementComponent = require('components.circular_movement_component')
local LinearMovementComponent = require('components.linear_movement_component')
local CosineMovementComponent = require('components.cosine_movement_component')
local Shake = require('components.shake_component')
local Timer = require('components.timer_component')
local Image = require('components.image_component')
local Text = require('components.text_component')
local Score = require('components.score_component')
local Hit = require('components.hit_component')

-- Export all components
return {
    Transform = TransformComponent,
    Render = RenderComponent,
    Movement = MovementComponent,
    Pulse = PulseComponent,
    CircularMovement = CircularMovementComponent,
    LinearMovement = LinearMovementComponent,
    CosineMovement = CosineMovementComponent,
    Shake = Shake,
    Timer = Timer,
    Image = Image,
    Text = Text,
    Score = Score,
    Hit = Hit
} 
