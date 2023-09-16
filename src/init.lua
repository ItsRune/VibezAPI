--[[
		 _   _ ___________ _____ ______
		| | | |_   _| ___ \  ___|___  /
		| | | | | | | |_/ / |__    / / 
		| | | | | | | ___ \  __|  / /  
		\ \_/ /_| |_| |_/ / |___./ /___
		 \___/ \___/\____/\____/\_____/

	Author: ltsRune
	Link: https://www.roblox.com/users/107392833/profile
	Discord: ltsrune // 352604785364697091
	Created: 9/11/2023 15:01 EST
	Updated: 9/15/2023 01:58 EST
	
	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
--

--// Documentation \\--
--[=[
	@interface extraOptionsType
	.isChatCommandsEnabled boolean
	.isUIEnabled boolean
	.commandPrefix string
	.minRank number
	.maxRank number
	.overrideGroupCheckForStudio boolean
	.loggingOriginName string
	.ignoreWarnings boolean
	@within VibezAPI
]=]

--[=[
	@interface groupIdResponse
	.success boolean
	.groupId number?
	@within VibezAPI
]=]

--[=[
	@interface errorResponse
	.success boolean
	.errorMessage string
	@within VibezAPI
]=]

--[=[
	@interface rankResponse
	.success boolean
	.message string
	.data { newRank: { id: number, name: string, rank: number, memberCount: number }, oldRank: { id: number, name: string, rank: number, groupInformation: { id: number, name: string, memberCount: number, hasVerifiedBadge: boolean } } }
	@within VibezAPI
]=]

--[=[
	@type responseBody groupIdResponse | errorResponse | rankResponse
	@within VibezAPI
]=]

--[=[
	@interface httpResponse
	.Body responseBody
	.Headers { [string]: any }
	.StatusCode number
	.StatusMessage string?
	.Success boolean
	.rawBody string
	@within VibezAPI
]=]

--// Services \\--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Constants \\--
local Types = require(script.Types)
local RateLimit = require(script.RateLimit)
local api = {}
local baseSettings = {
	commandPrefix = "!",
	isChatCommandsEnabled = false,
	minRank = 255,
	maxRank = 255,
	isUIEnabled = false,
	overrideGroupCheckForStudio = false,
	loggingOriginName = game.Name,
	ignoreWarnings = false,
}

--// Private Functions \\--
--[=[
	Uses `RequestAsync` to fetch required assets to make this API wrapper work properly. Automatically handles the API key and necessary headers associated with different routes.
	@param Route string
	@param Method string?
	@param Headers { [string]: any }?
	@param Body { any }?
	@param useNewApi boolean?
	@return boolean, httpResponse?

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:Http(
	Route: string,
	Method: string?,
	Headers: { [string]: any }?,
	Body: { any }?,
	useNewApi: boolean?
): (boolean, Types.httpResponse)
	local canContinue, err = self._private.rateLimiter:Check()
	if not canContinue then
		local message = `You're being rate limited! {err}`

		-- Create a fake error response
		return {
			Success = false,
			StatusCode = 429,
			StatusMessage = message,
			rawBody = "{}",
			Headers = {
				["Content-Type"] = "application/json",
				["x-api-key"] = self.Settings.apiKey,
			},
			Body = {
				success = false,
				errorMessage = message,
			},
		}
	end

	Route = (typeof(Route) == "string") and Route or "/"
	Method = (typeof(Method) == "string") and string.upper(Method) or "GET"
	Headers = (typeof(Headers) == "table") and Headers or { ["Content-Type"] = "application/json" }
	Body = (Method ~= "GET" and Method ~= "HEAD") and Body or nil

	if Body then
		Body["origin"] = self.Settings.loggingOriginName
	end

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route

	Headers["x-api-key"] = self.Settings.apiKey

	local apiToUse = (useNewApi == true) and self._private.newApiUrl or self._private.apiUrl
	local Options = {
		Url = apiToUse .. Route,
		Method = Method,
		Headers = Headers,
		Body = Body and HttpService:JSONEncode(Body) or nil,
	}

	local success, data = pcall(HttpService.RequestAsync, HttpService, Options)
	local successBody, decodedBody = pcall(HttpService.JSONDecode, HttpService, data.Body)

	if success and successBody then
		data.rawBody = data.Body
		data.Body = decodedBody
	end

	return (success or (data.StatusCode >= 200 and data.StatusCode < 300)), data
end

--[=[
	Fetches the group associated with the api key.
	@return number?

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:getGroupId()
	if self.GroupId ~= -1 then
		return self.GroupId
	end

	local isOk, res = self:Http("/ranking/groupid", "post", nil, nil, true)
	local Body: groupIdResponse = res.Body

	return isOk and Body.groupId or -1
end

--[=[
	Uses roblox's group service to get a player's rank.
	@param groupId number
	@param userId number
	@return number

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:getGroupFromUser(groupId: number, userId: number): { any }?
	if self.Settings.overrideGroupCheckForStudio and RunService:IsStudio() then
		return {
			Rank = self.Settings.maxRank,
		}
	end

	local isOk, playerGroups = pcall(GroupService.GetGroupsAsync, GroupService, userId)

	if not isOk then
		return nil
	end

	for _, groupData in pairs(playerGroups) do
		if groupData.Id == groupId then
			return groupData
		end
	end

	return nil
end

--[=[
	Handles players joining the game and checks for if commands/ui are enabled.
	@param Player Player

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:onPlayerAdded(Player: Player)
	-- This is only here in case they toggle commands in the middle of a game.
	if not self.Settings.isChatCommandsEnabled then
		return
	end

	if self._private.validStaff[Player.UserId] ~= nil then
		return
	end

	if self.Settings.isUIEnabled then
		local client = script.Client:Clone()

		client.Name = self._private.clientScriptName
		client.Enabled = true
		client.Parent = Player:WaitForChild("PlayerGui", math.huge)
	end

	self:_warn(`Settings up commands for user {Player.Name}.`)

	local theirGroupData = self:getGroupFromUser(self.GroupId, Player.UserId)
	if not theirGroupData or not self:isPlayerRankOkToProceed(theirGroupData.Rank) then
		return
	end

	self._private.validStaff[Player.UserId] = { Player, theirGroupData.Rank }

	-- We want to hold all connections from users in order to
	-- disconnect them later on, this will stop any memory
	-- leaks from occurring by vibez's api wrapper.

	self._private.Maid[Player.UserId] = {}
	table.insert(
		self._private.Maid[Player.UserId],
		Player.Chatted:Connect(function(message: string)
			return self:_onPlayerChatted(Player, message)
		end)
	)
end

--[=[
	Handles players leaving the game and disconnects any events.
	@param Player Player

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:onPlayerRemoved(Player: Player)
	-- Remove player from validated staff table.
	self._private.validStaff[Player.UserId] = nil

	-- Check for and delete any existing connections with the player.
	if self._private.Maid[Player.UserId] == nil then
		return
	end

	for _, connection: RBXScriptConnection in pairs(self._private.Maid[Player.UserId]) do
		connection:Disconnect()
	end

	self._private.Maid[Player.UserId] = nil
end

--[=[
	Compares a rank to the min/max ranks in settings for the commands/ui.
	@param playerRank number
	@return boolean

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:isPlayerRankOkToProceed(playerRank: number): boolean
	return (playerRank >= self.Settings.minRank and playerRank <= self.Settings.maxRank)
end

--[=[
	Gets a player's user identifier via their username.
	@param username string
	@return number?

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[=[
	Gets a player's username by their userId
	@param userId number
	@return string?

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:getNameById(userId: number): string?
	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	return isOk and userName or "Unknown"
end

--[=[
	Creates / Fetches a remote function in replicated storage for client communication.
	@return Remote RemoteFunction

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_createRemote()
	local currentRemote = ReplicatedStorage:FindFirstChild("__VibezEvent__")

	if not currentRemote then
		currentRemote = Instance.new("RemoteFunction")
		currentRemote.Name = "__VibezEvent__"
		currentRemote.Parent = ReplicatedStorage
	end

	return currentRemote
end

--[=[
	Gets the role id of a rank.
	@param rank number | string
	@return number?

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
function api:_getRoleIdFromRank(rank: number | string): number?
	-- Don't use normal HTTP function, it'll send the api key.
	local url = `https://groups.roproxy.com/v1/groups/{self.GroupId}/roles`
	local isOk, response = pcall(HttpService.GetAsync, HttpService, url)
	local decodedResponse = nil

	if not isOk then
		return nil
	end

	isOk, decodedResponse = pcall(HttpService.JSONDecode, HttpService, response)

	if not isOk then
		return nil
	end

	local toSearch = "rank"
	local canBeNumber = (tonumber(rank) ~= nil)

	if not canBeNumber then
		toSearch = "name"
	end

	for _, roleData in pairs(decodedResponse.roles) do
		if string.lower(tostring(roleData[toSearch])) == string.lower(tostring(rank)) then
			return roleData.id
		end
	end

	return nil
end

--[=[
	Gets the closest match to a player's username who's in game.
	@param usernames {string}
	@return {Player?}

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
function api:_getPlayers(usernames: { string }): { Player? }
	local found = {}

	for _, username in pairs(usernames) do
		for _, player in pairs(Players:GetPlayers()) do
			for _, operationData in pairs(self._private.commandOperationCodes) do
				local operationCode, operationFunction = operationData[1], operationData[2]

				if
					string.sub(string.lower(username), 0, string.len(tostring(operationCode)))
					~= string.lower(operationCode)
				then
					continue
				end

				local operationResult = operationFunction(
					player,
					string.sub(username, string.len(tostring(operationCode)) + 1, string.len(username))
				)

				if operationResult == true then
					table.insert(found, player)
				end
			end
		end
	end

	return found
end

--[=[
	Handles the main chatting event for commands.
	@param Player Player
	@param message string

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_onPlayerChatted(Player: Player, message: string)
	local theirCache = self._private.validStaff[Player.UserId]
	if not theirCache then
		return
	end

	local args = string.split(message, " ")
	local commandPrefix = self.Settings.commandPrefix

	if string.sub(args[1], 0, string.len(commandPrefix)) ~= commandPrefix then
		return
	end

	local command = string.sub(string.lower(args[1]), string.len(commandPrefix) + 1, #args[1])
	table.remove(args, 1)

	local users = self:_getPlayers(string.split(args[1], ","))
	for _, player in pairs(users) do
		if player == Player then
			continue
		end

		local playerRank = player:GetRankInGroup(self.GroupId)
		if playerRank >= theirCache[2] then -- Check if player running the command can use it.
			continue
		end

		local commandCallParameters = { player.UserId, { userId = Player.UserId, userName = Player.Name } }

		if command == "promote" then
			self:_Promote(table.unpack(commandCallParameters))
		elseif command == "demote" then
			self:_Demote(table.unpack(commandCallParameters))
		elseif command == "fire" then
			self:_Fire(table.unpack(commandCallParameters))
		end
	end
end

--[=[
	Checks for if HTTP is enabled
	@return boolean

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_checkHttp()
	local success = pcall(HttpService.GetAsync, HttpService, "https://google.com/")
	return success
end

--[=[
	Sets the rank of a player and uses "whoCalled" to send a message with origin logging name.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_setRank(
	userId: string | number,
	rankId: string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse
	local userName = self:getNameById(userId)
	local roleId = self:_getRoleIdFromRank(rankId)

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		} :: Types.errorResponse
	end

	local _, response = self:Http("/ranking/changerank", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
		rankId = tostring(roleId),
	}, true)

	return response.Body
end

--[=[
	Promotes a player and creates a fake "whoCalled" variable.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_Promote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		} :: Types.errorResponse
	end

	local _, response = self:Http("/ranking/promote", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[=[
	Demotes a player and uses "whoCalled", creates one if none is added.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_Demote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		} :: Types.errorResponse
	end

	local _, response = self:Http("/ranking/demote", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[=[
	Fires a player and creates a fake "whoCalled" variable if none is supplied.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_Fire(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		} :: Types.errorResponse
	end

	local _, response = self:Http("/ranking/fire", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[=[
	Destroys the class.

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_destroy()
	setmetatable(self, nil)
	self = nil
end

--[=[
	Displays a warning with the prefix of "[Vibez]"
	@param ... ...string

	@within VibezAPI
	@tag Internal
	@since 0.1.0
]=]
---
function api:_warn(...: string)
	if self.Settings.ignoreWarnings then
		return
	end

	warn("[Vibez]:", table.unpack({ ... }))
end

--// Public Functions \\--
--[=[
	Changes the rank of a player.
	@param userId string | number
	@param rankId string | number

	```lua
	local userId, rankId = 1, 200
	Vibez:SetRank(userId, rankId)
	```

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:SetRank(userId: string | number, rankId: string | number): Types.rankResponse
	return self:_setRank(userId, rankId)
end

--[=[
	Promotes a player.
	@param userId string | number

	```lua
	local userId = 1
	local response = Vibez:Promote(userId)
	```

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:Promote(userId: string | number): Types.rankResponse
	return self:_Promote(userId)
end

--[=[
	Demotes a player.
	@param userId string | number

	```lua
	local userId = 1
	local response = Vibez:Demote(userId)
	```

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:Demote(userId: string | number): Types.rankResponse
	return self:_Demote(userId)
end

--[=[
	Fires a player from the group.
	@param userId string | number

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:Fire(userId: string | number): Types.rankResponse
	return self:_Fire(userId)
end

--[=[
	Toggles the usage of commands within the experience.

	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:ToggleCommands(override: boolean?): nil
	if override ~= nil then
		self.Settings.isChatCommandsEnabled = override
	else
		self.Settings.isChatCommandsEnabled = not self.Settings.isChatCommandsEnabled
	end

	local status = self.Settings.isChatCommandsEnabled
	local functionToUse = (not status) and "onPlayerRemoved" or "onPlayerAdded"

	for _, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self[functionToUse])(self, player)
	end
end

--[=[
	Adds a command operation code.
	@param operationName string
	@param operationCode string
	@param operationFunction (playerToCheck: Player, incomingArgument: string) -> boolean
	@return VibezAPI

	:::caution
	This method will not work if there's already an existing operation name!
	:::

	```lua
	-- This command operation comes by default, no need to rewrite it.
	Vibez:addCommandOperation(
		"Team", -- Name of the operation.
		"%", -- Prefix before the operation argument.
		function(playerToCheck: Player, incomingArgument: string) -> boolean)
			return playerToCheck.Team ~= nil
				and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
					== string.lower(incomingArgument)
		end
	)
	```

	@within VibezAPI
	@tag Chainable
	@tag Public
	@since 0.1.0
]=]
function api:addCommandOperation(
	operationName: string,
	operationCode: string,
	operationFunction: (playerToCheck: Player, incomingArgument: string) -> boolean
): Types.vibezApi
	if self._private.commandOperationCodes[operationName] then
		self:_warn(`Command operation code '{operationCode}' already exists!`)
		return
	end

	for opName, opData in pairs(self._private.commandOperationCodes) do
		if operationCode == opData[1] then
			return self:_warn(`Operation code '{operationCode}' already exists for the operation '{opName}'!`)
		end
	end

	self._private.commandOperationCodes[operationName] = { operationCode, operationFunction }
	return self
end

--[=[
	Removes a command operation code.
	@param operationName string
	@return VibezAPI

	```lua
	Vibez:removeCommandOperation("Team")
	```

	@within VibezAPI
	@tag Chainable
	@tag Public
	@since 0.1.0
]=]
function api:removeCommandOperation(operationName: string): Types.vibezApi
	self._private.commandOperationCodes[operationName] = nil
	return self
end

--[=[
	Updates the logger's origin name.

	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:UpdateLoggerTitle(newTitle: string): nil
	self.Settings.loggingOriginName = tostring(newTitle)
end

--[=[
	Updates the api key.
	@param newApiKey string
	@return boolean

	@yields
	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:UpdateKey(newApiKey: string): boolean
	local savedKey = table.clone(self.Settings).apiKey

	self.Settings.apiKey = newApiKey
	local groupId = self:getGroupId()

	if groupId == -1 and savedKey ~= nil then
		self.Settings.apiKey = savedKey
		self:_warn(debug.traceback(`New api key "{newApiKey}" was invalid and was reverted to the previous one!`, 2))
		return false
	elseif groupId == -1 and not savedKey then
		self:_warn(
			debug.traceback(
				`Api key "{newApiKey}" was invalid! Please make sure there are no special characters or spaces in your key!`,
				2
			)
		)
		return false
	end

	self.GroupId = groupId
	return true
end

--[=[
	Destroys the VibezAPI class.

	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:Destroy()
	return self:_destroy()
end

--[=[
	Toggles the client promote/demote/fire UI.
	@param override boolean?

	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:ToggleUI(override: boolean?): nil
	if override ~= nil then
		self.Settings.isUIEnabled = override
	else
		self.Settings.isUIEnabled = not self.Settings.isUIEnabled
	end

	warn(self.Settings.isUIEnabled)

	for _, playerData in pairs(self._private.validStaff) do
		local player = playerData[1]

		if player.PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
			continue
		end

		coroutine.wrap(function()
			local client = script.Client:Clone()

			client.Name = self._private.clientScriptName
			client.Enabled = true
			client.Parent = player:WaitForChild("PlayerGui", math.huge)
		end)()
	end

	local status = self.Settings.isUIEnabled
	Workspace:SetAttribute(self._private.clientScriptName, status)
end

-- Gets the player's current activity (Route has been said to be buggy)
--[=[
	Gets the player's current activity.
	@param userId string | number
	@return httpResponse

	@yields
	@within VibezAPI
	@tag Public
	@unreleased
]=]
---
function api:getActivity(userId: string | number)
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:getUserIdByName(userId) or userId

	local _, response = self:Http("/activty/askJacobForTheRoute", "post", nil, {
		playerId = userId,
	}, true)

	return response
end

--[=[
	Saves the player's current activity
	@param userId string | number
	@param secondsSpent number
	@param messagesSent (number | { string })?
	@param joinTime number?
	@param leaveTime number?
	@return httpResponse

	@within VibezAPI
	@tag Public
	@since 0.1.0
]=]
---
function api:saveActivity(
	userId: string | number,
	secondsSpent: number,
	messagesSent: (number | { string })?,
	joinTime: number?,
	leaveTime: number?
): Types.httpResponse
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:getUserIdByName(userId) or userId
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent or (messagesSent == nil) and 0 or messagesSent
	joinTime = (typeof(joinTime) == "number") and joinTime or DateTime.now().UnixTimestamp
	leaveTime = (typeof(leaveTime) == "number") and leaveTime or DateTime.now().UnixTimestamp

	if not tonumber(messagesSent) then
		self:_warn(debug.traceback(`Cannot save activity with an invalid 'number' as the 'messagesSent'!`, 2))
		return
	end

	if not tonumber(secondsSpent) then
		self:_warn(debug.traceback(`'secondsSpent' parameter is required for this function!`, 2))
		return
	end

	if joinTime == leaveTime then
		joinTime -= secondsSpent
	end

	secondsSpent, messagesSent = tonumber(secondsSpent), tonumber(messagesSent)
	local _, response = self:Http("/activity/save", "post", nil, {
		playerId = userId,
		playtime = secondsSpent,
		messageCount = messagesSent,
		joinTime = joinTime,
		leaveTime = leaveTime,
	}, true)

	return response
end

--// Constructor \\--
--[=[
	@function new
	@within VibezAPI

	@param apiKey string -- Your Vibez API key.
	@param extraOptions extraOptionsType -- Extra settings to configure the api to work for you.
	@return VibezAPI

	Constructs the main Vibez API class.

	```lua
	local myKey = "YOUR_API_KEY_HERE"
	local VibezAPI = require(script.VibezAPI)
	local Vibez = VibezAPI(myKey)
	```
]=]
---
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi
	if RunService:IsClient() then
		return nil
	end

	--[=[
		@class VibezAPI
	]=]

	api.__index = api
	local self = setmetatable({}, api)

	if not self:_checkHttp() then
		self:_warn("Http is not enabled! Please enable it before trying to interact with our API!")

		-- Allow for GC to clean up the class.
		return self:Destroy()
	end

	-- @prop GroupId number
	self.GroupId = -1
	self.Settings = table.clone(baseSettings)
	self._private = {
		newApiUrl = "https://leina.vibez.dev",
		apiUrl = "https://api.vibez.dev/api",
		Maid = {},
		validStaff = {},
		clientScriptName = table.concat(string.split(HttpService:GenerateGUID(false), "-"), ""),
		rateLimiter = RateLimit.new(60, 60),
		commandOperationCodes = {
			["Team"] = {
				"%", -- Operation Code
				function(playerToCheck: Player, incomingArgument: string): boolean
					return playerToCheck.Team ~= nil
						and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
							== string.lower(incomingArgument)
				end,
			},

			["Rank"] = {
				"r:",
				function(playerToCheck: Player, incomingArgument: string): boolean
					local rank, tolerance = table.unpack(string.split(incomingArgument, ":"))

					if not tonumber(rank) then
						return false
					end

					tolerance = tolerance or "<="

					local isOk, currentPlayerRank = pcall(playerToCheck.GetRankInGroup, playerToCheck, tonumber(rank))
					if not isOk or currentPlayerRank == 0 then
						return false
					end

					if tolerance == "<=" then
						return currentPlayerRank <= tonumber(rank)
					elseif tolerance == ">=" then
						return currentPlayerRank >= tonumber(rank)
					elseif tolerance == "<" then
						return currentPlayerRank < tonumber(rank)
					elseif tolerance == ">" then
						return currentPlayerRank > tonumber(rank)
					elseif tolerance == "==" then
						return currentPlayerRank == tonumber(rank)
					end

					return false
				end,
			},

			["shortenedUsername"] = {
				"", -- Operation Code (Empty on purpose)
				function(playerToCheck: Player, incomingArgument: string): boolean
					return string.sub(string.lower(playerToCheck.Name), 0, string.len(incomingArgument))
						== string.lower(incomingArgument)
				end,
			},
		},
	}

	extraOptions = extraOptions or {}
	for key, value in pairs(extraOptions) do
		if self.Settings[key] == nil then
			self:_warn(`Optional key '{key}' is not a valid option.`)
			continue
		elseif typeof(self.Settings[key]) ~= typeof(value) then
			self:_warn(`Optional key '{key}' is not the same as it's defined value of {typeof(self.Settings[key])}!`)
			continue
		end

		self.Settings[key] = value
	end

	-- UI communication handler
	local communicationRemote = self:_createRemote() :: RemoteFunction
	communicationRemote.OnServerInvoke = function(Player: Player, Action: string, Target: Player)
		warn(Player, Action, Target)
		if Player == Target then
			return
		end

		if not self.Settings.isUIEnabled then
			return false
		end

		local userId = self:getUserIdByName(Target.Name)
		local theirGroupData = self:getGroupFromUser(self.GroupId, Player.UserId)

		if not theirGroupData or userId == -1 or not self:isPlayerRankOkToProceed(theirGroupData.Rank) then
			return false
		end

		-- Maybe actually log it somewhere... I have no clue where though.
		if Action ~= "promote" and Action ~= "demote" and Action ~= "fire" then
			Player:Kick(
				"Messing with vibez remote events, this has been logged and repeating offenders will be blacklisted from our services."
			)
			return false
		end

		local actionFunc
		if Action == "promote" then
			actionFunc = "_Promote"
		elseif Action == "demote" then
			actionFunc = "_Demote"
		elseif Action == "fire" then
			actionFunc = "_Fire"
		else
			return false
		end

		local result = self[actionFunc](userId, { userName = Player.Name, userId = Player.UserId })

		if not result["success"] then
			return false
		end

		return true
	end

	-- Chat command connections
	Players.PlayerAdded:Connect(function(Player)
		self:onPlayerAdded(Player)
	end)

	for _, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self.onPlayerAdded)(self, player)
	end

	-- Connect the player's maid cleanup function.
	Players.PlayerRemoving:Connect(function(Player)
		self:onPlayerRemoved(Player)
	end)

	-- Update the api key using the public function, in case of errors it'll log them.
	self:UpdateKey(apiKey)

	-- Initialize the workspace attribute
	local status = self.Settings.isUIEnabled
	Workspace:SetAttribute(self._private.clientScriptName, status)

	return self
end

return Constructor :: Types.vibezConstructor
