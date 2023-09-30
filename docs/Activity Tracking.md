---
sidebar_position: 5
---

### How does the activity tracking work?
The activity tracker works by using object orientated programming that creates specific functions to call upon each staff member within the game. This allows for a more efficient way of tracking staff members and their activity. The activity tracker is also able to track the amount of time a staff member has been active for, and the amount of time they have been inactive for. This allows for a more accurate representation of how active a staff member is.

**NOTE:** Inactivity is not sent to Vibez API, it is only used for the activity tracker.

### How do I use the activity tracker?
The activity tracker is very simple to use. All you need to do is require the main module and change an option to `true`.

```lua
local Vibez = require(0).new("API Key", {
    activityTrackingEnabled = true
})
```

In addition to this setting is 2 other options: `rankToStartTrackingActivityFor` and `toggleTrackingOfAFKActivity`
- `rankToStartTrackingActivityFor` is the rank that the activity tracker will start tracking activity for. This is useful if you want to only track activity for a specific rank.
- `toggleTrackingOfAFKActivity` is a boolean that toggles whether or not the activity tracker will automatically pause counting activity for AFK users.

### How do I get the activity of a staff member?
Getting the activity of a staff member is very simple. All you need to do is call the `getActivity` function on the Vibez object.

```lua
local Vibez = require(0).new("API Key", {
    activityTrackingEnabled = true
})

local activity = Vibez:getActivity(107392833) -- 107392833 is the user id of the staff member
```

**TIP:** If you'd like to get everyone's activity... Don't put a user id in the `getActivity` function.

### How do I add seconds to a specific player?
Vibez allows for customization when necessary, if you're writing your own activity tracker you can achieve this with the `saveActivity` method that the wrapper provides.

```lua
local Vibez = require(0).new("API Key", {
    activityTrackingEnabled = true
})

local function addSecondsToPlayer(UserId: number, secondsSpent: number, messagesSent: number)
    Vibez:saveActivity(UserId, secondsSpent, messagesSent)
end

addSecondsToPlayer(107392833, 10, 5) -- 107392833 is the user id of the staff member
```