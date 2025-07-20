-- =============================================================================
-- SCORING SYSTEM - Handles score calculation and display
-- =============================================================================
local System = require('ecs.base_system')
local Components = require('ecs.component')
local DartBoardBehavior = require('behaviors.dartboard_behavior')

-- Scoring System - processes entities with Hit components
local ScoringSystem = System.new("ScoringSystem", {"Transform", "Hit"})

function ScoringSystem:init(world)
    self.world = world
    -- Stats are now stored in world.gameState for ECS-compliant access
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
    
    -- Update total score in world game state
    if points > 0 then
        self.world.gameState.totalScore = self.world.gameState.totalScore + points
        self.world.gameState.hitCount = self.world.gameState.hitCount + 1
        print(string.format("HIT! %d points (%.1f pixels from center) - Total: %d points", 
              points, distanceFromCenter, self.world.gameState.totalScore))
    else
        print(string.format("MISS! (%.1f pixels from center)", distanceFromCenter))
    end
    
    return entity
end



-- Get current scoring statistics
function ScoringSystem:getStats()
    return {
        totalScore = self.world.gameState.totalScore,
        hitCount = self.world.gameState.hitCount,
        averageScore = self.world.gameState.hitCount > 0 and (self.world.gameState.totalScore / self.world.gameState.hitCount) or 0
    }
end

-- Reset scoring statistics
function ScoringSystem:reset()
    self.world.gameState.totalScore = 0
    self.world.gameState.hitCount = 0
    print("Score reset!")
end

function ScoringSystem:update(dt)
    -- Process all entities with Hit components
    for _, entity in ipairs(self.entities) do
        if entity.active then
            local transform = entity:getComponent("Transform")
            local hit = entity:getComponent("Hit")
            
            if transform and hit and not hit.processed then
                -- Mark as processed to avoid double-scoring
                hit.processed = true
                
                -- Calculate score for this hit
                self:processHit(entity, transform.x, transform.y)
                
                -- Remove the Hit component after processing
                self.world:removeComponentFromEntity(entity, "Hit")
            end
        end
    end
end

-- Process a hit at the given position (internal method)
function ScoringSystem:processHit(entity, x, y)
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

return ScoringSystem 
