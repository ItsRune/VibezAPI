---
sidebar_position: 2
---

<h3>Note: You do not need all settings to make it work, every setting attached has a default value!</h3>

Our first version of settings were... Well, clunky and messy to say the least. So, we've decided to make it a lot more simple and easier to understand. We've also added a lot more settings to make it more customizable to your needs. Every setting below or on the right are each their own table. You can look at the examples below to see how to use them. If you have any questions, feel free to join our Discord and ask in any of the general channels. We'll be happy to help you out!

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

## Example Usage

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

## Recommened Settings

<h3>Here's a simple table to help you understand the types:</h3>

|       Type        |               Example               |
|:-----------------:|:-----------------------------------:|
|      Boolean      |         `true` OR `false`           |
|      String       | `"Text"` OR `'Text'` OR `` `Text` ``  |
|      Number       | `-2,147,483,647` TO `2,147,483,647` |
|    Array | `{1, 2, 3}` OR `{"A", "B", "C"}` |
| Array <br/> Example | <ul><li>String&lt;whatYoureChanging&gt; → "Example"</li><li>Array&lt;String&lt;Something&gt;&gt; → `{"Something1", "Something2", "Something2"}`</li></ul> |

<details>
<summary>Commands</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables chat commands. | ✔ |
| useDefaultNames | Boolean | true | Determines whether default names should be included in the alias list. | ✔ |
| Prefix | String | ! | The prefix for chat commands. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use chat commands. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use chat commands. | ✔ |
| Alias | Array&lt;\{String&lt;commandName&gt;, String&lt;commandAlias&gt;\}&gt; | {} | The aliases for chat commands. | ✔ |

</details>

<details>
<summary>ActivityTracker</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables the activity tracker. | ✔ |
| MinRank | Number | 255 | The minimum rank required to track activity. | ✔ |
| disableInStudio | Boolean | true | Disables activity tracking in studio. | ✔ |
| disableWhenAFK | Boolean | false | Disables activity tracking when a player is AFK. | ✔ |
| delayBeforeAFK | Number | 30 | The amount of time in seconds before a player is marked 'AFK'. | ✔ |
| kickIfFails | Boolean | false | Kicks players if the activity tracker fails to initialize. | ✔ |
| failMessage | String | We were unable to initialize the activity tracker for you. Please rejoin the game. | The message sent when the activity tracker fails to initialize. | ✔ |

</details>

<details>
<summary>Interface</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables the interface. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use the interface. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use the interface. | ✔ |

</details>

<details>
<summary>RankSticks</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables rank sticks. | ✔ |
| MinRank | Number | 255 | The minimum rank required to use rank sticks. | ✔ |
| MaxRank | Number | 255 | The maximum rank required to use rank sticks. | ✔ |
| sticksModel | Model | Tool? | The model/tool to use as the rank sticks. (Optional) | ✔ |
| sticksAnimation | Number OR String | "17837716782\|17838391578" | The animation id to use when the stick is clicked. If you have a game that uses both R15 and R6, use a String with the pipe "\|" character to denote ("R15\|R6") versions (Optional) | ✔ |

</details>

<details>
<summary>Notifications</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables notifications. | ✔ |
| Font | String | Gotham | The font of the notifications. | ✔ |
| FontSize | Number | 16 | The size of the content with notifications (Use sizes for mobile). | ✔ |
| keyboardFontSizeMultiplier | Number | 1.25 | The multiplier for keyboard users. | ✔ |
| delayUntilRemoval | Number | 20 | The amount of seconds each notification is shown for. | ✔ |
| entranceTweenInfo | Array&lt;\{String&lt;Style&gt;, String&lt;Direction&gt;, Number&lt;timeItTakes&gt;\}&gt; | `{Style="Quint", Direction="InOut", timeItTakes=1}` | The information of the tween that plays when a new notification appears. | ✔ |
| exitTweenInfo | Array&lt;\{String&lt;Style&gt;, String&lt;Direction&gt;, Number&lt;timeItTakes&gt;\}&gt; | `{Style="Quint", Direction="InOut", timeItTakes=1}` | The information of the tween that plays when a notification needs to be deleted. | ✔ |

</details>

<details>
<summary>Blacklists</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| Enabled | Boolean | false | Enables/Disables whether blacklists will be kicked upon joining. | ✔ |
| userIsBlacklistedMessage | String | You have been blacklisted from the game for: &lt;BLACKLIST_REASON&gt; | The kick message presented to the user who's blacklisted. | ✔ |

</details>

<details>
<summary>Misc</summary>
<br />

| Setting Name | Type | Default Value | Description | Working? |
|:---------:|:---------:|:---------:|:---------:|:---------:|
| originLoggerText | String | Game | The text used in the origin logger. | ✔ |
| rankingCooldown | Number | 30 | Amount of seconds to wait between ranking the same person again. | ✔ |
| ignoreWarnings | Boolean | false | Ignores warnings. | ✔ |
| overrideGroupCheckForStudio | Boolean | false | Overrides the group check for studio. | ✔ |
| isAsync | Boolean | false | Toggles whether upon initialization should yield the current thread or not. | ✔ |
| createGlobalVariables | Boolean | false | Toggles whether upon initialization should the module create \_G variables to use. | ✔ |

</details>

## Extra Information

### Formatting Codes

| Code | Description | Example |
|:----------|:---------:|-----------:|
| (username) | The username of the player. | `(username) has just been ranked!` |
| (rank) | The player's group rank. | `Users with the rank (rank) were given 3 extra points!` |
| (rankname) | The players' group rank's name. | `A (rankname) has just joined the server!` |
| (groupid) | The id of the group. | `The group's ID is (groupid).` |
| (userid) | The user ID of the player. | `Your UserID is: (userid)` |
| (player) | The player object. | `game:GetService('ROBLOX')` |
| (replicatedstorage)| ReplicatedStorage | `game:GetService('ReplicatedStorage')` |
| (replicatedfirst) | ReplicatedFirst | `game:GetService('ReplicatedStorage')` |
| (serverstorage) | ServerStorage | `game:GetService('ServerStorage')` |
| (serverscriptservice) | ServerScriptService | `game:GetService('ServerScriptService')` |
| (workspace) | Workspace | `game:GetService('Workspace')` |
| (players) | Players | `game:GetService('Players')` |