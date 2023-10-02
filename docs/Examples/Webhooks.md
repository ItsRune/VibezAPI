---
sidebar-position: 9
---

### Join Logger
```lua
local Players = game:GetService("Players")

local Vibez = require(14946453963)("API Key", {
    loggingOriginName = "Join Logger"
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
This is a continuation from above:

```lua
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
```lua
local Players = game:GetService("Players")

local Connections = {}
local Vibez = require(14946453963)("API Key", {
    loggingOriginName = "Chat Logger"
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