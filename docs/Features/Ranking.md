---
sidebar_position: 1
---

Let's be honest, there's nothing worse than a potential future worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank.
This is why we have the ranking API. It allows you to rank workers in game without having to do it manually.

**NOTE**: Our ranking api can be used separately from this module, we recommend this if you're building a custom ranking system / application center / rank center.
You can find the module [here](https://create.roblox.com/store/asset/117806589757660/Ranking).

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

[**whoCalled: (See Below)**](/Vibez/docs/Features/Ranking#whats-this-whocalled-parameter)

### [Promote](/Vibez/api/Vibez#Promote)

Increments a player's rank by 1.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/Vibez/api/Vibez#rankResponse)

```lua
local userName = "ROBLOX"
Vibez:Promote(userId)
```

### [Demote](/Vibez/api/Vibez#Demote)

Decrements a player's rank by 1.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/Vibez/api/Vibez#rankResponse)

```lua
local userName = "ROBLOX"
Vibez:Demote(userId)
```

### [Fire](/Vibez/api/Vibez#Fire)

Sets a player's rank to the lowest rank.

`userId: number | string | Player` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/Vibez/api/Vibez#rankResponse)

```lua
local userName = "ROBLOX"
Vibez:Fire(userId)
```

### [setRank](/Vibez/api/Vibez#setRank)

Sets a player's rank to a specific rank.

`userId: number | string | Player` <br />
`rank: number | string` <br />
`whoCalled: { userName: string, userId: number }?`

Returns: [rankResponse](/Vibez/api/Vibez#rankResponse)

```lua
local userName = "ROBLOX"
local newRank = 2
Vibez:setRank(1, newRank)
```

## What's this `whoCalled` parameter?

Under the hood of the API, we use the `whoCalled` parameter to generate logs within a Discord channel of the action, who did it, and who was affected. **THIS PARAMETER IS OPTIONAL**. This is useful for auditing purposes, and to see who's abusing the API. If you supply nothing, the wrapper will automatically supply **SYSTEM** for the username, and the log generated will look different than with a proper user. If you supply a user's ID and name, the log will look like this:

<img src="/Vibez/rankingExampleWithUser.png"></img>

If you supply nothing, the log will look like this:

<img src="/Vibez/rankingExampleAutomatic.png"></img>

### How would I use this?

When issuing a function with the wrapper that has this included, just create a new parameter with the `userName` and `userId` keys, and supply the values. Here's an example:

```lua
Vibez:Promote(1, { userName = "ltsRune", userId = 107392833 })
```

## Why isn't it working?

There's many reasons why the ranking API may fail, maybe your discord bot is offline, or maybe the worker is already ranked to the rank you're trying to rank them to. If you're having issues with the ranking API, please join our discord below and ask for help in the support channel.

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>

## Examples

<details>
<summary>AutoRank Points</summary>
<br />

```lua title="ServerScriptService/autoRankPoints.server.lua"
--// Configuration \\--
local apiKey = "API KEY" -- Vibez's API Key
local pointRanks = {
	{ Rank = 2, pointsRequired = 10 }
}

-- IMPORTANT: Scroll down to line 23 to change the location
-- of a player's points!

--// Services \\--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--// Variables \\--
local Vibez = require(14946453963)(apiKey)
local dataStoreToUse = DataStoreService:GetDataStore("pointRanks_" .. game.PlaceId)
local userCache = {}

--// Functions \\--
local function onPlayerAdded(Player: Player)
	-- Wherever you're keeping your player's points, this is where you'd want to change it.
	local pointStats = Player:WaitForChild("leaderstats", 120):WaitForChild("Points", 120)

	-- Don't touch below unless you know what you're doing.
	local isOk, data, connections, formattedString
	isOk, data = pcall(dataStoreToUse.GetAsync, dataStoreToUse, tostring(Player.UserId))

	if not isOk then
		return
	end

	data = data or {}
	connections = {}

	table.sort(pointRanks, function(a, b)
		return a.pointsRequired < b.pointsRequired
	end)

	table.insert(connections, pointStats:GetPropertyChangedSignal("Value"):Connect(function()
		local userGroupData = Vibez:_getGroupFromUser(Vibez.GroupId, Player.UserId)
		local copiedData = userCache[Player.UserId][2] or {}

		if not userGroupData or userGroupData.Rank == 0 then
			return
		end

		for i = 1, #pointRanks do
			local data = pointRanks[i]

			if
                table.find(copiedData, data.Rank) ~= nil
                or userGroupData.Rank >= data.Rank
                or pointStats.Value < data.pointsRequired
            then
				continue
			end

			if
				userGroupData.Rank < data.Rank
				and pointStats.Value >= data.pointsRequired
			then
				local response = Vibez:setRank(Player, data.Rank)

				if response.success then
					table.insert(copiedData, data.Rank)
				end
				break
			end
		end

		userCache[Player.UserId][2] = copiedData
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
for _, v in ipairs(Players:GetPlayers()) do
	coroutine.wrap(onPlayerAdded)(v)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerLeft)
```

</details>
