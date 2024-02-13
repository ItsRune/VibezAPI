---
sidebar_position: 1
---

If you haven't read about how to use the [Activity Tracker](/docs/APIs/Activity%20Tracking) yet, we'd recommend reading that first.

### Creating a backup of a player's activity
```lua
--// Services \\--
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

--// Variables \\--
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

--// Functions \\--
local function onPlayerLeft(Player: Player)
    local userActivity = Vibez:getActivity(Player.UserId)
end

--// Connections \\--
Players.PlayerRemoving:Connect(onPlayerLeft)
```

### Add Activity
```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

local function addActivity(playerUserId: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(playerUserId, secondsSpent, messagesSent)
end

addActivity(107392833, 10, 5) -- 107392833 is the user id of the staff member
```