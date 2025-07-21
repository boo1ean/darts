# Bugs Found in Darts Game

## Critical Issues

### 1. Memory Leak - Font Creation
**Location**: `text_system.lua:84`
```lua
local font = love.graphics.newFont(text.fontSize)
```
**Problem**: Creating new font objects on every render frame without caching causes memory leak.
**Solution**: Cache fonts by size in a table.

### 2. Entity Removal During Iteration
**Location**: `world.lua:67-72`
```lua
for i, e in ipairs(self.entities) do
    if e.id == entity.id then
        table.remove(self.entities, i)
        break
    end
end
```
**Problem**: Removing entities from array during forward iteration can skip entities or cause index errors.
**Solution**: Iterate backwards or mark for removal and process after iteration.

## Logic Issues

### 3. Duplicate Movement Update
**Location**: `target_generation_system.lua:24` and `combined_movement_system.lua`
**Problem**: `moveTime` is incremented in TargetGenerationSystem but movement logic is in CombinedMovementSystem, causing potential timing conflicts.
**Solution**: Consolidate movement time tracking in one system.

### 4. Duplicate Target Generation Methods
**Location**: `combined_movement_system.lua:42` & `target_generation_system.lua:35`
**Problem**: Both systems have `generateNewTargets` methods that could conflict or duplicate work.
**Solution**: Single responsibility - one system should handle target generation.

### 5. Inconsistent Component Checking
**Location**: `render_system.lua:9-12`
```lua
function RenderSystem:canProcessEntity(entity)
    return entity:hasComponent("Transform") and 
           (entity:hasComponent("Render") or entity:hasComponent("Image"))
end
```
**Problem**: Custom `canProcessEntity` doesn't match base system's entity filtering mechanism.
**Solution**: Use consistent component requirements in system constructor.

## Potential Issues

### 6. Race Condition in Timer System
**Location**: `timer_system.lua:32-36`
**Problem**: Adding components through world vs directly on entity can cause timing issues with system updates.
**Solution**: Always use world methods for component management.

### 7. Missing nil Check
**Location**: `dartboard_behavior.lua:164-168`
```lua
transform.rotation = (transform.rotation or 0) + tiltRotation
```
**Problem**: While this handles nil rotation, it's done inline which could be missed elsewhere.
**Solution**: Initialize rotation in Transform component constructor.

### 8. Potential Division by Zero
**Location**: `utils.lua:30-32`
```lua
function Utils.normalizeVector(x, y)
    local length = math.sqrt(x * x + y * y)
    if length > 0 then
        return x / length, y / length
    end
    return 0, 0
end
```
**Problem**: Good handling, but the check happens after length calculation.
**Solution**: Current implementation is actually correct, but could add epsilon comparison for floating point safety.

## Performance Issues

### 9. Unused Asset Module
**Location**: `assets.lua:4-6`
**Problem**: Assets module exists but isn't used; image loaded directly in main.lua instead.
**Solution**: Either use the module or remove it to avoid confusion.

### 10. Inefficient Backward Iteration
**Location**: `text_system.lua:15`
```lua
for i = #self.entities, 1, -1 do
```
**Problem**: Uses `self.entities` array which may not be the filtered entity list, potentially processing wrong entities.
**Solution**: Ensure using the correct filtered entity list from base system.

## Minor Issues

### 11. Excessive Debug Logging
**Location**: Throughout systems
**Problem**: Many print statements that could impact performance in production.
**Solution**: Add debug flag or logging levels.

### 12. Magic Numbers
**Location**: Various files
**Problem**: Hard-coded values like `0.4` for transition time, `15` for margin, etc.
**Solution**: Move to configuration constants.

### 13. Missing Error Handling
**Location**: `main.lua:31`
**Problem**: No error handling for image loading failure.
**Solution**: Add try-catch or file existence check.

## Recommendations

1. **Implement a resource manager** for fonts, images, and other assets
2. **Add input validation** for all public methods
3. **Use consistent iteration patterns** throughout the codebase
4. **Add unit tests** for critical systems
5. **Profile memory usage** to catch leaks early