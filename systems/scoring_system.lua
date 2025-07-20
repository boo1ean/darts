-- =============================================================================
-- SCORING SYSTEM - Handles score calculation and display
-- =============================================================================
local System = require('ecs.base_system')
local Components = require('ecs.component')
local DartBoardBehavior = require('behaviors.dartboard_behavior')

-- Scoring System
local ScoringSystem = System.new("ScoringSystem", {})

function ScoringSystem:init(world)
    self.world = world
    self.totalScore = 0
    self.hitCount = 0
end

-- Calculate points based on distance from center
function ScoringSystem:calculatePoints(distanceFromCenter)
    -- Maximum distance for scoring (half the dartboard radius roughly)
    local maxScoringDistance = 150  -- Adjust based on your dartboard size
    
    if distanceFromCenter <= 15 then
        -- Bullseye - center hit
        return 100
    elseif distanceFromCenter <= 30 then
        -- Very close to center
        return 75
    elseif distanceFromCenter <= 50 then
        -- Close to center
        return 50
    elseif distanceFromCenter <= 80 then
        -- Medium distance
        return 25
    elseif distanceFromCenter <= 120 then
        -- Far from center
        return 10
    elseif distanceFromCenter <= maxScoringDistance then
        -- Very far but still on board
        return 5
    else
        -- Too far, no points
        return 0
    end
end

-- Create a score text entity at the given position
function ScoringSystem:createScoreText(x, y, points, distanceFromCenter)
    local entity = self.world:createEntity()
    
    -- Create transform at hit position
    local transform = Components.Transform.new(x, y)
    
    -- Determine text color based on score
    local color
    if points >= 100 then
        color = {1, 1, 0, 1}  -- Gold for bullseye
    elseif points >= 50 then
        color = {0, 1, 0, 1}  -- Green for good shots
    elseif points >= 25 then
        color = {1, 0.8, 0, 1}  -- Orange for decent shots
    elseif points > 0 then
        color = {1, 1, 1, 1}  -- White for any points
    else
        color = {0.7, 0.7, 0.7, 1}  -- Gray for no points
    end
    
    -- Create text with score
    local scoreText = points > 0 and "+" .. points or "MISS"
    local fontSize = math.max(20, math.min(36, 20 + points / 5))  -- Size based on score
    local text = Components.Text.new(scoreText, fontSize, color, 1.3, "popup")  -- Faster animation (was 2.0)
    
    -- Create score component
    local score = Components.Score.new(points, distanceFromCenter, {x = x, y = y})
    
    -- Add components to entity
    self.world:addComponentToEntity(entity, "Transform", transform)
    self.world:addComponentToEntity(entity, "Text", text)
    self.world:addComponentToEntity(entity, "Score", score)
    
    -- Update total score
    if points > 0 then
        self.totalScore = self.totalScore + points
        self.hitCount = self.hitCount + 1
        print(string.format("HIT! %d points (%.1f pixels from center) - Total: %d points", 
              points, distanceFromCenter, self.totalScore))
    else
        print(string.format("MISS! (%.1f pixels from center)", distanceFromCenter))
    end
    
    return entity
end

-- Score a hit at the given position
function ScoringSystem:scoreHit(x, y)
    -- Get dartboard center
    local centerX, centerY = DartBoardBehavior.getCenterFromWorld(self.world)
    
    -- Calculate distance from center
    local dx = x - centerX
    local dy = y - centerY
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Calculate points
    local points = self:calculatePoints(distance)
    
    -- Create visual score display
    return self:createScoreText(x, y, points, distance)
end

-- Get current scoring statistics
function ScoringSystem:getStats()
    return {
        totalScore = self.totalScore,
        hitCount = self.hitCount,
        averageScore = self.hitCount > 0 and (self.totalScore / self.hitCount) or 0
    }
end

-- Reset scoring statistics
function ScoringSystem:reset()
    self.totalScore = 0
    self.hitCount = 0
    print("Score reset!")
end

function ScoringSystem:update(dt)
    -- This system doesn't need regular updates
    -- Score entities are managed by other systems
end

return ScoringSystem 
