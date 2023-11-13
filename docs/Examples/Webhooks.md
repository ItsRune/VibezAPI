---
sidebar-position: 9
---

### Colors
Typically you would use a hexidecimal color code for the color parameter, but you can also use a `Color3` value. **Only works for `addEmbedWithBuilder`**

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

### Join Logger
Logs to discord everytime a player joins the game.

```lua
local Players = game:GetService("Players")

local Vibez = require(14946453963)("API Key", {
    nameOfGameForLogging = "Join Logger"
})

local function onPlayerAdded(Player: Player)
    local webhook = Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")

    webhook:addEmbedWithBuilder(function(embed)
        return embed
            :setTitle(Player.Name)
            :setDescription(`[{Player.Name}](https://www.roblox.com/users/{Player.UserId}/profile) has joined the game!`)
            :setColor("0x00ff00") -- Green
            :setTimestamp()
    end)

    webhook:Send()
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

### Leave Logger
Logs to discord everytime a player leaves the game.

```lua
local Players = game:GetService("Players")

local Vibez = require(14946453963)("API Key", {
    nameOfGameForLogging = "Join Logger"
})

local function onPlayerLeft(Player: Player)
    local webhook = Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")

    webhook:addEmbedWithBuilder(function(embed)
        return embed
            :setTitle(Player.Name)
            :setDescription(`[{Player.Name}](https://www.roblox.com/users/{Player.UserId}/profile) has left the game!`)
            :setColor("0xff0000") -- Red
            :setTimestamp()
    end)

    webhook:Send()
end

Players.PlayerRemoving:Connect(onPlayerLeft)
```

### Chat Logger
Logs to discord everytime a player chats in game.

```lua
local Players = game:GetService("Players")

local Connections = {}
local Vibez = require(14946453963)("API Key", {
    nameOfGameForLogging = "Chat Logger"
})

local function onPlayerChatted(Player: Player, Message: string)
    local webhook = Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")
    webhook:SetContent(string.format("[%s]: %s", Player.Name, Message)):Send()
end

local function onPlayerAdded(Player: Player)
    local theirConnections = {}

    table.insert(theirConnections, Player.Chatted:Connect(function(Message)
        onPlayerChatted(Player, Message) -- Bind the logger to the player's messages
    end))

    Connections[Player.UserId] = theirConnections
end

-- Disconnect the logger from the player's messages (cleans up memory)
local function onPlayerRemoved(Player: Player)
    local playerConnections = Connections[Player.UserId]

    for _, connection in ipairs(playerConnections) do
        connection:Disconnect()
    end

    Connections[Player.UserId] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoved)
```