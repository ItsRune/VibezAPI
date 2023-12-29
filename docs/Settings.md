---
sidebar_position: 2
---

<h3>Note: You do not need all settings to make it work, every setting attached has a default value!</h3>

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