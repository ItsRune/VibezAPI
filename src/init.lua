--[[
		 _   _ ___________ _____ ______
		| | | |_   _| ___ \  ___|___  /
		| | | | | | | |_/ / |__    / /
		| | | | | | | ___ \  __|  / /
		\ \_/ /_| |_| |_/ / |___./ /___
		 \___/ \___/\____/\____/\_____/

	Author: ltsRune
	Profile: https://www.roblox.com/users/107392833/profile
	Created: 9/11/2023 15:01 EST
	Updated: 7/23/2024 11:18 EST
	Version: 0.11.0

	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
local _VERSION = "0.11.0"

--// Services \\--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local TestService = game:GetService("TestService")

--// Modules \\--
local Types = require(script.Modules.Types)
local Hooks = require(script.Modules.Hooks)
local ActivityTracker = require(script.Modules.Activity)
local RateLimit = require(script.Modules.RateLimit)
local Table = require(script.Modules.Table)
local Promise = require(script.Modules.Promise)
local Utils = require(script.Modules.Utils)
local baseSettings = require(script.Modules.Settings)

--// Constants \\--
local api = {}

--// Local Functions \\--
local function getActionFunctionFromInvoke(Action: string)
	Action = string.lower(Action)

	if Action == "promote" then
		return "Promote"
	elseif Action == "demote" then
		return "Demote"
	elseif Action == "fire" then
		return "Fire"
	elseif Action == "setrank" then
		return "setRank"
	elseif Action == "blacklist" then
		return "addBlacklist"
	elseif Action == "unblacklist" then
		return "deleteBlacklist"
	end

	return nil
end

local function onServerInvoke(
	self: Types.vibezApi,
	Player: Player,
	Action: string,
	Origin: "Interface" | "Sticks" | "Commands",
	...: any
)
	local rankingActions = { "promote", "demote", "fire", "setrank", "blacklist", "unblacklist" }
	local Data = { ... }
	local actionIndex = table.find(rankingActions, string.lower(tostring(Action)))

	if actionIndex ~= nil then
		local Targets = Data[1]

		if typeof(Targets) ~= "table" then
			Targets = { Targets }
		end

		-- Check if UI is enabled or if Player has ranking sticks.
		if
			not self.Settings.Commands.Enabled
			and not self.Settings.Interface.Enabled
			and table.find(self._private.usersWithSticks, Player.UserId) == nil
		then
			return false
		end

		local resolvedPromises = table.create(#Targets)

		for _, Target: any in ipairs(Targets) do
			Promise.new(function(resolve, reject)
				-- Prevent user from ranking themself
				if Player == Target then
					self:_warn(Player.Name .. "(" .. Player.UserId .. ") attempted to '" .. Action .. "' themselves.")
					return reject("Player and Target are the same.")
				end

				-- If the Target is a partial of their user, then we need to create a fake Player 'userdata'
				if typeof(Target) == "number" or typeof(Target) == "string" then
					local toFetch = (typeof(Target) == "number") and "Name" or "UserId"
					local oppoFetch = (toFetch == "Name") and "UserId" or "Name"

					local fetched = self:_verifyUser(Target, toFetch)
					local rememberedOriginalValue = Target

					Target = {
						[oppoFetch] = rememberedOriginalValue,
						[toFetch] = fetched,
					}
				end

				local userId = self:_getUserIdByName(Target.Name)
				local fakeTargetInstance = { Name = Target.Name, UserId = userId }

				local targetGroupRank = self:_playerIsValidStaff(fakeTargetInstance)
				targetGroupRank = (targetGroupRank ~= nil) and targetGroupRank.Rank
					or self:_getGroupFromUser(self.GroupId, fakeTargetInstance.UserId)

				if typeof(targetGroupRank) == "table" then
					targetGroupRank = targetGroupRank.Rank
				end

				local callerGroupRank: { [number]: any } = self:_playerIsValidStaff(Player)
				if not callerGroupRank or callerGroupRank.Rank == nil then -- The user calling this function is NOT staff
					self:_warn(
						string.format(
							"%s (%d) attempted to '%s' user %s (%d) when they're not staff!",
							Player.Name,
							Player.UserId,
							string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action)),
							Target.Name,
							userId
						)
					)
					return reject("Unauthorized")
				end

				callerGroupRank = callerGroupRank.Rank
				local minRank, maxRank

				do
					minRank = (Origin == "Interface") and self.Settings.Interface.MinRank
						or (Origin == "Sticks" and self.Settings.RankSticks.MinRank)
						or (Origin == "Commands" and self.Settings.Commands.MinRank)
						or -1
					maxRank = (Origin == "Interface") and self.Settings.Interface.MaxRank
						or (Origin == "Commands" and self.Settings.Commands.MaxRank)
						or (Origin == "Sticks" and 255)
						or -1
				end

				if minRank == -1 or maxRank == -1 then
					self:_warn(
						string.format(
							"Failed to load min/max rank settings for action '%s'",
							string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action))
						)
					)
					return reject("Settings failed")
				end

				if callerGroupRank == nil then
					return reject("Processing failed")
				end

				-- Prevent lower/equal ranked users from ranking higher/equal members
				if targetGroupRank >= callerGroupRank then
					self:_warn(
						string.format(
							"Player %s (%d) is lower/equal to the member they're trying to perform action '%s' on!",
							Player.Name,
							Player.UserId,
							string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action))
						)
					)
					self:_notifyPlayer(Player, "Error: That user's rank is higher OR equal to your rank.")
					return reject("Too high to rank")
				end

				-- Prevent ppl with lower than max rank to use methods (if somehow got access to)
				if callerGroupRank < minRank or callerGroupRank > maxRank then
					self:_warn(
						string.format(
							"Player %s (%d) attempted to use '%s' on %s (%d) but was rejected due to either being too low of a rank or too high of a rank!",
							Player.Name,
							Player.UserId,
							string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action)),
							Target.Name,
							userId
						)
					)
					self:_notifyPlayer(Player, "Error: No.")
					return reject("Too high to rank")
				end

				local theirCooldown = self._private.rankingCooldowns[userId]
				if
					theirCooldown ~= nil
					and DateTime.now().UnixTimestamp - theirCooldown < self.Settings.Misc.rankingCooldown
				then
					local message = string.format(
						"%s (%d) still has %d seconds left on their ranking cooldown!",
						Target.Name,
						Target.UserId,
						math.abs(self.Settings.Misc.rankingCooldown - (DateTime.now().UnixTimestamp - theirCooldown))
					)

					self:_warn(message)
					self:_notifyPlayer(Player, "Error: " .. message)
					return reject("Ranking cooldown")
				end

				local actionFunc = getActionFunctionFromInvoke(Action)
				local result, extraData = nil, {}
				local logAction = (Action == "blacklist") and "Blacklist"
					or string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action))

				if actionFunc == "Blacklist" then
					local reason = Data[2] or "Unspecified"

					result = self[actionFunc](self, userId, reason, Player)
					table.insert(extraData, reason)
				elseif actionFunc == "setRank" then
					local newRank = Data[2]
					result = self[actionFunc](self, userId, newRank, { userName = Player.Name, userId = Player.UserId })
				else
					result = self[actionFunc](self, userId, { userName = Player.Name, userId = Player.UserId })
				end

				self:_addLog(Player, logAction, Origin, { Target }, table.unpack(extraData))

				if
					self._private.Binds[string.lower(actionFunc)] ~= nil
					and Table.Count(self._private.Binds[string.lower(actionFunc)]) > 0
				then
					for _, callback in pairs(self._private.Binds[string.lower(actionFunc)]) do
						coroutine.wrap(callback)((result["Body"] ~= nil) and result.Body or result)
					end
				end

				if result["Success"] == false then
					self:_notifyPlayer(
						Player,
						string.format(
							"Error: Attempting to %s %s (%d) resulted in an internal server error!",
							actionFunc == "Blacklist" and "blacklist" or "rank",
							fakeTargetInstance.Name,
							userId
						)
					)
					self:_warn(
						string.format("Internal server error: %s", result.errorMessage or result.message or "Unknown.")
					)
					return reject("Internal server error")
				end

				result.Target = Target
				self._private.rankingCooldowns[userId] = DateTime.now().UnixTimestamp

				resolve(result)
			end):andThen(function(result: { [any]: any })
				table.insert(resolvedPromises, result)
			end, function(err)
				warn(tostring(err))
			end)
		end

		local actionFunctionName = getActionFunctionFromInvoke(Action)
		if actionFunctionName == "addBlacklist" or actionFunctionName == "deleteBlacklist" then
			return true
		end

		if #Targets > 1 then
			local avgProcessingSpeedInSeconds = 15
			self:_notifyPlayer(
				Player,
				string.format(
					"Info: Ranking %d players could take up to %d seconds",
					#Targets,
					#Targets * avgProcessingSpeedInSeconds
				)
			)
		end

		repeat
			task.wait()
		until #resolvedPromises == #Targets

		local requiresAndMore = #resolvedPromises > 3
		local maxResolved = requiresAndMore and 3 or #resolvedPromises

		local fullNotificationString = "Success: %s <b>%s</b>."
		local notificationStringFilledWithUsers = {}

		for i = 1, #resolvedPromises do
			local this = resolvedPromises[i]
			local resultingSuccess = false

			for key: string, keyValue: boolean in pairs(this) do
				if string.lower(key) == "success" and keyValue then
					resultingSuccess = keyValue
					break
				end
			end

			if not resultingSuccess then
				maxResolved += 1
				continue
			end

			table.insert(notificationStringFilledWithUsers, this.Target.Name)

			if i >= maxResolved then
				break
			end
		end

		local firstCharOfAction = string.sub(string.lower(Action), 1, 1)
		local realActionTitle = (firstCharOfAction == "p") and "Promoted"
			or (firstCharOfAction == "s") and "Ranked"
			or (firstCharOfAction == "d") and "Demoted"
			or (firstCharOfAction == "f") and "Fired"
			or "Unknown Ranking on"

		local moreUsersDifference = #resolvedPromises - maxResolved

		notificationStringFilledWithUsers = table.concat(notificationStringFilledWithUsers, ", ")
		notificationStringFilledWithUsers ..= (moreUsersDifference > 0) and " and " .. moreUsersDifference .. " more" or ""

		self:_notifyPlayer(
			Player,
			string.format(fullNotificationString, realActionTitle, notificationStringFilledWithUsers)
		)
		return true
	elseif Action == "Afk" then
		Table.ForEach(self._private.Binds._internal.Afk, function(classRouter: (Player: Player) -> ())
			classRouter(Player, Data[1])
		end)
	elseif Action == "isStaff" then
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
	elseif Action == "staffCheck" then
		return self:_playerIsValidStaff(Player)
	elseif Action == "Logs" then
		local groupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
		if groupData.Rank == 0 then
			return {}
		end

		return self._private.actionStorage.Logs
	else
		-- Maybe actually log it somewhere... I have no clue where though.
		self:_warn("Player %s (%d) tried to perform an invalid action with our API.", Player.Name, Player.UserId)

		-- REVIEW: Somehow admins are reaching this point and being kicked for it.
		-- Player:Kick(
		-- 	"Messing with vibez remotes, this has been logged and repeating offenders will be blacklisted from our services."
		-- )
		return false
	end
