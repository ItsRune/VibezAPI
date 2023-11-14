---
sidebar-position: 11
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

### Loggers
[Loggers have been moved to their own page. You can find them here](/VibezAPI/docs/Loggers).