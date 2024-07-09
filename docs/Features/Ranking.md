---
sidebar_position: 1
---

Let's be honest, there's nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually.

## Usage
**IF** you're confused with the type definitons, this is for you:
You may notice that some parameters are separated by a `|` this is noting that you can use either of these types to fill the parameter. <br />
Examples:

<b>userId: number | string | Player</b>

- `1`
- `"ROBLOX"`
- `game.Players.ROBLOX`

<b>rank: number | string</b>

- `1`
- `"Worker"`
- `roleId`

[**whoCalled: (See Below)**](/VibezAPI/docs/Features/Ranking#whats-this-whocalled-parameter)

### [Promote](/VibezAPI/api/VibezAPI#Promote)
Increments a player's rank by 1.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/VibezAPI/api/VibezAPI#rankResponse)
```lua
local userId = 1
VibezApi:Promote(userId)
```

### [Demote](/VibezAPI/api/VibezAPI#Demote)
Decrements a player's rank by 1.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/VibezAPI/api/VibezAPI#rankResponse)
```lua
local userId = 1
VibezApi:Demote(userId)
```

### [Fire](/VibezAPI/api/VibezAPI#Fire)
Sets a player's rank to the lowest rank.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/VibezAPI/api/VibezAPI#rankResponse)
```lua
local userId = 1
local newRankId = 5
VibezApi:Fire(userId, newRankId)
```

### [setRank](/VibezAPI/api/VibezAPI#setRank)
Sets a player's rank to a specific rank.

`userId: number | string | Player` <br />
`rank: number | string` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/VibezAPI/api/VibezAPI#rankResponse)
```lua
local userId = 1
VibezApi:setRank(1, 2)
```

## What's this `whoCalled` parameter?
Under the hood of the API, we use the `whoCalled` parameter to generate logs within a Discord channel of the action, who did it, and who was affected. **THIS PARAMETER IS OPTIONAL**. This is useful for auditing purposes, and to see who's abusing the API. If you supply nothing, the wrapper will automatically supply **SYSTEM** for the username, and the log generated will look different than with a proper user. If you supply a user's ID and name, the log will look like this:

<img src="/VibezAPI/rankingExampleWithUser.png"></img>

If you supply nothing, the log will look like this:

<img src="/VibezAPI/rankingExampleAutomatic.png"></img>

### How would I use this?
When issuing a function with the wrapper that has this included, just create a new parameter with the `userName` and `userId` keys, and supply the values. Here's an example:

```lua
VibezApi:Promote(1, { userName = "ltsRune", userId = 107392833 })
```

## Why isn't it working?
There's many reasons why the ranking API may fail, maybe your discord bot is offline, or maybe the worker is already ranked to the rank you're trying to rank them to. If you're having issues with the ranking API, please join our discord below and ask for help in the support channel.

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

## Examples

<details>
<summary>AutoRank Points</summary>
<br />

There's a chance this script may not work, as it's not tested. If you have any issues, please join our discord and ask for help in the support channel.

```lua title="ServerScriptService/autoRankPoints.server.lua"
--// Configuration \\--
local groupId = 0, -- Your Group's Id
local apiKey = "API_KEY" -- Vibez's API Key
local pointRanks = {
    { Rank = 0, pointsRequired = 0 }
}

--// Services \\--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--// Variables \\--
local vibezApi = require(14946453963)(apiKey, { Misc = { isAsync = true } })
local dataStoreToUse = DataStoreService:GetDataStore("pointRanks_" .. game.PlaceId)
local userCache = {}

--// Functions \\--
local function onPlayerAdded(Player: Player)
    -- Wherever you're keeping your player's points, this is what you'd want to change it to.
    local pointStats = Player:WaitForChild("leaderstats", 120):WaitForChild("Points", 120)

    -- Don't touch below unless you know what you're doing.
    local isOk, data, connections, formattedString
    isOk, data = pcall(dataStoreToUse.GetAsync, dataStoreToUse, tostring(Player.UserId))

    if not isOk then
        return
    end

    data = data or {}
    connections = {}

    vibezApi = vibezApi:waitUntilLoaded()

    table.sort(pointRanks, function(a, b)
        return a.pointsRequired < b.pointsRequired
    end)

    table.insert(connections, pointStats:GetPropertyChangedSignal("Value"):Connect(function()
        local userGroupData = vibezApi:_getGroupFromUser(Player.UserId, groupId)
        if not userGroupData or userGroupData.Rank == 0 then
            return
        end

        for i = 1, #pointRanks do
            local data = pointRanks[i]
            local nextData = pointRanks[i + 1]

            if nextData == nil and (userGroupData.Rank >= data.Rank or pointStats.Value < data.pointsRequired) then
                return
            end

            if userGroupData.Rank < data.Rank and pointStats.Value >= data.pointsRequired and pointStats.Value < nextData.pointsRequired then
                vibezApi:setRank(Player, data.Rank)
                break
            end
        end
    end))

    userCache[Player.UserId] = {connections, data}
end

local function onPlayerLeft(Player: Player, retry: number?)
    local exists = userCache[Player.UserId]
    if not exists then
        return
    end

    local isOk = pcall(dataStoreToUse.SetAsync, dataStoreToUse, tostring(Player.UserId), exists[2])
    if not isOk then
        retry = retry or 0
        if retry > 3 then
            error("Failed to save data for user " .. Player.Name)
            return
        end

        task.wait(3)
        return onPlayerLeft(Player, retry + 1)
    end

    for _, connection: RBXScriptConnection in pairs(exists[1]) do
        connection:Disconnect()
    end

    userCache[Player.UserId] = nil
end

--// Events \\--
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerLeft)
```

</details>