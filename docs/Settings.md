---
sidebar_position: 2
---

<h3>Note: You do not need all settings to make it work, every setting attached has a default value!</h3>

:::danger
[**Legacy Settings**](/docs/Settings#legacy-settings-to-be-removed) are planning on being removed next update, please update your settings to the new ones!
:::

Our first version of settings were... Well, clunky and messy to say the least. So, we've decided to make it a lot more simple and easier to understand. We've also added a lot more settings to make it more customizable to your needs. Every setting below or on the right are each their own table. You can look at the examples below to see how to use them. If you have any questions, feel free to join our Discord and ask in any of the general channels. We'll be happy to help you out!

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

<h2>Example</h2>

```lua
local Vibez = require(14946453963)("API KEY", {
    Commands = {
        Enabled = true,
        MinRank = 200,
        -- Max rank is optional due to it being automatically set to, 255.
        Prefix = ";",
    },

    Interface = {
        Enabled = true,
        MinRank = 200,
    },
})
```

<h2>Types</h2>

Here's a simple table to help you understand the types:

|       Type        |               Example               |
|:-----------------:|:-----------------------------------:|
|      Boolean      |         `true` OR `false`           |
|      String       | `"Text"` OR `'Text'` OR `\`Text`\`  |
|      Number       | `-2,147,483,647` TO `2,147,483,647` |
|    Array | `{1, 2, 3}` OR `{"A", "B", "C"}` |
| Array <br/> Example | <ul><li>String<whatYoureChanging\> -> "Example"</li><li>Array<String<Something\>\> -> `{"Something1", "Something2", "Something2"}`</li></ul> |

## Commands
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables chat commands. | ✔ |
| Prefix | String | ! | The prefix for chat commands. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use chat commands. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use chat commands. | ✔ |
| Alias | Array<{String<commandName\>, String<commandAlias\>}\> | {} | The aliases for chat commands. | ✔ |

## ActivityTracker
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables the activity tracker. | ✔ |
| MinRank | Number | 255 | The minimum rank required to track activity. | ✔ |
| disableInStudio | Boolean | true | Disables activity tracking in studio. | ✔ |
| disableWhenAFK | Boolean | false | Disables activity tracking when a player is AFK. | ✔ |
| delayBeforeAFK | Number | 30 | The amount of time in seconds before a player is marked 'AFK'. | ✔ |
| kickIfFails | Boolean | false | Kicks players if the activity tracker fails to initialize. | ✔ |
| failMessage | String | We were unable to initialize the activity tracker for you. Please rejoin the game. | The message sent when the activity tracker fails to initialize. | ✔ |

## Interface
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables the interface. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use the interface. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use the interface. | ✔ |

## RankSticks
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables rank sticks. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use rank sticks. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use rank sticks. | ✔ |
| sticksModel | Model? | Model | The model/tool to use as the rank sticks. | ✔ |

## Notifications
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables notifications. | ❌ |
| Position | String | Bottom-Right | The position of the notifications. | ❌ |

## Misc
| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| originLoggerText | String | Game | The text used in the origin logger. | ✔ |
| ignoreWarnings | Boolean | false | Ignores warnings. | ✔ |
| overrideGroupCheckForStudio | Boolean | false | Overrides the group check for studio. | ✔ |
| isAsync | Boolean | false | Toggles whether upon initialization should yield the current thread or not. | ✔ |
| usePromises | Boolean | false | Toggles whether to use promises or not. (Long term project) | ❌ |

## Legacy Settings (To Be Removed)
These are settings that were available in a previous version, and are now removed. They still work, but you'll receive a warning to switch to the new settings.

| Setting Name | Type | Default Value | Description | New Setting (Ignore, this is for spacing) |
|:---------:|:---------:|:---------:|:---------:|:---------|
| isChatCommandsEnabled | boolean | false | Determines whether in-game commands are enabled. | { <br/> &ensp;["Commands"] = { <br/> &emsp;["Enabled"] = false, <br/> &ensp;} <br/>} |
| commandPrefix | string | ! | The prefix for commands. | { <br/> &ensp;["Commands"] = { <br/> &emsp;["Prefix"] = "!", <br/> &ensp;} <br/> } |
| minRankToUseCommandsAndUI | number | 255 | The minimum rank required to use ranks and/or commands. | { <br/> &ensp;["Commands"] = { <br/> &emsp;["MinRank"] = 255, <br/> &ensp;} <br/> } |
| maxRankToUseCommandsAndUI | number | 255 | The maximum rank required to use ranks and/or commands. | { <br/> &ensp;["Commands"] = { <br/> &emsp;["MaxRank"] = 255, <br/> &ensp;} <br/> } |
| isUIEnabled | boolean | false | Determines whether client-sided user interface is enabled. | { <br/> &ensp;["Interface"] = { <br/> &emsp;["Enabled"] = false, <br/> &ensp;} <br/> } |
| activityTrackingEnabled | boolean | false | Determines whether activity tracking is enabled. | { <br/> &ensp;["ActivityTracker"] = { <br/> &emsp;["Enabled"] = false, <br/> &ensp;} <br/> } |
| disableActivityTrackingInStudio | boolean | true | Determines whether activity tracking should not send to our servers when play-testing in studio. | |
| disableActivityTrackingWhenAFK | boolean | true | Determines whether activity tracking should stop when a player is detected as AFK. | |
| rankToStartTrackingActivityFor | number | 255 | The minimum rank required to be tracked for activity. | |
| delayBeforeMarkedAFK | number | 30 | The amount of seconds to allow a player to come back until they're marked as AFK. | |
| nameOfGameForLogging | string | Game | When ranking logs occur, this name will be used for the "Origin" field. | |
| overrideGroupCheckForStudio | boolean | true | Determines whether to override fetching group ranks when in studio. | |
| ignoreWarnings | boolean | false | Determines whether to show warnings in the output. | |