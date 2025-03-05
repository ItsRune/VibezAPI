---
sidebar_position: 7
---

# Global API

### What is a global API?
The global API is a set of functions that can be accessed from any script within your game. This is more efficient than having to create a new API for each script that needs to access the same data.

### How do I use a global API?
Our global API is located withing Roblox's 'ServerStorage' service. You can find it by using the 'getGlobalsForKey' method from the Vibez module. This method will return the global API associated to that api key.

### Is there an easier method to fetching the global API?
Yes! If your script has direct access to the module, you can use `.getGlobalsForKey(ApiKey)` to get your api key's specific global API.

### It doesn't exist when trying to lookup my api key within ServerStorage.
This is completely normal and is not a bug. Due to the way we store the global API, it would not be smart to name the folder after your api key. Instead, we generate a new GUID (Globally Unique Identifier) for each specific key.

```lua
local Vibez = require(14946453963)
local globalsAPI = Vibez.getGlobalsForKey("myApiKey")
```

---

## What global APIs are available?

### Ranking
<a href="#ranking/promote"><h3>Promote</h3></a>
Increments a player's rank by 1.

`userId: number`

```lua title="ServerScriptService/ExampleScript.server.lua"
globalsAPI.Ranking.Promote:Invoke(1)
```

<a href="#ranking/demote"><h3>Demote</h3></a>
Decrements a player's rank by 1.

`userId: number`

```lua
globalsAPI.Ranking.Demote:Invoke(1)
```

<a href="#ranking/fire"><h3>Fire</h3></a>
Sets the player's rank back to 1.

`userId: number`

```lua
globalsAPI.Ranking.Fire:Invoke(1)
```

<a href="#ranking/setrank"><h3>setRank</h3></a>
Sets a player's rank to a specific rank.

`userId: number` <br />
`rank: number | string`

```lua
globalsAPI.Ranking.setRank:Invoke(1, 2)
```

---

### ActivityTracker
<a href="#activity/get"><h3>Fetch</h3></a>
Gets the activity of a player.

`userId: number`

```lua
globalsAPI.ActivityTracker.Fetch:Invoke(1)
```

<a href="#activity/save"><h3>Save</h3></a>
Gets the activity of a player.

`userId: number` <br />
`userRank: number` <br />
`seconds: number` <br />
`messages: number` <br />
`forceFetchRank: boolean`

```lua
globalsAPI.ActivityTracker.Save:Invoke(1, 0, 20, 0, false)
```

<a href="#activity/delete"><h3>Delete</h3></a>
Gets the activity of a player.

`userId: number` <br />
`userRank: number` <br />
`seconds: number` <br />
`messages: number` <br />
`forceFetchRank: boolean`

```lua
globalsAPI.ActivityTracker.Save:Invoke(1, 0, 20, 0, false)
```

---

### Hooks
<a href="#hooks/create"><h3>Create</h3></a>
Creates a new webhook.

`webhook: string`

```lua
globalsAPI.Hooks.Create:Invoke("https://discord.com/api/webhooks/")
```

---

### Notifications
<a href="#notifications/send"><h3>Send</h3></a>
Send a notification to the player. Please note that there are specific keywords that are used to color code the notification messages. Please visit [this page](/docs/Features/Notifications) to see the full list of keywords.

`player: Player` <br />
`message: string`

```lua
globalsAPI.Notifications.Send:Invoke(game.Players.ltsRune, "Hello World!")
```

---

### General
<a href="#general/getgroup"><h3>getGroup</h3></a>
Gets a group from the player's perspective.

`player: Player` <br />
`groupId: number`

```lua
globalsAPI.General.getGroup:Invoke(game.Players.ltsRune, 0)
```

<a href="#general/getgrouprank"><h3>getGroupRank</h3></a>
Gets a player's group rank.

`player: Player` <br />
`groupId: number`

```lua
globalsAPI.General.getGroupRank:Invoke(game.Players.ltsRune, 0)
```

<a href="#general/getgrouprole"><h3>getGroupRole</h3></a>
Gets a player's group role.

`player: Player` <br />
`groupId: number`

```lua
globalsAPI.General.getGroupRole:Invoke(game.Players.ltsRune, 0)
```

---
### Blacklists
<a href="#blacklists/get"><h3>Get</h3></a>
Gets a player's blacklist information.

`player: Player | string | number` <br />

```lua
globalsAPI.Blacklists.Get:Invoke(game.Players.ltsRune)
```

<a href="#blacklists/add"><h3>Add</h3></a>
Adds a player to the blacklist.

`userToBlacklist: Player` <br />
`Reason: string?` <br />
`blacklistExecutedBy: (Player | string | number)?` <br />

```lua
globalsAPI.Blacklists.Add:Invoke(game.Players.ltsRune)
```

<a href="#blacklists/delete"><h3>Delete</h3></a>
Deletes a player from being blacklisted.

`player: Player | string | number` <br />

```lua
globalsAPI.Blacklists.Delete:Invoke(game.Players.ROBLOX)
```


---

## Examples
Here are some examples of how you can use our global APIs:

<details>
<summary>Welcome Message</summary>
<br />

```lua title="ServerScriptService/Welcome_Message.lua"
local function onPlayerAdded(Player: Player)
    local vibezGlobal = _G["VibezApi"]

    while vibezGlobal == nil do
        vibezGlobal = _G["VibezApi"]
        task.wait(.25)
    end

    vibezGlobal.Notifications.new:Invoke(Player, "Welcome to the game!")
end

game:GetService("Players").PlayerAdded:Connect(onPlayerAdded)
```

</details>

<details>
<summary>Join and Leave logger</summary>
<br />

```lua title="ServerScriptService/Join_Logger_And_Leave_Logger.lua"
local Players = game:GetService("Players")

local function onPlayerAdded(Player: Player)
    local vibezGlobal = _G["VibezApi"]

    while vibezGlobal == nil do
        vibezGlobal = _G["VibezApi"]
        task.wait(.25)
    end

    local webHook = vibezGlobal.Hooks.new:Invoke("https://discord.com/api/webhooks/")
    webHook
        :setContent(
            string.format(
                "[**%s**](<https://www.roblox.com/users/%d/profile>) has joined the game!",
                Player.Name,
                Player.UserId
            )
        )
        :Send()
end

local function onPlayerLeft(Player: Player)
    local vibezGlobal = _G["VibezApi"]

    while vibezGlobal == nil do
        vibezGlobal = _G["VibezApi"]
        task.wait(.25)
    end

    local webHook = vibezGlobal.Hooks.new:Invoke("https://discord.com/api/webhooks/")
    webHook
        :setContent(
            string.format(
                "[**%s**](<https://www.roblox.com/users/%d/profile>) has left the game!",
                Player.Name,
                Player.UserId
            )
        )
        :Send()
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerLeft)
```

</details>