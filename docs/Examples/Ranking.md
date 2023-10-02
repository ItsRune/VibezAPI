---
sidebar-position: 8
---

## Implementing in-game services
> In game services include ranking commands, ranking UI and the activity tracker.
1. Create a new script in "ServerScriptServices" called "VibezServices"
2. Insert the below code into the script
3. Adjust the settings based on your needs

# The script
```lua
local myKey = "YOUR_API_KEY_HERE"
local VibezRankingAPI = require(14946453963)
local Wrapper = VibezRankingAPI(myKey, {
  -- Activity
  activityTrackingEnabled = true;
  toggleTrackingOfAFKActivity = false;
  rankToStartTrackingActivityFor = 220;

  -- UI OR Commands
  isChatCommandsEnabled = true;
  isUIEnabled = true;

  minRankToUseCommandsAndUI = 255;
  maxRankToUseCommandsAndUI = 255;

  -- Commands Only
  commandPrefix = "!";

  -- Utility
  overrideGroupCheckForStudio = true;
  ignoreWarnings = false;
  loggingOriginName = "Main Game";
})
```

### SetRank
```lua
local Vibez = require(14946453963).new("API Key")

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
local Vibez = require(14946453963).new("API Key")

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