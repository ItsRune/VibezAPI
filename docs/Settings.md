---
sidebar_position: 2
---

<h3>Note: You do not need all settings to make it work, every setting attached has a default value!</h3>

Our first version of settings were... Well, clunky and messy to say the least. So, we've decided to make it a lot more simple and easier to understand. We've also added a lot more settings to make it more customizable to your needs. Every setting below or on the right are each their own table. You can look at the examples below to see how to use them. If you have any questions, feel free to join our Discord and ask in any of the general channels. We'll be happy to help you out!

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

## Example Usage

```lua
local Vibez = require(game:GetService("ServerScriptService").VibezAPI)("API KEY", {
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

|  Type   |               Example                |
| :-----: | :----------------------------------: |
| boolean |          `true` OR `false`           |
| string  | `"Text"` OR `'Text'` OR `` `Text` `` |
| number  | `-2,147,483,647` TO `2,147,483,647`  |

<details>
<summary>Commands</summary>

#### Enabled

Enables chat commands. <br/>
`boolean` <br/>
`false`

#### MinRank

Minimum group rank required. <br/>
`number` <br/>
`255`

#### MaxRank

Maximum group rank required. <br/>
`number` <br/>
`255`

#### Prefix

The prefix to use. <br/>
`string` <br/>
`!`

#### Alias

Creates alias commands for already defined commands. <br/>
`table` <br/>
Example:

```lua
{
    ["Promote"] = "up",
    ["Demote"] = {"de", "down"}
}
```

#### Removed

Removes commands from being used. <br/>
`table` <br/>
Example:

```lua
{
    "Promote"
}
```

</details>

<details>
<summary>ActivityTracker</summary>

#### Enabled

Toggles whether we track the activity of players within your game. <br/>
`boolean` <br/>
`false`

#### MinRank

The minimum rank a staff member needs to be tracked. <br/>
`number` <br/>
`255`

#### MaxRank

The maximum rank a staff member needs to be tracked. <br/>
`number` <br/>
`255`

#### disableWhenInStudio

Toggles whether we stop tracking when in studio play-test. <br/>
`boolean` <br/>
`true`

#### disableWhenAFK

Stops tracking activity when a player goes afk. <br/>
`boolean` <br/>
`false`

#### delayBeforeMarkedAFK

Marks a player as AFK after this delay (along with checks). <br/>
`number` <br/>
`30`

#### kickIfFails

If our activity tracker fails to load for a player, should we kick them? <br/>
`boolean` <br/>
`false`

#### failMessage

If 'kickIfFails' is true, what message would you like to display? <br/>
`string` <br/>
`We were unable to initialize the activity tracker for you. Please rejoin the game.`

</details>

<details>
<summary>Interface</summary>

#### Enabled

Toggles the interface. <br/>
`boolean` <br/>
`false`

#### MinRank

Minimum group rank required. <br/>
`number` <br/>
`255`

#### MaxRank

Maximum group rank required. <br/>
`number` <br/>
`255`

#### useBetaUI ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Toggles the usage of an interface that's currently in development. <br/>
`boolean` <br/>
`false`

#### nonViewableTabs ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Anything placed in this array will be immediately disabled from a player's view. <br/>
`table` <br/>
Example:

```lua
{
    "Ranking",
    "Logs"
}
```

#### maxUsersForSelection ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Maximum users that can be selected on the beta interface. <br/>
`number` <br/>
`5`

#### Suggestions ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Determines how we handle user suggestions and how they look. <br/>
`table` <br/>

```lua
{
    searchPlayersOutsideServer = false,
    outsideServerTagText = "External",
    outsideServerTagColor = Color3.fromRGB(255, 50, 50),
}
```

#### Activation ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Changes the behavior of how we handle activation of the new interface. <br/>
`table` <br/>

```lua
{
    Keybind = Enum.KeyCode.RightShift,
    iconButtonPosition = "Center",
    iconButtonImage = "rbxassetid://3610247188",
    iconToolTip = "Vibez UI",
}
```

#### Logs ![Beta](https://img.shields.io/badge/BETA-8A2BE2)

Determines how we handle a player attempting to interact with our server logs. <br/>
`table` <br/>

```lua
{
    Enabled = false,
    MinRank = 255,
}
```

</details>

<details>
<summary>RankSticks</summary>

#### Enabled

Toggles the rank sticks. <br/>
`boolean`
`false`

#### Mode

Determines the behavior the sticks should use. There's currently 2 modes; 'DetectionInFront' (Default) and 'ClickOnPlayer'. DetectionInFront checks for a player who's character is directly in front of you in order for it to work, unlike ClickOnPlayer where the player's character has to be clicked on by your mouse. <br/>
`string` <br/>
`DetectionInFront`

#### Removed

Removes specified rank stick types from being handed to the staff member. <br/>
`array<string>` <br/>

```lua
{}
```

#### MinRank

The minimum rank required to use rank sticks. <br/>
`number` <br/>
`255`

#### MaxRank

The maximum rank required to use rank sticks. <br/>
`number` <br/>
`255`

#### Model

The model/tool to use as the rank sticks. <br/>
[`(Model | Tool)?`](/) <br/>
`nil`

#### Animation

The animation id to use when the stick is activated. <br/>
`table` <br/>

```lua
{
    R6 = 17838471144,
    R15 = 17837716782,
}
```

</details>

<details>
<summary>Notifications</summary>

#### Enabled

Toggles whether notifications show for players. <br/>
`boolean` <br/>
`false`

#### [Font](https://create.roblox.com/docs/reference/engine/datatypes/Font)

The font of the notifications. <br/>
`string` <br/>
`Gotham`

#### FontSize

The font size of the notifications. <br/>
`number` <br/>
`16`

#### keyboardFontSizeMultiplier

Self-explanatory, it multiplies the font size for keyboard players. <br/>
`number` <br/>
`1.25`

#### delayUntilRemoval

How many seconds until the notification disappears. <br/>
`number` <br/>
`20`

#### entranceTweenInfo

Tweening info that determines how notifications will act when they appear on screen. <br/>
`table` <br/>

```lua
{
    Style = "Quint",
    Direction = "InOut",
    timeItTakes = 1,
}
```

#### exitTweenInfo

Tweening info that determines how notifications will act when they leave the screen. <br/>
`table` <br/>

```lua
{
    Style = "Quint",
    Direction = "InOut",
    timeItTakes = 1,
}
```

</details>

<details>
<summary>Blacklists</summary>

#### Enabled

Toggles the blacklisting module. <br/>
`boolean`
`false`

#### userIsBlacklistedMessage

The message presented to the user when they've been blacklisted. <br/>
`string`
`You have been blacklisted from the game by &lt;BLACKLISTED_BY&gt; for: &lt;BLACKLIST_REASON&gt;

