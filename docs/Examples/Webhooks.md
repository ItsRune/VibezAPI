---
sidebar-position: 10
---

### Colors
Typically you would use a hexidecimal color code for the color parameter, but you can also use a `Color3` value. **Only works for `addEmbedWithBuilder`**

<h4>Preview:</h4>
<img src="/VibezAPI/color3WebhookExample.png"></img>

```lua
local Vibez = require(14946453963)("API Key", {
    nameOfGameForLogging = "Colors Example"
})

local webhook = Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")
webhook:addEmbedWithBuilder(function(embed)
    return embed
        :setColor(Color3.fromRGB(255, 125, 255)) -- Light pink
        :setTitle("Color3 Example")
        :setDescription("This is an example of using a Color3 value for the color parameter.")
end):Send()
```

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