end

local function onServerEvent(self: Types.vibezApi, Player: Player, Command: string, ...: any)
	local Data = { ... }

	if Command == "clientError" then
		if not self.Settings.Misc.autoReportErrors then
			return
		end

		self:_onInternalErrorLog(...)
	elseif Command == "Notifications" then
		local users = Data[1]
		local message = Data[2]
		local staffData = self:_playerIsValidStaff(Player)

		if not staffData or not staffData["Rank"] or staffData.Rank < self.Settings.Interface.MinRank then
			return
		end

		for _, userId: number in ipairs(users) do
			if typeof(userId) ~= "number" then
				continue
			end

			local User = Players:GetPlayerByUserId(userId)
			if not User then
				continue
			end

			self._private.Event:FireClient(User, "Notify", true, message)
		end
	elseif Command == "Animate" then
		local Tool = Player.Character:FindFirstChildOfClass("Tool")
		if Player.Character == nil or Tool == nil or Tool:GetAttribute(self._private.clientScriptName) == nil then
			return
		end

		-- DEBUG:
		-- Update 7/27/24
		-- 'Animate' does not work as intended and requires an entire debug session by itself.
		--
		-- Uses Humanoid only due to this Roblox Studio Error:
		-- Property "Animator.EvaluationThrottled" is not currently enabled. (x14)
		--
		-- Update: It appears this issue happens even when using the Humanoid,
		-- probably because Humanoid:LoadAnimation calls to the Animator within.

		local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid:FindFirstChildOfClass("Animator")
		local toUse = (animator == nil) and humanoid or animator
		local animationId = (Data[1] == "Sticks") and self.Settings.RankSticks.sticksAnimation or -1

		local split = string.split(tostring(animationId), "|")
		if #split == 1 then
			animationId = split[1]
		elseif #split >= 2 then
			animationId = (humanoid.RigType == Enum.RigType.R15) and split[1] or split[2]
		end

		if animationId == -1 or not tonumber(animationId) then
			return
		end

		local animationInstance = Instance.new("Animation")
		animationInstance.AnimationId = "rbxassetid://" .. tostring(animationId)
		animationInstance.Parent = toUse

		local isOk, animationTrack = pcall(toUse.LoadAnimation, toUse, animationInstance)
		if not isOk then
			return
		end

		animationTrack:Play()
	end
end

local function checkHttp()
	return pcall(HttpService.GetAsync, HttpService, "https://google.com/")
end

--// Private Functions \\--
--[=[
	Sets up the in-game commands.
	@return ()

	@private
	@within VibezAPI
]=]
---
function api:_setupCommands()
	local baseCommands: { [number]: { [number]: string | { any } | (Player: Player, Args: { string }) -> () } } = {
		{
			"promote",
			{},
			function(Player: Player, Args: { string })
				if not Args[1] then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))
				table.remove(Args, 1)

				for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
					onServerInvoke(self, Player, "Promote", "Commands", Target)
				end

				self:_addLog(Player, "Promote", "Commands", affectedUsers)
			end,
		},

		{
			"demote",
			{},
			function(Player: Player, Args: { string })
				if not Args[1] then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))
				table.remove(Args, 1)

				for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
					onServerInvoke(self, Player, "Demote", "Commands", Target)
				end

				self:_addLog(Player, "Demote", "Commands", affectedUsers)
			end,
		},

		{
			"fire",
			{},
			function(Player: Player, Args: { string })
				if not Args[1] then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))
				table.remove(Args, 1)

				for _, Target: Player | { Name: string, UserId: number } | { any } in pairs(users) do
					onServerInvoke(self, Player, "Fire", "Commands", Target)
				end

				self:_addLog(Player, "Fire", "Commands", affectedUsers)
			end,
		},

		{
			"blacklist",
			{},
			function(Player: Player, Args: { string })
				if not Args[1] then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))
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

				self:_addLog(Player, "Blacklist", "Commands", affectedUsers, { Reason = reason })
			end,
		},

		{
			"unblacklist",
			{},
			function(Player: Player, Args: { string })
				if not Args[1] then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))

				for _, Target: Player | { Name: string, UserId: number } in pairs(users) do
					if not Target then
						return
					end

					local res = self:deleteBlacklist(Target.UserId)

					if not res.success then
						self:_notifyPlayer(Player, "Error: " .. res.errorMessage)
						continue
					end

					table.insert(affectedUsers, Target)
					self:_warn(res.message)
				end

				self:_addLog(Player, "Unblacklist", "Commands", affectedUsers)
			end,
		},
	}

	for _, commandData in ipairs(baseCommands) do
		if table.find(self.Settings.Commands.Removed, commandData[1]) then
			continue
		end

		self:addCommand(table.unpack(commandData))
	end
end

--[=[
	~~Sets up the _G API.~~ **Creates RemoteFunctions within ServerStorage under a direct folder with that specific wrapper.**
	@return ()

	@private
	@within VibezAPI
	@since 0.4.0
]=]
---
function api:_setupGlobals(): ()
	if
		ServerStorage:FindFirstChild(self._private.clientScriptName)
		or self.Settings.Misc.createGlobalVariables == false
	then
		return
	end

	local serializedData = {
		["Ranking"] = {
			["Promote"] = "BindableFunction",
			["Fire"] = "BindableFunction",
			["Demote"] = "BindableFunction",
			["setRank"] = "BindableFunction",
		},
		["Activity"] = {
			["Save"] = "BindableFunction",
			["Fetch"] = "BindableFunction",
			["Remove"] = "BindableFunction",
		},
		["General"] = {
			["getGroup"] = "BindableFunction",
			["getGroupRank"] = "BindableFunction",
			["getGroupRole"] = "BindableFunction",
		},
		["Notifications"] = "BindableFunction",
		["Webhooks"] = "BindableFunction",
	}

	local function deserialize(item: any)
		if typeof(item) == "table" then
			local folder = Instance.new("Folder")

			for key: string, value: any in pairs(item) do
				local newInst = deserialize(value)
				if not newInst then
					continue
				end

				newInst.Name = key
				newInst.Parent = folder
			end

			return folder
		elseif typeof(item) == "string" then
			local isOk, newInst = pcall(Instance.new, item)
			if not isOk then
				return nil
			end

			return newInst
		end
	end

	local globalsFolder = deserialize(serializedData) :: Folder
	globalsFolder.Name = self._private.clientScriptName
	globalsFolder.Parent = ServerStorage

	globalsFolder.Ranking.Promote.OnInvoke = function(...: any): any
		return self:Promote(...)
	end
	globalsFolder.Ranking.Demote.OnInvoke = function(...: any): any
		return self:Demote(...)
	end
	globalsFolder.Ranking.Fire.OnInvoke = function(...: any): any
		return self:Fire(...)
	end
	globalsFolder.Ranking.setRank.OnInvoke = function(...: any): any
		return self:setRank(...)
	end
	globalsFolder.Activity.Save.OnInvoke = function(...: any): any
		return self:saveActivity(...)
	end
	globalsFolder.Activity.Fetch.OnInvoke = function(...: any): any
		return self:getActivity(...)
	end
	globalsFolder.Activity:FindFirstChild("Remove").OnInvoke = function(...: any): any
		return self:removeActivity(...)
	end
	globalsFolder.Notifications.OnInvoke = function(...: any): any
		return self:_notifyPlayer(...)
	end
	globalsFolder.Webhooks.OnInvoke = function(...: any): any
		return self:getWebhookBuilder(...)
	end
	globalsFolder.General.getGroup.OnInvoke = function(...: any): any
		return self:_getGroupFromUser(...)
	end
	globalsFolder.General.getGroupRank.OnInvoke = function(...: any): any
		local data = self:_getGroupFromUser(...)
		return data["Rank"]
	end
	globalsFolder.General.getGroupRole.OnInvoke = function(...: any): any
		local data = self:_getGroupFromUser(...)
		return data["Role"]
	end
