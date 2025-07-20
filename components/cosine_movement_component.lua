-- =============================================================================
-- COSINE MOVEMENT COMPONENT
-- =============================================================================

-- Cosine movement component for oscillatory wave movement
local CosineMovementComponent = {}
CosineMovementComponent.__index = CosineMovementComponent

function CosineMovementComponent.new(amplitudeX, amplitudeY, frequencyX, frequencyY, phaseX, phaseY)
    local self = setmetatable({}, CosineMovementComponent)
    self.type = "CosineMovement"
    
    -- Amplitude controls how far the oscillation extends
    self.amplitudeX = amplitudeX or (10 + math.random() * 30)  -- Random 10-40
    self.amplitudeY = amplitudeY or (10 + math.random() * 30)  -- Random 10-40
    
    -- Frequency controls how fast the oscillation happens
    self.frequencyX = frequencyX or (0.5 + math.random() * 2)  -- Random 0.5-2.5
    self.frequencyY = frequencyY or (0.5 + math.random() * 2)  -- Random 0.5-2.5
    
    -- Phase creates offset in the wave (for variety)
    self.phaseX = phaseX or (math.random() * math.pi * 2)  -- Random 0-2π
    self.phaseY = phaseY or (math.random() * math.pi * 2)  -- Random 0-2π
    
    -- Internal time tracking for wave progression
    self.time = 0
    
    -- Previous values for smooth transitions
    self.previousAmplitudeX = self.amplitudeX
    self.previousAmplitudeY = self.amplitudeY
    self.previousFrequencyX = self.frequencyX
    self.previousFrequencyY = self.frequencyY
    self.previousPhaseX = self.phaseX
    self.previousPhaseY = self.phaseY
    
    return self
end

-- Generate new random parameters for the cosine movement
function CosineMovementComponent:randomizeParameters()
    -- Store current as previous
    self.previousAmplitudeX = self.amplitudeX
    self.previousAmplitudeY = self.amplitudeY
    self.previousFrequencyX = self.frequencyX
    self.previousFrequencyY = self.frequencyY
    self.previousPhaseX = self.phaseX
    self.previousPhaseY = self.phaseY
    
    -- Generate new random parameters
    self.amplitudeX = 10 + math.random() * 30
    self.amplitudeY = 10 + math.random() * 30
    self.frequencyX = 0.5 + math.random() * 2
    self.frequencyY = 0.5 + math.random() * 2
    self.phaseX = math.random() * math.pi * 2
    self.phaseY = math.random() * math.pi * 2
    
    print("  Cosine wave: Amp(" .. math.floor(self.amplitudeX) .. "," .. math.floor(self.amplitudeY) .. ") Freq(" .. string.format("%.1f", self.frequencyX) .. "," .. string.format("%.1f", self.frequencyY) .. ")")
end

return CosineMovementComponent 
