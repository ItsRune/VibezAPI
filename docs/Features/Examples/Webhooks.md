---
sidebar_position: 2
---

If you haven't read up on how to use our [webhooks](/docs/APIs/Webhooks) yet, we'd recommend reading that first.

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

### Embeds
Embeds are a way to format your messages in a more organized way. You can add multiple embeds to a webhook message.

```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")
    :addEmbedWithBuilder(function(embed)
        return embed
            :setColor(Color3.new(1, 1, 1)) -- White | Default color is always light pink.
            :setTitle("Embed Example")
            :setDescription("This is an example of using an embed.")
    end)
    :Send()
```

#### Multiple Embeds

```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")
    :addEmbedWithBuilder(function(embed)
        return embed
            :setColor(Color3.new(1, 1, 1)) -- White | Default color is always light pink.
            :setTitle("Embed Example")
            :setDescription("This is an example of using an embed.")
    end)
    :addEmbedWithBuilder(function(embed)
        return embed
            :setColor(Color3.fromRGB(155, 155, 255)) -- Light blue
            :setTitle("Embed Example 2")
            :setDescription("This is the second example of using an embed.")
    end)
    :Send()
```

#### Embeds without the builder

```lua
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

Vibez:getWebhookBuilder("https://discord.com/api/webhooks/")
    -- Since we're not using the builder, we have to use hex values for the "color" property.
    :addEmbed({
        title = "Embed Example",
        description = "This is an example of using an embed.",
        color = Color3.fromRGB(1, 1, 1):ToHex(), -- White | Default color is always light pink.
    })
    :addEmbed({
        title = "Embed Example 2",
        description = "This is the second example of using an embed.",
        color = Color3.fromRGB(155, 155, 255):ToHex(), -- Light blue
    })
    :Send()
```