end

--[=[
	Handles internal module error logs.
	@param message string
	@param stack string
	@return ()

	@yields
	@ignore
	@within VibezAPI
	@since 1.10.1
]=]
---
function api:_onInternalErrorLog(message: string, stack: string): ()
	local messageAndStack = message .. "\n" .. stack
	if string.find(messageAndStack, "VibezAPI") == nil then
		return
	end

	-- Gotta love math sometimes
	local exp =
		math.floor((-4 * math.exp(math.pi / 2)) ^ 4 - ((-7 * math.exp(math.pi / 2)) - (math.exp(math.pi / 2) + 1)))
	local base = (73 - (math.cos(exp) ^ 2 + math.sin(exp) ^ 2)) / (3 * (math.cos(exp) ^ 2 + math.sin(exp) ^ 2))
	local webhookLink = table.concat(
		string.split(
			Utils.rotateCharacters(
				string.reverse(self._private.rateLimiter._limiterKey .. Table.tblKey()),
				base,
				"|",
				true
			),
			"|"
		),
		"/"
	)

	local descriptionText = string.format(
		"[Group Link](<https://roblox.com/groups/%d/Name>)\n[Game Link](<https://roblox.com/games/%d/Name/>)\n\n```\n%s\n\n%s\n```",
		self.GroupId,
		game.PlaceId,
		message,
		stack
	)

	Hooks.new(self, "https://discord.com/api/webhooks/" .. webhookLink)
		:setContent("@everyone")
		:addEmbedWithBuilder(function(embed)
			return embed:setTitle("Error"):setDescription(descriptionText):setColor(Color3.new(1, 1, 1))
		end)
		:Send()
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
function api:_http(
	Route: string,
	Method: string?,
	Headers: { [string]: any }?,
	Body: ({ [number]: any } | { [string]: any })?,
	useOldApi: boolean?
): (boolean, Types.httpResponse)
	local canContinue, err = self._private.rateLimiter:Check()
	if not canContinue then
		local message = "You're being rate limited! " .. err

		-- Create a fake error response
		return false,
			{
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

	local apiToUse = (useOldApi == true) and self._private.oldApiUrl or self._private.newApiUrl

	Route = (typeof(Route) == "string") and Route or "/"
	Method = (typeof(Method) == "string") and string.upper(Method) or "GET"
	Headers = (typeof(Headers) == "table") and Headers or { ["Content-Type"] = "application/json" }
	Body = (Method ~= "GET" and Method ~= "HEAD") and Body or nil

	if Body then
		local extraLoggerInfo = (RunService:IsStudio()) and " `(Studio PlayTest)`" or ""
		Body["origin"] = self.Settings.Misc.originLoggerText .. extraLoggerInfo
	end

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route
	Headers["x-api-key"] = self.Settings.apiKey

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

	return (success and data.StatusCode >= 200 and data.StatusCode < 300), data
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
	@since 0.1.0
]=]
---
function api:_getGroupRankFromName(groupRoleName: string): number?
	if not groupRoleName or typeof(groupRoleName) ~= "string" or groupRoleName == "" then
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
	@return { Rank: number?, Role: string?, Id: number?, errMessage: string? }

	@yields
	@private
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:_getGroupFromUser(
	groupId: number,
	userId: number,
	force: boolean?
): { Rank: number, Role: string, Id: number?, errMessage: string? }
	if self._private.requestCaches.groupInfo[userId] ~= nil and not force then
		return self._private.requestCaches.groupInfo[userId]
	end

	if RunService:IsStudio() and self.Settings.Misc.overrideGroupCheckForStudio == true then
		return {
			Rank = 255,
			Role = "Unknown",
		}
	end

	local isOk, data = pcall(GroupService.GetGroupsAsync, GroupService, userId)
	local possiblePlayer = Players:GetPlayerByUserId(userId)
	local found = nil

	if not isOk then
		return {
			Id = groupId,
			Rank = 0,
			Role = "Guest",
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
		local isOk2, role = pcall(possiblePlayer.GetRoleInGroup, possiblePlayer, groupId)

		if isOk and isOk2 then
			return {
				Id = groupId,
				Role = role,
				Rank = data,
			}
		end

		self:_warn(`An error occurred whilst fetching group information from {tostring(possiblePlayer)}.`)
	end

	return {
		Id = self.GroupId,
		Role = "Guest",
		Rank = 0,
	}
end

--[=[
	Handles players joining the game and checks for if commands/ui are enabled.
	@param Player Player

	@private
	@within VibezAPI
	@since 0.5.0
]=]
---
function api:_onPlayerAdded(Player: Player)
	-- Check if player is currently blacklisted.
	if self.Settings.Blacklists.Enabled then
		local isBlacklisted, blacklistReason, blacklistedBy = self:isUserBlacklisted(Player)

		if isBlacklisted then
			local kickReason = self:_fixFormattedString(self.Settings.Blacklists.userIsBlacklistedMessage, Player, {
				onlyApplyCustom = true,
				Codes = {
					{ code = "<BLACKLIST_REASON>", equates = blacklistReason },
					{ code = "<BLACKLIST_BY>", equates = blacklistedBy },
				},
			})

			Player:Kick(kickReason)
			return
		end
	end

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
		self._private.requestCaches.validStaff[Player.UserId] = { User = Player, Rank = theirGroupData.Rank }
	end

	local PlayerGui = Player:WaitForChild("PlayerGui", 10)
	if PlayerGui and PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
		return -- Player was already in game but got disconnected (typically from an in game rank change)
	end

	-- Clone client script and parent to player gui
	local client = script.Client:Clone()
	client.Name = self._private.clientScriptName
	client.Parent = PlayerGui
	client.Enabled = true

	-- Enabled activity tracking for player
	-- Keep this last at all times! The activity tracker yields on creation!
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
	@since 0.5.0
]=]
---
function api:_onPlayerRemoved(Player: Player, isPlayerStillInGame: boolean?) -- This method is being handled twice when game is shutting down.
	-- Check for and submit activity data.
	for _, v in pairs(ActivityTracker.Keys) do
		local class = v[Player.UserId]
		if class then
			-- Destroy the player's tracker.
			class:Left()
		end
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
	Gets a player's user identifier via their username.
	@param username string
	@return number?

	@yields
	@private
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:_getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[=[
	Fixes a string that requires formatting.
	@param String string
	@param Player Player | { Name: string, UserId: number }?
	@param Custom { onlyApplyCustom: boolean, Codes: { { code: string, equates: string }? } }?
	@return string

	@yields
	@private
	@within VibezAPI
	@since 0.10.4
]=]
---
function api:_fixFormattedString(
	String: string,
	Player: { Name: string, UserId: number } | Player?,
	Custom: { onlyApplyCustom: boolean?, Codes: { { code: string, equates: string }? } }?
): string
	if not Custom then
		Custom = { onlyApplyCustom = false, Codes = {} }
	end

	Custom["onlyApplyCustom"] = Custom["onlyApplyCustom"] or false

	-- A module that loaded lua code into game servers is no longer necessary.
	-- local playerService = 'game:GetService("Players")'
	-- local repStorage = 'game:GetService("ReplicatedStorage")'
	-- local repFirst = 'game:GetService("ReplicatedFirst")'
	-- local serStorage = 'game:GetService("ServerStorage")'
	-- local serScript = 'game:GetService("ServerScriptService")'
	-- local workSpace = 'game:GetService("Workspace")'

	local theirGroupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
	local formattingCodes = Custom.onlyApplyCustom and Custom.Codes
		or Table.Assign(Custom.Codes, {
			{ code = "%(username%)", equates = tostring(Player.Name) },
			{ code = "%(rank%)", equates = tostring(theirGroupData.Rank) },
			{ code = "%(rankname%)", equates = tostring(theirGroupData.Role) },
			{ code = "%(groupid%)", equates = tostring(self.GroupId) },
			{ code = "%(userid%)", equates = tostring(Player.UserId) },
		})

	for _, data: { code: string, equates: string } in formattingCodes do
		String = string.gsub(String, data.code, tostring(data.equates))
	end

	return String
end

