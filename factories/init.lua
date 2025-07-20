-- =============================================================================
-- FACTORY LOADER - Loads and exports all individual factories
-- =============================================================================
local DotFactory = require('factories.dot_factory')
local DartboardFactory = require('factories.dartboard_factory')

-- Combined factory interface for backward compatibility
local EntityFactory = {}

-- Export all dot factory functions
EntityFactory.createPulsingDot = DotFactory.createPulsingDot
EntityFactory.createMovingDot = DotFactory.createMovingDot
EntityFactory.createCircularDot = DotFactory.createCircularDot
EntityFactory.createStaticPulsingDot = DotFactory.createStaticPulsingDot

-- Export dartboard factory functions
EntityFactory.createDartBoard = DartboardFactory.createDartBoard

-- Also export individual factories for direct access if needed
EntityFactory.Dot = DotFactory
EntityFactory.Dartboard = DartboardFactory

return EntityFactory 
