-- =============================================================================
-- COSINE MOVEMENT COMPONENT
-- =============================================================================

-- Cosine movement component for oscillatory wave movement
local CosineMovementComponent = {}
CosineMovementComponent.__index = CosineMovementComponent

function CosineMovementComponent.new(amplitudeX, amplitudeY, frequencyX, frequencyY, phaseX, phaseY, factor)
    local self = setmetatable({}, CosineMovementComponent)
    self.type = "CosineMovement"
    
    -- Factor controls overall intensity of cosine movement - AGGRESSIVE RANGE
    self.factor = factor or (0.1 + math.random() * 2.9)  -- Random 0.1-3.0 for EXTREME variety
    
    -- Amplitude controls how far the oscillation extends - AGGRESSIVE OSCILLATIONS
    self.amplitudeX = amplitudeX or (5 + math.random() * 25)   -- Random 5-30 (AGGRESSIVE oscillation range)
    self.amplitudeY = amplitudeY or (5 + math.random() * 25)   -- Random 5-30 (AGGRESSIVE oscillation range)
    
    -- Frequency controls how fast the oscillation happens - AGGRESSIVE RANGE
    self.frequencyX = frequencyX or (0.5 + math.random() * 2.5)  -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    self.frequencyY = frequencyY or (0.5 + math.random() * 2.5)  -- Random 0.5-3.0 (AGGRESSIVE wave speeds)
    
    -- Phase creates offset in the wave (for variety)
    self.phaseX = phaseX or (math.random() * math.pi * 2)  -- Random 0-2π
    self.phaseY = phaseY or (math.random() * math.pi * 2)  -- Random 0-2π
    
    -- Internal time tracking for wave progression
    self.time = 0
    
    -- Previous values for smooth transitions
    self.previousFactor = self.factor
    self.previousAmplitudeX = self.amplitudeX
    self.previousAmplitudeY = self.amplitudeY
    self.previousFrequencyX = self.frequencyX
    self.previousFrequencyY = self.frequencyY
    self.previousPhaseX = self.phaseX
    self.previousPhaseY = self.phaseY
    
    return self
end



return CosineMovementComponent 
