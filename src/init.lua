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
	Updated: 10/31/2023 03:08 EST
	Version: 1.0.23
	
	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
--

--// Documentation \\--
--[=[
	@interface extraOptionsType
	.isChatCommandsEnabled boolean -- Automatically load commands for users.
	.isUIEnabled boolean -- Allow for player's to click on another for ranking options.
	.commandPrefix string -- Change the prefix of commands.
	.minRankToUseCommandsAndUI number -- Minimum rank to use commands. (Default: 255)
	.maxRankToUseCommandsAndUI number -- Maximum rank to use commands. (Default: 255)
	.overrideGroupCheckForStudio boolean -- When in studio, it'll force any rank checks to be the 'maxRankForCommands' value.
	.loggingOriginName string -- Name of logger's 'Origin' embed field.
	.ignoreWarnings boolean -- Ignores any VibezAPI warnings (Excluding Webhooks & Activity Tracking)
	.activityTrackingEnabled boolean -- Track a user's activity if their rank is higher than 'rankToStartTrackingActivityFor'.
	.rankToStartTrackingActivityFor boolean -- Minimum rank required to start tracking activity. (Default: 255)
	.trackAFKActivity boolean -- Subtracts time of users who are detected as 'AFK'.
	.delayBeforeMarkedAFK number -- The amount of time in seconds before a player is marked 'AFK'. (Default: 30)
	.disableActivityTrackingInStudio boolean -- Stops saving any activity tracked when play testing in studio.
	.usePromises boolean -- Determines whether the module should return promises or not.
	@within VibezAPI
]=]

--[=[
	@interface groupIdResponse
	.success boolean
	.groupId number?
	@within VibezAPI
	@private
]=]

--[=[
	@interface errorResponse
	.success boolean
	.errorMessage string
	@within VibezAPI
	@private
]=]

--[=[
	@interface rankResponse
	.success boolean
	.message string
	.data { newRank: { id: number, name: string, rank: number, memberCount: number }, oldRank: { id: number, name: string, rank: number, groupInformation: { id: number, name: string, memberCount: number, hasVerifiedBadge: boolean } } }
	@within VibezAPI
	@private
]=]

--[=[
	@interface vibezCommandFunctions
	.getGroupRankFromName (self: VibezAPI, groupRoleName: string) -> number?
	.getGroupFromUser (self: VibezAPI, groupId: number, userId: number) -> { any }?
	.Http (self: VibezAPI, Route: string, Method: string?, Headers: { [string]: any }, Body: { any }) -> httpResponse
	@within VibezAPI
	@private
]=]

--[=[
	@interface infoResponse
	.success boolean
	.message string
	@within VibezAPI
	@private
]=]

--[=[
	@interface activityResponse
	.secondsUserHasSpent number
	.messagesUserHasSent number
	.detailsLogs [ {timestampLeftAt: number, secondsUserHasSpent: number, messagesUserHasSent: number}? ]
	@within VibezAPI
	@private
]=]

--[=[
	@type responseBody groupIdResponse | errorResponse | rankResponse
	@within VibezAPI
	@private
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
	@private
]=]

--// Before Execution \\--
local ServerScriptService = game:GetService("ServerScriptService")
local scriptExistsInService = ServerScriptService:FindFirstChild(script.Name)

if scriptExistsInService ~= nil and script.Parent ~= ServerScriptService then
	script:Destroy()
	return require(ServerScriptService[script.Name])
else
	script.Parent = ServerScriptService
end

--// Services \\--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Constants \\--
local scriptNameIncrement = 0
local api = {}
local baseSettings = {
	commandPrefix = "!",
	isChatCommandsEnabled = false,
	minRankToUseCommandsAndUI = 255,
	maxRankToUseCommandsAndUI = 255,
	isUIEnabled = false,
	overrideGroupCheckForStudio = false,
	disableActivityTrackingInStudio = true,
	loggingOriginName = game.Name,
	ignoreWarnings = false,
	activityTrackingEnabled = false,
	trackAFKActivity = false,
	rankToStartTrackingActivityFor = 255,
	delayBeforeMarkedAFK = 30,
	usePromises = false,
}

--// Modules \\--
local Types = require(script.Modules.Types)
local Hooks = require(script.Modules.Hooks)
local ActivityTracker = require(script.Modules.Activity)
local RateLimit = require(script.Modules.RateLimit)
local Promise = require(script.Modules.Promise)
local Table = require(script.Modules.Table)

