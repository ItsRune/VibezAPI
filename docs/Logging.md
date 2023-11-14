---
sidebar_position: 8
---

### How do I use the new logging system?
Well, first let's be straight here, it's built into the wrapper. So, that means... Oh you guessed it! It's in the settings! There are currently 3 types of loggers available at the moment:

| Log Name | Description | Parameters | Has Default |
| --- | --- | --- | --- |
| Player Joined | Logs when a player joins the game. | `Player` | Yes |
| Player Left | Logs when a player leaves the game. | `Player` | Yes |
| Player Message | Logs when a player chats in game. | `Player`, `Message` | Yes |

So now that you know the why and the how, let's get into the settings. There's 6 new settings for logging. They are as follows:
1. `joinLogWebhook` - The webhook url to send the join logs to.
    1. `joinLogFormat` - A function that returns the content and embed of the log. Special Parameter: `Player`.
2. `leaveLogWebhook` - The webhook url to send the leave logs to.
    1. `leaveLogFormat` - A function that returns the content and embed of the log. Special Parameter: `Player`.
3. `messageLogWebhook` - The webhook url to send the message logs to.
    1. `messageLogFormat` - A function that returns the content and embed of the log. Special Parameters: `Player`, `Message`.

### What do the default formats look like?

<h4>Join Logs</h4>
<img src="/VibezAPI/joinLogExample.png"></img>

<h4>Leave Logs</h4>
<img src="/VibezAPI/leaveLogExample.png"></img>

<h4>Message Logs</h4>
<img src="/VibezAPI/messageLogExample.png"></img>

### How do I change the default formats?
Well, it's pretty simple. You just need to change the settings. Here's an example of how to change the message log format:
```lua
local Vibez = require(14946453963)("API Key", {
    messageLogWebhook = "https://discord.com/api/webhooks/",

    messageLogFormat = function(Player, Message, embed)
        embed
            :setTitle(Player.Name)
            :setDescription(Message)
            :setColor(Color3.fromRGB(0, 255, 255))
        
        -- No content to return since we do it all in the embed.
        return "", embed
    end
})
```

### Why isn't it working in studio?
The wrapper will automatically stop logging if it detects that you're in studio. This is to prevent any issues with logging in studio. If you want to test logging in studio, you can change the `shouldLogInStudio` setting to `true`. This will allow you to test logging in studio.

### Why should I use this method of logging?
Well, there are a few reasons why you should use this method of logging.
1. To begin, this method is much easier and already built in.
2. There was a major flaw with allowing group owners/developers handle the logging. Whenever you tried to connect to the `Players.PlayerAdded` event, it wouldn't work. Why? Because the wrapper would be busy trying to validate your api key before it could connect to that event. Which result in bulky code as shown below.
3. All though this method has some draw backs which we are exploring in fixing, it's still a much better method than the previous one.

### What was the bulky code needed before this update?
The previous code in the examples looked something like this:
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
	end)

	webhook:Send()
end

Players.PlayerAdded:Connect(onPlayerAdded)
```
The newer code ended up being like this:
```lua
local Players = game:GetService("Players")
local Vibez

coroutine.wrap(function()
	Vibez = require(script.Parent.MainModule)("API Key", {
		nameOfGameForLogging = "Join Logger"
	})
end)()

local function onPlayerAdded(Player: Player)
	if not Vibez then
		repeat task.wait(1) -- BREAK POINT
		until Vibez ~= nil
	end
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
If there was an issue with your key not loading, the loop defined at `BREAK POINT` would infinitely run and never stop. This would cause your game to keep a thread open for no reason. This is why we decided to move the logging to the wrapper itself.