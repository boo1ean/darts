# Incremental Game Design for Darts

## Core Concept
Transform the darts game into an active incremental game (not idle) where players actively throw darts to progress through increasingly complex upgrade trees and prestige systems.

## Core Loop

### Active Gameplay
```lua
CoreLoop = {
    throwDart = "Manual action - costs energy",
    hitTarget = "Earn points based on accuracy",
    collectCurrency = "Points convert to coins",
    upgrade = "Spend coins on improvements",
    prestige = "Reset with permanent bonuses"
}
```

The game remains **actively played** - no idle mechanics. Players must be present and engaged to progress.

## Currency System

### Primary Currencies

1. **Coins** 💰
   - Earned by hitting targets
   - Used for basic upgrades
   - Reset on first prestige

2. **Gems** 💎
   - Earned from achievements and perfect shots
   - Used for premium upgrades and time skips
   - Persist through first prestige

3. **Skill Points** ⚡
   - Earned from level ups
   - Used for permanent passive bonuses
   - Persist through all prestiges

4. **Prestige Tokens** 🌟
   - Earned from prestige resets
   - Used for powerful meta-upgrades
   - Never reset

## Progression Trees

### 1. Dart Mastery Tree

Focus on improving your throwing abilities:

```lua
DartMastery = {
    accuracy = {
        levels = 100,
        effect = "Reduce dart spread by 2% per level",
        cost = "coins * level^1.5",
        description = "Steadier hands mean better aim"
    },
    
    power = {
        levels = 100,
        effect = "Increase base points by 5% per level",
        cost = "coins * level^1.6",
        description = "Throw with more force for higher scores"
    },
    
    critical_chance = {
        levels = 50,
        effect = "+1% chance for golden dart (10x points)",
        cost = "coins * level^2",
        description = "Sometimes you throw a perfect dart"
    },
    
    multi_throw = {
        levels = 10,
        effect = "Throw +1 dart simultaneously",
        cost = "gems * level^3",
        description = "Master the art of throwing multiple darts"
    },
    
    piercing = {
        levels = 20,
        effect = "Darts pass through targets, hitting 10% more",
        cost = "skill_points * level^1.5",
        description = "Your darts penetrate deeper"
    }
}
```

### 2. Target Evolution Tree

Improve the targets you're aiming at:

```lua
TargetEvolution = {
    target_value = {
        levels = 200,
        effect = "Targets worth +10% more",
        cost = "coins * level^1.4"
    },
    
    spawn_rate = {
        levels = 50,
        effect = "New target every -0.1s (base: 5s)",
        cost = "coins * level^1.8"
    },
    
    target_types = {
        unlocks = {
            [1] = {name = "Silver targets", value = 2, cost = 1000},
            [5] = {name = "Gold targets", value = 5, cost = 10000},
            [10] = {name = "Diamond targets", value = 10, cost = 100000},
            [20] = {name = "Rainbow targets", value = "scaling", cost = 1000000},
            [30] = {name = "Quantum targets", value = "random 1-100x", cost = 10000000}
        }
    },
    
    target_size = {
        levels = 30,
        effect = "Targets 3% larger",
        cost = "coins * level^2.2"
    },
    
    magnetism = {
        levels = 40,
        effect = "Targets attract darts within 2 pixels",
        cost = "skill_points * level"
    }
}
```

### 3. Dartboard Improvements

Upgrade your playing field:

```lua
DartboardUpgrades = {
    board_quality = {
        tiers = {
            cork = {
                multiplier = 1.0,
                description = "A basic cork board"
            },
            sisal = {
                multiplier = 1.5,
                cost = 1000,
                description = "Professional-grade sisal fibers"
            },
            electronic = {
                multiplier = 2.0,
                cost = 10000,
                description = "LED-enhanced scoring zones"
            },
            magnetic = {
                multiplier = 3.0,
                cost = 100000,
                description = "Magnetic assistance technology"
            },
            holographic = {
                multiplier = 5.0,
                cost = 1000000,
                description = "3D holographic projection"
            },
            quantum = {
                multiplier = 10.0,
                cost = 10000000,
                description = "Quantum superposition scoring"
            }
        }
    },
    
    scoring_zones = {
        levels = 50,
        effect = "Bullseye zone +2% larger",
        cost = "coins * level^1.7"
    },
    
    zone_multipliers = {
        inner_ring = {
            levels = 100,
            effect = "+0.1x multiplier",
            cost = "coins * level^1.5"
        },
        outer_ring = {
            levels = 100,
            effect = "+0.05x multiplier",
            cost = "coins * level^1.3"
        }
    },
    
    special_zones = {
        unlocks = {
            [10] = "Triple score zone",
            [25] = "Moving bonus zone",
            [50] = "Chaos zone (random 0.1x-10x)"
        }
    }
}
```