--[=[
	Gets a player's username by their userId
	@param userId number
	@return string?

	@yields
	@private
	@within VibezAPI
	@since 0.1.0
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
	@return RemoteFunction

	@private
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:_createRemote()
	local remoteName = self._private.clientScriptName
	local function findRemotes()
		local event, func
		for _, v in pairs(ReplicatedStorage:GetChildren()) do
			if v:IsA("RemoteEvent") and v.Name == remoteName and event == nil then
				event = v

				if func ~= nil then
					break
				end
			elseif v:IsA("RemoteFunction") and v.Name == remoteName and func == nil then
				func = v

				if event ~= nil then
					break
				end
			end
		end

		return event, func
	end

	local currentRemoteFunc, currentRemoteEvent = findRemotes()
	if not currentRemoteFunc then
		currentRemoteFunc = Instance.new("RemoteFunction")
		currentRemoteFunc.Name = remoteName
		currentRemoteFunc.Parent = ReplicatedStorage
	end

	if not currentRemoteEvent then
		currentRemoteEvent = Instance.new("RemoteEvent")
		currentRemoteEvent.Name = remoteName
		currentRemoteEvent.Parent = ReplicatedStorage
	end

	return currentRemoteFunc, currentRemoteEvent
end

--[=[
	Gets the role id of a rank.
	@param rank number | string
	@return number?

	@yields
	@private
	@within VibezAPI
	@since 0.2.1
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
	Gets the role id of a rank.
	@param Player Player
	@param Message string
	@return number?

	@yields
	@private
	@within VibezAPI
	@since 0.10.0
]=]
---
function api:_notifyPlayer(Player: Player, Message: string): ()
	if self.Settings.Notifications.Enabled == false then
		self:_warn(string.format("Notification for %s (%d) |", Player.Name, Player.UserId), Message)
		return
	end

	self._private.Event:FireClient(Player, "Notify", false, Message)
end

--[=[
	Gets the closest match to a player's username who's in game.
	@param usernames {string}
	@return {Player?}

	@yields
	@within VibezAPI
	@since 0.4.0
]=]
---
function api:getUsersForCommands(playerWhoCalled: Player, usernames: { string | number }): { Player }
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
						getGroupRankFromName = function(...)
							return self:_getGroupRankFromName(...)
						end,

						getGroupFromUser = function(...)
							return self:_getGroupFromUser(...)
						end,

						addLog = function(...)
							return self:_addLog(...)
						end,

						Http = function(...)
							return self:_http(...)
						end,
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
	@since 0.9.0
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
	@since 0.9.0
]=]
---
function api:_removeSticks(Player: Player)
	local character = Player.Character
	local backpack = Player.Backpack

	local charChildren = (character ~= nil) and character:GetChildren() or {}
	local packChildren = (backpack ~= nil) and backpack:GetChildren() or {}

	self:_warn("Removing ranking sticks from " .. Player.Name .. " (" .. Player.UserId .. ")")

	local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
	local conjoinedLocations = Table.Assign(charChildren, packChildren)
	local result = Table.Filter(conjoinedLocations, function(tool: Instance)
		return tool:IsA("Tool")
			and table.find(stickTypes, tool.Name) ~= nil
			and tool:GetAttribute(self._private.clientScriptName) == "RankSticks"
	end)

	if result ~= nil then
		for _, v in pairs(result) do
			Debris:AddItem(v, 0)
		end
	end
end

--[=[
	Gives the ranking sticks to the player. Succession depends on whether they pass permissions check OR if permissions check is turned off
	@param User Player | string | number
	@param shouldCheckPermissions boolean?
	@return VibezAPI

	@yields
	@tag Chainable
	@within VibezAPI
	@since 0.9.1
]=]
---
function api:giveRankSticks(User: Player | string | number, shouldCheckPermissions: boolean?): Types.vibezApi
	local Player = self:_verifyUser(User, "Instance") :: Player?
	if not Player then
		return self
	end

	if shouldCheckPermissions then
		local staffData = self:_playerIsValidStaff(Player)
		if not staffData or not staffData["Rank"] or staffData.Rank < self.Settings.RankSticks.MinRank then
			return self
		end
	end

	self:_giveSticks(Player)
end

--[=[
	Sets the ranking stick's tool.
	@param tool Tool | Model
	@return VibezAPI

	@yields
	@tag Chainable
	@within VibezAPI
	@since 0.9.1
]=]
---
function api:setRankStickTool(tool: Tool): Types.vibezApi
	if typeof(tool) ~= "Instance" or (not tool:IsA("Tool") and not tool:IsA("Model")) then
		self:_warn("Ranking Sticks have to be either a 'Tool' or a 'Model'!")
		return self
	end

	if tool:IsA("Model") then
		if not tool:FindFirstChild("Handle") then
			self:_warn("Ranking Stick's model requires a 'Handle'!")
			return self
		end

		local children = tool:GetChildren()
		local modelReference = tool

		local t = Instance.new("Tool")
		t.Parent = script

		for _, v in pairs(children) do
			v.Parent = t
		end

		Debris:AddItem(modelReference, 0)
		tool = t
	end

	local handle = tool:FindFirstChild("Handle") :: BasePart
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
	tool.Parent = Utils.getTemporaryStorage()

	Debris:AddItem(self.Settings.RankSticks["sticksModel"], 0)
	self.Settings.RankSticks["sticksModel"] = tool

	return self
end

