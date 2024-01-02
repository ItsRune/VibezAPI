--!native
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
	Updated: 11/13/2023 16:24 EST
	Version: 1.0.23
	
	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
--

--// Documentation \\--
--[=[
	@interface extraOptionsType
	.Commands { Enabled: boolean, useDefaultNames: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, Prefix: string, Alias: {string?} }
	.RankSticks { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, SticksModel: Model? }
	.Interface { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255> }
	.Notifications { Enabled: boolean, Position: String }
	.ActivityTracker { Enabled: boolean, MinRank: number<0-255>, disabledWhenInStudio: boolean, delayBeforeMarkedAFK: number, kickIfFails: boolean, failMessage: string }
	.Misc { originLoggerText: string, ignoreWarnings: boolean, rankingCooldown: number, overrideGroupCheckForStudio: boolean, isAsync: boolean, usePromises: boolean }
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
	@interface userBlacklistResponse
	.success boolean
	.data { blacklisted: boolean, reason: string }
	@within VibezAPI
	@private
]=]

--[=[
	@interface fullBlacklists
	.success boolean
	.blacklists: { [number | string]: { reason: string, blacklistedBy: number } }
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

--// Services \\--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Modules \\--
local Types = require(script.Modules.Types)
local Hooks = require(script.Modules.Hooks)
local ActivityTracker = require(script.Modules.Activity)
local RateLimit = require(script.Modules.RateLimit)
local Promise = require(script.Modules.Promise)
local Table = require(script.Modules.Table)

--// Constants \\--
local api = {}
local legacySettings, baseSettings =
	require(script.Modules.legacySettings), {
		Commands = {
			Enabled = false,
			useDefaultNames = true,

			MinRank = 255,
			MaxRank = 255,

			Prefix = "!",
			Alias = {},
		},

		RankSticks = {
			Enabled = false,
			MinRank = 255,
			MaxRank = 255,

			sticksModel = nil, -- Uses default
		},

		Notifications = {
			Enabled = true,
			Position = "Bottom-Right",
		},

		Interface = {
			Enabled = false,
			MinRank = 255,
			MaxRank = 255,
		},

		ActivityTracker = {
			Enabled = false,
			MinRank = 255,

			disableWhenInStudio = true,
			disableWhenAFK = false,
			delayBeforeMarkedAFK = 30,
			kickIfFails = false,
			failMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",
		},

		Misc = {
			originLoggerText = game.Name,
			ignoreWarnings = false,
			overrideGroupCheckForStudio = false,
			isAsync = false,
			rankingCooldown = 30, -- 30 Seconds
			usePromises = false, -- Broken
		},
	}

--// Local Functions \\--
local function onServerInvoke(
	self: Types.vibezApi,
	Player: Player,
	Action: string,
	Origin: "Interface" | "Sticks" | "Commands",
	...: any
)
	local rankingActions = { "promote", "demote", "fire" }
	local Data = { ... }
	local actionIndex = table.find(rankingActions, string.lower(tostring(Action)))

	if actionIndex ~= nil then
		local Target = Data[1]

		-- Check if UI is enabled or if Player has ranking sticks.
		if
			self.Settings.Commands.Enabled
			and not self.Settings.Interface.Enabled
			and table.find(self._private.usersWithSticks, Player.UserId) == nil
		then
			return false
		end

		-- Prevent user from ranking themself
		if Player == Target then
			self:_warn(Player.Name .. "(" .. Player.UserId .. ") attempted to '" .. Action .. "' themselves.")
			return false
		end

		local userId = self:_getUserIdByName(Target.Name)
		local fakeTargetInstance = { Name = Target.Name, UserId = userId }

		local targetGroupRank = self:_playerIsValidStaff(fakeTargetInstance)
		targetGroupRank = (targetGroupRank ~= nil) and targetGroupRank[2]
			or self:_getGroupFromUser(self.GroupId, fakeTargetInstance.UserId)

		if typeof(targetGroupRank) == "table" then
			targetGroupRank = targetGroupRank.Rank
		end

		local callerGroupRank = self:_playerIsValidStaff(Player)
		if not callerGroupRank or callerGroupRank[2] == nil then -- The user calling this function is NOT staff
			return false
		end
		callerGroupRank = callerGroupRank[2] -- THIS IS A NUMBER

		local minRank = (Origin == "Interface") and self.Settings.Interface.MinRank
			or (Origin == "Sticks" and self.Settings.RankSticks.MinRank)
			or (Origin == "Commands" and self.Settings.Commands.MinRank)
			or -1
		local maxRank = (Origin == "Interface") and self.Settings.Interface.MaxRank
			or (Origin == "Commands" and self.Settings.Commands.MaxRank)
			or (Origin == "Sticks" and 255)
			or -1

		if minRank == -1 or maxRank == -1 then
			return false
		end

		if
			callerGroupRank == nil -- basic check
			or (callerGroupRank < minRank or callerGroupRank > maxRank) -- Prevent ppl with lower than max rank to use methods (if somehow got access to)
			or (targetGroupRank >= callerGroupRank) -- Prevent lower/equal ranked users from ranking higher/equal members
		then
			return false
		end

		local theirCooldown = self._private.rankingCooldowns[userId]
		if
			theirCooldown ~= nil
			and DateTime.now().UnixTimestamp - theirCooldown < self.Settings.Misc.rankingCooldown
		then
			self:_warn(
				string.format(
					"User %s (%d) still has %d seconds left on their ranking cooldown!",
					Target.Name,
					Target.UserId,
					math.abs(self.Settings.Misc.rankingCooldown - (DateTime.now().UnixTimestamp - theirCooldown))
				)
			)
			return false
		end

		local actionFunc
		Action = string.lower(Action)
		if Action == "promote" then
			actionFunc = "_Promote"
		elseif Action == "demote" then
			actionFunc = "_Demote"
		elseif Action == "fire" then
			actionFunc = "_Fire"
		end

		local result = self[actionFunc](self, userId, { userName = Player.Name, userId = Player.UserId })
		if result["success"] == false then
			return false
		end

		result = result.Body
		self._private.rankingCooldowns[userId] = DateTime.now().UnixTimestamp

		-- DO NOT TOUCH TABBING IT RUINS THE WARNING
		self:_warn(
			string.format(
				[[
	RANK RESULT
Success: %s
User: %s (%d)
Ranked By: %s (%d)
New Rank
  - Name: %s
  - Rank: %d
  - RoleId: %d
Old Rank
  - Name: %s
  - Rank: %d
  - RoleId: %d
			]],
				tostring(result.success),
				fakeTargetInstance.Name,
				userId,
				Player.Name,
				Player.UserId,
				result.data.newRank.name,
				result.data.newRank.rank,
				result.data.newRank.id,
				result.data.oldRank.name,
				result.data.oldRank.rank,
				result.data.oldRank.id
			)
		)

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
	elseif Action == "isStaff" then
		self:waitUntilLoaded()
		local groupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
		local tbl = {}

		if #Data == 0 then
			return tbl
		end

		for _, actionSubCategory in pairs(Data) do
			if
				not self.Settings[actionSubCategory]
				or (self.Settings[actionSubCategory] ~= nil and self.Settings[actionSubCategory]["MinRank"] == nil)
			then
				self:_warn(
					"INTERNAL WARNING: Action Category '"
						.. tostring(actionSubCategory)
						.. "' is not a handled category!"
				)
				tbl[actionSubCategory] = false
				continue
			end

			tbl[actionSubCategory] = (
				actionSubCategory ~= nil
				and self.Settings[actionSubCategory].Enabled == true
				and groupData.Rank >= self.Settings[actionSubCategory].MinRank
			)
		end

		return tbl
	else
		-- Maybe actually log it somewhere... I have no clue where though.
		Player:Kick(
			"Messing with vibez remotes, this has been logged and repeating offenders will be blacklisted from our services."
		)
		return false
	end
end

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
	if self.Settings.Misc.usePromises then
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
		Body["origin"] = self.Settings.Misc.originLoggerText
	end

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route
	Headers["x-api-key"] = self.Settings.apiKey

	local apiToUse = (useOldApi == true) and self._private.oldApiUrl or self._private.newApiUrl

	-- Prevents sending api key to external URLs
	-- Remove from 'Route' extra slash that was added
	-- Make 'apiToUse' an empty string since "Route" and "apiToUse" get concatenated on request.
	if string.match(Route, "[http://]|[https://]") ~= nil then
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
	@return number | -1

	@yields
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:getGroupId()
	if self.GroupId ~= -1 and not self._private.recentlyChangedKey then
		return self.GroupId
	end

	self._private.recentlyChangedKey = false
	local isOk, res = self:Http("/ranking/groupid", "post", nil, nil)
	local Body: groupIdResponse = res.Body

	-- Make this a new thread, in case there's a failure we don't return nothing.
	coroutine.wrap(function()
		if Body["inGameConfigJSON"] ~= nil then
			self:_warn("Loading Settings from dashboard...")

			-- Convert JSON payload to lua tables
			local jsonConversionIsOk, JSON = pcall(HttpService.JSONDecode, HttpService, Body.inGameConfigJSON)

			if not jsonConversionIsOk then
				self:_warn("Settings JSON parse error.")
				return
			end

			-- Make current settings the template, so we can keep api key in the
			-- settings table.
			self.Settings = Table.Reconcile(JSON, self.Settings)
			self:_warn("Settings have been loaded from the dashboard successfully!")
		end
	end)()

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

	if RunService:IsStudio() and self.Settings.Misc.overrideGroupCheckForStudio == true then
		return {
			Rank = 255,
		}
	end

	local isOk, data = pcall(GroupService.GetGroupsAsync, GroupService, userId)
	local possiblePlayer = Players:GetPlayerByUserId(userId)
	local found = nil

	if not isOk then
		return {
			Id = groupId,
			Rank = 0,
			errMessage = data,
		}
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
	end

	if possiblePlayer ~= nil then
		isOk, data = pcall(possiblePlayer.GetRankInGroup, possiblePlayer, groupId)

		if isOk then
			return {
				Id = groupId,
				Rank = data,
			}
		end

		self:_warn(`An error occurred whilst fetching group information from {tostring(possiblePlayer)}.`)
	end

	return {
		Id = self.GroupId,
		Rank = 0,
	}
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
	-- Get group data for setup below.
	local theirGroupData = self:_getGroupFromUser(self.GroupId, Player.UserId)

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

	-- Figure out a solution here to check for rank (Prevent rank 0 in validStaff table)
	if self._private.requestCaches.validStaff[Player.UserId] == nil then
		self._private.requestCaches.validStaff[Player.UserId] = { Player, theirGroupData.Rank }
	end

	local PlayerGui = Player:WaitForChild("PlayerGui", 10)
	if PlayerGui and PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
		return -- Player was already in game but got disconnected (typically from an in game rank change)
	end

	-- Clone client script and parent to player gui
	local client = script.Client:Clone()
	client.Name = self._private.clientScriptName
	client.Enabled = true
	client.Parent = PlayerGui

	-- Enabled activity tracking for player
	if
		self.Settings.ActivityTracker.Enabled == true
		and theirGroupData.Rank >= self.Settings.ActivityTracker.MinRank
	then
		local tracker = ActivityTracker.new(self, Player)
		table.insert(self._private.requestCaches.validStaff[Player.UserId], tracker)
	end
end

--[=[
	Handles players leaving the game and disconnects any events.
	@param Player Player

	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_onPlayerRemoved(Player: Player, isPlayerStillInGame: boolean?) -- This method is being handled twice when game is shutting down.
	-- Check for and submit activity data.
	local existingTracker = ActivityTracker.Users[Player.UserId]
	if existingTracker and not isPlayerStillInGame then
		existingTracker:Left()

		-- Clear from activity tracking.
		ActivityTracker.Users[Player.UserId] = nil
	end

	-- Check for ranking sticks
	local sticksIndex = table.find(self._private.usersWithSticks, Player.UserId)
	if sticksIndex ~= nil and not isPlayerStillInGame then
		table.remove(self._private.usersWithSticks, sticksIndex)
	end

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
	Fires when the game's server is shutting down. (Not used)

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
	if typeof(userId) == "string" and tonumber(userId) == nil then
		return userId
	end

	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(userId))
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
	local remoteName = self._private.clientScriptName
	local currentRemote = ReplicatedStorage:FindFirstChild(remoteName)

	local function createNewRemote()
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
function api:_getPlayers(playerWhoCalled: Player, usernames: { string | number }): { Player? }
	local found = {}

	local externalCodes = {}
	local foundIndices = {}

	Table.ForEach(self._private.commandOperationCodes, function(data)
		if data["isExternal"] ~= nil and data["isExternal"] == true then
			table.insert(externalCodes, data)
		end
	end)

	for index, username in pairs(usernames) do
		for _, player in pairs(Players:GetPlayers()) do
			for _, operationData in pairs(self._private.commandOperationCodes) do
				local operationCode, operationFunction = operationData.Code, operationData.Execute

				if operationData["isExternal"] == true then
					continue
				end

				if
					string.sub(string.lower(username), 0, string.len(tostring(operationCode)))
					~= string.lower(operationCode)
				then
					continue
				end

				local operationResult = operationFunction(
					playerWhoCalled,
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
					table.insert(foundIndices, index)
				end
			end
		end
	end

	if #externalCodes > 0 then
		for index: number, username: string in pairs(usernames) do
			if table.find(foundIndices, index) ~= nil then
				continue
			end

			for _, operationData in pairs(externalCodes) do
				local code, codeFunc = operationData.Code, operationData.Execute

				if string.lower(string.sub(username, 1, #code)) == string.lower(code) then
					local data = codeFunc(string.sub(username, #code + 1, #username))

					if not data then
						continue
					end

					table.insert(foundIndices, index)
					table.insert(found, data)
				end
			end
		end
	end

	return found
end

--[=[
	Gives a Player the ranking sticks.
	@param Player Player

	@yields
	@private
	@within VibezAPI
	@since 1.3.0
]=]
---
function api:_giveSticks(Player: Player)
	local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
	local rankStick = (self.Settings.RankSticks["sticksModel"] == nil) and script.RankSticks
		or self.Settings.RankSticks["sticksModel"]

	local playerBackpack = Player:WaitForChild("Backpack", 10)

	if not playerBackpack then
		return
	end

	for _, operationName: string in ipairs(stickTypes) do
		local cloned = rankStick:Clone()
		cloned:SetAttribute(self._private.clientScriptName, "RankSticks")

		cloned.Name = operationName
		cloned.Parent = playerBackpack
	end

	table.insert(self._private.usersWithSticks, Player.UserId)
end

--[=[
	Removes ranking sticks from a player.
	@param Player Player

	@yields
	@private
	@within VibezAPI
	@since 1.3.0
]=]
---
function api:_removeSticks(Player: Player)
	local character = Player.Character
	local backpack = Player.Backpack

	self:_warn("Removing ranking sticks from " .. Player.Name .. " (" .. Player.UserId .. ")")

	local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
	local conjoinedLocations = Table.Assign(character:GetChildren(), backpack:GetChildren())
	local result = Table.Filter(conjoinedLocations, function(tool: Instance)
		return tool:IsA("Tool")
			and table.find(stickTypes, tool.Name) ~= nil
			and tool:GetAttribute(self._private.clientScriptName) == "RankSticks"
	end)

	if result ~= nil then
		for _, v in pairs(result) do
			v:Destroy()
		end
	end
end

--[=[
	Sets the ranking stick's tool.
	@param tool Tool | Model

	@yields
	@within VibezAPI
	@since 1.3.0
]=]
---
function api:setRankStickTool(tool: Tool | Model): ()
	if typeof(tool) ~= "Instance" or (not tool:IsA("Tool") and not tool:IsA("Model")) then
		self:_warn("Ranking Sticks have to be either a 'Tool' or a 'Model'!")
		return
	end

	if tool:IsA("Model") then
		if not tool:FindFirstChild("Handle") then
			self:_warn("Ranking Stick's model requires a 'Handle'!")
			return
		end

		local children = tool:GetChildren()
		local modelReference = tool

		local t = Instance.new("Tool")
		t.Parent = script

		for _, v in pairs(children) do
			v.Parent = t
		end

		modelReference:Destroy()
		tool = t
	end

	local handle = tool:FindFirstChild("Handle")
	handle.Anchored = false
	handle.CanCollide = false

	for _, v in pairs(tool:GetDescendants()) do
		if v == handle or not v:IsA("BasePart") then
			continue
		end

		local newWeld = Instance.new("WeldConstraint")
		newWeld.Name = `{v.Name}_{handle.Name}`
		newWeld.Part0 = handle
		newWeld.Part1 = v
		newWeld.Parent = handle

		v.Anchored = false
	end

	tool.CanBeDropped = false
	tool.Name = "RankingSticks"

	self.Settings.RankSticks["sticksModel"] = tool
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
	-- Check for activity tracker to increment messages sent.
	local existingTracker = ActivityTracker.Users[Player.UserId]
	if existingTracker then
		existingTracker:Chatted()
	end

	-- Commands handler
	if self.Settings.Commands.Enabled == false then
		return
	end

	local callerStaffData = self._private.requestCaches.validStaff[Player.UserId]
	-- { Player, groupRank }
	if not callerStaffData then
		return
	end

	local args = string.split(message, " ")
	local commandPrefix = self.Settings.Commands.Prefix

	if string.sub(args[1], 0, string.len(commandPrefix)) ~= commandPrefix then
		return
	end

	local command = string.sub(string.lower(args[1]), string.len(commandPrefix) + 1, #args[1])
	table.remove(args, 1)

	local commandData = Table.Filter(self._private.commandOperations, function(data)
		return data.Enabled == true
			and (
				(self.Settings.Commands.useDefaultNames == true and string.lower(command) == string.lower(data.Name))
				or Table.Filter(data.Alias, function(innerData)
						return string.lower(innerData) == string.lower(command)
					end)[1]
					~= nil
			)
	end)

	if commandData[1] == nil then
		return
	end

	commandData[1].Execute(Player, args)
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
	Disconnects and reconnects player events to fix permissions within servers.
	@param userId number
	@return ()

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_checkPlayerForRankChange(userId: number)
	local target = Players:GetPlayerByUserId(userId)
	if target == nil then
		return
	end

	--[[
		We wanna keep activity tracking but also disconnect any other connections, the second
		parameter below should do that. Afterwards we need to reconnect everything.
	]]
	--
	self:_onPlayerRemoved(target, true)
	self:_onPlayerAdded(target)
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

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

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

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

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

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

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

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

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
	if self.Settings.Misc.ignoreWarnings then
		return
	end

	warn("[Vibez]:", table.concat({ ... }, " "))
end

--[=[
	Adds an entry into the in-game logs.
	@param calledBy Player
	@param Action string
	@param affectedUsers { { Name: string, UserId: number } }
	@param ... any

	@private
	@within VibezAPI
	@since 2.3.6
]=]
---
function api:_addLog(calledBy: Player, Action: string, affectedUsers: { { Name: string, UserId: number } }?, ...: any)
	table.insert(self._private.inGameLogs, {
		calledBy = calledBy,
		affectedCount = (affectedUsers == nil) and 0 or #affectedUsers,
		affectedUsers = affectedUsers,
		extraData = { ... },

		Action = Action,
		Timestamp = DateTime.now().UnixTimestamp,
	})

	self._private.inGameLogs = Table.Truncate(self._private.inGameLogs, 100)
end

--[=[
	Builds the attributes of the settings for workspace.

	@within VibezAPI
	@private
	@since 2.3.1
]=]
---
function api:_buildAttributes()
	local dataToEncode = {
		AFK = {
			Status = self.Settings.ActivityTracker.disableWhenAFK,
			Delay = self.Settings.ActivityTracker.delayBeforeMarkedAFK,
		},

		UI = {
			Status = self.Settings.Interface.Enabled,
			Notifications = {
				Status = false, -- self.Settings.Notifications.Enabled,
				Position = "Bottom-Right", -- self.Settings.Notifications.Position,
			},
		},

		STICKS = {
			Status = self.Settings.RankSticks.Enabled,
		},
	}

	Workspace:SetAttribute(self._private.clientScriptName, HttpService:JSONEncode(dataToEncode))
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
			"'setRankWithCaller' was supplied with no 'idOfUser' or 'nameOfUser', defaulting to normal ':SetRank'"
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
		self.Settings.Commands.Enabled = override
	else
		self.Settings.Commands.Enabled = not self.Settings.Commands.Enabled
	end

	local status = self.Settings.Commands.Enabled
	local functionToUse = (not status) and "onPlayerRemoved" or "onPlayerAdded"

	for _, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self[functionToUse])(self, player)
	end

	return self
end

--[=[
	Creates a new command within our systems.
	@param commandName string
	@param commandAliases {string}?
	@param commandOperation (Player: Player, Args: { string }, addLog: (calledBy: Player, Action: string, affectedUsers: {Player}?, ...any) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }) -> ()
	@return VibezAPI

	@within VibezAPI
	@since 2.3.6
]=]
function api:addCommand(
	commandName: string,
	commandAliases: { string }?,
	commandOperation: (
		Player: Player,
		Args: { string },
		addLog: (
			calledBy: Player,
			Action: string,
			affectedUsers: { Player }?,
			...any
		) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }
	) -> ()
): boolean
	-- Make sure command doesn't already exist.
	commandAliases = (typeof(commandAliases) == "table") and commandAliases or {}

	local flatData = Table.Flat(Table.Map(self._private.commandOperations, function(value)
		return value.Alias
	end))

	local mappedCommandNames = Table.Map(self._private.commandOperations, function(value)
		return value.Name
	end)

	-- Conjoin the two tables into 1 | Result: { string }
	local keys = Table.Assign(flatData, mappedCommandNames)

	-- Both command names and aliases cannot be used as a command name.
	-- Just stop execution when detected.
	for _, key in ipairs(keys) do
		if string.lower(tostring(key)) == string.lower(tostring(commandName)) then
			return false
		end
	end

	-- Remove any aliases that are already taken.
	for _, alias in ipairs(flatData) do
		local _, index = Table.Find(commandAliases, function(value)
			return string.lower(value) == string.lower(alias)
		end)

		table.remove(commandAliases, index)
	end

	-- TODO: Allow developers to trigger 'self:_addLog' when their command runs.
	table.insert(self._private.commandOperations, {
		Name = string.lower(commandName),
		Alias = commandAliases,
		Enabled = true,
		Execute = commandOperation,
	})

	return true
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
		if operationCode == opData.Code and operationCode ~= "" then
			return self:_warn(`Operation code '{operationCode}' already exists for the operation '{opName}'!`)
		end
	end

	self._private.commandOperationCodes[operationName] = { Code = operationCode, Execute = operationFunction }
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
function api:updateLoggerName(newTitle: string): nil
	self.Settings.Misc.originLoggerText = tostring(newTitle)
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
	self._private.recentlyChangedKey = true

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
	Checks if the user is currently a nitro booster. (Only specific guilds have this feature)
	@param User number | string | Player
	@return boolean

	@yields
	@private
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
		self.Settings.Interface.Enabled = override
	else
		self.Settings.Interface.Enabled = not self.Settings.Interface.Enabled
	end

	for _, playerData in pairs(self._private.requestCaches.validStaff) do
		local player = playerData[1]

		if player.PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
			continue
		end
	end

	self:_buildAttributes()
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
	Adds a blacklist to your api key.
	@param userToBlacklist (Player string | number)
	@param Reason string?
	@param blacklistExecutedBy (Player string | number)?
	@return blacklistResponse

	@within VibezAPI
	@since 1.1.0
]=]
---
function api:addBlacklist(
	userToBlacklist: Player | string | number,
	Reason: string?,
	blacklistExecutedBy: (Player | string | number)?
)
	local userId, reason, blacklistedBy = nil, (Reason or "Unknown."), nil

	if not userToBlacklist then
		return nil
	elseif not blacklistExecutedBy then
		blacklistExecutedBy = -1
	end

	if typeof(userToBlacklist) == "Instance" then
		userId = userToBlacklist.UserId
	else
		userId = (typeof(userToBlacklist) == "string" and not tonumber(userToBlacklist))
				and self:_getUserIdByName(userToBlacklist)
			or userToBlacklist
	end

	if typeof(blacklistExecutedBy) == "Instance" then
		blacklistedBy = blacklistExecutedBy.UserId
	else
		blacklistedBy = (typeof(blacklistExecutedBy) == "string" and not tonumber(blacklistExecutedBy))
				and self:_getUserIdByName(blacklistExecutedBy)
			or blacklistExecutedBy
	end

	local isOk, response = self:Http(`/blacklists/{userId}`, "put", nil, {
		reason = reason,
		blacklistedBy = blacklistedBy,
	})

	if not isOk then
		return {
			success = false,
			message = "Internal server error.",
		}
	end

	return response.Body
end

--[=[
	Deletes a blacklist from your api key.
	@param userToDelete (Player string | number)
	@return blacklistResponse

	@within VibezAPI
	@since 1.1.0
]=]
---
function api:deleteBlacklist(userToDelete: Player | string | number)
	local userId

	if not userToDelete then
		return nil
	end

	if typeof(userToDelete) == "Instance" then
		userId = userToDelete.UserId
	else
		userId = (typeof(userToDelete) == "string" and not tonumber(userToDelete))
				and self:_getUserIdByName(userToDelete)
			or userToDelete
	end

	local isOk, response = self:Http(`/blacklists/{userId}`, "delete")

	if not isOk then
		return {
			success = false,
			message = "Internal server error.",
		}
	end

	return response.Body
end

--[=[
	Gets either a full list of blacklists or checks if a player is currently blacklisted.
	@param userId (string | number)?
	@return blacklistResponse

	@within VibezAPI
	@since 1.1.0
]=]
---
function api:getBlacklists(userId: (string | number)?): Types.blacklistResponse
	if typeof(userId) == nil then
		userId = ""
	else
		userId = (typeof(userId) == "string" and not tonumber(userId)) and self:_getUserIdByName(userId) or userId
	end

	local isOk, response = self:Http(`/blacklists/{userId}`)

	if not isOk or not response.Success then
		return { success = false, message = response.Body.message or "Internal server error." }
	end

	local res = {}

	if response.Body["isBlacklisted"] ~= nil then
		res = {
			success = true,
			data = {
				blacklisted = response.Body.isBlacklisted,
				reason = response.Body.details.reason,
				blacklistedBy = response.Body.details.blacklistedBy,
			},
		}
	else
		local newTable = {}
		for _, value: { userId: number | string, reason: string, blacklistedBy: number | string } in
			pairs(response.Body.blacklists)
		do
			local userIdIndex = value.userId
			value.userId = nil

			newTable[userIdIndex] = value
		end

		res = {
			success = true,
			blacklists = newTable,
		}
	end

	return res
end

--[=[
	Gets either a full list of blacklists or checks if a player is currently blacklisted.
	@param userId (string | number)?
	@return blacklistResponse

	@within VibezAPI
	@since 1.1.0
]=]
---
function api:isUserBlacklisted(userId: (string | number)?): (boolean, string?, number?)
	local blacklistData = self:getBlacklists(userId)

	if blacklistData.success then
		local data = {
			blacklistData.data.blacklisted,
			blacklistData.data.reason or nil,
			blacklistData.data.blacklistedBy or nil,
		}

		return table.unpack(data)
	end

	return false
end

--[=[
	Gets a player's or everyone's current activity
	@return VibezAPI?

	@tag Chainable
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:waitUntilLoaded(): Types.vibezApi?
	if self["Loaded"] == true then
		return self
	end

	local counter = 0
	local maxCount = 25

	-- Remove 'repeat' and replace with something more performant and can cancel.
	repeat
		task.wait(1)
		counter += 1
	until self.Loaded == true or counter >= maxCount

	return self.Loaded and self or nil
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
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:_getUserIdByName(userId) or userId

	local _, result = self:Http("/activity/fetch2", "post", nil, {
		userId = userId,
	})

	return result.Body
end

--[=[
	Saves the player's current activity
	@param userId string | number
	@param userRank number
	@param secondsSpent number
	@param messagesSent (number | { string })?
	@param shouldFetchGroupRank boolean?
	@return httpResponse

	@within VibezAPI
	@since 1.0.0
]=]
---
function api:saveActivity(
	userId: string | number,
	userRank: number,
	secondsSpent: number,
	messagesSent: (number | { string })?,
	shouldFetchGroupRank: boolean?
): Types.infoResponse
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:_getUserIdByName(userId) or userId
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent
		or (tonumber(messagesSent) ~= nil) and messagesSent
		or nil
	userRank = (typeof(userRank) == "number" or tonumber(userRank) ~= nil) and userRank or nil

	if not tonumber(messagesSent) then
		self:_warn(debug.traceback(`Cannot save activity with an invalid 'number' as the 'messagesSent' parameter!`, 2))
		return
	elseif not tonumber(secondsSpent) then
		self:_warn(debug.traceback(`Cannot save activity with an invalid 'number' as the 'secondsSpent' parameter!`, 2))
		return
	end

	if shouldFetchGroupRank == true then
		local groupData = self:_getGroupFromUser(self.GroupId, userId)

		if typeof(groupData) ~= "table" then
			self:_warn(`Could not fetch group data.`)
			return
		end

		userRank = groupData.Rank
	end

	secondsSpent, messagesSent = tonumber(secondsSpent), tonumber(messagesSent)

	local _, response = self:Http("/activity/save2", "post", nil, {
		userId = userId,
		userRank = userRank,
		secondsUserHasSpent = secondsSpent,
		messagesUserHasSent = messagesSent,
	})

	return response.Body
end

--[=[
	Returns the staff member's cached data.
	@param Player Player | number | string
	@return { Player, number } | ()

	@private
	@within VibezAPI
	@since 2.1.2
]=]
function api:_playerIsValidStaff(Player: Player | number | string)
	local userId = 0
	if typeof(Player) == "Instance" and Player:IsA("Player") then
		userId = Player.UserId
	elseif typeof(Player) == "number" or typeof(Player) == "string" and tonumber(Player) ~= nil then
		userId = tonumber(Player)
	elseif typeof(Player) == "string" and not tonumber(Player) then
		self:_getUserIdByName(tostring(Player))
	end

	return self._private.requestCaches.validStaff[userId]
end

--[=[
	Initializes the entire module.
	@param apiKey string
	@return ()

	@private
	@within VibezAPI
	@since 1.3.0
]=]
function api:_initialize(apiKey: string): ()
	if self._private._initialized then
		return
	end
	self._private._initialized = true

	if not self:_checkHttp() then
		self:_warn("Http is not enabled! Please enable it before trying to interact with our API!")

		-- Allow for GC to clean up the class.
		self:Destroy()
	end

	-- Update the api key using the public function, in case of errors it'll log them.
	local isOk = self:updateKey(apiKey)
	self.Loaded = true

	if not isOk then
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
	communicationRemote.OnServerInvoke = function(Player: Player, ...: any)
		onServerInvoke(self, Player, ...)
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

	-- selene: allow(incorrect_standard_library_use)
	-- Connect to when the game shuts down.
	game:BindToClose(self._onGameShutdown, self)

	-- Initialize the workspace attribute
	self:_buildAttributes()

	-- Track activity
	if self.Settings.ActivityTracker.Enabled == true then
		RunService.Heartbeat:Connect(function()
			for _, data in pairs(self._private.requestCaches.validStaff) do
				if data[3] == nil then
					continue
				end

				data[3]:Increment()
			end
		end)
	end
end

--// Constructor \\--
local function deepFetch(tbl: { any }, index: string | number)
	for k, v in pairs(tbl) do
		if k == index then
			return v
		elseif typeof(v) == "table" then
			return deepFetch(v)
		end
	end
end

local function deepChange(tbl: { any }, index: string | number, value: any)
	for k, v in pairs(tbl) do
		if k == index then
			tbl[k] = value
			break
		elseif typeof(v) == "table" then
			tbl[k] = deepChange(v, index, value)
		end
	end

	return tbl
end

local function stringifyTableDeep(tbl: { any }, tabbing: number?): string
	tabbing = tabbing or 1
	local str = "{\n"

	local function applyTabbing()
		if tabbing == 0 then
			return
		end

		for _ = 1, tabbing do
			str ..= "    "
		end
	end

	for index, value in pairs(tbl) do
		applyTabbing()

		if typeof(index) == "string" then
			str ..= string.format('["%s"] = ', index)
		end

		if typeof(value) == "table" then
			str ..= stringifyTableDeep(value, tabbing + 1) .. ","
		else
			str ..= (typeof(value) == "string" and `"{value}"` or tostring(value)) .. ","
		end

		str ..= "\n"
	end

	tabbing -= 1
	applyTabbing()

	return str .. "}"
end

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
		:::important
		When using this module, we recommend using the number-based format rather than importing the scripts into the game.
		:::
	]=]

	api.__index = api
	local self = setmetatable({}, api)

	self.Loaded = false
	self.GroupId = -1
	self.Settings = Table.Copy(baseSettings, true) -- Performs a deep copy
	self._private = {
		_initialized = false,
		recentlyChangedKey = false,

		newApiUrl = "https://leina.vibez.dev",
		oldApiUrl = "https://api.vibez.dev/api",

		clientScriptName = table.concat(string.split(HttpService:GenerateGUID(false), "-"), ""),
		rateLimiter = RateLimit.new(60, 60),

		externalConfigCheckDelay = 600, -- 600 = 10 minutes | Change below if changed
		lastLoadedExternalConfig = DateTime.now().UnixTimestamp - 600,

		inGameLogs = {},
		Maid = {},
		rankingCooldowns = {},

		usersWithSticks = {},
		stickTypes = '["Promote","Demote","Fire"]', -- JSON

		requestCaches = {
			validStaff = {},
			nitro = {},
			groupInfo = {},
		},

		commandOperations = {
			{
				Name = "promote",
				Alias = {},
				Enabled = true,
				Execute = function(Player: Player, Args: { string })
					local affectedUsers = {}
					local users = self:_getPlayers(Player, string.split(Args[1], ","))
					table.remove(Args, 1)

					for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
						onServerInvoke(self, Player, "Promote", "Commands", Target)
					end

					self:_addLog(Player, "Promote", affectedUsers)
				end,
			},

			{
				Name = "demote",
				Alias = {},
				Enabled = true,
				Execute = function(Player: Player, Args: { string })
					local affectedUsers = {}
					local users = self:_getPlayers(Player, string.split(Args[1], ","))
					table.remove(Args, 1)

					for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
						onServerInvoke(self, Player, "Demote", "Commands", Target)
					end

					self:_addLog(Player, "Demote", affectedUsers)
				end,
			},

			{
				Name = "fire",
				Alias = {},
				Enabled = true,
				Execute = function(Player: Player, Args: { string })
					local affectedUsers = {}
					local users = self:_getPlayers(Player, string.split(Args[1], ","))
					table.remove(Args, 1)

					for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
						onServerInvoke(self, Player, "Fire", "Commands", Target)
					end

					self:_addLog(Player, "Fire", affectedUsers)
				end,
			},

			{
				Name = "blacklist",
				Alias = {},
				Enabled = true,
				Execute = function(Player: Player, Args: { string })
					local affectedUsers = {}
					local users = self:_getPlayers(Player, string.split(Args[1], ","))
					table.remove(Args, 1)

					local reason = table.concat(Args, " ")

					for _, Target: Player in pairs(users) do
						local res = self:addBlacklist(Target.UserId, reason, Player.UserId)

						if not res.success then
							self:_warn("Blacklist resulted in an error, please try again later.")
							return
						end

						table.insert(affectedUsers, Target)
						self:_warn(res.message)
					end

					self:_addLog(Player, "Blacklist", affectedUsers, reason)
				end,
			},

			{
				Name = "unblacklist",
				Alias = {},
				Enabled = true,
				Execute = function(Player: Player, Args: { string })
					local affectedUsers = {}
					local targetData = table.remove(Args[1])
					local Targets

					Targets = Table.Map(string.split(targetData, ","), function(value)
						if tonumber(value) ~= nil then
							local nameIsOk, targetName = pcall(Players.GetNameFromUserIdAsync, Players, value)
							if not nameIsOk then
								return
							end

							return { Name = targetName, UserId = tonumber(value) }
						else
							local idIsOk, targetUserId = pcall(Players.GetUserIdFromNameAsync, Players, value)
							if not idIsOk then
								return
							end

							return { Name = value, UserId = targetUserId }
						end
					end)

					for _, Target: { Name: string, UserId: number } in pairs(Targets) do
						if not Target then
							return
						end

						local res = self:deleteBlacklist(Target.UserId)

						-- TODO: Add a way to warn client for their mistake!
						--selene: allow(empty_if)
						if not res.success then
							-- self:_warn("")
						end

						table.insert(affectedUsers, Target)
						self:_warn(res.message)
					end

					self:_addLog(Player, "Unblacklist", affectedUsers)
				end,
			},
		},

		commandOperationCodes = {
			["Team"] = {
				Code = "%", -- Operation Code
				Execute = function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
					return playerToCheck.Team ~= nil
						and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
							== string.lower(incomingArgument)
				end,
			},

			["Rank"] = {
				Code = "r:",
				Execute = function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
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
				Code = "", -- Operation Code (Empty on purpose)
				Execute = function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
					return string.sub(string.lower(playerToCheck.Name), 0, string.len(incomingArgument))
						== string.lower(incomingArgument)
				end,
			},

			["externalUser"] = {
				Code = "e:",
				isExternal = true,
				Execute = function(incomingArgument: string): { Name: string, UserId: number } | { any }
					local name, id
					if tonumber(incomingArgument) ~= nil then
						local isOk, userName =
							pcall(Players.GetNameFromUserIdAsync, Players, tonumber(incomingArgument))

						if isOk then
							name = userName
							id = tonumber(incomingArgument)
						end
					else -- String
						local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, incomingArgument)

						if isOk then
							name = incomingArgument
							id = userId
						end
					end

					if not name or not id then
						return nil
					end

					return {
						Name = name,
						UserId = id,
					}
				end,
			},
		},
	}

	extraOptions = extraOptions or {}
	local fixedSettings = { {}, {} }
	for key, value in pairs(extraOptions) do
		if self.Settings[key] == nil then
			if legacySettings[key] ~= nil then
				local data = Table.Copy(legacySettings[key])

				for _, strPath: string in pairs(data) do
					local strPathSplit = string.split(strPath, ".")

					if not fixedSettings[strPathSplit[1]] then
						fixedSettings[strPathSplit[1]] = {}
					end

					fixedSettings[strPathSplit[1]][strPathSplit[2]] = value
					table.insert(fixedSettings[2], key)

					local split = string.split(strPath, ".")
					for i = 2, #split do
						local tbl = self.Settings[split[1]]
						if not tbl then
							break
						end

						local toCheck = deepFetch(tbl, split[i])
						if typeof(toCheck) ~= typeof(value) then
							self:_warn(
								`Optional key '{key}' is not the same as its default value of '{typeof(toCheck)}'!`
							)
							break
						end

						local newTbl = deepChange(tbl, split[i], value)
						self.Settings[split[1]] = newTbl
					end
				end

				continue
			end

			self:_warn(`Optional key '{key}' is not a valid option.`)
			continue
		end

		if typeof(value) == "table" then
			for k, j in pairs(value) do
				if self.Settings[key][k] == nil then
					self:_warn(`Optional key 'Settings.{key}.{k}' is not a valid option.`)
					continue
				elseif typeof(self.Settings[key][k]) ~= typeof(j) then
					-- stylua: ignore
					-- Styles were messing up this line
					self:_warn(`Optional key 'Settings.{key}.{k}' is not the same type as its default value of '{typeof(self.Settings[key][k])}'!`)
					continue
				end

				self.Settings[key][k] = j
			end
		else
			self.Settings[key] = value
		end
	end

	-- Check for if ranking sticks and commands are enabled and add
	-- sticks command
	if self.Settings.RankSticks.Enabled == true and self.Settings.Commands.Enabled == true then
		self:addCommand("sticks", {}, function(Player: Player)
			local staffData = self:_playerIsValidStaff(Player)
			if not staffData or staffData[2] == nil or staffData[2] < self.Settings.Commands.MinRank then
				return
			end

			local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
			local foundSticks = Table.Filter(
				Table.Assign(Player.Character:GetChildren(), Player.Backpack:GetChildren()),
				function(value)
					return value:IsA("Tool")
						and table.find(stickTypes, value.Name) ~= nil
						and value:GetAttribute(self._private.clientScriptName) == "RankSticks"
				end
			)

			if #foundSticks > 0 then
				self:_addLog(Player, "RankSticks", nil, "Removed")

				for _, v in pairs(foundSticks) do
					v:Destroy()
				end
				return
			end

			self:_giveSticks(Player)
			self:_addLog(Player, "RankSticks", nil, "Given")
		end)
	end

	-- Check for aliases changed and update them (Separate Thread)
	if #self.Settings.Commands.Alias > 0 then
		coroutine.wrap(function()
			Table.ForEach(self.Settings.Commands.Alias, function(data: { any }) -- data: { string, { string } }
				if
					typeof(data) ~= "table"
					or typeof(data[1]) ~= "string"
					or typeof(data[2]) ~= "table"
					or typeof(data[2][1]) ~= "string"
				then
					return
				end

				-- Listen... We don't talk about this one..
				Table.ForEach(
					Table.Assign(
						data[2],
						Table.FlatMap(self._private.commandOperations, function(command)
							return command.Alias
						end)
					),
					function(temp)
						local isNotOk = string.lower(temp) == string.lower(data[1])

						if isNotOk then
							return
						end

						local mapped = Table.Map(self._private.commandOperations, function(command)
							if string.lower(command.Name) == string.lower(data[1]) then
								table.insert(command.Alias, temp)
							end

							return command
						end)

						self._private.commandOperations = mapped
					end
				)
			end)
		end)()
	end

	-- Useful for when you want to require at the top of a script
	-- and you don't want it to yield as it gathers necessary api data.
	-- ie, fetching group data & external-config
	if self.Settings.Misc.isAsync then
		coroutine.wrap(self._initialize)(self, apiKey)
	else
		self:_initialize(apiKey)
	end

	return self :: Types.vibezApi
end

return setmetatable({
	new = Constructor,
}, {
	__call = function(t, ...)
		return rawget(t, "new")(...)
	end,
}) :: Types.vibezConstructor
