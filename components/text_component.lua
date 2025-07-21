-- =============================================================================
-- TEXT COMPONENT - For displaying text labels with animation
-- =============================================================================

local TextComponent = {}
TextComponent.__index = TextComponent

function TextComponent.new(text, fontSize, color, duration, animationType)
    local self = setmetatable({}, TextComponent)
    self.type = "Text"
    self.text = text or ""
    self.fontSize = fontSize or 24
    self.color = color or { 1, 1, 1, 1 } -- RGBA
    self.duration = duration or 2.0 -- How long to display
    self.animationType = animationType or "popup" -- popup, fade, etc.

    -- Animation state
    self.time = 0
    self.startScale = 0.1
    self.maxScale = 1.2
    self.endScale = 1.0
    self.alpha = 1.0
    self.offsetY = 0 -- For upward movement animation

    return self
end

return TextComponent