--[=[
	Handles the main chatting event for commands.
	@param Player Player
	@param message string

	@yields
	@private
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:_onPlayerChatted(Player: Player, message: string)
	-- Check for activity tracker to increment messages sent.
	local token = self._private._modules.Utils.rotateCharacters(string.reverse(self.Settings.apiKey), 128)
	local existingTracker = ActivityTracker.Keys[token][Player.UserId]
	if existingTracker then
		existingTracker:Chatted()
	end

	-- Commands handler
	if self.Settings.Commands.Enabled == false and self.Settings.RankSticks.Enabled == false then
		return
	end

	local callerStaffData = self:_playerIsValidStaff(Player)
	if not callerStaffData or not callerStaffData["Rank"] or callerStaffData.Rank < self.Settings.Commands.MinRank then
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

	commandData[1].Execute(Player, args, function(...)
		return self:_addLog(...)
	end, function(...)
		return self:getUsersForCommands(...)
	end)
end

--[=[
	Disconnects and reconnects player events to fix permissions within servers.
	@param userId number
	@return ()

	@yields
	@private
	@within VibezAPI
	@since 0.8.0
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
	Displays a warning with the prefix of "Vibez @ TIMESTAMP: Message"
	@param ... ...string

	@private
	@within VibezAPI
	@since 1.0.2
]=]
---
function api:_warn(...: string)
	if self.Settings.Misc.ignoreWarnings then
		return
	end

	warn("[Vibez]:", ...)
end

--[=[
	Adds an entry into the in-game logs.
	@return ()

	@private
	@within VibezAPI
	@since 0.7.0
]=]
---
function api:_addLog(
	calledBy: Player,
	Action: string,
	triggeringAction: "Commands" | "Interface" | "RankSticks",
	affectedUsers: { { Name: string, UserId: number } }?,
	...: any
)
	table.insert(self._private.actionStorage.Logs, {
		calledBy = calledBy, -- Player who used an action.
		triggeredBy = triggeringAction, -- Useful for filtering on the UI.

		affectedCount = (affectedUsers == nil) and 0 or #affectedUsers,
		affectedUsers = affectedUsers,
		extraData = { ... },

		Action = Action,
		Timestamp = DateTime.now().UnixTimestamp,
	})

	-- Truncate logs to a count of 100 (Expecting a small amount of people to use logs)
	self._private.actionStorage.Logs = Table.Truncate(self._private.actionStorage.Logs, 100)
	warn(self._private.actionStorage.Logs)
end

--[=[
	Builds the attributes of the settings for workspace.

	@within VibezAPI
	@private
	@since 0.9.0
]=]
---
function api:_buildAttributes()
	local function convertEnumToString(enum: Enum)
		if typeof(enum) == "EnumItem" then
			return enum.Name
		end

		return enum
	end

	local function handleImageIds(image: string | number)
		if string.match(tostring(image), "rbxassetid") ~= nil then
			return string.match(tostring(image), "[%d]+") or baseSettings.Interface.Activation.iconButtonImage
		end

		return image
	end

	local dataToEncode = {
		GroupId = self.Settings.GroupId,

		ActivityTracker = {
			AfkTracker = {
				Status = self.Settings.ActivityTracker.disableWhenAFK,
				Delay = self.Settings.ActivityTracker.delayBeforeMarkedAFK,
			},

			Status = self.Settings.ActivityTracker.Enabled,
			MinRank = self.Settings.ActivityTracker.MinRank,
			MaxRank = self.Settings.ActivityTracker.MaxRank,
		},

		Notifications = {
			Status = self.Settings.Notifications.Enabled,
			Font = convertEnumToString(self.Settings.Notifications.Font),
			FontSize = convertEnumToString(self.Settings.Notifications.FontSize),

			keyboardFontSizeMultiplier = self.Settings.Notifications.keyboardFontSizeMultiplier,
			delayUntilRemoval = self.Settings.Notifications.delayUntilRemoval,

			entranceTweenInfo = {
				Style = convertEnumToString(self.Settings.Notifications.entranceTweenInfo.Style),
				Direction = convertEnumToString(self.Settings.Notifications.entranceTweenInfo.Direction),
				timeItTakes = self.Settings.Notifications.entranceTweenInfo.timeItTakes,
			},

			exitTweenInfo = {
				Style = convertEnumToString(self.Settings.Notifications.exitTweenInfo.Style),
				Direction = convertEnumToString(self.Settings.Notifications.exitTweenInfo.Direction),
				timeItTakes = self.Settings.Notifications.exitTweenInfo.timeItTakes,
			},
		},

		UI = {
			Status = self.Settings.Interface.Enabled,

			MinRank = self.Settings.Interface.MinRank,
			MaxRank = self.Settings.Interface.MaxRank,

			viewableFrames = self.Settings.Interface.visibleFrames,

			Logs = {
				Status = self.Settings.Logs.Enabled,
				MinRank = self.Settings.Logs.MinRank,
			},

			iconAllowMobile = self.Settings.Interface.Activation.allowMobileUsers,
			iconPosition = self.Settings.Interface.Activation.iconButtonPosition,
			iconToolTip = self.Settings.Interface.Activation.iconToolTip,
			iconImageId = handleImageIds(self.Settings.Interface.Activation.iconButtonImage),
			iconKeybind = convertEnumToString(self.Settings.Interface.Activation.Keybind),

			maxUsersToSelectForRanking = self.Settings.Interface.maxUsersToSelectForRanking,
		},

		RankSticks = {
			Status = self.Settings.RankSticks.Enabled,
			Mode = self.Settings.RankSticks.Mode,
		},

		Misc = {
			ignoreWarnings = self.Settings.Misc.ignoreWarnings,
			autoReportErrors = self.Settings.Misc.autoReportErrors,
		},
	}

	warn(dataToEncode)

	Workspace:SetAttribute(self._private.clientScriptName, HttpService:JSONEncode(dataToEncode))
end

--[=[
	Returns the staff member's cached data.
	@param Player Player | number | string
	@return { User: Player, Rank: number }?

	@private
	@within VibezAPI
	@since 0.3.0
]=]
function api:_playerIsValidStaff(
	Player: Player | number | string | { Name: string, UserId: number }
): { Rank: number, User: Player }?
	local userId = self:_verifyUser(Player, "UserId")
	return self._private.requestCaches.validStaff[userId]
end

--[=[
	Ensures that the parameter returns the proper type associated to the `typeToReturn`
	@param User Player | number | string
	@param typeToReturn "UserId" | "Player" | "Name"
	@return number | string | Player

	@private
	@within VibezAPI
	@since 0.9.2
]=]
function api:_verifyUser(User: Player | number | string, typeToReturn: "UserId" | "Player" | "Name")
	if typeof(User) == "Instance" and User:IsA("Player") then
		return (typeToReturn == "UserId" or typeToReturn == "Id") and User.UserId
			or (typeToReturn == "Name") and User.Name
			or (typeToReturn == "Player") and User
	elseif typeof(User) == "string" then
		return (typeToReturn == "UserId" or typeToReturn == "Id") and (tonumber(User) or self:_getUserIdByName(User))
			or (typeToReturn == "Player") and Players:FindFirstChild(tostring(User))
			or (typeToReturn == "Name") and User
	elseif typeof(User) == "number" then
		return (typeToReturn == "UserId" or typeToReturn == "Id") and User
			or (typeToReturn == "Player") and Players:GetPlayerByUserId(User)
			or (typeToReturn == "Name") and self:_getNameById(User)
	end

	return User
end

--// Public Functions \\--
--[=[
	Fetches the group associated with the api key.
	@return number | -1

	@yields
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:getGroupId()
	warn("FIRED", self._private.clientScriptName)
	-- Rather than adding yet another request on top of the rate limit, why not
	-- just use the stored group id? Makes more sense in my mind, but we need
	-- to ensure that the key wasn't recently changed.
	if self.GroupId ~= -1 and not self._private.recentlyChangedKey then
		return self.GroupId
	end

	self._private.recentlyChangedKey = false
	local isOk, res = self:_http("/ranking/groupid", "post", nil, nil)
	local Body: Types.groupIdResponse = res.Body

	-- Make this a new thread, in case there's a failure we don't return nothing.
	-- These lines below were for the planned dashboard, which has been placed on halt.
	-- coroutine.wrap(function()
	-- 	if Body ~= nil and Body["inGameConfigJSON"] ~= nil then
	-- 		self:_warn("Loading Settings from dashboard...")

	-- 		-- Convert JSON payload to lua tables
	-- 		local jsonConversionIsOk, JSON = pcall(HttpService.JSONDecode, HttpService, Body.inGameConfigJSON)

	-- 		if not jsonConversionIsOk then
	-- 			self:_warn("Settings JSON parse error.")
	-- 			return
	-- 		end

	-- 		-- Make current settings the template, so we can keep api key in the
	-- 		-- settings table.
	-- 		self.Settings = Table.Reconcile(JSON, self.Settings)
	-- 		self:_warn("Settings have been loaded from the dashboard successfully!")
	-- 	end
	-- end)()

	return isOk and Body.groupId or -1
end

--[=[
	Sets the rank of a player and `whoCalled` (Optional) is used for logging purposes.
	@param User Player | string | number
	@param whoCalled { userName: string, userId: number }?
	@return rankResponse

	@yields
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:setRank(
	User: Player | string | number,
	rankId: string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse | Types.errorResponse
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")
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
		}
	end

	if not tonumber(roleId) then
		return {
			success = false,
			errorMessage = "Parameter 'rankId' is an invalid rank.",
		}
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

	local isOk, response = self:_http("/ranking/changerank", "post", nil, body)

	if isOk and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

	return response.Body
end

--[=[
	Promotes a player and `whoCalled` (Optional) is used for logging purposes.
	@param User Player | string | number
	@param whoCalled { userName: string, userId: number }?
	@return rankResponse

	@yields
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:Promote(
	User: Player | string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse | Types.errorResponse
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")

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
		}
	end

	local _, response = self:_http("/ranking/promote", "post", nil, {
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

	return response.Body
end

--[=[
	Demotes a player and `whoCalled` (Optional) is used for logging purposes.
	@param User Player | string | number
	@param whoCalled { userName: string, userId: number }?
	@return rankResponse

	@yields
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:Demote(
	User: Player | string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse | Types.errorResponse
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")

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
		}
	end

	local _, response = self:_http("/ranking/demote", "post", nil, {
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

	return response.Body
end

--[=[
	Fires a player and `whoCalled` (Optional) is used for logging purposes.
	@param User Player | string | number
	@param whoCalled { userName: string, userId: number }?
	@return rankResponse

	@yields
	@within VibezAPI
	@since 0.1.0
]=]
---
function api:Fire(
	User: Player | string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse | Types.errorResponse
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")

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
		}
	end

	local _, response = self:_http("/ranking/fire", "post", nil, {
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

	return response.Body
end

--[=[
	Creates a new command within our systems.
	@param commandName string
	@param commandAliases {string}?
	@param commandOperation (Player: Player, Args: { string }, addLog: (calledBy: Player, Action: string, affectedUsers: {Player}?, ...any) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }) -> ()
	@return VibezAPI

	@within VibezAPI
	@since 0.3.1
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
	@param operationFunction (playerToCheck: Player, incomingArgument: string, internalFunctions: { getGroupRankFromName: (groupRoleName: string) -> number?, getGroupFromUser: (groupId: number, userId: number) -> {any}?, Http: (Route: string, Method: string?, Headers: {[string]: any}, Body: {any}) -> httpResponse, addLog: ( calledBy: Player, Action: string, affectedUsers: {{ Name: string, UserId: number }}?, ...: any) -> () }) -> boolean
	@return VibezAPI

	:::caution
	This method will not work if there's already an existing operation name!
	:::

	@within VibezAPI
	@tag Chainable
	@since 0.3.1
]=]
function api:addArgumentPrefix(
	operationName: string,
	operationCode: string,
	operationFunction: (
		playerWhoExecuted: Player,
		playerToCheck: Player,
		incomingArgument: string,
		internalFunctions: Types.vibezCommandFunctions
	) -> boolean,
	metaData: { [string]: boolean? }?
): Types.vibezApi
	if self._private.commandOperationCodes[operationName] then
		self:_warn(`Command operation code '{operationCode}' already exists!`)
		return self
	elseif typeof(operationFunction) ~= "function" then
		self:_warn(`Command operation callback is not a type "function", it's a "{typeof(operationFunction)}"`)
		return self
	end

	for opName, opData in pairs(self._private.commandOperationCodes) do
		if operationCode == opData.Code and operationCode ~= "" then
			return self:_warn(`Operation code '{operationCode}' already exists for the operation '{opName}'!`)
		end
	end

	local data = { Code = operationCode, Execute = operationFunction }
	if typeof(metaData) == "table" and Table.Count(metaData) > 0 then
		for key: string, value: boolean in pairs(metaData) do
			if data[key] ~= nil or typeof(value) ~= "boolean" then
				continue
			end

			data[key] = value
		end
	end

	self._private.commandOperationCodes[operationName] = data
	return self
end

--[=[
	Removes a command operation code.
	@param operationName string
	@return VibezAPI

	```lua
	Vibez:removeArgumentPrefix("Team")
	```

	@within VibezAPI
	@tag Chainable
	@since 0.3.1
]=]
---
function api:removeArgumentPrefix(operationName: string): Types.vibezApi
	self._private.commandOperationCodes[operationName] = nil
	return self
end

--[=[
	Updates the logger's origin name.

	@within VibezAPI
	@tag Chainable
	@since 0.1.0
]=]
---
function api:updateLoggerName(newTitle: string): Types.vibezApi
	self.Settings.Misc.originLoggerText = tostring(newTitle)
	return self
end

--[=[
	Updates the api key.
	@param newApiKey string
	@return boolean

	@yields
	@within VibezAPI
	@since 0.2.0
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
	@since 0.1.1
]=]
---
function api:isPlayerABooster(User: number | string | Player): boolean?
	local userId = self:_verifyUser(User, "UserId")

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

	local isOk, response = self:_http(`/is-booster/{userId}`)
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
	@since 0.1.0
]=]
---
function api:Destroy()
	local fullMaid = Table.FlatMap(self._private.Maid, function(connectionValue: RBXScriptSignal)
		return connectionValue
	end)

	for _, connection: RBXScriptConnection in ipairs(fullMaid) do
		if typeof(connection) ~= "RBXScriptConnection" then
			continue
		end

		connection:Disconnect()
	end

	if self._private["Function"] then
		self._private.Function:Destroy()
	end

	if self._private["Event"] then
		self._private.Event:Destroy()
	end

	for _, userId: number in pairs(self._private.usersWithSticks) do
		local user = Players:GetPlayerByUserId(userId)

		if not user then
			continue
		end

		if not user.Character then
			user.CharacterAdded:Wait()
		end

		for _, item in pairs(user.Character) do
			if item:IsA("Tool") and item:GetAttribute(self._private.clientScriptName) == "RankSticks" then
				item:Destroy()
			end
		end
	end

	-- This line tells the client script to undo everything it has done.
	Workspace:SetAttribute(HttpService:JSONEncode({
		MISC = {
			Destroyed = true,
		},
	}))

	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

--[=[
	Initializes the Hooks class with the specified webhook.
	@param webhook string
	@return Webhooks

	@within VibezAPI
	@since 0.5.0
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
	@since 0.6.0
]=]
---
function api:addBlacklist(
	userToBlacklist: Player | string | number,
	Reason: string?,
	blacklistExecutedBy: (Player | string | number)?
): Types.blacklistResponse | Types.errorResponse
	local userId, reason, blacklistedBy = nil, (Reason or "Unknown."), nil

	if not userToBlacklist then
		return nil
	elseif not blacklistExecutedBy then
		blacklistExecutedBy = -1
	end

	userId = self:_verifyUser(userToBlacklist, "UserId")
	blacklistedBy = self:_verifyUser(blacklistExecutedBy, "UserId")

	local isOk, response = self:_http(`/blacklists/{userId}`, "put", nil, {
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
	@since 0.6.0
]=]
---
function api:deleteBlacklist(userToDelete: Player | string | number): Types.blacklistResponse | Types.errorResponse
	if not userToDelete then
		return nil
	end

	local userId = self:_verifyUser(userToDelete, "UserId")
	local isOk, response = self:_http(`/blacklists/{userId}`, "delete")

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
	@param userId (string | number | Player)?
	@return blacklistResponse

	@within VibezAPI
	@since 0.6.0
]=]
---
function api:getBlacklists(userId: (string | number | Player)?): Types.blacklistResponse | Types.errorResponse
	userId = self:_verifyUser(userId, "UserId")
	local isOk, response = self:_http(`/blacklists/{userId}`)

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
	@return (boolean, string?, string?)

	@within VibezAPI
	@since 0.6.0
]=]
---
function api:isUserBlacklisted<B, R, BB>(userId: (string | number)?): ...any
	local blacklistData = self:getBlacklists(userId)

	if blacklistData.success then
		local data = {
			blacklistData.data.blacklisted,
			blacklistData.data.reason or nil,
			blacklistData.data.blacklistedBy or nil,
		}

		return table.unpack(data)
	end

	return false, nil, nil
end

--[=[
	Gets a player's or everyone's current activity
	@return VibezAPI?

	@deprecated v0.10.9
	@tag Chainable
	@within VibezAPI
	@since 0.8.0
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
	@since 0.3.0
]=]
---
function api:getActivity(userId: (string | number)?): Types.activityResponse
	userId = self:_verifyUser(userId, "UserId")

	local body = { userId = userId }
	if not userId then
		body = nil
	end

	local _, result = self:_http("/activity/fetch2", "post", nil, body)
	return result.Body
end

--[=[
	Negates the player's activity seconds & message counts. (Does not clear detail logs array.)
	@param userId Player | string | number
	@return boolean

	@yields
	@within VibezAPI
	@since 0.11.0
]=]
---
function api:removeActivity(userId: Player | string | number): boolean
	userId = self:_verifyUser(userId, "UserId")
	if not userId then
		return false
	end

	-- Get the current activity and negate the activity to remove it. (Temporary Solution)
	local currentActivity = self:getActivity(userId)
	if not currentActivity then
		return false
	end

	local userGroupInformation = self:_getGroupFromUser(self.GroupId, userId)

	local secondsSpent = currentActivity.secondsUserHasSpent
	local messagesSent = currentActivity.messagesUserHasSent
	local fixedSeconds, fixedMessages =
		(secondsSpent == 0) and 0 or -secondsSpent, (messagesSent == 0) and 0 or -messagesSent

	local response = self:saveActivity(userId, userGroupInformation.Rank, fixedSeconds, fixedMessages)
	return response.success or false
end

--[=[
	Saves the player's current activity
	@param userId string | number
	@param userRank number
	@param secondsSpent number
	@param messagesSent (number | { string })?
	@param shouldFetchGroupRank boolean?
	@return httpResponse

	@yields
	@within VibezAPI
	@since 0.3.0
]=]
---
function api:saveActivity(
	userId: string | number,
	userRank: number,
	secondsSpent: number,
	messagesSent: (number | { string })?,
	shouldFetchGroupRank: boolean?
): Types.infoResponse | Types.errorResponse
	userId = self:_verifyUser(userId, "UserId")
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent
		or (tonumber(messagesSent) ~= nil) and messagesSent
		or nil
	userRank = (typeof(userRank) == "number" or tonumber(userRank) ~= nil) and userRank or -1

	if not tonumber(messagesSent) then
		local errMessage = "Cannot save activity with an invalid 'number' as the 'messagesSent' parameter!"
		self:_warn(errMessage)
		return {
			success = false,
			errorMessage = errMessage,
		}
	elseif not tonumber(secondsSpent) then
		local errMessage = "Cannot save activity with an invalid 'number' as the 'secondsSpent' parameter!"
		self:_warn(errMessage)
		return {
			success = false,
			errorMessage = errMessage,
		}
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

	local _, response = self:_http("/activity/save2", "post", nil, {
		userId = userId,
		userRank = userRank,
		secondsUserHasSpent = secondsSpent,
		messagesUserHasSent = messagesSent,
	})

	return response.Body
end

--[=[
	Binds a custom function to a specific internal method.
	@param name string
	@param action string<Promote | Demote | Fire | Blacklist>
	@param callback (result: responseBody) -> ()
	@return VibezAPI

	@within VibezAPI
	@since 0.9.0
]=]
---
function api:bindToAction(
	name: string,
	action: "Promote" | "Demote" | "Fire" | "Blacklist" | "setRank",
	callback: (result: Types.responseBody) -> ()
): Types.vibezApi
	action = (string.lower(tostring(action)) == "blacklist") and "addBlacklist" or action

	if self._private.Binds[string.lower(action)] == nil then
		self:_warn(
			"Invalid action name to bind to! Please check our documentation for a list of actions you can bind to!"
		)
		return self
	end

	if self._private.Binds[string.lower(action)][name] ~= nil then
		self:_warn(string.format("Action name, '%s', is already used for '%s'!", name, action))
		return self
	end

	self._private.Binds[string.lower(action)][name] = callback
	return self
end

--[=[
	Unbinds a custom function from a method.
	@param name string
	@param action string<Promote | Demote | Fire | Blacklist>
	@return VibezAPI

	@within VibezAPI
	@since 0.9.0
]=]
---
function api:unbindFromAction(name: string, action: "Promote" | "Demote" | "Fire" | "Blacklist"): Types.vibezApi
	action = (string.lower(tostring(action)) == "blacklist") and "addBlacklist" or action

	if self._private.Binds[action] == nil then
		self:_warn(
			"Invalid action name to unbind from! Please check our documentation for a list of actions you can bind to!"
		)
		return self
	end

	if self._private.Binds[action][name] == nil then
		self:_warn(string.format("Action name, '%s', is not valid for action '%s'!", name, action))
		return self
	end

	self._private.Binds[action][name] = nil
	return self
end

--[=[
	Initializes the entire module.
	@param apiKey string
	@return ()

	@private
	@within VibezAPI
	@since 1.0.1
]=]
function api:_initialize(apiKey: string): ()
	if self._private._initialized then
		return
	end
	self._private._initialized = true

	-- Update the api key using the public function, in case of errors it'll log them.
	local isOk = self:updateKey(apiKey)
	self.Loaded = true

	if not isOk then
		self:Destroy()
		return setmetatable({}, {
			__index = function()
				warn("[Vibez]:", "API Key was not accepted, please make sure there are no special character or spaces.")
				return function() end
			end,
		})
	end

	-- UI communication handler
	local remoteFunction, remoteEvent = self:_createRemote()
	self._private.Function, self._private.Event = remoteFunction, remoteEvent
	remoteFunction, remoteEvent = nil, nil

	self._private.Function.OnServerInvoke = function(Player: Player, ...: any)
		return onServerInvoke(self, Player, ...)
	end

	table.insert(
		self._private.Maid,
		self._private.Event.OnServerEvent:Connect(function(Player: Player, ...: any)
			return onServerEvent(self, Player, ...)
		end)
	)

	-- Chat command connections
	table.insert(
		self._private.Maid,
		Players.PlayerAdded:Connect(function(Player)
			self:_onPlayerAdded(Player)
		end)
	)

	for _, Player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self._onPlayerAdded)(self, Player)
	end

	-- Connect the player's maid cleanup function.
	table.insert(
		self._private.Maid,
		Players.PlayerRemoving:Connect(function(Player)
			self:_onPlayerRemoved(Player)
		end)
	)

	-- Initialize the workspace attribute
	self:_buildAttributes()

	-- Track activity
	if self.Settings.ActivityTracker.Enabled then
		table.insert(
			self._private.Maid,
			RunService.Heartbeat:Connect(function()
				-- Perform this check again in case the setting changes in game.
				if self.Settings.ActivityTracker.Enabled == true then
					for _, data in pairs(self._private.requestCaches.validStaff) do
						if data[3] == nil then
							continue
						end

						data[3]:Increment()
					end
				end
			end)
		)
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
	`require(game:GetService("ServerScriptService").VibezAPI)("API Key")`
	`require(game:GetService("ServerScriptService").VibezAPI).new("API Key")`
	:::

	Constructs the main Vibez API class.

	```lua
	local myKey = "YOUR_API_KEY_HERE"
	local VibezAPI = require(game:GetService("ServerScriptService").VibezAPI)
	local Vibez = VibezAPI(myKey)
	```

	@server
	@since 1.0.1
]=]
---
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi
	if RunService:IsClient() and not RunService:IsStudio() then
		Debris:AddItem(script, 0)
		error("[Vibez]: Cannot fetch API on the client!")
		return nil
	end

	if not checkHttp() then
		error("[VibezAPI]: Http is not enabled! Please enable it before trying to interact with our API!")
		return
	end

	--[=[
		@class VibezAPI
		:::important
		Hey there! We recommend beginning at the introduction page! [Click Here](/docs/intro)
		:::
	]=]

	api.__index = api

	local self = setmetatable({}, api)

	--[=[
		@prop isVibez boolean
		@since 0.11.0
		@within VibezAPI
		A quick boolean check to determine whether the table is indeed related to Vibez.
	]=]
	self.isVibez = true

	--[=[
		@prop Loaded boolean
		@since 0.4.0
		@within VibezAPI
		Determines whether the API has loaded.
	]=]
	self.Loaded = false

	--[=[
		@prop GroupId number
		@since 0.2.0
		@within VibezAPI
		Holds the groupId associated with the API Key.
	]=]
	self.GroupId = -1

	--[=[
		@prop Settings extraOptionsType
		@since 0.1.0
		@within VibezAPI
		Holds a copy of the settings for the API.
	]=]
	self.Settings = Table.Copy(baseSettings, true) -- Performs a deep copy

	--[=[
		@prop _private {Event: RemoteEvent?, Function: RemoteFunction?, _initialized: boolean, _lastVersionCheck: number, recentlyChangedKey: boolean, newApiUrl: string, oldApiUrl: string, clientScriptName: string, rateLimiter: RateLimit, externalConfigCheckDelay: number, lastLoadedExternalConfig: boolean, Maid: {[number]: {RBXScriptConnection?}}, rankingCooldowns: {[number]: number}, usersWithSticks: {number}, stickTypes: string, requestCaches: {nitro: {any}, validStaff: {number}, groupInfo: {[number]: {any}?}}, commandOperations: {any}, commandOperationCodes: {[string]: {Code: string, Execute: (playerWhoFired: Player, playerToCheck: Player, incomingArgument: string) -> boolean}}, Binds: {[string]: {[string]: (...any) -> any?}}}
		@since 0.1.0
		@private
		@within VibezAPI
		From caches to simple booleans/instances/numbers, this table holds all the information necessary for this API to work. 
	]=]
	self._private = {
		Event = nil,
		Function = nil,

		_initialized = false,
		_lastVersionCheck = DateTime.now().UnixTimestamp,
		_rotateIndex = Random.new():NextInteger(12, 256),
		_modules = { -- This is to prevent stack overflow on multiple required modules.
			Utils = Utils,
			Table = Table,
		},

		recentlyChangedKey = false,
		newApiUrl = "https://leina.vibez.dev",
		oldApiUrl = "https://api.vibez.dev/api",

		clientScriptName = table.concat(string.split(HttpService:GenerateGUID(false), "-"), ""),
		rateLimiter = RateLimit.new(60, 60),

		externalConfigCheckDelay = 600, -- 600 = 10 minutes | Change below if changed
		lastLoadedExternalConfig = DateTime.now().UnixTimestamp - 600,

		Maid = {},
		rankingCooldowns = {},

		usersWithSticks = {},
		stickTypes = '["Promote","Demote","Fire"]', -- JSON

		requestCaches = {
			validStaff = {},
			nitro = {},
			groupInfo = {},
		},

		Binds = {
			["promote"] = {},
			["demote"] = {},
			["fire"] = {},
			["setrank"] = {},
			["addblacklist"] = {},
			["_internal"] = {
				["Afk"] = {},
			},
		},

		validModes = {
			RankSticks = {
				["detectioninfront"] = "DetectionInFront",
				["clickonplayer"] = "ClickOnPlayer",
			},
		},

		actionStorage = {
			Bans = {},
			Logs = {
				{
					["Action"] = "Demote",
					["Timestamp"] = 1722537033,
					["affectedCount"] = 1,
					["affectedUsers"] = {
						[1] = {
							["Name"] = "DoWhiIe",
							["UserId"] = 1945330710,
						},
					},
					["calledBy"] = { Name = "ltsRune", UserId = 1 },
					["extraData"] = "",
					["triggeredBy"] = "Interface",
				},
			},
		},
		commandOperations = {},
		commandOperationCodes = {},
	}

	--/ Command Operation Codes \--
	self:addArgumentPrefix(
		"shortenedUsername",
		"",
		function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
			return string.sub(string.lower(playerToCheck.Name), 0, string.len(incomingArgument))
				== string.lower(incomingArgument)
		end
	)

	self:addArgumentPrefix(
		"externalUser",
		"e:",
		function(incomingArgument: string): { Name: string, UserId: number } | { any }
			local name, id
			if tonumber(incomingArgument) ~= nil then
				local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(incomingArgument))

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
		{ isExternal = true }
	)

	self:addArgumentPrefix("Rank", "r:", function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
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
	end)

	self:addArgumentPrefix("Team", "%", function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
		return playerToCheck.Team ~= nil
			and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
				== string.lower(incomingArgument)
	end)

	--/ Configuration Fixing \--
	local wereOptionsAttempted = not (extraOptions == nil)
	extraOptions = (typeof(extraOptions) == "table") and extraOptions or {}

	if Table.Count(extraOptions) == 0 and wereOptionsAttempted then
		self:_warn("Extra options have an error associated with them, reverting to default options...")
	end

	-- Only run the settings check if extra options were changed.
	if not wereOptionsAttempted then
		for settingSubCategory, value in pairs(extraOptions) do
			if self.Settings[settingSubCategory] == nil then
				self:_warn(`Optional key '{settingSubCategory}' is not a valid option.`)
				continue
			end

			-- Final settings check
			if typeof(value) == "table" then
				-- Handle 'nilCheckIgnore' for tables that can be somewhat-wrongly typed.
				for settingToChange, newSetting in pairs(value) do
					local currentSettingToChange = self.Settings[settingSubCategory][settingToChange]

					-- 'sticksModel' is nil by default.
					if currentSettingToChange == nil and settingToChange ~= "sticksModel" then
						self:_warn(
							string.format(
								"Optional key 'Settings.%s.%s' is not a valid option.",
								settingSubCategory,
								settingToChange
							)
						)
						continue
					elseif
						-- Custom logic to validate feature modes.
						self.Settings[settingSubCategory] ~= nil
						and currentSettingToChange ~= nil
						and settingToChange == "Mode"
						and typeof(newSetting) == "string"
					then
						if not self._private.validModes[settingSubCategory] then
							self:_warn(
								string.format(
									"The 'Mode' setting within '%s' is not correctly validated! Please screenshot this message and send it to @ltsRune!",
									settingSubCategory
								)
							)
							continue
						end

						if self._private.validModes[settingSubCategory][string.lower(tostring(newSetting))] == nil then
							self:_warn(
								string.format(
									"Optional mode '%s' for 'Settings.%s' is not a valid, it's been overwritten to the default of '%s'.",
									newSetting,
									settingSubCategory,
									currentSettingToChange
								)
							)
							continue
						end
					elseif
						-- Write in custom logic for 'Instance' types.
						typeof(currentSettingToChange) ~= typeof(newSetting)
						and (settingToChange == "sticksModel" and typeof(newSetting) ~= "Instance")
					then
						self:_warn(
							string.format(
								"Optional key 'Settings.%s.%s' is not the same type as it's default value of '%s'",
								settingSubCategory,
								settingToChange,
								typeof(currentSettingToChange)
							)
						)
						continue
					end

					self.Settings[settingSubCategory][settingToChange] = newSetting
				end
			else
				self.Settings[settingSubCategory] = value
			end
		end
	end

	--/ Configuration Setup \--
	-- Only add "sticks" command when rank sticks is enabled.
	if self.Settings.RankSticks.Enabled == true then
		self:addCommand("sticks", {}, function(Player: Player)
			local staffData = self:_playerIsValidStaff(Player)
			if not staffData or staffData.Rank == nil or staffData.Rank < self.Settings.Commands.MinRank then
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
				self:_addLog(Player, "RankSticks", "Commands", nil, "Removed")

				for _, v in pairs(foundSticks) do
					Debris:AddItem(v, 0)
				end
				return
			end

			self:_giveSticks(Player)
			self:_addLog(Player, "RankSticks", "Commands", nil, "Given")
		end)

		-- We need to ensure that the module is indeed setting up
		-- commands, otherwise sticks can never be given.
		self.Settings.Commands.Enabled = true
	end

	-- Add rest of the commands when "Commands" is enabled.
	if self.Settings.Commands.Enabled == true then
		self:_setupCommands()
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
		self:_warn("Setting 'isAsync' has been marked deprecated, it is not recommended to use this method.")
		coroutine.wrap(self._initialize)(self, apiKey)
	else
		self:_initialize(apiKey)
	end

	if Table.Count(self) == 0 then
		return
	end

	-- Setup the global variables for use.
	if self.Settings.Misc.createGlobalVariables then
		self:_setupGlobals()
	end

	-- This code will be kept in case I brick the module again with my descriptive comments. :rolling_eyes:
	-- if self.Settings.Misc.checkForUpdates then
	-- 	-- Auto-Update with github, lets hope this doesn't hit any rate limits.
	-- 	-- Check with _VERSION variable and warn the download link.
	-- 	-- [%d]+.[%d]+.[%d]+
	-- 	local isOk, response, JSON
	-- 	isOk, response =
	-- 		pcall(HttpService.GetAsync, HttpService, "https://api.github.com/repos/ItsRune/VibezAPI/releases/latest")
	-- 	if not isOk then
	-- 		return
	-- 	end

	-- 	isOk, JSON = pcall(HttpService.JSONDecode, HttpService, response)
	-- 	if not isOk then
	-- 		return
	-- 	end

	-- 	local tagName = JSON.tag_name
	-- 	local currentTag = "v" .. _VERSION
	-- 	if currentTag ~= tagName then
	-- 		local downloadLink = "(Can't Find)"
	-- 		do
	-- 			local vibezRBXM = Table.Find(JSON.assets, function(data)
	-- 				return string.match(data.name, ".rbxm") ~= nil
	-- 			end)

	-- 			if vibezRBXM then
	-- 				downloadLink = vibezRBXM.browser_download_url
	-- 			end
	-- 		end

	-- 		local updateInfo = string.format(
	-- 			"There's an update available whenever you're free! Your current version is v%s the latest version is %s\n\nYou can download the update here:\n%s",
	-- 			_VERSION,
	-- 			tagName,
	-- 			downloadLink
	-- 		)
	-- 		local changelogInfo = ""

	-- 		if JSON.body ~= "" then
	-- 			local fixedBody = string.gsub(JSON.body, "`[%(%)a-zA-Z]+`", function(str: string)
	-- 				return string.format("'%s'", string.sub(str, 2, #str - 1))
	-- 			end)
	-- 			changelogInfo = string.format("\n\nChangelog:\n%s", fixedBody)
	-- 		end

	-- 		if _G.VIBEZ_VERSION_CHECK then
	-- 			return
	-- 		end

	-- 		_G.VIBEZ_VERSION_CHECK = true
	-- 		TestService:Message("\n" .. updateInfo .. changelogInfo)
	-- 		-- self:_warn(updateInfo .. changelogInfo)
	-- 	end
	-- end

	if self.Settings.Misc.autoReportErrors then
		table.insert(
			self._private.Maid,
			ScriptContext.Error:Connect(function(...)
				self:_onInternalErrorLog(...)
			end)
		)
	end

	_G["vibez_api_key_private_names"] = _G["vibez_api_key_private_names"] or {}
	_G["vibez_api_key_private_names"][self.Settings.apiKey] = self._private.clientScriptName

	TestService:Message(string.format("Vibez v%s has successfully been loaded into this server!", _VERSION))

	-- Cast to the Vibez API Type.
	return self :: Types.vibezApi
end

--[=[
	@function awaitGlobals
	
	Awaits for the Global API to be loaded.
	@return VibezAPI

	```lua
	local globals = VibezAPI.awaitGlobals()
	```

	@yields
	@within VibezAPI
	@deprecated 0.11.0
	@since 0.1.0
]=]
---

--[=[
	@function getGlobalsForKey
	Awaits for the Global API to be loaded.
	@param apiKey string
	@return Folder

	```lua
	local globals = VibezAPI.getGlobalsForKey("API KEY")
	globals.Notifications:Invoke(Player, "Hello World!")
	```

	@within VibezAPI
	@since 0.11.0
]=]
---
return setmetatable({
	isVibezAPI = true,

	awaitGlobals = function()
		assert(false, "This method has been deprecated, we recommend using the new 'getGlobalsForKey' function.")

		-- local mod = nil
		-- local counter = 0

		-- while mod == nil do
		-- 	mod = _G["VibezApi"]
		-- 	counter += 1

		-- 	if counter >= 1000 then
		-- 		break
		-- 	end

		-- 	task.wait()
		-- end

		-- return mod
	end,

	getGlobalsForKey = function(apiKey: string)
		local vibezKey = _G["vibez_api_key_private_names"][apiKey]
		return (vibezKey ~= nil) and ServerStorage:FindFirstChild(vibezKey) or nil
	end,

	new = Constructor,
}, {
	__call = function(t, ...)
		return rawget(t, "new")(...)
	end :: Types.vibezConstructor,
})

--[=[
	@interface extraOptionsType
	.Commands { Enabled: boolean, useDefaultNames: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, Prefix: string, Alias: {string?} }
	.RankSticks { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, SticksModel: Model? }
	.Interface { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, visibleFrames: { string }, Activation: { Keybind: string, iconToolTip: string, iconButtonPosition: "Left" | "Right" | "Center", iconButtonImage: string | number } }
	.Notifications { Enabled: boolean, Font: Enum.Font, FontSize: number<1-100>, keyboardFontSizeMultiplier: number, delayUntilRemoval: number, entranceTweenInfo: {Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number}, exitTweenInfo: {Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number} }
	.ActivityTracker { Enabled: boolean, MinRank: number<0-255>, disabledWhenInStudio: boolean, disableWhenInPrivateServer: boolean, disableWhenAFK: boolean, delayBeforeMarkedAFK: number, kickIfFails: boolean, failMessage: string }
	.Misc { originLoggerText: string, ignoreWarnings: boolean, rankingCooldown: number, overrideGroupCheckForStudio: boolean, createGlobalVariables: boolean, isAsync: boolean }
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
	@interface blacklistResponse
	.success boolean
	.message string
	@within VibezAPI
]=]

--[=[
	@interface fullBlacklists
	.success boolean
	.blacklists: { [number | string]: { reason: string, blacklistedBy: number } }
	@within VibezAPI
]=]

--[=[
	@interface infoResponse
	.success boolean
	.message string
	@within VibezAPI
]=]

--[=[
	@interface activityResponse
	.secondsUserHasSpent number
	.messagesUserHasSent number
	.detailsLogs [ {timestampLeftAt: number, secondsUserHasSpent: number, messagesUserHasSent: number}? ]
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

--[=[
	@interface vibezDebugTools
	.stringifyTableDeep (tbl: { any }, tabbing: number?) -> string
	@private
	@within VibezAPI
]=]