</details>

<details>
<summary>Misc</summary>

#### originLoggerText

This text is used in an embed sent from your bot to a logs channel, specifically changes the 'Origin' portion of the embed. <br/>
`string` <br/>
`Game`

#### rankingCooldown

A number of seconds the staff would have to wait until chain ranking another player. <br/>
`number` <br/>
`30`

#### ignoreWarnings

Ignores warnings thrown from our module. <br/>
`boolean` <br/>
`false`

#### overrideGroupCheckForStudio

Overrides our permissions check when play testing in studio. <br/>
`boolean` <br/>
`false`

#### createGlobalVariables

Toggles whether we create easy access for our api (and your api key) to be used from other **Server** scripts. <br/>
`boolean` <br/>
`false`

</details>

<details>
<summary>Debug</summary>

#### logMessages

Prints a debug message about what the server script is doing. <br />
`boolean` <br/>
`false`

#### logClientMessages

Sends a debug message on the client's end about information of what it's doing. <br />
`boolean` <br/>
`false`

</details>

## Extra Information

### Formatting Codes

| Code                  |           Description           |                                                 Example |
| :-------------------- | :-----------------------------: | ------------------------------------------------------: |
| (username)            |   The username of the player.   |                      `(username) has just been ranked!` |
| (rank)                |    The player's group rank.     | `Users with the rank (rank) were given 3 extra points!` |
| (rankname)            | The players' group rank's name. |              `A (rankname) has just joined the server!` |
| (groupid)             |      The id of the group.       |                          `The group's ID is (groupid).` |
| (userid)              |   The user ID of the player.    |                              `Your UserID is: (userid)` |
| (player)              |       The player object.        |                             `game:GetService('ROBLOX')` |
| (replicatedstorage)   |        ReplicatedStorage        |                  `game:GetService('ReplicatedStorage')` |
| (replicatedfirst)     |         ReplicatedFirst         |                  `game:GetService('ReplicatedStorage')` |
| (serverstorage)       |          ServerStorage          |                      `game:GetService('ServerStorage')` |
| (serverscriptservice) |       ServerScriptService       |                `game:GetService('ServerScriptService')` |
| (workspace)           |            Workspace            |                          `game:GetService('Workspace')` |
| (players)             |             Players             |                            `game:GetService('Players')` |
