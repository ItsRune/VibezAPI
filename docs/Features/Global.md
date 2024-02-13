---
sidebar_position: 6
---

# Global API

### What is a global API?
A global API is an API that you can use whilst in game. This means that you can use it in the command line or in a script; without having to require a new module. This is because the API is already loaded into the game and removes the need for reinitializing everything which could potentially slow down response times of certain scripts.

### How do I use a global API?
Our global API is located within Roblox's `_G` global variable. This means that you can access it by using `_G` followed by the API name. For example, if you wanted to use the `Ranking` API, you would use `_G.VibezAPI.Ranking` to access it. We have neatly separated our APIs to make it easier to find and use them.

--------------------

### What global APIs are available?
We have a variety of global APIs available for you to use, each method returns function that has it's own parameters as defined below. These include:

<h2>Ranking</h2>

| Method Name | Arguments | Description | Example |
| :---: | :---: | :---: | :---: |
| `Promote` | `userId:number` | Increments a player's rank by 1. | `_G.VibezApi.Ranking:Promote(1)` |
| `Demote` | `userId:number` | Decrements a player's rank by 1. | `_G.VibezApi.Ranking:Demote(1)` |
| `setRank` | `userId:number`,<br />`rank:number` | Sets a player's rank to a specific rank. | `_G.VibezApi.Ranking:setRank(1, 0)` |

<h2>Activity</h2>

| Method Name | Arguments | Description | Example |
| :---: | :---: | :---: | :---: |
| `getActivity` | `userId:number` | Gets the activity of a player. | `_G.VibezApi.Activity:getActivity(1)` |
| `saveActivity` | `userId:number`,<br />`userRank:number`,<br />`seconds:number`,<br />`messages:number`,<br />`forceFetchRank:boolean` | Saves the activity of a player. | `_G.VibezApi.Activity:saveActivity(1, 0, 20, 0, false)` |

<h2>Hooks</h2>

| Method Name | Arguments | Description | Example |
| :---: | :---: | :---: | :---: |
| `new` | `webhook:string` | Creates a new webhook. | `_G.VibezApi.Hooks:new("https://discord.com/api/webhooks/")` |

<h2>Notifications</h2>

| Method Name | Arguments | Description | Example |
| :---: | :---: | :---: | :---: |
| `new` | `player:Player`,<br />`message:string` | Creates a notification for a player. | `_G.VibezApi.Notifications:new(game.Players.LocalPlayer, "Hello World!")` |

--------------------

### Examples
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