--// Private Functions \\--
--[=[
	Uses `Promise.lua` to attempt to promisify a method. (Only applies when `usePromises` is set to true).
	@param functionToBind (...any) -> ...any
	@param ... any
	@return Promise | any

	@yields
	@tag Unavailable
	@private
	@within VibezAPI
	@since 1.0.12
]=]
---
function api:_promisify(functionToBind: (...any) -> ...any, ...: any): any
	if self.Settings.usePromises then
		return Promise.promisify(functionToBind)(...)
	end

	return functionToBind(...)
end

--[=[
	Uses `RequestAsync` to fetch required assets to make this API wrapper work properly. Automatically handles the API key and necessary headers associated with different routes.
	@param Route string
	@param Method string?
	@param Headers { [string]: any }?
	@param Body { any }?
	@param useOldApi boolean?
	@return boolean, httpResponse?

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:Http(
	Route: string,
	Method: string?,
	Headers: { [string]: any }?,
	Body: { any }?,
	useOldApi: boolean?
): (boolean, Types.httpResponse)
	local canContinue, err = self._private.rateLimiter:Check()
	if not canContinue then
		local message = "You're being rate limited! " .. err

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

	local apiToUse = (useOldApi == true) and self._private.oldApiUrl or self._private.newApiUrl

	-- Prevents sending api key to external URLs
	-- Remove from 'Route' extra slash that was added
	-- Make 'apiToUse' an empty string since "Route" and "apiToUse" get concatenated on request.
	if string.match(Route, "https://") ~= nil then
		Route = string.sub(Route, 2, #Route)
		apiToUse = ""
		Headers["x-api-key"] = nil
	end

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
	@since 1.0.0
]=]
---
function api:getGroupId()
	if self.GroupId ~= -1 then
		return self.GroupId
	end

	local isOk, res = self:Http("/ranking/groupid", "post", nil, nil)
	local Body: groupIdResponse = res.Body

	return isOk and Body.groupId or -1
end

--[=[
	Fetches the group's role name's rank value.
	@param groupRoleName string
	@return number?

	Allows for partial naming, example:
	```lua
	-- Using Frivo's group ID
	local rankNumber = VibezAPI:_getGroupRankFromName("facili") --> Expected: 250 (Facility Developer)
	```

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_getGroupRankFromName(groupRoleName: string): number?
	if not groupRoleName or typeof(groupRoleName) ~= "string" then
		return nil
	end

	local isOk, groupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, self.GroupId)

	if not isOk then
		return nil
	end

	for _, data in pairs(groupInfo.Roles) do
		if string.sub(string.lower(data.Name), 0, #groupRoleName) == string.lower(groupRoleName) then
			return data.Rank
		end
	end

	return nil
end

--[=[
	Uses roblox's group service to get a player's rank.
	@param groupId number
	@param userId number
	@return { any }

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_getGroupFromUser(groupId: number, userId: number, force: boolean?): any?
	if self._private.requestCaches.groupInfo[userId] ~= nil and not force then
		return self._private.requestCaches.groupInfo[userId]
	end

	if self.Settings.overrideGroupCheckForStudio == true and RunService:IsStudio() then
		return {
			Rank = self.Settings.maxRankToUseCommandsAndUI,
		}
	end

	local isOk, data = pcall(GroupService.GetGroupsAsync, GroupService, userId)
	local found = nil

	if not isOk then
		return "Error: " .. data
	end

	for _, groupData in pairs(data) do
		if groupData.Id == groupId then
			found = groupData
			break
		end
	end

	if typeof(found) == "table" then
		self._private.requestCaches.groupInfo[userId] = found
		return found
	else
		return "Not found."
	end
end

--[=[
	Handles players joining the game and checks for if commands/ui are enabled.
	@param Player Player

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_onPlayerAdded(Player: Player)
	-- This is only here in case they toggle commands in the middle of a game.
	if not self.Settings.isChatCommandsEnabled then
		return
	end

	if self._private.requestCaches.validStaff[Player.UserId] ~= nil then
		return
	end

	-- Clone client script and parent to player
	local client = script.Client:Clone()
	client.Name = self._private.clientScriptName .. "-" .. scriptNameIncrement
	client.Enabled = true
	client.Parent = Player:WaitForChild("PlayerGui", math.huge)

	self:_warn(`Setting up commands for user {Player.Name}.`)
	local theirGroupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
	if typeof(theirGroupData) ~= "table" then
		self:_warn(`Error occurred: {theirGroupData}`)
		return
	end

	self._private.requestCaches.validStaff[Player.UserId] = { Player, theirGroupData.Rank }

	if
		self.Settings.activityTrackingEnabled == true
		and theirGroupData.Rank >= self.Settings.rankToStartTrackingActivityFor
	then
		local tracker = ActivityTracker.new(self, Player)
		table.insert(self._private.requestCaches.validStaff[Player.UserId], tracker)
	end

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

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_onPlayerRemoved(Player: Player) -- This method is being handled twice when game is shutting down.
	-- Check for and submit activity data.
	local existingTracker = ActivityTracker.Users[Player.UserId]
	if existingTracker then
		existingTracker:Left()
	end

	-- Clear from activity tracking.
	ActivityTracker.Users[Player.UserId] = nil

	-- Clear from cached group information.
	self._private.requestCaches.groupInfo[Player.UserId] = nil

	-- Remove player from other cached tables.
	for cacheName, _ in pairs(self._private.requestCaches) do
		self._private.requestCaches[cacheName][Player.UserId] = nil
	end

	-- Check for and delete any existing connections with the player.
	if self._private.Maid[Player.UserId] == nil then
		return
	end

	-- Disconnect connections connected to specific user.
	for _, connection: RBXScriptConnection in pairs(self._private.Maid[Player.UserId]) do
		connection:Disconnect()
	end

	-- Clear them from the maid.
	self._private.Maid[Player.UserId] = nil
end

--[=[
	Fires when the game's server is shutting down.

	@private
	@within VibezAPI
	@since 1.1.0
]=]
---
function api:_onGameShutdown() -- Broken atm
	return
	-- if #Players:GetPlayers() == 0 then
	-- 	return
	-- end

	-- for _, Player: Player in pairs(Players:GetPlayers()) do
	-- 	coroutine.wrap(self._onPlayerRemoved)(self, Player)
	-- end
end

--[=[
	Compares a rank to the min/max ranks in settings for the commands/ui.
	@param toCheck number
	@param minCheck number
	@param maxCheck number
	@return boolean

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_isPlayerRankOkToProceed(toCheck: number, minCheck: number, maxCheck: number): boolean
	return (toCheck >= minCheck and toCheck <= maxCheck)
end

--[=[
	Gets a player's user identifier via their username.
	@param username string
	@return number?

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[=[
	Gets a player's username by their userId
	@param userId number
	@return string?

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_getNameById(userId: number): string?
	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	return isOk and userName or "Unknown"
end

--[=[
	Creates / Fetches a remote function in replicated storage for client communication.
	@param alreadyAttemptedLoopCheck boolean?
	@return Remote RemoteFunction

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_createRemote(alreadyAttemptedLoopCheck: boolean?)
	-- SHA1 Hash translation: VIBEZ-DEV
	local remoteName = "4bc06805148f173646ac84bff8a02dda70cbe6da-2fada46fb6f0950336a4765018e59d30b4ac5255-"
		.. scriptNameIncrement
	local currentRemote = ReplicatedStorage:FindFirstChild(remoteName)

	local function createNewRemote()
		scriptNameIncrement += 1

		currentRemote = Instance.new("RemoteFunction")
		currentRemote.Name = remoteName
		currentRemote.Parent = ReplicatedStorage
	end

	if currentRemote ~= nil and not currentRemote:IsA("RemoteFunction") then
		if not alreadyAttemptedLoopCheck then
			local found = nil

			-- In case people wanna name their Instances the same name
			for _, inst in pairs(ReplicatedStorage:GetChildren()) do
				if inst:IsA("RemoteFunction") and inst.Name == remoteName then
					found = inst
					break
				end
			end

			if not found then
				createNewRemote()
			end
		elseif alreadyAttemptedLoopCheck then
			createNewRemote()
		end
	elseif currentRemote == nil then
		createNewRemote()
	end

	return currentRemote
end

--[=[
	Gets the role id of a rank.
	@param rank number | string
	@return number?

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
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
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
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
					string.sub(username, string.len(tostring(operationCode)) + 1, string.len(username)),
					{
						getGroupRankFromName = self._getGroupRankFromName,
						getGroupFromUser = self._getGroupFromUser,
						Http = self.Http,
					}
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
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_onPlayerChatted(Player: Player, message: string)
	local theirCache = self._private.requestCaches.validStaff[Player.UserId]
	if not theirCache then
		return
	end

	local existingTracker = ActivityTracker.Users[Player.UserId]
	if existingTracker then
		existingTracker:Chatted()
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
	@private
	@within VibezAPI
	@since 1.0.0
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
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_setRank(
	userId: string | number,
	rankId: string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse
	local userName = self:_getNameById(userId)
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

	if not tonumber(roleId) then
		return {
			success = false,
			errorMessage = "Parameter 'rankId' is an invalid rank.",
		} :: Types.errorResponse
	end

	local body = {
		userToRank = {
			userId = tonumber(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tonumber(userId),
		rankId = tonumber(roleId),
	}

	local _, response = self:Http("/ranking/changerank", "post", nil, body)
	return response.Body
end

--[=[
	Promotes a player and creates a fake "whoCalled" variable.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_Promote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:_getNameById(userId)

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
	})

	return response
end

--[=[
	Demotes a player and uses "whoCalled", creates one if none is added.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_Demote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:_getNameById(userId)

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
	})

	return response
end

--[=[
	Fires a player and creates a fake "whoCalled" variable if none is supplied.
	@param userId string | number
	@param whoCalled { userName: string, userId: number }
	@return rankResponse

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_Fire(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:_getNameById(userId)

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
	})

	return response
end

--[=[
	Displays a warning with the prefix of "[Vibez]"
	@param ... ...string

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_warn(...: string)
	if self.Settings.ignoreWarnings then
		return
	end

	warn("[Vibez]:", table.concat({ ... }, " "))
end

--// Public Functions \\--
--[=[
	Changes the rank of a player.
	@param userId string | number
	@param rankId string | number
	@return rankResponse

	```lua
	local userId, rankId = 1, 200
	Vibez:setRank(userId, rankId)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:setRank(userId: string | number, rankId: string | number): Types.rankResponse
	return self:_setRank(userId, rankId)
end

--[=[
	Promotes a player.
	@param userId string | number
	@return rankResponse

	```lua
	local userId = 1
	local response = Vibez:Promote(userId)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:Promote(userId: string | number): Types.rankResponse
	return self:_Promote(userId)
end

--[=[
	Demotes a player.
	@param userId string | number
	@return rankResponse

	```lua
	local userId = 1
	local response = Vibez:Demote(userId)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:Demote(userId: string | number): Types.rankResponse
	return self:_Demote(userId)
end

--[=[
	Fires a player from the group.
	@param userId string | number
	@return rankResponse

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:Fire(userId: string | number): Types.rankResponse
	return self:_Fire(userId)
end

--[=[
	Changes the rank of a player & logs with the Username/UserId who used the function.
	@param userId string | number
	@param rankId string | number
	@param idOfUser number
	@param nameOfUser string
	@return rankResponse

	```lua
	local userId, rankId = 1, 200
	local idOfCaller, nameOfCaller = 1, "ROBLOX"
	Vibez:setRankWithCaller(userId, rankId, 1, nameOfCaller)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:setRankWithCaller(
	userId: string | number,
	rankId: string | number,
	idOfUser: number,
	nameOfUser: string
): Types.rankResponse
	if not idOfUser or not nameOfUser then
		self:_warn(
			"'SetRankWithCaller' was supplied with no 'idOfUser' or 'nameOfUser', defaulting to normal ':SetRank'"
		)
		return self:_setRank(userId, rankId)
	end

	return self:_setRank(userId, rankId, { userName = nameOfUser, userId = idOfUser })
end

--[=[
	Promotes a player & logs with the Username/UserId who used the function.
	@param userId string | number
	@param idOfUser number
	@param nameOfUser string
	@return rankResponse

	```lua
	local userId = 1
	local idOfCaller, nameOfCaller = 1, "ROBLOX"
	Vibez:promoteWithCaller(userId, 1, nameOfCaller)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:promoteWithCaller(userId: string | number, idOfUser: number, nameOfUser: string): Types.rankResponse
	if not idOfUser or not nameOfUser then
		self:_warn(
			"'PromoteWithCaller' was supplied with no 'idOfUser' or 'nameOfUser', defaulting to normal ':Promote'"
		)
		return self:_Promote(userId)
	end

	return self:_Promote(userId, { userName = nameOfUser, userId = idOfUser })
end

--[=[
	Demotes a player & logs with the Username/UserId who used the function.
	@param userId string | number
	@param idOfUser number
	@param nameOfUser string
	@return rankResponse

	```lua
	local userId = 1
	local idOfCaller, nameOfCaller = 1, "ROBLOX"
	Vibez:demoteWithCaller(userId, 1, nameOfCaller)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:demoteWithCaller(userId: string | number, idOfUser: number, nameOfUser: string): Types.rankResponse
	if not idOfUser or not nameOfUser then
		self:_warn("'DemoteWithCaller' was supplied with no 'idOfUser' or 'nameOfUser', defaulting to normal ':Demote'")
		return self:_Demote(userId)
	end

	return self:_Demote(userId, { userName = nameOfUser, userId = idOfUser })
end

--[=[
	Fires a player & logs with the Username/UserId who used the function.
	@param userId string | number
	@param idOfUser number
	@param nameOfUser string
	@return rankResponse

	```lua
	local userId = 1
	local idOfCaller, nameOfCaller = 1, "ROBLOX"
	Vibez:fireWithCaller(userId, 1, nameOfCaller)
	```

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:fireWithCaller(userId: string | number, idOfUser: number, nameOfUser: string): Types.rankResponse
	if not idOfUser or not nameOfUser then
		self:_warn("'FireWithCaller' was supplied with no 'idOfUser' or 'nameOfUser', defaulting to normal ':Fire'")
		return self:_Fire(userId)
	end

	return self:_Fire(userId, { userName = nameOfUser, userId = idOfUser })
end

--[=[
	Toggles the usage of commands within the experience.
	@return VibezAPI

	@within VibezAPI
	@tag Chainable
	@since 1.0.0
]=]
---
function api:toggleCommands(override: boolean?): nil
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

	return self
end

--[=[
	Adds a command operation code.
	@param operationName string
	@param operationCode string
	@param operationFunction (playerToCheck: Player, incomingArgument: string, internalFunctions: vibezCommandFunctions) -> boolean
	@return VibezAPI

	:::caution
	This method will not work if there's already an existing operation name!
	:::

	```lua
	-- This operation comes by default, no need to rewrite it.
	Vibez:addCommandOperation(
		"Team", -- Name of the operation.
		"%", -- Prefix before the operation argument.
		function(playerToCheck: Player, incomingArgument: string, internalFunctions)
			return playerToCheck.Team ~= nil
				and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
					== string.lower(incomingArgument)
		end
	)
	```

	The `internalFunctions` parameter contains a table of functions that are meant to ease the developmental process of operations. Here's an example of one of them being used:
	```lua
	Vibez:addCommandOperation(
		"SHR", -- Name of the operation.
		"shr", -- Prefix before the operation argument.
		function(playerToCheck: Player, incomingArgument: string, internalFunctions)
			local playerGroupInfo = internalFunctions
				._getGroupFromUser(Vibez, Vibez.GroupId, playerToCheck.UserId):await()

			return playerGroupInfo.Rank >= 250
		end
	)
	```

	@within VibezAPI
	@tag Chainable
	@since 1.0.0
]=]
function api:addCommandOperation(
	operationName: string,
	operationCode: string,
	operationFunction: (
		playerToCheck: Player,
		incomingArgument: string,
		internalFunctions: Types.vibezCommandFunctions
	) -> boolean
): Types.vibezApi
	if self._private.commandOperationCodes[operationName] then
		self:_warn(`Command operation code '{operationCode}' already exists!`)
		return
	elseif typeof(operationFunction) ~= "function" then
		self:_warn(`Command operation callback is not a type "function", it's a "{typeof(operationFunction)}"`)
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
	@since 1.0.0
]=]
---
function api:removeCommandOperation(operationName: string): Types.vibezApi
	self._private.commandOperationCodes[operationName] = nil
	return self
end

--[=[
	Updates the logger's origin name.

	@within VibezAPI
	@tag Chainable
	@since 1.0.0
]=]
---
function api:updateLoggerTitle(newTitle: string): nil
	self.Settings.loggingOriginName = tostring(newTitle)
	return self
end

--[=[
	Updates the api key.
	@param newApiKey string
	@return boolean

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:updateKey(newApiKey: string): boolean
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
	Checks if the user is currently a nitro booster.
	@param User number | string | Player
	@return boolean

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:isPlayerBoostingDiscord(User: number | string | Player): boolean
	local userId

	if typeof(User) == "Instance" and User:IsA("Player") then
		userId = User.UserId
	elseif typeof(User) == "Instance" then
		self:_warn(`Class name, "{User.ClassName}", is not supported for ":isPlayerBoostingDiscord"`)
		return nil
	else
		userId = (typeof(userId) == "number" or tonumber(userId) ~= nil) and tonumber(userId) or self:_get(userId)
	end

	if not userId then
		self:_warn("UserId is not a valid player.")
		return
	end

	local theirCache = self._private.requestCaches.nitro[userId]
	if theirCache ~= nil then
		local timestamp, value = theirCache.timestamp, theirCache.responseValue
		local now = DateTime.now().UnixTimestamp

		if timestamp - now > 0 then
			return value
		end
	end

	local isOk, response = self:Http(`/is-booster/{userId}`)
	if not isOk or (response.StatusCode == 200 and response.Body ~= nil and response.Body.success == false) then
		return false
	end

	local newCacheData = {
		value = response.Body.isBooster,
		timestamp = DateTime.now().UnixTimestamp + (60 * 10), -- 10 minute offset
	}

	self._private.requestCaches.nitro[userId] = newCacheData
	return newCacheData.value
end

--[=[
	Destroys the VibezAPI class.

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

--[=[
	Toggles the client promote/demote/fire UI.
	@param override boolean?

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:toggleUI(override: boolean?): nil
	if override ~= nil then
		self.Settings.isUIEnabled = override
	else
		self.Settings.isUIEnabled = not self.Settings.isUIEnabled
	end

	for _, playerData in pairs(self._private.requestCaches.validStaff) do
		local player = playerData[1]

		if player.PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
			continue
		end
	end

	local uiStatus = self.Settings.isUIEnabled
	Workspace:SetAttribute(self._private.clientScriptName .. "_UI", uiStatus)
end

--[=[
	Initializes the Hooks class with the specified webhook.
	@param webhook string
	@return VibezHooks

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:getWebhookBuilder(webhook: string): Types.vibezHooks
	local newHook = Hooks.new(self, webhook)
	return newHook
end

--[=[
	Gets a player's or everyone's current activity
	@param userId (string | number)?
	@return activityResponse

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:getActivity(userId: (string | number)?): Types.activityResponse
	local _, result = self:Http("/activity/fetch2", "post", nil, {
		userId = userId,
	})

	return result.Body
end

--[=[
	Saves the player's current activity
	@param userId string | number
	@param secondsSpent number
	@param messagesSent (number | { string })?
	@return httpResponse

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:saveActivity(
	userId: string | number,
	secondsSpent: number,
	messagesSent: (number | { string })?
): Types.infoResponse
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:_getUserIdByName(userId) or userId
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent or (messagesSent == nil) and 0 or messagesSent

	if not tonumber(messagesSent) then
		self:_warn(debug.traceback(`Cannot save activity with an invalid 'number' as the 'messagesSent'!`, 2))
		return
	elseif not tonumber(secondsSpent) then
		self:_warn(debug.traceback(`'secondsSpent' parameter is required for this function!`, 2))
		return
	end

	local rankId = 0
	local groupData = self:_getGroupFromUser(self.GroupId, userId)

	if typeof(groupData) ~= "table" then
		self:_warn(`Could not fetch group data.`)
		return
	end

	rankId = groupData.Rank
	secondsSpent, messagesSent = tonumber(secondsSpent), tonumber(messagesSent)

	local _, response = self:Http("/activity/save2", "post", nil, {
		userId = userId,
		userRank = rankId,
		secondsUserHasSpent = secondsSpent,
		messagesUserHasSent = messagesSent,
	})

	return response.Body
end

--// Constructor \\--
--[=[
	@function new
	@within VibezAPI

	@param apiKey string -- Your Vibez API key.
	@param extraOptions extraOptionsType -- Extra settings to configure the api to work for you.
	@return VibezAPI

	:::caution Notice
	This method can be used as a normal function or invoke the ".new" function:    
	`require(14946453963)("API Key")`  
	`require(14946453963).new("API Key")`
	:::

	Constructs the main Vibez API class.

	```lua
	local myKey = "YOUR_API_KEY_HERE"
	local VibezAPI = require(14946453963)
	local Vibez = VibezAPI(myKey)
	```

	@tag Constructor
]=]
---
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi
	if RunService:IsClient() then
		return nil
	end

	--[=[
		@class VibezAPI
		**IMPORTANT**: When using this module, we recommend using the number-based format rather than importing the scripts into the game.
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
	self.Settings = Table.Copy(baseSettings)
	self._private = {
		newApiUrl = "https://leina.vibez.dev",
		oldApiUrl = "https://api.vibez.dev/api",
		clientScriptName = table.concat(string.split(HttpService:GenerateGUID(false), "-"), ""),
		rateLimiter = RateLimit.new(60, 60),
		Maid = {},
		requestCaches = {
			validStaff = {},
			nitro = {},
			groupInfo = {},
		},
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
			self:_warn( -- This is only made like this to fix github syntax highlights.
				"Optional key '"
					.. key
					.. "' is not the same as it's defined value of "
					.. typeof(self.Settings[key])
					.. "!"
			)
			continue
		end

		self.Settings[key] = value
	end

	-- Update the api key using the public function, in case of errors it'll log them.
	local isKeyOK = self:updateKey(apiKey)

	if not isKeyOK then
		self:Destroy()
		return setmetatable({}, {
			__index = function()
				warn("API Key was not accepted, please make sure there are no special character or spaces.")
				return function() end
			end,
		})
	end

	-- UI communication handler
	local communicationRemote = self:_createRemote() :: RemoteFunction
	communicationRemote.OnServerInvoke = function(Player: Player, Action: string, ...: any)
		local rankingActions = { "promote", "demote", "fire" }
		local Data = { ... }

		local actionIndex = table.find(rankingActions, string.lower(tostring(Action)))
		if actionIndex ~= nil then
			local Target = Data[1]

			if Player == Target then
				return
			end

			if not self.Settings.isUIEnabled then
				return false
			end

			local userId = self:_getUserIdByName(Target.Name)
			local groupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
			if typeof(groupData) ~= "table" then
				self:_warn(groupData)
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
			end

			local result = self[actionFunc](userId, { userName = Player.Name, userId = Player.UserId })

			if not result["success"] then
				return false
			end

			return true
		elseif Action == "Afk" then
			local override = Data[1]
			local existingTracker = ActivityTracker.Users[Player.UserId]

			if not existingTracker then
				return
			end

			if override == nil then
				override = not existingTracker.isAfk
			end

			existingTracker:changeAfkState(override)
		else
			return false
		end
	end

	-- Chat command connections
	Players.PlayerAdded:Connect(function(Player)
		self:_onPlayerAdded(Player)
	end)

	for _, Player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self._onPlayerAdded)(self, Player)
	end

	-- Connect the player's maid cleanup function.
	Players.PlayerRemoving:Connect(function(Player)
		self:_onPlayerRemoved(Player)
	end)

	-- Connect to when the game shuts down.
	game:BindToClose(function()
		self:_onGameShutdown()
	end)

	-- Initialize the workspace attribute
	local uiStatus = self.Settings.isUIEnabled
	local afkStatus = self.Settings.trackAFKActivity
	local afkDelay = self.Settings.delayBeforeMarkedAFK

	Workspace:SetAttribute(self._private.clientScriptName .. "_UI", uiStatus)
	Workspace:SetAttribute(self._private.clientScriptName .. "_AFK", afkStatus)
	Workspace:SetAttribute(self._private.clientScriptName .. "_AFK_DELAY", afkDelay)

	-- Track activity
	if self.Settings.activityTrackingEnabled == true then
		RunService.Heartbeat:Connect(function()
			for _, data in pairs(self._private.requestCaches.validStaff) do
				if data[3] == nil then
					continue
				end

				data[3]:Increment()
			end
		end)
	end

	return self
end

return setmetatable({
	new = Constructor,
}, {
	__call = function(t, ...)
		return rawget(t, "new")(...)
	end,
}) :: Types.vibezConstructor
