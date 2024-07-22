---
sidebar_position: 6
---

# Global API

### What is a global API?
The global API is a set of functions that can be accessed from any script within your game. This is more efficient than having to create a new API for each script that needs to access the same data.

### How do I use a global API?
Our global API is located withing Roblox's 'ServerStorage' service. You can find it by using the 'getGlobalsForKey' method from the Vibez module. This method will return the global API associated to that api key.

### Is there an easier method to fetching the global API?
Yes! If your script has direct access to the module, you can use `.awaitGlobals()` to wait for the global APIs to load. This is useful if you're unsure if the global APIs have loaded yet.

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

<a href="#ranking/setrank"><h3>setRank</h3></a>
Sets a player's rank to a specific rank.

`userId: number` <br />
`rank: number | string`

```lua
globalsAPI.Ranking.setRank:Invoke(1, 2)
```

---

### Activity
<a href="#activity/get"><h3>getActivity</h3></a>
Gets the activity of a player.

`userId: number`

```lua
globalsAPI.Activity.Fetch:Invoke(1)
```

<a href="#activity/save"><h3>saveActivity</h3></a>
Gets the activity of a player.

`userId: number` <br />
`userRank: number` <br />
`seconds: number` <br />
`messages: number` <br />
`forceFetchRank: boolean`

```lua
globalsAPI.Activity.Save:Invoke(1, 0, 20, 0, false)
```

---

### Hooks
<a href="#hooks/new"><h3>new</h3></a>
Creates a new webhook.

`webhook: string`

```lua
globalsAPI.Hooks:Invoke("https://discord.com/api/webhooks/")
```

---

### Notifications
<a href="#notifications/new"><h3>new</h3></a>
Creates a notification for a player.

`player: Player` <br />
`message: string`

```lua
globalsAPI.Notifications:Invoke(game.Players.ltsRune, "Hello World!")
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