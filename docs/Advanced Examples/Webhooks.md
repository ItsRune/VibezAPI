---
sidebar_position: 14
---

<h3>Note: You do NOT need every example in your game, just pick and choose what you'd like.</h3>

## Logs
For any kind of logs that require an on server start-up event, you should use `:waitUntilLoaded()` to ensure that the API is loaded before you try to use it. You also have to set `isAsync` to `true` in the API settings.

### Join Logs

<h4>Preview:</h4>
<img src="/VibezAPI/joinLogExample.png"></img>

```lua
local Players = game:GetService("Players")
local Vibez = require(14946453963)("API Key", {
    isAsync = true
})

Players.PlayerAdded:Connect(function(Player)
    local api = Vibez:waitUntilLoaded()
    if api == nil then
        error("API Failed to load!")
    end

    local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")
    webhook:setContent(
        `[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>) has joined the game!`
    ):Send()
end)
```

### Leave Logs

<h4>Preview:</h4>
<img src="/VibezAPI/leaveLogExample.png"></img>

```lua
local Players = game:GetService("Players")
local Vibez = require(14946453963)("API Key", {
    isAsync = true
})

Players.PlayerRemoving:Connect(function(Player)
    local api = Vibez:waitUntilLoaded()
    if api == nil then
        error("API Failed to load!")
    end

    local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")
    webhook:setContent(
        `[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>) has left the game!`
    ):Send()
end)
```

### Message Logs

<h4>Preview:</h4>
<img src="/VibezAPI/messageLogExample.png"></img>

```lua
local Players = game:GetService("Players")
local Vibez = require(14946453963)("API Key", {
    isAsync = true
})

Players.PlayerAdded:Connect(function(Player)
    local api = Vibez:waitUntilLoaded()
    if api == nil then
        error("API Failed to load!")
    end

    Player.Chatted:Connect(function(Message: string)
        local webhook = api:getWebhookBuilder("https://discord.com/api/webhooks/")
        webhook:setContent(
            `\[[**{Player.Name}**](<https://roblox.com/users/{Player.UserId}/profile>)\]: {Message}`
        ):Send()
    end)
end)
```