---
sidebar-position: 2
---

<h3>Note: You do NOT need every example in your game, just pick and choose what you'd like.</h3>

### SetRank for application center
```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

local function gradePlayerApplication(Player: Player, application: {any})
    local score = 0

    -- Computation for score

    if score >= application.minScore then
        Vibez:setRank(Player.UserId, application.Rank)
    end
end
```

### Promotions/Demotions/Firing Staff
```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

local function promotePlayer(Player: Player)
    Vibez:Promote(Player.UserId)
end

local function demotePlayer(Player: Player)
    Vibez:Demote(Player.UserId)
end

local function firePlayer(Player: Player)
    Vibez:Fire(Player.UserId)
end

local function setPlayerRank(Player: Player, Rank: number | string)
    Vibes:setRank(Player.UserId, Rank)
end
```