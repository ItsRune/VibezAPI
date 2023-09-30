---
sidebar-position: 6
---

## Quick Links
- [Api Options](#api_options)
- [Ranking](#ranking)

### API Options <a name="api_options"></a>
The wrapper includes options that you can change to your liking. Look at [API Options](/VibezAPI/api/VibezAPI#extraOptionsType) for the list of options and the values they require.

### Ranking <a name="ranking"></a>
This function demonstrates how to use the ranking system.

#### SetRank
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

#### Promotions/Demotions/Firing Staff
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

### Activity
This function demonstrates how to get/add activity.

#### Get Activity
```lua
local Vibez = require(0).new("API Key")

local function getActivity(Player: Player)
    local activity = Vibez:getActivity(Player.UserId)
    print(activity)
end
```

#### Add Activity
```lua
local Vibez = require(0).new("API Key")

local function addActivity(playerUserId: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(playerUserId, secondsSpent, messagesSent)
end

addActivity(107392833, 10, 5) -- 107392833 is the user id of the staff member
```