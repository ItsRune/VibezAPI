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
	Updated: 9/12/2023 14:01 EST
	
	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
--

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
--[[
	* Fetches the group associated with the api key.
	 - Socket hang up is possible if the api key is invalid when trying to make a request!
	* Params Route<string>, Method<string>, Headers<{[string]: any}>, Body<{any}?>
	* Returns Success<boolean>, Response<{any}>
]]
--
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

--[[
	* Fetches the group associated with the api key.
	* Returns groupId<number> - a number symbolizing the group identifier attached to the api key.
]]
--
function api:getGroupId()
	if self.GroupId ~= -1 then
		return self.GroupId
	end

	local isOk, res = self:Http("/ranking/groupid", "post", nil, nil, true)
	local Body: groupIdResponse = res.Body

	return isOk and Body.groupId or -1
end

--[[
	* Uses roblox's group service to get a player's rank.
	* Params groupId<number>, userId<number>
	* Returns groupRank<number>
]]
--
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

--[[
	* Handles players joining the game and connecting chatting event to them.
	* Params Player<Player>
]]
--
function api:onPlayerAdded(Player: Player)
	-- This is only here in case they toggle commands in the middle of a game.
	if not self.Settings.isChatCommandsEnabled then
		return
	end

	if self._private.validStaff[Player.UserId] ~= nil then
		return
	end

	self:_warn(`Settings up commands for user {Player.Name}.`)

	local theirGroupData = self:getGroupFromUser(self.GroupId, Player.UserId)
	if not theirGroupData or not self:isPlayerRankOkToProceed(theirGroupData.Rank) then
		return
	end

	self._private.validStaff[Player.UserId] = Player

	-- We want to hold all connections from users in order to
	-- disconnect them later on, this will stop any memory
	-- leaks from occurring by vibez's api wrapper.

	self._private.Maid[Player.UserId] = {}
	table.insert(
		self._private.Maid[Player.UserId],
		Player.Chatted:Connect(function(message: string)
			return self:onPlayerChatted(Player, message)
		end)
	)
end

--[[
	* Handles players leaving the game and disconnects any events.
	* Params Player<Player>
]]
--
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

--[[
	* Compares rank to min/max rank for commands or UI.
	* Params rank<number>
	* Returns isOk<boolean>
]]
--
function api:isPlayerRankOkToProceed(playerRank: number): boolean
	return (playerRank >= self.Settings.minRank and playerRank <= self.Settings.maxRank)
end

--[[
	* Gets player's user identifers without needing to be in game.
	* Params username<string>
	* Returns userId<number?>
]]
--
function api:getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[[
	* Gets player's username.
	* Params userId<number>
	* returns username<string?>
]]
--
function api:getNameById(userId: number): string?
	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	return isOk and userName or "Unknown"
end

--[[
	* Creates or fetches the current remote used for client communication.
	* Returns Remote<RemoteEvent>
]]
--
function api:createRemote()
	local currentRemote = ReplicatedStorage:FindFirstChild("__VibezEvent__")

	if not currentRemote then
		currentRemote = Instance.new("RemoteFunction")
		currentRemote.Name = "__VibezEvent__"
		currentRemote.Parent = ReplicatedStorage
	end

	return currentRemote
end