### 4. Technique Tree

Master advanced throwing techniques:

```lua
TechniqueTree = {
    focus_mode = {
        description = "Time slows while aiming",
        levels = 20,
        effect = "Time scale -5% per level",
        cost = "skill_points * level"
    },
    
    combo_master = {
        description = "Consecutive hits build multiplier",
        levels = 50,
        effect = "+0.1x per hit, max +5x at level 50",
        cost = "skill_points * level^1.2"
    },
    
    ricochet = {
        description = "Darts bounce to nearby targets",
        levels = 10,
        effect = "+1 bounce",
        cost = "gems * level^2"
    },
    
    curve_shot = {
        description = "Control dart trajectory mid-flight",
        levels = 30,
        effect = "3% more curve control",
        cost = "skill_points * level^1.5"
    },
    
    zen_mode = {
        description = "Perfect throws restore energy",
        levels = 20,
        effect = "+5 energy on bullseye",
        cost = "gems * level"
    }
}
```

## Prestige System

### Three-Layer Prestige

#### 1. Professional Level (First Prestige)
- **Requirement**: 1 million total points
- **Reset**: Coins, basic upgrades
- **Keep**: Gems, achievements, skill points
- **Bonus**: +100% point gain per prestige level
- **Unlock**: New dart types, advanced techniques

#### 2. Championship Level (Second Prestige)
- **Requirement**: 100 professional levels
- **Reset**: Professional levels, most upgrades
- **Keep**: Some permanent upgrades, collection items
- **Bonus**: Fundamental scoring changes
- **Unlock**: Exotic dartboards, quantum mechanics

#### 3. Legendary Level (Third Prestige)
- **Requirement**: 10 championship levels
- **Reset**: Almost everything
- **Keep**: Core statistics, hall of fame entry
- **Bonus**: Reality-bending dart physics
- **Unlock**: Developer mode, custom rule sets

### Prestige Bonuses

```lua
PrestigeBonuses = {
    -- Professional bonuses
    starting_coins = "1000 * professional_level",
    starting_accuracy = "5% * professional_level",
    
    -- Championship bonuses
    all_targets_golden = "10% * championship_level",
    energy_regen_boost = "0.5/s * championship_level",
    
    -- Legendary bonuses
    reality_break = "Can throw through time",
    infinite_bounce = "Darts never stop bouncing",
    
    -- Automation unlocks
    unlock_automation = {
        [5] = "Auto-collect coins",
        [10] = "Auto-buy cheapest upgrade",
        [25] = "Smart upgrade AI",
        [50] = "Perfect throw assistant",
        [100] = "Predictive targeting"
    }
}
```

## Active Mechanics

### Energy System

Players must manage their energy to keep playing:

```lua
EnergySystem = {
    max_energy = 100,
    regen_rate = "1 per second",
    throw_cost = 10,
    
    upgrades = {
        max_energy = {
            levels = 50,
            effect = "+10 max energy",
            cost = "coins * level^1.8"
        },
        regen_rate = {
            levels = 100,
            effect = "+0.1 per second",
            cost = "coins * level^1.5"
        },
        efficiency = {
            levels = 20,
            effect = "-0.5 energy per throw",
            cost = "gems * level"
        }
    },
    
    energy_sources = {
        perfect_shot = "+5 energy",
        combo_milestone = "+10 energy",
        watch_ad = "Full refill",
        wait_time = "1 per second"
    }
}
```

### Challenge System

Keep players engaged with varied objectives:

```lua
Challenges = {
    -- Quick challenges (refresh every 5 minutes)
    quick_challenges = {
        "Hit 3 bullseyes in a row",
        "Score exactly 500 points",
        "Hit all corners in order"
    },
    
    -- Daily challenges
    daily_challenges = {
        monday = "Reach 50x combo",
        tuesday = "Unlock 5 upgrades",
        wednesday = "Hit 100 moving targets",
        thursday = "Score 1 million in one session",
        friday = "Complete without missing once",
        weekend = "Double points special"
    },
    
    -- Lifetime achievements
    lifetime_challenges = {
        "The Perfectionist" = "100 bullseyes in a row",
        "Speed Demon" = "1000 targets in 60 seconds",
        "The Collector" = "Unlock all dart types",
        "Precision Master" = "1 million total bullseyes",
        "The Legend" = "Reach legendary prestige"
    }
}
```

## Meta-Progression

### Research Lab

