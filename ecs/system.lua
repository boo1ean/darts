-- =============================================================================
-- SYSTEM LOADER - LOADS ALL INDIVIDUAL SYSTEMS
-- =============================================================================

-- Load all system modules
local MovementSystem = require('systems.movement_system')
local PulseSystem = require('systems.pulse_system')
local CircularMovementSystem = require('systems.circular_movement_system')
local CombinedMovementSystem = require('systems.combined_movement_system')
local TargetGenerationSystem = require('systems.target_generation_system')
local TimerSystem = require('systems.timer_system')
local ShakeSystem = require('systems.shake_system')
local RenderSystem = require('systems.render_system')

-- Export all systems
return {
    MovementSystem = MovementSystem,
    PulseSystem = PulseSystem,
    CircularMovementSystem = CircularMovementSystem,
    CombinedMovementSystem = CombinedMovementSystem,
    TargetGenerationSystem = TargetGenerationSystem,
    TimerSystem = TimerSystem,
    ShakeSystem = ShakeSystem,
    RenderSystem = RenderSystem
} 
