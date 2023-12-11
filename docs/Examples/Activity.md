---
sidebar-position: 1
---

<h3>Note: You do NOT need every example in your game, just pick and choose what you'd like.</h3>

### Get Activity
```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

local function getActivity(Player: Player)
    local activity = Vibez:getActivity(Player.UserId)
    return activity
end
```

### Add Activity
```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

local function addActivity(playerUserId: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(playerUserId, secondsSpent, messagesSent)
end

addActivity(107392833, 10, 5) -- 107392833 is the user id of the staff member
```