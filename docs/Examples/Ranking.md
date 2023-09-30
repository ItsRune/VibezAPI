---
sidebar-position: 1
---

### SetRank
```lua
local Vibez = require(0).new("API Key")

local function gradePlayerApplication(Player: Player, application: {any})
    local score = 0

    -- Computation for score

    if score >= application.minScore then
        Vibez:SetRank(Player.UserId, application.Rank)
    end
end
```

### Promotions/Demotions/Firing Staff
```lua
local Vibez = require(0).new("API Key")

local function promotePlayer(Player: Player)
    Vibez:Promote(Player.UserId)
end

local function demotePlayer(Player: Player)
    Vibez:Demote(Player.UserId)
end

local function firePlayer(Player: Player)
    Vibez:Fire(Player.UserId)
end
```