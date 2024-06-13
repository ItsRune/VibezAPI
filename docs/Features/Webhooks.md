---
sidebar_position: 3
---

### What are webhooks?
Webhooks are a way to send messages to Discord channels without using a bot. They can be used to send messages to channels from external sources, such as a website or a game server. You can find more information about webhooks [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).

### How do I create a webhook?

<div>
    <h4>You can get a webhook link by going to your Discord server settings.</h4>
    <img src="/VibezAPI/firstStepWebhook.png"></img>

    <h4>Navigate to the "Integrations" page.</h4>
    <img src="/VibezAPI/secondStepWebhook.png"></img>

    <h4>Click on "Webhooks" and "New Webhook", customize it however you'd like and copy the webhook link.</h4>
    <img src="/VibezAPI/thirdStepWebhook.png"></img>
</div>

## Usage
### [getWebhookBuilder](/VibezAPI/api/VibezAPI#getWebhookBuilder)
Creates a new webhook builder.

Parameter(s): <br />
``webhookLink: string`` - The webhook link you got from Discord.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
local webhookLink = "https://discord.com/api/webhooks/"
local myWebhook = VibezAPI:getWebhookBuilder(webhookLink)
```

### [WebhookBuilder:setContent](/VibezAPI/api/Webhooks#setContent)
Sets the content of the message.

Parameter(s): <br />
``content: string`` - The content of the message.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:setContent("Hello World!")
```

### [WebhookBuilder:addEmbed](/VibezAPI/api/Webhooks#addEmbed)
Adds an embed to the message with raw embed data.

Parameter(s): <br />
``embed: table`` - The embed data.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:addEmbed({
    title = "My Title",
    description = "My Description"
})
```

### [WebhookBuilder:addEmbedWithBuilder](/VibezAPI/api/Webhooks#addEmbedWithBuilder)
Adds an embed to the message with a builder.

Parameter(s): <br />
``...(embedCreator: EmbedBuilder) -> EmbedBuilder`` - The embed builder.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:addEmbedWithBuilder(function(embed)
    return embed
        :setTitle("My Title")
        :setDescription("My Description")
end)
```

### [WebhookBuilder:Send](/VibezAPI/api/Webhooks#Send)
Sends the message.

Parameter(s): <br />
``None``
```lua
myWebhook:Send()
```

### [WebhookBuilder:setData](/VibezAPI/api/Webhooks#setData)
Sets the data of the message.

Parameter(s): <br />
``data: table`` - The data of the message.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:setData({
    content = "Hello World!",
    embeds = {
        {
            title = "My Title",
            description = "My Description"
        }
    }
})
```

### [WebhookBuilder:setUsername](/VibezAPI/api/Webhooks#setUsername)
Sets the username of the webhook.

Parameter(s): <br />
``username: string`` - The username of the webhook.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:setUsername("My Username")
```

### [WebhookBuilder:setTTS](/VibezAPI/api/Webhooks#setTTS) <img src="https://img.shields.io/badge/BROKEN-FF0000"></img>
Sets the TTS of the webhook.

Parameter(s): <br />
``tts: boolean`` - The TTS of the webhook.

Returns: [Webhooks](/VibezAPI/api/Webhooks)
```lua
myWebhook:setTTS(true)
```

## Example Usage
<details>
<summary>Join/Leave Logger</summary>
<br />

```lua
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local myWebhook = "Webhook_Link_Here"
local Vibez = require(14946453963)("API Key", { Misc = { isAsync = true } })

--// Functions \\--
local function sendWebhook(Player: Player, state: "joined" | "left")
    local webhook = Vibez:getWebhookBuilder(myWebhook)
    webhook:setContent(
        string.format(
            "**%s** has %s [the game.](https://roblox.com/games/%d/~)",
            Player.Name,
            state,
            game.PlaceId
        )
    ):Send()
end

local function onPlayerAdded(Player: Player)
    Vibez:waitUntilLoaded() -- Await it due to it being async.
    sendWebhook(Player, "joined")
end

local function onPlayerRemoving(Player: Player)
    Vibez:waitUntilLoaded() -- Await it due to it being async.
    sendWebhook(Player, "left")
end

--// Connections \\--
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
```

</details>

<details>
<summary>Sending an Embed using Color3</summary>
<br />

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

</details>