Long-term projects that unlock new mechanics:

```lua
ResearchLab = {
    projects = {
        dart_physics = {
            time = "10 minutes",
            cost = "10000 coins",
            reward = "Unlock curved throw",
            stages = 5
        },
        
        target_ai = {
            time = "1 hour",
            cost = "100000 coins",
            reward = "Targets move intelligently",
            stages = 10
        },
        
        quantum_darts = {
            time = "24 hours",
            cost = "10 gems",
            reward = "Darts exist in multiple states",
            stages = 20
        },
        
        time_manipulation = {
            time = "7 days",
            cost = "100 gems",
            reward = "Rewind bad throws",
            stages = 50
        }
    }
}
```

### Collection System

Collect and display your achievements:

```lua
Collections = {
    dart_types = {
        "Standard", "Steel tip", "Tungsten", "Laser",
        "Plasma", "Black hole", "Quantum", "Temporal"
    },
    
    board_themes = {
        "Classic", "Neon", "Space", "Medieval",
        "Cyberpunk", "Abstract", "Matrix", "Void"
    },
    
    legendary_throws = {
        "The One" = "Hit exact center pixel",
        "Around the World" = "Hit every zone in one throw",
        "Time Stop" = "Hit target at 0.001s remaining"
    },
    
    set_bonuses = {
        complete_dart_set = "+50% all gains",
        themed_setup = "+25% specific gains",
        legendary_combo = "Unlock secret ending"
    }
}
```

## Scaling and Balance

### Cost Scaling Formula

```lua
function calculateCost(basePrice, level, growthRate)
    -- Exponential growth with soft caps
    local softCap1 = 25
    local softCap2 = 100
    local softCap3 = 500
    
    if level < softCap1 then
        -- Normal exponential growth
        return math.floor(basePrice * growthRate^level)
    elseif level < softCap2 then
        -- First soft cap - slower growth
        local baseCost = basePrice * growthRate^softCap1
        return math.floor(baseCost * (1 + (level - softCap1) * 0.5))
    elseif level < softCap3 then
        -- Second soft cap - linear growth
        local baseCost = calculateCost(basePrice, softCap2, growthRate)
        return math.floor(baseCost * (1 + (level - softCap2) * 0.1))
    else
        -- Final soft cap - logarithmic growth
        local baseCost = calculateCost(basePrice, softCap3, growthRate)
        return math.floor(baseCost * (1 + math.log(level - softCap3 + 1)))
    end
end
```

### Points Calculation

```lua
function calculatePoints(base, accuracy, multipliers)
    -- Base points from target type
    local points = base
    
    -- Accuracy bonus (distance from center)
    local accuracyMultiplier = 2.0 - (accuracy / 100) -- 2x at center, 1x at edge
    points = points * accuracyMultiplier
    
    -- Apply all multipliers
    for source, mult in pairs(multipliers) do
        points = points * mult
    end
    
    -- Prestige multipliers (multiplicative)
    points = points * (1 + professionalLevel * 1.0)
    points = points * (1 + championshipLevel * 5.0)
    points = points * (1 + legendaryLevel * 25.0)
    
    return math.floor(points)
end
```

## Special Features

### NO Idle Progress
This is an **active incremental** game. Key differences:
- No offline progress
- No passive income
- Energy system requires active play
- All progress requires player action

### Skill-Based Progression
- Accuracy matters for income
- Timing challenges
- Pattern recognition
- Resource management decisions

### Social Features
```lua
SocialFeatures = {
    tournaments = {
        daily = "Same seed competition",
        weekly = "Endurance challenge",
        special = "Holiday themed events"
    },
    
    friendChallenges = {
        ghost_race = "Beat friend's best run",
        coop_targets = "Hit targets together",
        versus = "Real-time competition"
    },
    
    sharing = {
        replay_best_throw = true,
        screenshot_achievements = true,
        challenge_friends = true
    }
}
```

## Monetization (Optional)

### Ethical Monetization
- **No pay-to-win** - Only convenience and cosmetics
- **Energy refills** - Watch ads or wait
- **Cosmetic packs** - Dart skins, board themes
- **Research boost** - Reduce research time by 50%
- **Starter packs** - One-time purchases for new prestiges

## End Game Content

### Infinity Mode
After reaching Legendary 10:
- Exponential scaling enemies
- Procedural challenge generation
- Community leaderboards
- Weekly "impossible" challenges

### New Game Plus
- Keep one upgrade tree
- All costs 10x
- All rewards 10x
- New story mode unlocked

This design creates a compelling active incremental experience that rewards both short sessions and long-term dedication without relying on idle mechanics.