---
sidebar_position: 6
---

# Global API

### What is a global API?
A global API is an API that you can use whilst in game. This means that you can use it in the command line or in a script; without having to require a new module. This is because the API is already loaded into the game and removes the need for reinitializing everything which could potentially slow down response times of certain scripts.

### How do I use a global API?
Our global API is located within Roblox's `_G` global variable. This means that you can access it by using `_G` followed by the API name. For example, if you wanted to use the `Ranking` API, you would use `_G.VibezAPI.Ranking` to access it. We have neatly separated our APIs to make it easier to find and use them.

### Is there an easier method to fetching the global API?
Yes! If your script has direct access to the module, you can use `.awaitGlobals()` to wait for the global APIs to load. This is useful if you're unsure if the global APIs have loaded yet.

```lua
local Vibez = require(game:GetService("ServerScriptService").VibezAPI)
local globalApi = Vibez.awaitGlobals()
```

---

## What global APIs are available?

### Ranking
<a href="#ranking/promote"><h3>Promote</h3></a>
Increments a player's rank by 1.

`userId: number`

```lua
_G.VibezApi.Ranking:Promote(1)
```

<a href="#ranking/demote"><h3>Demote</h3></a>
Decrements a player's rank by 1.

`userId: number`

```lua
_G.VibezApi.Ranking:Demote(1)
```

<a href="#ranking/setrank"><h3>setRank</h3></a>
Sets a player's rank to a specific rank.

`userId: number` <br />
`rank: number | string`

```lua
_G.VibezApi.Ranking:setRank(1, 2)
```

---

### Activity
<a href="#activity/get"><h3>getActivity</h3></a>
Gets the activity of a player.

`userId: number`

```lua
_G.VibezApi.Activity:getActivity(1)
```

<a href="#activity/save"><h3>saveActivity</h3></a>
Gets the activity of a player.

`userId: number` <br />
`userRank: number` <br />
`seconds: number` <br />
`messages: number` <br />
`forceFetchRank: boolean`

```lua
_G.VibezApi.Activity:saveActivity(1, 0, 20, 0, false)
```

---

### Hooks
<a href="#hooks/new"><h3>new</h3></a>
Creates a new webhook.

`webhook: string`

```lua
_G.VibezApi.Hooks:new("https://discord.com/api/webhooks/")
```

---

### Notifications
<a href="#notifications/new"><h3>new</h3></a>
Creates a notification for a player.

`player: Player` <br />
`message: string`

```lua
_G.VibezApi.Notifications:new(game.Players.ltsRune, "Hello World!")
```

---

### General
<a href="#general/getgroup"><h3>getGroup</h3></a>
Gets a group from the player's perspective.

`player: Player` <br />
`groupId: number`

```lua
_G.VibezApi.General:getGroup(game.Players.ltsRune, 0)
```

<a href="#general/getgrouprank"><h3>getGroupRank</h3></a>
Gets a player's group rank.

`player: Player` <br />
`groupId: number`

```lua
_G.VibezApi.General:getGroupRank(game.Players.ltsRune, 0)
```

<a href="#general/getgrouprole"><h3>getGroupRole</h3></a>
Gets a player's group role.

`player: Player` <br />
`groupId: number`

```lua
_G.VibezApi.General:getGroupRole(game.Players.ltsRune, 0)
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

    vibezGlobal.Notifications:new(Player, "Welcome to the game!")
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

    local webHook = vibezGlobal.Hooks:new("https://discord.com/api/webhooks/")
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

    local webHook = vibezGlobal.Hooks:new("https://discord.com/api/webhooks/")
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