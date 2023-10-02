---
sidebar_position: 4
---

### What are webhooks?
Webhooks are a way to send messages to Discord channels without using a bot. They can be used to send messages to channels from external sources, such as a website or a game server. You can find more information about webhooks [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).

### How do I create a webhook?

<h4>You can get a webhook link by going to your Discord server settings.</h4>
<img src="/VibezAPI/firstStepWebhook.png"></img>


<h4>Navigate to the "Integrations" page.</h4>
<img src="/VibezAPI/secondStepWebhook.png"></img>

<h4>Click on "Webhooks" and "New Webhook", customize it however you'd like and copy the webhook link.</h4>
<img src="/VibezAPI/thirdStepWebhook.png"></img>

### How do I send a message to a webhook?
Using Vibez's webhook api is very simple. You just need to create a webhook builder using the webhook link you got from the previous step.

```lua
local VibezAPI = require(14946453963)("My API Key")
local myWebhook = VibezAPI:getWebhookBuilder("Discord Webhook Link")
```

After that you can send a test message!

```lua
myWebhook:setContent("Hello World!"):Send()
```

Please look at information about [chaining](/VibezAPI/docs/Chainable) to learn more about how chaining benefits you.

### How do I send an embed to a webhook?
There are 2 ways to create an embed. First, you could use the built in embed builder:

```lua
myWebhook:addEmbedWithBuilder(function(myEmbed)
    myEmbed:setTitle("my title")
    myEmbed:setDescription("my description")
end):Send()
```

Or, you could create an embed using a table:

```lua
myWebhook:addEmbed({
    title = "my title",
    description = "my description"
}):Send()
```

### Why isn't my message sending?
If your message isn't sending, it's possibly 2 issues.
1. You didn't call `:Send()` at the end of your message.
2. If you're using embeds, you didn't set the title/description of your embed.

### Limitations
There are some limitations to webhooks. For example, you can only send 10 embeds per message. You can find more information about these limitations [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks).