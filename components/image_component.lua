-- =============================================================================
-- IMAGE COMPONENT
-- =============================================================================

-- Image Component (for rendering textures/images)
local Image = {}
Image.__index = Image

function Image.new(image, width, height)
    local self = setmetatable({}, Image)
    self.type = "Image"
    self.image = image  -- Love2D image object
    self.width = width or (image and image:getWidth() or 0)
    self.height = height or (image and image:getHeight() or 0)
    self.scaleX = 1
    self.scaleY = 1
    return self
end

return Image 
