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
	.isChatCommandsEnabled boolean -- Automatically load commands for users.
	.isUIEnabled boolean -- Allow for player's to click on another for ranking options.
	.commandPrefix string -- Change the prefix of commands.
	.minRankToUseCommandsAndUI number -- Minimum rank to use commands. (Default: 255)
	.maxRankToUseCommandsAndUI number -- Maximum rank to use commands. (Default: 255)
	.overrideGroupCheckForStudio boolean -- When in studio, it'll force any rank checks to be the 'maxRankForCommands' value.
	.nameOfGameForLogging string -- Name of logger's 'Origin' embed field.
	.ignoreWarnings boolean -- Ignores any VibezAPI warnings (Excluding Webhooks & Activity Tracking)
	.activityTrackingEnabled boolean -- Track a user's activity if their rank is higher than 'rankToStartTrackingActivityFor'.
	.rankToStartTrackingActivityFor boolean -- Minimum rank required to start tracking activity. (Default: 255)
	.disableActivityTrackingWhenAFK boolean -- Subtracts time of users who are detected as 'AFK'.
	.shouldKickPlayerIfActivityTrackerFails boolean -- When enabled, it'll kick the player if the activity tracker can't initialize a player.
	.activityTrackerFailedMessage string -- The kick message for a player if their activity tracker fails to load.
	.delayBeforeMarkedAFK number -- The amount of time in seconds before a player is marked 'AFK'. (Default: 30)
	.disableActivityTrackingInStudio boolean -- Stops saving any activity tracked when play testing in studio.
	.usePromises boolean -- Determines whether the module should return promises or not.
	.isAsync boolean -- Determines whether initialization will yield your script or not.
	.isRankingSticksEnabled boolean -- Determines whether ranking sticks are given to staff.
	.giveRankSticksToRankAndAbove number -- A rank that has the tolerance of '>=' (Setting this to 1 will give everyone in ur group the rank sticks)
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
local rankStick = script.RankSticks
local baseSettings = {
	-- Commands
	commandPrefix = "!",

	-- Ranks for interactives
	minRankToUseCommandsAndUI = 255,
	maxRankToUseCommandsAndUI = 255,
	giveRankSticksToRankAndAbove = 255,

	-- Interactives
	isChatCommandsEnabled = false,
	isUIEnabled = false,
	isRankingSticksEnabled = false,

	-- Activity
	disableActivityTrackingInStudio = true,
	activityTrackingEnabled = false,
	disableActivityTrackingWhenAFK = true,
	rankToStartTrackingActivityFor = 255,
	delayBeforeMarkedAFK = 30,
	shouldKickPlayerIfActivityTrackerFails = false,
	activityTrackerFailedMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",

	-- Logging origin name
	nameOfGameForLogging = game.Name,

	-- Misc
	overrideGroupCheckForStudio = false,
	ignoreWarnings = false,
	isAsync = false,
	usePromises = false, -- Broken
}

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
		Body["origin"] = self.Settings.nameOfGameForLogging
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

	if RunService:IsStudio() and self.Settings.overrideGroupCheckForStudio == true then
		return {
			Rank = self.Settings.maxRankToUseCommandsAndUI,
		}
	end

	local isOk, data = pcall(GroupService.GetGroupsAsync, GroupService, userId)
	local possiblePlayer = Players:GetPlayerByUserId(userId)
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

	-- Distribute rank sticks to players
	if self.Settings["isRankingSticksEnabled"] then
		local rankToGiveTo = self.Settings.giveRankSticksToRankAndAbove

		if theirGroupData and theirGroupData.Rank >= rankToGiveTo then
			self:_warn("Giving ranking sticks to " .. Player.Name .. " (" .. Player.UserId .. ")")
			self:_giveSticks(Player)
		end
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

	if
		self.Settings.activityTrackingEnabled == true
		and theirGroupData.Rank >= self.Settings.rankToStartTrackingActivityFor
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
function api:_getPlayers(usernames: { string | number }): { Player? }
	local found = {}

	for _, username in pairs(usernames) do
		if tonumber(username) ~= nil then
			table.insert(found, {
				UserId = tonumber(username),
			})
			continue
		end

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

	for _, operationName: string in ipairs(stickTypes) do
		local cloned = rankStick:Clone()

		cloned:SetAttribute(self._private.clientScriptName, "RankSticks")
		cloned.Name = operationName
		cloned.Parent = Player:WaitForChild("Backpack", 10)
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
function api:rankingStickSetModel(tool: Tool | Model): ()
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

		tool = Instance.new("Tool")
		tool.Parent = script

		for _, v in pairs(children) do
			v.Parent = tool
		end

		modelReference:Destroy()
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
	rankStick = tool
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
	if self.Settings.isChatCommandsEnabled == false then
		return
	end

	local callerStaffData = self._private.requestCaches.validStaff[Player.UserId]
	-- { Player, groupRank }
	if not callerStaffData then
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
	table.remove(args, 1)

	for _, Target: Player in pairs(users) do
		if Target == Player then
			continue
		end

		local targetGroupData = (self._private.validStaff[Target.UserId] ~= nil)
				and { Rank = self._private.validStaff[Target.UserId][2] }
			or self:_getGroupFromUser(self.GroupId, Target.UserId)

		-- Check if target is a higher rank than the player using the command.
		if not targetGroupData or targetGroupData.Rank >= callerStaffData[2] then
			continue
		end

		local commandCallParameters = { Target.UserId, { userId = Player.UserId, userName = Player.Name } }
		if command == "promote" then
			self:_Promote(table.unpack(commandCallParameters))
		elseif command == "demote" then
			self:_Demote(table.unpack(commandCallParameters))
		elseif command == "fire" then
			self:_Fire(table.unpack(commandCallParameters))
		elseif command == "blacklist" then
			local res = self:addBlacklist(Target.UserId, table.concat(args, " "), Player.UserId)

			--selene: allow(empty_if)
			if not res.success then
				self:_warn("Blacklist resulted in an error, please try again later.")
				return
			end

			self:_warn(res.message)
		elseif command == "unblacklist" then
			local res = self:deleteBlacklist(Target.UserId)

			--selene: allow(empty_if)
			if not res.success then
				-- warn user
			end

			self:_warn(res.message)
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
function api:updateLoggerName(newTitle: string): nil
	self.Settings.nameOfGameForLogging = tostring(newTitle)
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

	return self._private.validStaff[userId]
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
	communicationRemote.OnServerInvoke = function(Player: Player, Action: string, ...: any)
		local rankingActions = { "promote", "demote", "fire" }
		local Data = { ... }

		local actionIndex = table.find(rankingActions, string.lower(tostring(Action)))
		if actionIndex ~= nil then
			local Target = Data[1]

			-- Check if UI is enabled or if Player has ranking sticks.
			if not self.Settings.isUIEnabled and table.find(self._private.usersWithSticks, Player.UserId) == nil then
				return false
			end

			-- Prevent user from ranking themself
			if Player == Target then
				self:_warn(Player.Name .. "(" .. Player.UserId .. ") attempted to '" .. Action .. "' themselves.")
				return false
			end

			local userId = self:_getUserIdByName(Target.Name)
			local targetGroupData = self:_playerIsValidStaff(Target)
			targetGroupData = targetGroupData or self:_getGroupFromUser(self.GroupId, Target.UserId)

			local groupData = self:_playerIsValidStaff(Player)
			if not groupData then -- The user calling this function is NOT staff
				return false
			end

			if
				(
					not self:_isPlayerRankOkToProceed(
						groupData.Rank,
						self.Settings.minRankToUseCommandsAndUI,
						self.Settings.maxRankToUseCommandsAndUI
					)
				)
				or (targetGroupData ~= nil and targetGroupData.Rank >= groupData.Rank) -- Prevent lower ranked users from ranking higher members
			then
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

	-- selene: allow(incorrect_standard_library_use)
	-- Connect to when the game shuts down.
	game:BindToClose(self._onGameShutdown, self)

	-- Initialize the workspace attribute
	local dataToEncode = {
		AFK = {
			Status = self.Settings.disableActivityTrackingWhenAFK,
			Delay = self.Settings.delayBeforeMarkedAFK,
		},

		UI = {
			Status = self.Settings.isUIEnabled,
		},

		STICKS = {
			Status = self.Settings.isRankingSticksEnabled,
		},
	}

	Workspace:SetAttribute(self._private.clientScriptName, HttpService:JSONEncode(dataToEncode))

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

		Maid = {},

		usersWithSticks = {},
		stickTypes = '["Promote","Demote","Fire"]', -- JSON

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

	if self.Settings.isAsync then
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
}) :: Types.vibezApi
