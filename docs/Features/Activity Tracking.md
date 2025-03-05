---
sidebar_position: 3
---

## How does the activity tracking work?
The activity tracker works by using object orientated programming that creates specific functions to call upon each staff member within the game. This allows for a more efficient way of tracking staff members and their activity. The activity tracker is also able to track the amount of time a staff member has been active for, and the amount of time they have been inactive for. This allows for a more accurate representation of how active a staff member is.

## Setup
All you need to do is require the main module and change an option to `true`. Then you're all set up to use the activity tracker within your game.

```lua
local Vibez = require(14946453963)("API Key", {
    ActivityTracker = {
        Enabled = true, -- Enabled the tracker for players.
        MinRank = 255, -- The minimum rank that a staff member must be to be tracked.
        disableWhenInStudio = true, -- Disables when studio play testing.
        disableWhenAFK = true, -- Disables when player is detected as AFK.
        disableWhenInPrivateServer = true, -- Disables when player is in a private server.
        delayBeforeMarkedAFK = 15, -- The amount of seconds to wait before the player is marked AFK.

        kickIfFails = true, -- Used to kick the player if the activity tracker fails to initialize, below is the message for this occurrence.
        failMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",
    }
})
```

## Usage
### [getActivity](/VibezAPI/api/VibezAPI#getActivity)
Gets a player's current activity. (Leave blank for everyone's activity)

Parameter(s): <br />
``userId: (string | number | Player)?`` - The user id of the player you want to get the activity of. **OPTIONAL**<br />

Returns: [activityResponse](/VibezAPI/api/VibezAPI#activityResponse)

```lua
local allPlayerActivity = VibezApi:getActivity()
local myActivity = VibezApi:getActivity(107392833)
```

### [saveActivity](/VibezAPI/api/VibezAPI#saveActivity)
Saves a player's activity.

Parameter(s): <br />
``userId: (string | number | Player)`` - The user id of the player you want to save the activity of. <br />
``userRank: number`` - The rank of the player.<br />
``secondsSpent: number`` - The amount of seconds the player has spent. <br />
``messagesSent: number`` - The amount of messages the player has sent. <br />

Returns: [httpResponse](/VibezAPI/api/VibezAPI#httpResponse)

```lua
VibezApi:saveActivity(107392833, 200, 10, 5)
```

## Examples

<details>
<summary>Creating a backup of all player activity</summary>
<br />

```lua "ServerScriptService/ActivityBackup.lua"
--// Services \\--
local DataStoreService = game:GetService("DataStoreService")

--// Variables \\--
local Vibez = require(14946453963)("API Key")
local backupDataStore = DataStoreService:GetDataStore("PlayerActivity")

--// Functions \\--
local function onGameShutdown()
    local allActivity = Vibez:getActivity() -- Leaving this blank will invoke all player's activity.
    pcall(backupDataStore.SetAsync, backupDataStore, "Backup", allActivity)
end

--// Connections \\--
game:BindToClose(onGameShutdown)
```

</details>