--[[
	* Handles the main chatting event.
	* Params Player<Player>, message<string>
]]
--
function api:onPlayerChatted(Player: Player, message: string)
	warn(1)
	if not self._private.validStaff[Player.UserId] then
		return
	end

	local args = string.split(message, " ")
	local commandPrefix = self.Settings.commandPrefix

	if string.sub(args[1], 0, string.len(commandPrefix)) ~= commandPrefix then
		return
	end

	local command = string.sub(string.lower(args[1]), string.len(commandPrefix) + 1, #args[1])
	table.remove(args, 1)

	local username = args[1]
	local userId = -1

	if not tonumber(username) then
		userId = self:getUserIdByName(username)
	end

	if userId == -1 or userId == Player.UserId then
		return
	end

	if command == "promote" then
		self:Promote(userId)
	elseif command == "demote" then
		self:Demote(userId)
	elseif command == "fire" then
		self:Fire(userId)
	end
end

--[[
	* Checks for if Http is enabled.
]]
--
function api:_checkHttp()
	local success = pcall(HttpService.GetAsync, HttpService, "https://google.com/")
	return success
end

--[[
	* Sets the rank of a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, rankId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
--
function api:_setRank(
	userId: string | number,
	rankId: string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse
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

	local _, response = self:Http("/ranking/changerank", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
		rankId = tostring(rankId),
	}, true)

	return response
end

--[[
	* Promotes a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
--
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

--[[
	* Demotes a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
--
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

--[[
	* Fires a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
--
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

--[[
	* Destroys the class and sets it up to be GC'ed.
]]
--
function api:_destroy()
	setmetatable(self, nil)
	self = nil
end

--[[
	Displays a warning with the prefix of "[Vibez]", will do nothing if 'ignoreWarnings' is set to true
	@param ...<...string>
]]
--
function api:_warn(...: string)
	if self.Settings.ignoreWarnings then
		return
	end

	warn("[Vibez]:", table.unpack({ ... }))
end

--// Public Functions \\--
-- Sets the rank of an employee
function api:SetRank(userId: string | number, rankId: string | number): Types.rankResponse
	return self:_setRank(userId, rankId)
end

-- Promotes an employee
function api:Promote(userId: string | number): Types.rankResponse
	return self:_Promote(userId)
end

-- Demotes an employee
function api:Demote(userId: string | number): Types.rankResponse
	return self:_Demote(userId)
end

-- Fires an employee
function api:Fire(userId: string | number): Types.rankResponse
	return self:_Fire(userId)
end

-- Toggles commands
function api:ToggleCommands(): nil
	self.Settings.isChatCommandsEnabled = not self.Settings.isChatCommandsEnabled

	local status = self.Settings.isChatCommandsEnabled
	local functionToUse = (not status) and "onPlayerRemoved" or "onPlayerAdded"

	for _, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self[functionToUse])(self, player)
	end
end

-- Updates the origin name
function api:UpdateLoggerTitle(newTitle: string): nil
	self.Settings.loggingOriginName = tostring(newTitle)
end

-- Updates the api key
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

-- Destroys the class
function api:Destroy()
	return self:_destroy()
end

-- Toggles ui handler
function api:ToggleUI(): nil
	self.Settings.isUIEnabled = not self.Settings.isUIEnabled

	local status = self.Settings.isUIEnabled
	Workspace:SetAttribute("__Vibez UI__", status)
end

-- Gets the player's current activity (Route has been said to be buggy)
-- function api:getActivity(userId: string | number)
-- 	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:getUserIdByName(userId) or userId

-- 	local _, response = self:Http("/activty/askJacobForTheRoute", "post", nil, {
-- 		playerId = userId,
-- 	}, true)

-- 	return response
-- end

-- Saves the player's current activity
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
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi
	if RunService:IsClient() then
		return nil
	end

	api.__index = api
	local self = setmetatable({}, api)

	if not self:_checkHttp() then
		self:_warn("Http is not enabled! Please enable it before trying to interact with our API!")

		-- Allow for GC to clean up the class.
		return self:Destroy()
	end

	self.GroupId = -1
	self.Settings = table.clone(baseSettings)
	self._private = {
		newApiUrl = "https://leina.vibez.dev",
		apiUrl = "https://api.vibez.dev/api",
		Maid = {},
		validStaff = {},
		rateLimiter = RateLimit.new(60, 60),
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
	local communicationRemote = self:createRemote() :: RemoteFunction
	communicationRemote.OnServerInvoke = function(Player: Player, Action: string, Target: Player)
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

		if Action == "promote" then
			self:_Promote(userId, { userName = Player.Name, userId = Player.UserId })
		elseif Action == "demote" then
			self:_Demote(userId, { userName = Player.Name, userId = Player.UserId })
		elseif Action == "fire" then
			self:_Fire(userId, { userName = Player.Name, userId = Player.UserId })
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

	return self
end

return Constructor :: Types.vibezConstructor