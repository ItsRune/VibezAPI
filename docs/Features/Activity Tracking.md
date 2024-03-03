---
sidebar_position: 2
---

### How does the activity tracking work?
The activity tracker works by using object orientated programming that creates specific functions to call upon each staff member within the game. This allows for a more efficient way of tracking staff members and their activity. The activity tracker is also able to track the amount of time a staff member has been active for, and the amount of time they have been inactive for. This allows for a more accurate representation of how active a staff member is.

**NOTE:** Inactivity is not sent to Vibez API, it is only used for the activity tracker.

### How do I use the activity tracker?
The activity tracker is very simple to use. All you need to do is require the main module and change an option to `true`.

```lua
local Vibez = require(14946453963)("API Key", {
    ActivityTracker = {
        Enabled = true, -- Enabled the tracker for players.
        MinRank = 255, -- The minimum rank that a staff member must be to be tracked.
    }
})
```

In addition to this setting is a couple of other settings that you can change to your liking. These settings are as follows:

| Setting | Type | Description |
| :---: | :---: | :---: |
| `Enabled` | `boolean` | Whether or not the activity tracker is enabled. |
| `MinRank` | `number` | The minimum rank that a staff member must be to be tracked. |
| `disableWhenInStudio` | `boolean` | Disables when studio play testing. |
| `disableWhenAFK` | `boolean` | Disables when player is detected as AFK. |
| `disableWhenInPrivateServer` | `boolean` | Disables when player is in a private server. |
| `delayBeforeMarkedAFK` | `number` | The amount of seconds to wait before the player is marked AFK. |
| `kickIfFails` | `boolean` | Sometimes ROBLOX can mess up player initialization, when this occurs it can cause the activity tracker to not setup with the player. Would you like to kick the player when this happens? |
| `failMessage` | `string` | The message to kick the player with when `kickIfFails` is enabled. |

### How do I get the activity of a staff member?
Getting the activity of a staff member is very simple. All you need to do is call the `getActivity` function on the Vibez object.

```lua
local Vibez = require(14946453963)("API Key", {
    ActivityTracker = {
        Enabled = true,
        MinRank = 255,
    }
})

local activity = Vibez:getActivity(107392833) -- 107392833 is the user id of the staff member
```

**TIP:** If you'd like to get everyone's activity... Don't put a user id in the `getActivity` function.

### How do I add seconds to a specific player?
Vibez allows for customization when necessary, if you're writing your own activity tracker you can achieve this with the `saveActivity` method that the wrapper provides.

```lua
local Vibez = require(14946453963)("API Key", {
    ActivityTracker = {
        Enabled = true,
        MinRank = 255,
    }
})

local function addSecondsToPlayer(UserId: number, userRank: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(UserId, userRank, secondsSpent, messagesSent)
end

local function addSecondsToPlayerWithoutRank(UserId: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(UserId, nil, secondsSpent, messagesSent, true)
end

-- Example usage
-- adding 10 seconds and 5 messages
addSecondsToPlayer(107392833, 250, 10, 5)
addSecondsToPlayerWithoutRank(107392833, 10, 5)
```

### How do I get everyone's activity?
Currently you cannot, but in the future we hope to add this as a feature.