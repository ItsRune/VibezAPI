---
sidebar-position: 2
---

<h3>Note: You do not need all settings to make it work, every setting attached has a default!</h3>

Settings are a crucial part of Vibez. They allow you to customize the behavior of our wrapper within your games. You can enabled/disable features, change the prefix, and more. This page will go over all of the settings and what they do.

## How to change settings
Once requiring the module, you can change settings using the second parameter of the constructor... Most of you don't know a word I just said, but that's okay. Here's an example of how to enable chat commands:

```lua
local myApiKey = "YOUR_API_KEY_HERE"
--                                  Param1              Param2
local Vibez = require(14946453963)(myApiKey, { isChatCommandsEnabled = true, })
```

Simple, right? You can change any setting this way. Just make sure you keep within the bounds of the setting. For example, you can't set `prefix` to a number. It has to be a string. For you non-scripters, a string is a word or sentence wrapped in quotation marks.

## Types
Here's a simple table to help you understand the types:

|       Type        |             Expected               |
|:-----------------:|:----------------------------------:|
|      Boolean      |         `true` OR `false`          |
|      String       | `"Text"` OR `'Text'` OR \``Text`\` |
|      Number       |     `-2 billion` TO `2 billion`    |
|      Array        | `{1, 2, 3}` OR `{"a", "b", "c"}`   |

## isUIEnabled
Type: `Boolean`<br/>
Don't like how the client side UI functions? Want to remove it from your place? This setting allows for you to do just that. If you set this to false, the UI will not be loaded in your place. This means that you will not be able to use the UI to change settings.

## isChatCommandsEnabled
Type: `Boolean`<br/>
This setting allows you to enable/disable chat commands. If you set this to false, you will not be able to use chat commands. This is useful if you want to use the API for something other than chat commands.

## commandPrefix
Type: `String`<br/>
This setting allows you to change the prefix for chat commands. The default prefix is `!`. You can change it to anything you'd like, as long as it's a string.

## minRankToUseCommandsAndUI
Type: `Number`<br/>
Want to change the minimum rank required to use chat commands or the UI? This setting allows you to do just that. The default rank is `255`, which means only the group owner can use the UI or chat commands.

## maxRankToUseCommandsAndUI
Type: `Number`<br/>
This setting is just like `minRankToUseCommandsAndUI`, except it's the maximum rank. The default rank is `255`, which means only the group owner can use the UI or chat commands.

## overrideGroupCheckForStudio
Type: `Boolean`<br/>
This setting allows you to override the group check for studio. This means that you can use the UI and chat commands in studio, even if you're not in the group. This is useful for testing purposes.

## nameOfGameForLogging
Type: `String`<br/>
This setting is mainly for organizational purposes. It allows you to change the name of the game that shows up in your bot's discord logging channel. The default name is `Game`.

## ignoreWarnings
Type: `Boolean`<br/>
Oh no! Are you getting warnings from our module? Don't worry, we can fix that. This setting allows you to disable warnings. This is useful if you're getting warnings that you don't care about.

## activityTrackingEnabled
Type: `Boolean`<br/>
Did you know we have a built in activity tracker? No? Well, now you do! This setting allows you to enable/disable the activity tracker. Setting this to true will automatically track the activity of your game. This is useful if you want to see how many minutes your staff is in game for.

## rankToStartTrackingActivityFor
Type: `Number`<br/>
This setting allows you to change the minimum rank required to track activity. The default rank is `1`, which means anyone can be tracked. Setting this to `255` will only track the activity of the group owner.

## disableActivityTrackingWhenAFK
Type: `Boolean`<br/>
This setting allows you to disable activity tracking when a player is AFK. This is useful if you want to track the activity of your staff, but don't want to track the activity of your players.

## shouldKickPlayerIfActivityTrackerFails
Type: `Boolean`<br/>
This setting allows you to kick players if the activity tracker fails to initialize a player.

## activityTrackerFailedMessage
Type: `String`<br/>
This setting allows you to change the message that is sent when the activity tracker fails to initialize. The default message is `We were unable to initialize the activity tracker for you. Please rejoin the game.`.

## delayBeforeMarkedAFK
Type: `Number`<br/>
The amount of time in seconds before a player is marked 'AFK'. The default time is `30` seconds.

## disableActivityTrackingInStudio
Type: `Boolean`<br/>
Don't want to track activity in studio? This setting allows you to disable activity tracking in studio. The default value is `true`.

## isAsync
Type: `Boolean`<br/>
Determines whether initialization will yield your script or not. In non-fancy terms, this setting allows you to choose whether or not you want to wait for the module to initialize. The default value is `true`.

## isRankingSticksEnabled
Type: `Boolean`<br/>
This setting allows you to enable/disable ranking sticks. The default value is `false`. (WIP)

## rankingSticksPermissions
Type: `Array`<br/>
This setting allows you to change the permissions for ranking sticks. (WIP)

## usePromises
Type: `Boolean`<br/>
Changing this setting won't do anything. Not Implemented.