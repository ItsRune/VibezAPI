--!strict
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
	Updated: 1/24/2025 14:34 EST
	Version: 0.11.2

	Note: If you don't know what you're doing, I would
	not	recommend messing with anything. We don't offer
	support for modified modules.
]]
local _VERSION = "0.11.2"

--// Services \\--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local TestService = game:GetService("TestService")

--// Modules \\--
local Types = require(script.Modules.Internal.Types)
local checkingMethods = require(script.Modules.Internal.SettingsChecker)
local Hooks = require(script.Modules.Hooks)
local ActivityTracker = require(script.Modules.Activity)
local RateLimit = require(script.Modules.RateLimit)
local Table = require(script.Modules.Table)
local Promise = require(script.Modules.Promise)
local Utils = require(script.Modules.Utils)
local baseSettings = require(script.Modules.Settings)

--// Constants \\--
local api = {} :: Types.vibezInternalApi & Types.vibezPublicApi
local _privateKeys = {} :: { [string]: string? }

--// Local Functions \\--
--[=[
	https://devforum.roblox.com/t/your-name-color-in-chat-%E2%80%94-history-and-how-it-works/2702247
	Generates a name color to use for Player -> All Client's notifications.
	@param username string
	@return Color3

	@within VibezAPI
	@ignore
]=]
local function generateNameColorForNotification(username: string): Color3
	local NAME_COLORS = {
		Color3.new(253 / 255, 41 / 255, 67 / 255), -- BrickColor.new("Bright red").Color,
		Color3.new(1 / 255, 162 / 255, 255 / 255), -- BrickColor.new("Bright blue").Color,
		Color3.new(2 / 255, 184 / 255, 87 / 255), -- BrickColor.new("Earth green").Color,
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color,
	}

	local function GetNameValue(pName)
		local value = 0
		for index = 1, #pName do
			local cValue = string.byte(string.sub(pName, index, index))
			local reverseIndex = #pName - index + 1
			if #pName % 2 == 1 then
				reverseIndex = reverseIndex - 1
			end
			if reverseIndex % 4 >= 2 then
				cValue = -cValue
			end
			value = value + cValue
		end
		return value
	end

	return NAME_COLORS[(GetNameValue(username) % #NAME_COLORS) + 1]
end

--[=[
	Converts an invoking method into a valid action name.
	@param Action string
	@return string

	@within VibezAPI
	@ignore
]=]
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

	return "nil"
end

--[=[
	Main handler for client invokation on the module.
	@param self VibezAPI
	@param Player Player
	@param Action string
	@param Origin "Interface" | "Sticks" | "Commands",
	@param ... ...any
	@return any

	@within VibezAPI
	@ignore
]=]
local function onServerInvoke(
	self: any,
	Player: Player,
	Action: string,
	Origin: "Interface" | "Sticks" | "Commands",
	...: any
): any
	local rankingActions = { "promote", "demote", "fire", "setrank", "blacklist", "unblacklist" }
	local Data = { ... }
	local actionIndex = table.find(rankingActions, string.lower(tostring(Action)))

	if actionIndex ~= nil then
		local Targets = Data[1]

		if typeof(Targets[1]) ~= "table" then
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
				-- If the Target is a partial of their user, then we need to create a fake Player 'userdata'
				elseif typeof(Target) ~= "table" then
					local userId, name = self:_verifyUser(Target, "UserId"), self:_verifyUser(Target, "Name")
					Target = {
						["Name"] = name,
						["UserId"] = userId,
					}
				-- Partial target information
				elseif typeof(Target["Name"]) ~= "string" or typeof(Target["UserId"]) ~= "number" then
					local targetItem = Table.Find(Table.Flat(Target), function(item)
						return typeof(item) == "string" or typeof(item) == "number"
					end)

					if not targetItem then
						self:_debug(
							"serverinvoke_resolve_target",
							"Flattening of table did not possess a valid 'number' or 'string'! (CRITICAL)"
						)
						return reject("Target could not be properly resolved! (Internal Issue)")
					end

					local userId, name = self:_verifyUser(targetItem, "UserId"), self:_verifyUser(targetItem, "Name")
					Target = {
						["Name"] = name,
						["UserId"] = userId,
					}
				end

				local targetGroupData = self:_playerIsValidStaff(Target)
				local targetGroupRank = (targetGroupData ~= nil) and targetGroupData.Rank
					or self:_getGroupFromUser(self.GroupId, Target.UserId)

				if typeof(targetGroupRank) == "table" then
					targetGroupRank = targetGroupRank.Rank
				end

				local callerGroupData: { [any]: any } = self:_playerIsValidStaff(Player)
				if not callerGroupData or callerGroupData.Rank == nil then -- The user calling this function is NOT staff
					self:_warn(
						string.format(
							"%s (%d) attempted to '%s' user %s (%d) when they're not staff!",
							Player.Name,
							Player.UserId,
							string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action)),
							Target.Name,
							Target.UserId
						)
					)
					return reject("Unauthorized")
				end

				local callerGroupRank = callerGroupData.Rank
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
					self:notifyPlayer(Player, "Error: That user's rank is higher OR equal to your rank.")
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
							Target.UserId
						)
					)
					return reject("Too high to rank")
				end

				-- TODO: Handle different modes: "PerTarget" | "PerStaff" | "Both"
				if self.Settings.Cooldowns.Enabled then
					local theirCooldown = self._private.Cooldowns.Ranking[Target.UserId]
					local now = DateTime.now().UnixTimestampMillis / 1000

					if now - theirCooldown < self.Settings.Cooldowns.Ranking then
						local message = string.format(
							"%s (%d) still has %d seconds left on their ranking cooldown!",
							Target.Name,
							Target.UserId,
							math.abs(self.Settings.Cooldowns.Ranking - (DateTime.now().UnixTimestamp - theirCooldown))
						)

						self:_warn(message)
						self:notifyPlayer(Player, "Error: " .. message)
						return reject("Ranking cooldown")
					end

					self._private.Cooldowns.Ranking[Target.UserId] = now
				end

				local actionFunc = getActionFunctionFromInvoke(Action)
				local result, extraData = nil, {}
				local logAction = (Action == "blacklist") and "Blacklist"
					or string.upper(string.sub(Action, 1, 1)) .. string.lower(string.sub(Action, 2, #Action))

				warn(actionFunc, Data)
				if actionFunc == "Blacklist" then
					local reason = Data[2] or "Unspecified"

					result = self[actionFunc](self, Target.UserId, reason, Player)
					table.insert(extraData, reason)
				elseif actionFunc == "setRank" then
					local newRank = Data[2]
					result = self[actionFunc](
						self,
						Target.UserId,
						newRank,
						{ userName = Player.Name, userId = Player.UserId }
					)
				else
					result = self[actionFunc](self, Target.UserId, { userName = Player.Name, userId = Player.UserId })
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
					self:notifyPlayer(
						Player,
						string.format(
							"Error: Attempting to %s %s (%d) resulted in an internal server error!",
							actionFunc == "Blacklist" and "blacklist" or "rank",
							Target.Name,
							Target.UserId
						)
					)
					self:_warn(
						string.format("Internal server error: %s", result.errorMessage or result.message or "Unknown.")
					)
					return reject("Internal server error")
				end

				result.Target = Target
				resolve(result)
			end):andThen(function(result: { [any]: any })
				table.insert(resolvedPromises, result)
			end, function(err)
				self:_warn(tostring(err))
			end)
		end

		local actionFunctionName = getActionFunctionFromInvoke(Action)
		if actionFunctionName == "addBlacklist" or actionFunctionName == "deleteBlacklist" then
			return true
		end

		if #Targets > 1 then
			local avgProcessingSpeedInSeconds = 3
			self:notifyPlayer(
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
		local notificationStringFilledWithUsers: { string } = {}
		local likelyErrors: { { any } } = {}

		for i = 1, #resolvedPromises do
			local this = resolvedPromises[i]
			local resultingSuccess = false

			if this["success"] ~= nil and this["success"] ~= resultingSuccess then
				resultingSuccess = this["success"]
			end

			if not resultingSuccess and this["message"] ~= nil then
				maxResolved += 1

				local _, index = Table.Find(likelyErrors, function(item)
					return item[1] == this["message"]
				end)

				if index then
					likelyErrors[index] = { this.message, likelyErrors[index][2] + 1 }
				else
					table.insert(likelyErrors, { this.message, 1 })
				end

				continue
			end

			table.insert(notificationStringFilledWithUsers, this.Target.Name)

			if i >= maxResolved then
				break
			end
		end

		table.sort(likelyErrors, function(a, b)
			return a[2] < b[2]
		end)

		local firstErr = likelyErrors[1]
		if firstErr and firstErr[2] >= #Targets then
			self:notifyPlayer(Player, "Error: Internal issue - <b>" .. firstErr[1] .. "</b>")
			return false
		end

		local firstCharOfAction = string.sub(string.lower(Action), 1, 1)
		local realActionTitle = (firstCharOfAction == "p") and "Promoted"
			or (firstCharOfAction == "s") and "Ranked"
			or (firstCharOfAction == "d") and "Demoted"
			or (firstCharOfAction == "f") and "Fired"
			or "Unknown Ranking Action"

		local moreUsersDifference = #resolvedPromises - maxResolved
		local concatenatedUsernames = table.concat(notificationStringFilledWithUsers, ", ")
			.. ((moreUsersDifference > 0) and " and " .. moreUsersDifference .. " more" or "")

		self:notifyPlayer(Player, string.format(fullNotificationString, realActionTitle, concatenatedUsernames))
		return true
	elseif Action == "Afk" then
		Table.ForEach(self._private.Binds._internal.Afk, function(classRouter: (Player: Player, something: any) -> ())
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
		local data = table.clone(self:_playerIsValidStaff(Player))

		-- No need to send their activity down to the client.
		data.Tracker = nil

		return data
	elseif Action == "Logs" then
		local groupData = self:_getGroupFromUser(self.GroupId, Player.UserId)
		if groupData.Rank == 0 then
			return {}
		end

		return self._private.actionStorage.Logs
	else
		-- Maybe actually log it somewhere... I have no clue where though.
		self:_warn(
			string.format("Player %s (%d) tried to perform an invalid action with our API.", Player.Name, Player.UserId)
		)
		self:_debug(string.format("'%s' attempted to perform action '%s' which is invalid.", Player.Name, Action))

		-- REVIEW: Somehow admins are reaching this point and being kicked for it.
		-- Player:Kick(
		-- 	"Messing with vibez remotes, this has been logged and repeating offenders will be blacklisted from our services."
		-- )
		return false
	end

	return
end

--[=[
	Handler for main remote event.
	@param self VibezAPI
	@param Player Player
	@param Command string
	@param ... ...any

	@within VibezAPI
	@ignore
]=]
local function onServerEvent(self: any, Player: Player, Command: string, ...: any)
	local Data = { ... }

	if Command == "Notifications" then
		local users = Data[1]
		local usernameColor = generateNameColorForNotification(Player.Name):ToHex()
		local prefix = string.format('[<font color="#%s">%s</font>]: ', usernameColor, Player.Name)
		local message = prefix .. Data[2]
		local staffData = self:_playerIsValidStaff(Player)

		if not staffData or not staffData["Rank"] or staffData.Rank < self.Settings.Interface.MinRank then
			return
		end

		local affectedUsers = {}
		for _, userId: number in ipairs(users) do
			if typeof(userId) ~= "number" then
				continue
			end

			local User = Players:GetPlayerByUserId(userId)
			if not User then
				continue
			end

			table.insert(affectedUsers, { Name = User.Name, UserId = User.UserId })
			self._private.Event:FireClient(User, "Notify", true, message)
		end

		self:_addLog(Player, "Notify", "Interface", affectedUsers)
	elseif Command == "Animate" then
		local Character = Player.Character
		if not Character then
			self:_warn("No Character.")
			return
		end

		local Tool = Character:FindFirstChildOfClass("Tool")
		if Tool == nil or Tool:GetAttribute(self._private.clientScriptName) == nil then
			self:_debug("ranksticks_animation", "Improper tool detected.")
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

		local humanoid: Humanoid? = Character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			self:_debug("ranksticks_animation", "No humanoid.")
			return
		end

		local animator = humanoid:FindFirstChildOfClass("Animator")
		local animationId: number? = self.Settings.RankSticks.Animation[humanoid.RigType.Name]

		if not animationId or not tonumber(animationId) then
			self:_debug("ranksticks_animation", "Animation ID is not a valid number. (Settings check has failed you.)")
			return
		elseif not animator then
			self:_debug("ranksticks_animation", "Humanoid's Animator is not loaded yet.")
			return
		end

		local animationInstance = Instance.new("Animation")
		animationInstance.AnimationId = "rbxassetid://" .. tostring(animationId)
		animationInstance.Parent = animator

		local isOk, animationTrack = pcall(animator.LoadAnimation, animator, animationInstance)
		if not isOk then
			self:_debug("ranksticks_animation", "Internal Server Error: " .. tostring(animationTrack))
			return
		end

		animationTrack:Play()
	end
end

--[=[
	Invokes a protected-call to google.com
	@return (boolean, string)

	@within VibezAPI
	@ignore
]=]
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
	type commandBase = { [number]: { Name: string, Alias: { string? }, Func: (Player: Player, Args: { string }) -> () } }
	local baseCommands: commandBase = {
		{
			Name = "promote",
			Alias = {},
			Func = function(Player: Player, Args: { string })
				local staffData = self:_playerIsValidStaff(Player)
				if
					not staffData
					or not staffData.Rank
					or staffData.Rank < self.Settings.Commands.MinRank
					or not Args[1]
				then
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
			Name = "demote",
			Alias = {},
			Func = function(Player: Player, Args: { string })
				local staffData = self:_playerIsValidStaff(Player)
				if
					not staffData
					or not staffData.Rank
					or staffData.Rank < self.Settings.Commands.MinRank
					or not Args[1]
				then
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
			Name = "fire",
			Alias = {},
			Func = function(Player: Player, Args: { string })
				local staffData = self:_playerIsValidStaff(Player)
				if
					not staffData
					or not staffData.Rank
					or staffData.Rank < self.Settings.Commands.MinRank
					or not Args[1]
				then
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
			Name = "blacklist",
			Alias = {},
			Func = function(Player: Player, Args: { string })
				local staffData = self:_playerIsValidStaff(Player)
				if
					not staffData
					or not staffData.Rank
					or staffData.Rank < self.Settings.Commands.MinRank
					or not Args[1]
				then
					return
				end

				local affectedUsers: { any } = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))
				table.remove(Args, 1)

				local reason = table.concat(Args, " ")
				local blacklistReason =
					self:_fixFormattedString(self.Settings.Blacklists.userIsBlacklistedMessage, Player, {
						onlyApplyCustom = true,
						Codes = {
							{ code = "<BLACKLIST_REASON>", equates = reason },
							{ code = "<BLACKLIST_BY>", equates = Player.Name },
						},
					})

				for _, Target: any in ipairs(users) do
					local res = self:addBlacklist(Target.UserId, reason, Player.UserId) :: Types.userBlacklistResponse
					if not res or not res.success then
						self:_warn("Blacklist resulted in an error, please try again later.")
						return
					end

					table.insert(affectedUsers, Target)
					self:_warn(res.message)

					local inGameTarget = Players:GetPlayerByUserId(Target.UserId)
					if inGameTarget then
						inGameTarget:Kick(blacklistReason)
					end
				end

				self:_addLog(Player, "Blacklist", "Commands", affectedUsers, { Reason = reason })
			end,
		},

		{
			Name = "unblacklist",
			Alias = {},
			Func = function(Player: Player, Args: { string })
				local staffData = self:_playerIsValidStaff(Player)
				if
					not staffData
					or not staffData.Rank
					or staffData.Rank < self.Settings.Commands.MinRank
					or not Args[1]
				then
					return
				end

				local affectedUsers = {}
				local users = self:getUsersForCommands(Player, string.split(Args[1], ","))

				for _, Target: any in pairs(users) do
					if not Target then
						return
					end

					local res: any = self:deleteBlacklist(Target.UserId)
					if not res or not res.success then
						self:notifyPlayer(Player, "Error: " .. res.errorMessage)
						continue
					end

					table.insert(affectedUsers, Target)
					self:_warn(res.message)
				end

				self:_addLog(Player, "Unblacklist", "Commands", affectedUsers)
			end,
		},
	}

	local removedCommands = Table.Map(self.Settings.Commands.Removed or {}, function(commandName: string?)
		return string.lower(tostring(commandName))
	end)

	for _, commandData in ipairs(baseCommands) do
		if table.find(removedCommands, string.lower(commandData.Name)) then
			continue
		end

		local developerDefinedAliases = self.Settings.Commands.Alias[string.lower(commandData.Name)]
		local aliases: { string } = {}

		if developerDefinedAliases ~= nil then
			local removedAliases = 0

			if typeof(developerDefinedAliases) == "string" then
				aliases = { developerDefinedAliases }
			elseif typeof(developerDefinedAliases) == "table" then
				aliases = developerDefinedAliases
			end

			for index, alias in ipairs(aliases) do
				local existingCommand = Table.Find(self._private.commandOperations, function(data)
					return string.lower(tostring(data.Name)) == string.lower(tostring(alias))
						or table.find(data.Alias, string.lower(tostring(alias))) ~= nil
				end)

				if existingCommand then
					local warningMessage =
						"Insertion of alias '%s' caused an internal issue, this alias will not work for command '%s'"
					self:_warn(string.format(warningMessage, alias, existingCommand.Name))

					table.remove(aliases, index - removedAliases)
					removedAliases += 1
					continue
				end

				aliases[index - removedAliases] = string.lower(tostring(alias))
			end
		end

		self:addCommand(commandData.Name, aliases, commandData.Func)
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

	local globalsFolder = script.baseGlobalsFolder:Clone() :: any

	globalsFolder.Name = self._private.clientScriptName
	globalsFolder.Parent = ServerStorage :: any

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

	globalsFolder.ActivityTracker.Save.OnInvoke = function(...: any): any
		return self:saveActivity(...)
	end

	globalsFolder.ActivityTracker.Fetch.OnInvoke = function(...: any): any
		return self:getActivity(...)
	end

	globalsFolder.ActivityTracker.Delete.OnInvoke = function(...: any): any
		return self:removeActivity(...)
	end

	globalsFolder.Notifications.Send.OnInvoke = function(...: any): any
		return self:notifyPlayer(...)
	end

	globalsFolder.Webhooks.Create.OnInvoke = function(...: any): any
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

	globalsFolder.Blacklists.Get.OnInvoke = function(...: any): any
		return self:getBlacklists(...)
	end

	globalsFolder.Blacklists.Add.OnInvoke = function(...: any): any
		return self:addBlacklist(...)
	end

	globalsFolder.Blacklists.Delete.OnInvoke = function(...: any): any
		return self:deleteBlacklist(...)
	end
end

--[=[
	Uses `RequestAsync` to fetch required assets to make this API wrapper work properly. Automatically handles the API key and necessary headers associated with different routes.
	@param Route string
	@param Method any
	@param Headers { [string]: any }?
	@param Body { any }?
	@return boolean, httpResponse?

	@yields
	@private
	@within VibezAPI
	@since 1.0.0
]=]
---
function api:_http(
	Route: string,
	Method: any,
	Headers: { [string]: any }?,
	Body: { [any]: any }?
): (boolean, Types.httpResponse)
	local canContinue: boolean, err: string? = self._private.rateLimiter:Check()
	if not canContinue then
		local message = "You're being rate limited! " .. tostring(err)

		-- Create a fake error response
		return false,
			{
				Success = false,
				StatusCode = 429,
				StatusMessage = message,
				rawBody = "{}",
				Headers = {
					["Content-Type"] = "application/json",
					["x-api-key"] = self.apiKey,
				},
				Body = {
					success = false,
					errorMessage = message,
				},
			}
	end

	local apiToUse = self._private.newApiUrl
	Route = (typeof(Route) == "string") and Route or "/"
	Method = (typeof(Method) == "string") and string.upper(Method) or "GET"
	Body = (Method ~= "GET" and Method ~= "HEAD") and Body or nil

	local generatedHeaders = Headers :: { [string]: any }
	if not Headers or typeof(Headers) ~= "table" then
		generatedHeaders = { ["Content-Type"] = "application/json" }
	end

	if Body then
		local extraLoggerInfo = (RunService:IsStudio()) and " `(Studio PlayTest)`" or ""
		Body["origin"] = self.Settings.Misc.originLoggerText :: string .. extraLoggerInfo
	end

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route
	generatedHeaders["x-api-key"] = self.apiKey

	-- Prevents sending api key to external URLs
	-- Remove from 'Route' extra slash that was added
	-- Make 'apiToUse' an empty string since "Route" and "apiToUse" get concatenated on request.
	if string.match(Route, "[http://]|[https://]") ~= nil then
		Route = string.sub(Route, 2, #Route)
		apiToUse = ""
		generatedHeaders["x-api-key"] = nil
	end

	local Options = {
		Url = apiToUse .. Route,
		Method = Method,
		Headers = generatedHeaders,
		Body = Body and HttpService:JSONEncode(Body) or nil,
		Compress = Enum.HttpCompression.None,
	}

	local success, data: any = pcall(HttpService.RequestAsync, HttpService, Options)
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
		self:_debug("get_group_from_user", "Studio override for permission check.")
		return {
			Rank = 255,
			Role = "Unknown",
		}
	end

	local isOk, data: { [any]: any } | string = pcall(GroupService.GetGroupsAsync, GroupService, userId)
	local possiblePlayer = Players:GetPlayerByUserId(userId)
	local found = nil

	if not isOk then
		self:_debug("get_group_from_user", "Failed to fetch group data for '" .. userId .. "'; Fake data provided.")
		return {
			Id = groupId,
			Rank = 0,
			Role = "Guest",
			errMessage = data :: string,
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
		local rankOk, rank = pcall(possiblePlayer.GetRankInGroup, possiblePlayer, groupId)
		local roleOk, role = pcall(possiblePlayer.GetRoleInGroup, possiblePlayer, groupId)

		if rankOk and roleOk then
			return {
				Id = groupId,
				Role = role,
				Rank = rank,
			}
		end

		self:_warn(`An error occurred whilst fetching group information from {tostring(possiblePlayer)}.`)
	end

	self:_debug("get_group_from_user", "Unexpected issue occurred.")
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
	-- Ensure API loads with all settings before initializing client.
	local counter = 0
	repeat
		task.wait()
		counter += 1
	until counter >= 1000 or self.Loaded

	if not self.Loaded and counter >= 1000 then
		self:_debug("api_took_too_long", "Client joined, but couldn't initialize due to slow api response time!")
		return
	elseif Player.Parent ~= Players then
		self:_debug("api_took_too_long", "Client left the game as we were awaiting the api to load fully.")
		return
	else
		self:_debug("api_took_too_long", "Passed ✅")
	end

	-- Check if player is currently blacklisted.
	if self.Settings.Blacklists.Enabled then
		local isBlacklisted, blacklistReason, blacklistedBy = self:isUserBlacklisted(Player)

		if isBlacklisted then
			local blacklistedByUsernameIsOk, blacklistedByUsername =
				pcall(Players.GetNameFromUserIdAsync, Players, blacklistedBy)

			if not blacklistedByUsernameIsOk and blacklistedBy == -1 then
				blacklistedByUsernameIsOk, blacklistedByUsername = true, "System"
			end

			local kickReason = self:_fixFormattedString(self.Settings.Blacklists.userIsBlacklistedMessage, Player, {
				onlyApplyCustom = true,
				Codes = {
					{ code = "<BLACKLIST_REASON>", equates = blacklistReason },
					{
						code = "<BLACKLIST_BY>",
						equates = blacklistedByUsernameIsOk and blacklistedByUsername or blacklistedBy,
					},
				},
			})

			Player:Kick(kickReason)
			self:_debug(
				"user_blacklist_check",
				"'"
					.. Player.Name
					.. "' was blacklisted by '"
					.. (blacklistedByUsernameIsOk and blacklistedByUsername or blacklistedBy)
					.. "' for '"
					.. blacklistReason
					.. "'!"
			)
			return
		end
	end

	-- Get group data for setup below.
	local theirGroupData: { Rank: number, Role: string, Id: number?, errMessage: string? } =
		self:_getGroupFromUser(self.GroupId, Player.UserId)

	-- We want to hold all connections from users in order to
	-- disconnect them later on, this will stop any memory
	-- leaks from occurring by vibez's api wrapper.
	self._private.Maid[Player.UserId] = {}
	table.insert(
		self._private.Maid[Player.UserId] :: { RBXScriptConnection },
		Player.Chatted:Connect(function(message: string)
			return self:_onPlayerChatted(Player, message)
		end)
	)

	-- Figure out a solution here to check for rank (Prevent rank 0 in validStaff table)
	if self._private.requestCaches.validStaff[Player.UserId] == nil then
		self._private.requestCaches.validStaff[Player.UserId] = { User = Player, Rank = theirGroupData.Rank }
	end

	local PlayerGui = Player:WaitForChild("PlayerGui", 30)
	if not PlayerGui then
		self:_debug("user_initialization", "Failed to find PlayerGui.")
		return
	end

	if PlayerGui:FindFirstChild(self._private.clientScriptName) ~= nil then
		self:_debug("user_initialization", "User already has been initialized.")
		return -- Player was already in game but got disconnected (typically from an in game rank change)
	end

	-- Clone client script and parent to player gui
	local client = script.Client:Clone()
	client.Name = self._private.clientScriptName
	client.Parent = PlayerGui :: any
	client.Enabled = true

	-- Enabled activity tracking for player
	-- Keep this last at all times! The activity tracker yields on creation!
	if
		self.Settings.ActivityTracker.Enabled == true
		and theirGroupData.Rank >= self.Settings.ActivityTracker.MinRank
	then
		local tracker = ActivityTracker.new(self, Player)
		self._private.requestCaches.validStaff[Player.UserId].Tracker = tracker
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
		self:_debug("user_removal", "User has no existing RBXScriptConnections to disconnect.")
		return
	end

	-- Disconnect connections connected to specific user.
	for _, connection: RBXScriptConnection? in pairs(self._private.Maid[Player.UserId] :: { RBXScriptConnection }) do
		if not connection then
			continue
		end

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
	Player: { Name: string, UserId: number } | Player,
	Custom: { onlyApplyCustom: boolean, Codes: { { code: string, equates: string } } }
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
		}) :: { { code: string, equates: string } }

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
function api:_getNameById(userId: number): string
	local fixedUserId = tonumber(userId)
	if not fixedUserId then
		return tostring(userId)
	end

	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, fixedUserId)
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
	local remoteName: string = self._private.clientScriptName
	local function findRemotes()
		local event, func
		for _, v in pairs(ReplicatedStorage:GetChildren()) do
			if v:IsA("RemoteEvent") and v.Name == remoteName and event == nil then
				event = v

				if func then
					break
				end
			elseif v:IsA("RemoteFunction") and v.Name == remoteName and func == nil then
				func = v

				if event then
					break
				end
			end
		end

		return event, func
	end

	local currentRemoteEvent, currentRemoteFunc = findRemotes()
	if not currentRemoteFunc then
		local newRemoteFunc = Instance.new("RemoteFunction")
		newRemoteFunc.Name = remoteName
		newRemoteFunc.Parent = ReplicatedStorage
		currentRemoteFunc = newRemoteFunc
	end

	if not currentRemoteEvent then
		local newRemoteEvent = Instance.new("RemoteEvent")
		newRemoteEvent.Name = remoteName
		newRemoteEvent.Parent = ReplicatedStorage
		currentRemoteEvent = newRemoteEvent
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
	Sends a notification to a player.
	@param Player Player
	@param Message string
	@return number?

	@yields
	@within VibezAPI
	@since 0.11.0
]=]
---
function api:notifyPlayer(Player: Player, Message: string): ()
	if self.Settings.Notifications.Enabled == false then
		self:_warn(string.format("Notification request for %s (%d): ", Player.Name, Player.UserId), Message)
		return
	end

	self._private.Event:FireClient(Player, "Notify", false, Message)
end

--[=[
	Gets the closest match to a player's username who's in game.
	@param playerWhoCalled Player
	@param usernames {string}
	@param ignoreExternal boolean
	@return {Player}

	@yields
	@within VibezAPI
	@since 0.4.0
]=]
---
function api:getUsersForCommands(
	playerWhoCalled: Player,
	usernames: { string | number },
	ignoreExternal: boolean?
): { Player }
	local found = {}
	local externalCodes = {}
	local foundIndices = {}

	if not ignoreExternal then
		Table.ForEach(self._private.commandOperationCodes, function(data)
			if data["isExternal"] ~= nil and data["isExternal"] == true then
				table.insert(externalCodes, data)
			end
		end)
	end

	for index, username in pairs(usernames) do
		for _, player in pairs(Players:GetPlayers()) do
			for _, operationData in pairs(self._private.commandOperationCodes) do
				local operationCode, operationFunction = operationData.Code, operationData.Execute

				if operationData["isExternal"] == true then
					continue
				end

				if
					string.sub(string.lower(tostring(username)), 0, string.len(tostring(operationCode)))
					~= string.lower(operationCode)
				then
					continue
				end

				local operationResult = operationFunction(
					playerWhoCalled,
					player,
					string.sub(
						tostring(username),
						string.len(tostring(operationCode)) + 1,
						string.len(tostring(username))
					),
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
		for index: number, username: string | number in pairs(usernames) do
			if table.find(foundIndices, index) ~= nil then
				continue
			end

			for _, operationData in pairs(externalCodes) do
				local code: string, codeFunc: (...any) -> ...any = operationData.Code, operationData.Execute

				if string.lower(string.sub(tostring(username), 1, #code)) == string.lower(code) then
					local data = codeFunc(nil, nil, string.sub(tostring(username), #code + 1, #tostring(username)))

					if data == nil then
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
		or self.Settings.RankSticks["sticksModel"] :: any

	local playerBackpack = Player:WaitForChild("Backpack", 10)
	if not playerBackpack then
		return
	end

	local sticksToIgnore = Table.Map(self.Settings.RankSticks.Removed, function(str: string)
		return string.lower(tostring(str))
	end)

	for _, operationName: string in ipairs(stickTypes) do
		if table.find(sticksToIgnore, string.lower(tostring(operationName))) then
			continue
		end

		local cloned = rankStick:Clone()
		cloned:SetAttribute(self._private.clientScriptName, "RankSticks")

		cloned.Name = operationName
		cloned.Parent = playerBackpack :: any
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
function api:_removeSticks(Player: Player): ()
	local character = Player.Character
	local backpack: Backpack? = Player.Backpack

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
	local Player = self:_verifyUser(User, "Player") :: Player
	if not Player then
		return self
	end

	if shouldCheckPermissions then
		local staffData: { Rank: number } = self:_playerIsValidStaff(Player)
		if not staffData or not staffData["Rank"] or staffData.Rank < self.Settings.RankSticks.MinRank then
			return self
		end
	end

	self:_giveSticks(Player)
	return self
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
function api:setRankStickTool(tool: any): Types.vibezApi
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

	local newTool = tool :: Tool
	newTool.CanBeDropped = false
	newTool.Name = "RankingSticks"
	newTool.Parent = Utils.getTemporaryStorage()

	Debris:AddItem(self.Settings.RankSticks["sticksModel"] :: any, 0)
	self.Settings.RankSticks["sticksModel"] = tool :: any

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
	local token = Utils.rotateCharacters(string.reverse(self.apiKey), 128)
	local existingTracker = (ActivityTracker.Keys[token] ~= nil) and ActivityTracker.Keys[token][Player.UserId] or nil
	if existingTracker then
		existingTracker:Chatted()
	end

	-- Commands handler
	if self.Settings.Commands.Enabled == false and self.Settings.RankSticks.Enabled == false then
		return
	end

	local callerStaffData: { Rank: number } = self:_playerIsValidStaff(Player)
	if not callerStaffData or not callerStaffData["Rank"] then
		return
	end

	local args = string.split(message, " ")
	local commandPrefix = self.Settings.Commands.Prefix

	if string.sub(args[1], 0, string.len(commandPrefix)) ~= commandPrefix then
		return
	end

	local command = string.sub(string.lower(args[1]), string.len(commandPrefix) + 1, #args[1])
	table.remove(args, 1)

	local commandData = Table.Find(self._private.commandOperations, function(data)
		return data.Enabled
			and (
				string.lower(tostring(data.Name)) == string.lower(tostring(command))
				or Table.Find(data.Alias, function(aliasData)
						return string.lower(tostring(aliasData)) == string.lower(tostring(command))
					end)
					~= nil
			)
	end)

	if commandData == nil then
		return
	end

	commandData.Execute(Player, args, function(...: any)
		return self:_addLog(...)
	end, function(...: any)
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
	Displays a warning to the output.
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
	Displays a debug message to the output.
	@param starter string
	@param ... ...string

	@private
	@within VibezAPI
	@since 1.0.2
]=]
---
function api:_debug(starter: string, ...: string)
	if not self.Settings or not self.Settings.Debug or not self.Settings.Debug.logMessages then
		return
	end

	local prefix = string.format("[Debug-vibez_%s]:", starter)
	print(prefix, ...)
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
	affectedUsers: { { Name: string, UserId: number } },
	extraData: any?
): ()
	table.insert(
		self._private.actionStorage.Logs,
		{
			calledBy = calledBy, -- Player who used an action.
			triggeredBy = triggeringAction, -- Useful for filtering on the UI.

			affectedCount = (affectedUsers == nil) and 0 or #affectedUsers,
			affectedUsers = affectedUsers,
			extraData = extraData,

			Action = Action,
			Timestamp = DateTime.now().UnixTimestamp,
		} :: any
	)

	-- Truncate logs to a count of 100 (Expecting a small amount of people to use logs)
	self._private.actionStorage.Logs = Table.Truncate(self._private.actionStorage.Logs, 100)
end

--[=[
	Builds the attributes of the settings for workspace.

	@within VibezAPI
	@private
	@since 0.9.0
]=]
---
function api:_buildAttributes()
	local function _convertEnumToString(
		enum: Enum.Font | Enum.FontSize | Enum.EasingDirection | Enum.EasingStyle | Enum.KeyCode | string | number
	): any
		if typeof(enum) == "EnumItem" then
			return enum.Name
		end

		return enum
	end

	local function _serializeColor(Color: Color3 | BrickColor): string
		local color3: Color3
		if typeof(Color) == "BrickColor" then
			color3 = Color.Color :: Color3
		elseif typeof(Color) == "Color3" then
			color3 = Color
		else
			self:_debug("attributes_color_serializer", "Supplied color is not a valid color type.")
			return ""
		end

		return string.format(
			"%d,%d,%d",
			math.floor(color3.R * 255),
			math.floor(color3.G * 255),
			math.floor(color3.B * 255)
		)
	end

	local function _handleImageIds(image: string | number): number?
		if string.match(tostring(image), "rbxassetid") ~= nil then
			local result = tonumber(string.match(tostring(image), "[%d]+"))

			if not result then
				self:_debug("attributes_image_ids", "Invalid image id was supplied, using base setting.")
				return baseSettings.Interface.Activation.iconButtonImage :: any
			end

			return result
		end

		return tonumber(image)
	end

	local dataToEncode = {
		GroupId = self.GroupId,

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
			Font = _convertEnumToString(self.Settings.Notifications.Font),
			FontSize = _convertEnumToString(self.Settings.Notifications.FontSize),

			keyboardFontSizeMultiplier = self.Settings.Notifications.keyboardFontSizeMultiplier,
			delayUntilRemoval = self.Settings.Notifications.delayUntilRemoval,

			entranceTweenInfo = {
				Style = _convertEnumToString(self.Settings.Notifications.entranceTweenInfo.Style),
				Direction = _convertEnumToString(self.Settings.Notifications.entranceTweenInfo.Direction),
				timeItTakes = self.Settings.Notifications.entranceTweenInfo.timeItTakes,
			},

			exitTweenInfo = {
				Style = _convertEnumToString(self.Settings.Notifications.exitTweenInfo.Style),
				Direction = _convertEnumToString(self.Settings.Notifications.exitTweenInfo.Direction),
				timeItTakes = self.Settings.Notifications.exitTweenInfo.timeItTakes,
			},
		},

		UI = {
			Status = self.Settings.Interface.Enabled,
			useBeta = self.Settings.Interface.useBetaUI,

			MinRank = self.Settings.Interface.MinRank,
			MaxRank = self.Settings.Interface.MaxRank,

			nonViewableTabs = self.Settings.Interface.nonViewableTabs,

			Logs = {
				Status = self.Settings.Interface.Logs.Enabled,
				MinRank = self.Settings.Interface.Logs.MinRank,
			},

			Suggestions = {
				allowExternalPlayerSearch = self.Settings.Interface.Suggestions.searchPlayersOutsideServer,
				externalSearchTagText = self.Settings.Interface.Suggestions.outsideServerTagText,
				externalSearchTagColor = _serializeColor(self.Settings.Interface.Suggestions.outsideServerTagColor),
			},

			iconPosition = self.Settings.Interface.Activation.iconButtonPosition,
			iconToolTip = self.Settings.Interface.Activation.iconToolTip,
			iconImageId = _handleImageIds(self.Settings.Interface.Activation.iconButtonImage),
			iconKeybind = _convertEnumToString(self.Settings.Interface.Activation.Keybind),

			maxUsersToSelectForRanking = self.Settings.Interface.maxUsersForSelection,
		},

		RankSticks = {
			Status = self.Settings.RankSticks.Enabled,
			Mode = self.Settings.RankSticks.Mode,
			clickOnPlayerRadius = self.Settings.RankSticks.clickOnPlayerRadius,
		},

		Misc = {
			ignoreWarnings = self.Settings.Misc.ignoreWarnings,
			showDebugMessages = self.Settings.Debug.logClientMessages,
		},
	}

	self:_debug("attributes", "Applying attributes.")
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
function api:_playerIsValidStaff(Player: Player | number | string): { Rank: number, User: Player }
	local userId = self:_verifyUser(Player, "Id") :: number
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
function api:_verifyUser(
	User: Player | number | string,
	typeToReturn: "UserId" | "Player" | "Name" | "Id"
): Player | number | string
	if typeof(User) == "Instance" and User:IsA("Player") then
		if typeToReturn == "UserId" or typeToReturn == "Id" then
			return User.UserId
		elseif typeToReturn == "Name" then
			return User.Name
		elseif typeToReturn == "Player" then
			return User
		end
	elseif typeof(User) == "string" then
		if typeToReturn == "UserId" or typeToReturn == "Id" then
			return (tonumber(User) or self:_getUserIdByName(User))
		elseif typeToReturn == "Name" then
			return User
		elseif typeToReturn == "Player" then
			return Players:FindFirstChild(User) :: Player
		end
	elseif typeof(User) == "number" then
		if typeToReturn == "UserId" or typeToReturn == "Id" then
			return User
		elseif typeToReturn == "Name" then
			return self:_getNameById(User)
		elseif typeToReturn == "Player" then
			return Players:GetPlayerByUserId(User) :: Player
		end
	end

	self:_debug(
		"user_verification",
		"Supplied user parameter does not match the types checked. ('" .. typeof(User) .. "')"
	)
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
	-- Rather than adding yet another request on top of the rate limit, why not
	-- just use the stored group id? Makes more sense in my mind, but we need
	-- to ensure that the key wasn't recently changed.
	if self.GroupId ~= -1 and not self._private.recentlyChangedKey then
		return self.GroupId
	end

	self._private.recentlyChangedKey = false
	local isOk, res = self:_http("/ranking/groupid", "post", nil :: any, nil)
	local Body = res.Body :: Types.groupIdResponse

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
): Types.responseBody
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
		self:_debug("set_rank", "Supplied UserId is not valid.")
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		}
	end

	if not tonumber(roleId) then
		self:_debug("set_rank", "Supplied RoleId is not valid.")
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

	local isOk, response: any = self:_http("/ranking/changerank", "post", nil :: any, body)

	if isOk and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, tonumber(userId) :: number)
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
		self:_debug("promote", "Supplied UserId is not valid.")
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		}
	end

	local _, response: any = self:_http("/ranking/promote", "post", nil :: any, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	})

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId :: number)
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
): Types.responseBody
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		self:_debug("demote", "Supplied UserId is not valid.")
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		}
	end

	local _, response: any = self:_http("/ranking/demote", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	})

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId :: number)
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
function api:Fire(User: Player | string | number, whoCalled: { userName: string, userId: number }?): Types.responseBody
	local userId = self:_verifyUser(User, "UserId")
	local userName = self:_verifyUser(User, "Name")

	if not whoCalled then
		whoCalled = {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	if not tonumber(userId) then
		self:_debug("fire", "Supplied UserId is not valid.")
		return {
			success = false,
			errorMessage = "Parameter 'userId' must be a valid number.",
		}
	end

	local _, response: any = self:_http("/ranking/fire", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	})

	if response.Success and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId :: number)
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
	commandAliases: { string? },
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
	local currentCommands = self._private.commandOperations
	local existingCommand = Table.Find(currentCommands, function(data)
		return string.lower(data.Name) == string.lower(commandName)
			or table.find(data.Alias, string.lower(commandName)) ~= nil
	end)

	if existingCommand then
		local isAttemptedCommandNameOverwrite = (string.lower(existingCommand.Name) == string.lower(commandName))
		local warningMessage = "Attempting to %s is not possible."

		self:_warn(
			string.format(
				warningMessage,
				(
					isAttemptedCommandNameOverwrite and "overwrite existing command name"
					or "create a command with an existing alias"
				)
			)
		)

		return false
	end

	commandAliases = Table.Map(commandAliases, function(data)
		return string.lower(tostring(data))
	end)

	local newData: any = {
		Name = string.lower(commandName),
		Alias = commandAliases,
		Enabled = true,
		Execute = commandOperation,
	}

	table.insert(self._private.commandOperations, newData)
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
		otherPlayer: Player,
		incomingArgument: string,
		internalFunctions: Types.vibezCommandFunctions
	) -> boolean,
	metaData: { [string]: boolean }?
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
			self:_warn(`Operation code '{operationCode}' already exists for the operation '{opName}'!`)
			return self
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
	local savedKey = self.apiKey

	self.apiKey = newApiKey
	self._private.recentlyChangedKey = true

	local groupId = self:getGroupId()
	if groupId == -1 and savedKey ~= nil then
		self.apiKey = savedKey
		self:_debug("update_key", "New api key '" .. newApiKey .. "' was invalid and was reverted to the previous one!")
		self:_warn("We attempted to update your API key, however it resulted in being invalid!")
		return false
	elseif groupId == -1 and not savedKey then
		self:_debug(
			"update_key",
			"Api key '"
				.. newApiKey
				.. "' was invalid! Please make sure there are no special characters or spaces in your key!"
		)
		warn(
			"[Vibez]: Hey! The API key provided was invalid! Please ensure your key has no special characters (including spaces). If this error persists, please DM our Support Bot.\n\n",
			debug.traceback(nil, 4)
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

	local theirCache = self._private.requestCaches.nitro[userId :: number]
	if theirCache ~= nil then
		local timestamp: number, value = theirCache.timestamp, theirCache.responseValue
		local now = DateTime.now().UnixTimestamp

		if timestamp - now > 0 then
			return value
		end
	end

	local isOk, response: any = self:_http(`/is-booster/{userId}`)
	if not isOk or (response.StatusCode == 200 and response.Body ~= nil and response.Body.success == false) then
		return false
	end

	local newCacheData = {
		responseValue = response.Body.isBooster,
		timestamp = DateTime.now().UnixTimestamp + (60 * 10), -- 10 minute offset
	}

	self._private.requestCaches.nitro[userId :: number] = newCacheData
	return newCacheData.responseValue
end

--[=[
	Destroys the VibezAPI class.

	@within VibezAPI
	@since 0.1.0
]=]
---
function api:Destroy()
	local fullMaid = Table.FlatMap(self._private.Maid, function(connectionValue: any)
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

	for _, userId: number? in pairs(self._private.usersWithSticks) do
		local user = Players:GetPlayerByUserId(userId :: number)
		if not user then
			continue
		end

		local userCharacter = user.Character :: Model
		if not userCharacter then
			userCharacter = user.CharacterAdded:Wait()
		end

		for _, item in pairs(userCharacter:GetChildren()) do
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
	self = nil :: never

	return nil
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
	blacklistExecutedBy: Player | string | number
): (Types.blacklistResponse | Types.errorResponse | Types.infoResponse)?
	local userId, reason, blacklistedBy =
		nil, (typeof(Reason) ~= "string" or Reason == "") and "Unknown." or Reason, nil

	if not userToBlacklist then
		self:_debug("add_blacklist", "An invalid user was supplied.")
		return nil
	elseif not blacklistExecutedBy then
		blacklistExecutedBy = -1
	end

	userId = self:_verifyUser(userToBlacklist, "UserId")
	blacklistedBy = self:_verifyUser(blacklistExecutedBy, "UserId")

	local isOk, response: any = self:_http(`/blacklists/{userId}`, "put", nil, {
		reason = reason,
		blacklistedBy = blacklistedBy,
	})

	if not isOk then
		self:_debug("add_blacklist", "An unexpected server issue occurred.")
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
function api:deleteBlacklist(
	userToDelete: Player | string | number
): (Types.blacklistResponse | Types.errorResponse | Types.infoResponse)?
	if not userToDelete then
		self:_debug("delete_blacklist", "An invalid user was supplied.")
		return nil
	end

	local userId = self:_verifyUser(userToDelete, "UserId")
	local isOk, response: any = self:_http(`/blacklists/{userId}`, "delete")

	if not isOk then
		self:_debug("delete_blacklist", "An unexpected server issue occurred.")
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
function api:getBlacklists(
	userId: (string | number | Player)?
): (Types.blacklistResponse | Types.errorResponse | Types.infoResponse)?
	userId = (userId ~= nil) and self:_verifyUser(userId, "UserId") or ""
	local isOk, response: any = self:_http(`/blacklists/{userId}`)

	if not isOk or not response.Success then
		self:_debug("get_blacklist", "An unexpected server issue occurred.")
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
		for _, value: { userId: (number | string)?, reason: string, blacklistedBy: number | string } in
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

	return res :: any
end

--[=[
	Gets either a full list of blacklists or checks if a player is currently blacklisted.
	@param User Player | string | number
	@return (boolean, string?, string?)

	@within VibezAPI
	@since 0.6.0
]=]
---
function api:isUserBlacklisted(User: Player | string | number): ...any
	local userId = self:_verifyUser(User, "Id")
	local blacklistData: any = self:getBlacklists(userId :: number) :: Types.userBlacklistResponse

	if blacklistData.success then
		local data = {
			blacklistData.data.blacklisted,
			blacklistData.data.reason,
			blacklistData.data.blacklistedBy,
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
	self:_warn("Method 'waitUntilLoaded' is deprecated and shouldn't be used in newer games.")
	self:_debug("deprecated_method_wait_until_loaded", "Attempted to use deprecated method.")
	return self.Loaded and self or nil

	-- if self.Loaded == true then
	-- 	return self
	-- end

	-- local counter = 0
	-- local maxCount = 25

	-- -- Remove 'repeat' and replace with something more performant and can cancel.
	-- repeat
	-- 	task.wait(1)
	-- 	counter += 1
	-- until self.Loaded == true or counter >= maxCount
end

--[=[
	Gets a player's or everyone's current activity
	@param User Player | string | number
	@return activityResponse

	@within VibezAPI
	@since 0.3.0
]=]
---
function api:getActivity(User: Player | string | number): Types.activityResponse | Types.errorResponse
	local userId = self:_verifyUser(User, "UserId")

	local body: any = { userId = userId }
	if User ~= nil and not userId then
		self:_debug("get_activity", "Supplied user was not valid.")
		return {
			success = false,
			errorMessage = "Invalid user was supplied.",
		} :: Types.errorResponse
	elseif not userId then
		body = nil
	end

	local _, result = self:_http("/activity/fetch2", "post", nil, body)
	return result.Body :: Types.activityResponse
end

--[=[
	Negates the player's activity seconds & message counts. (Does not clear detail logs array.)
	@param User Player | string | number
	@return boolean

	@yields
	@within VibezAPI
	@since 0.11.0
]=]
---
function api:removeActivity(User: Player | string | number): boolean
	local userId = self:_verifyUser(User, "UserId") :: number
	if not userId then
		self:_debug("remove_activity", "Supplied user was not valid.")
		return false
	end

	-- Get the current activity and negate the activity to remove it. (Temporary Solution)
	local currentActivity = self:getActivity(userId) :: Types.activityResponse
	if not currentActivity or not currentActivity["secondsUserHasSpent"] then
		self:_debug("remove_activity", "Internal server error.")
		return false
	end

	local userGroupInformation = self:_getGroupFromUser(self.GroupId, userId)

	local secondsSpent = currentActivity.secondsUserHasSpent
	local messagesSent = currentActivity.messagesUserHasSent
	local fixedSeconds, fixedMessages =
		(secondsSpent == 0) and 0 or -secondsSpent, (messagesSent == 0) and 0 or -messagesSent

	local response: any = self:saveActivity(userId, userGroupInformation.Rank, fixedSeconds, fixedMessages)
	return response.success or false
end

--[=[
	Saves the player's current activity
	@param User Player | string | number
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
	User: Player | string | number,
	userRank: number,
	secondsSpent: number?,
	messagesSent: (number | { string })?,
	shouldFetchGroupRank: boolean?
): (Types.infoResponse | Types.errorResponse)?
	local userId = self:_verifyUser(User, "UserId") :: number
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

	local _, response: any = self:_http("/activity/save2", "post", nil, {
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
function api:bindToAction(name: string, action: string, callback: (result: Types.responseBody) -> ()): Types.vibezApi
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
function api:unbindFromAction(name: string, action: string): Types.vibezApi
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

	if not isOk then
		self:Destroy()
		return setmetatable({}, {
			__index = function()
				warn(
					"[Vibez]:",
					"API Key was not accepted, please make sure there are no special characters or spaces."
				)
				return function() end
			end,
		})
	end

	-- UI communication handler
	local remoteFunction: any, remoteEvent: any = self:_createRemote()
	self._private.Function, self._private.Event = remoteFunction, remoteEvent
	remoteFunction, remoteEvent = nil, nil

	self:_debug("initialization", "Connecting RemoteFunction.")
	self._private.Function.OnServerInvoke = function(Player: Player, ...: any)
		return onServerInvoke(self, Player, ...)
	end

	self:_debug("initialization", "Connecting RemoteEvent.")
	table.insert(
		self._private.Maid,
		self._private.Event.OnServerEvent:Connect(function(Player: Player, ...: any)
			return onServerEvent(self, Player, ...)
		end)
	)

	-- Chat command connections
	self:_debug("initialization", "Connecting 'PlayerAdded' event.")
	table.insert(
		self._private.Maid,
		Players.PlayerAdded:Connect(function(Player)
			self:_onPlayerAdded(Player)
		end)
	)

	self:_debug("initialization", "Connecting 'PlayerAdded' event to existing players in game.")
	for _, Player in pairs(Players:GetPlayers()) do
		coroutine.wrap(self._onPlayerAdded)(self, Player)
	end

	-- Connect the player's maid cleanup function.
	self:_debug("initialization", "Connecting 'PlayerRemoving' event.")
	table.insert(
		self._private.Maid,
		Players.PlayerRemoving:Connect(function(Player)
			self:_onPlayerRemoved(Player)
		end)
	)

	-- Initialize the workspace attribute
	self:_debug("initialization", "Building attributes for client.")
	self:_buildAttributes()

	-- Track activity
	if self.Settings.ActivityTracker.Enabled then
		self:_debug("activity_tracker_initialization", "Connecting 'Heartbeat' event.")
		table.insert(
			self._private.Maid,
			RunService.Heartbeat:Connect(function()
				-- Perform this check again in case the setting changes in game.
				if self.Settings.ActivityTracker.Enabled == true then
					for _, data in pairs(self._private.requestCaches.validStaff) do
						if data.Tracker == nil then
							continue
						end

						data.Tracker:Increment()
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
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi?
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
		:::info
		Hey there! We recommend beginning at the introduction page! [Click Here](/docs/intro)
		:::
	]=]

	api.__index = api

	-- No autofill for this section, can't get Luau-LSP to work well with this.
	local self = setmetatable({}, api) :: any

	--[=[
		@prop Version string
		@since 0.11.0
		@within VibezAPI
		A string containing the current loaded version of the wrapper.
	]=]
	self.Version = _VERSION

	--[=[
		@prop isVibez boolean
		@since 0.11.0
		@within VibezAPI
		A boolean to determine whether the wrapper is indeed related to Vibez.
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
		@prop _private {Event: RemoteEvent?, Function: RemoteFunction?, _initialized: boolean, _lastVersionCheck: number, recentlyChangedKey: boolean, newApiUrl: string, clientScriptName: string, rateLimiter: RateLimit, externalConfigCheckDelay: number, lastLoadedExternalConfig: boolean, Maid: {[number]: {RBXScriptConnection?}}, Cooldowns: {Ranking:{[number]: number},Blacklisting:{[number]: number}}, usersWithSticks: {number}, stickTypes: string, requestCaches: {nitro: {any}, validStaff: {number}, groupInfo: {[number]: {any}?}}, commandOperations: {any}, commandOperationCodes: {[string]: {Code: string, Execute: (playerWhoFired: Player, playerToCheck: Player, incomingArgument: string) -> boolean}}, Binds: {[string]: {[string]: (...any) -> any?}}}
		@since 0.1.0
		@private
		@within VibezAPI
		From caches to simple booleans/instances/numbers, this table holds all the information necessary for this API to work. 
	]=]
	self._private = {
		Event = nil,
		Function = nil,

		_initialized = false,

		recentlyChangedKey = false,
		newApiUrl = "https://leina.vibez.dev",

		clientScriptName = table.concat(string.split(HttpService:GenerateGUID(false), "-"), ""),
		rateLimiter = RateLimit.new(60, 60),

		externalConfigCheckDelay = 600, -- 600 = 10 minutes | Change below if changed
		lastLoadedExternalConfig = DateTime.now().UnixTimestamp - 600,

		Maid = {},
		Cooldowns = {
			Ranking = table.create(#Players:GetPlayers()),
			Blacklisting = table.create(#Players:GetPlayers()),
		},

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
				["default"] = "DetectionInFront",
				["detectioninfront"] = "DetectionInFront",
				["clickonplayer"] = "ClickOnPlayer",
			},
		},

		actionStorage = {
			Bans = {},
			Logs = {},
		},
		commandOperations = {},
		commandOperationCodes = {},
	}

	-- We'll have to set the settings debug/warning messages before
	-- the settings check so that debug/warnings print properly.
	self.Settings.Debug.logMessages = (
		extraOptions
		and extraOptions["Debug"] ~= nil
		and typeof(extraOptions["Debug"]["logMessages"]) == "boolean"
		and extraOptions["Debug"]["logMessages"]
	) or baseSettings.Debug.logMessages
	self.Settings.Debug.logClientMessages = (
		extraOptions
		and extraOptions["Debug"] ~= nil
		and typeof(extraOptions["Debug"]["logClientMessages"]) == "boolean"
		and extraOptions["Debug"]["logClientMessages"]
	) or baseSettings.Debug.logClientMessages
	self.Settings.Misc.ignoreWarnings = (
		extraOptions
		and extraOptions["Misc"] ~= nil
		and typeof(extraOptions["Misc"]["ignoreWarnings"]) == "boolean"
		and extraOptions["Misc"]["ignoreWarnings"]
	) or baseSettings.Misc.ignoreWarnings

	--/ Command Operation Codes \--
	self:addArgumentPrefix(
		"shortenedUsername",
		"",
		function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
			return string.sub(string.lower(playerToCheck.Name), 0, string.len(incomingArgument))
				== string.lower(incomingArgument)
		end
	)

	self:addArgumentPrefix("externalUser", "e:", function(_: Player, _: Player, incomingArgument: string): any
		local name, id
		local arg = tonumber(incomingArgument)

		if arg then
			local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, arg)

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
	end, { isExternal = true })

	self:addArgumentPrefix("Rank", "r:", function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
		local rank, tolerance = table.unpack(string.split(incomingArgument, ":"))
		local rankToCheck = tonumber(rank)

		if not rankToCheck then
			return false
		end

		tolerance = tolerance or "<="

		local isOk, currentPlayerRank = pcall(playerToCheck.GetRankInGroup, playerToCheck, rankToCheck)
		if not isOk or currentPlayerRank == 0 then
			return false
		end

		if tolerance == "<=" then
			return currentPlayerRank <= rankToCheck
		elseif tolerance == ">=" then
			return currentPlayerRank >= rankToCheck
		elseif tolerance == "<" then
			return currentPlayerRank < rankToCheck
		elseif tolerance == ">" then
			return currentPlayerRank > rankToCheck
		elseif tolerance == "==" then
			return currentPlayerRank == rankToCheck
		end

		return false
	end)

	self:addArgumentPrefix("Team", "%", function(_: Player, playerToCheck: Player, incomingArgument: string): boolean
		return playerToCheck.Team
			and string.sub(string.lower(playerToCheck.Team.Name), 0, #incomingArgument)
				== string.lower(incomingArgument)
	end)

	--/ Configuration Fixing \--
	local wereOptionsAttempted = not (extraOptions == nil)
	extraOptions = (typeof(extraOptions) == "table") and extraOptions or {} :: Types.vibezSettings

	if Table.Count(extraOptions) == 0 and wereOptionsAttempted then
		self:_warn("Extra options have an error associated with them, reverting to default options...")
	end

	-- Only run the settings check if extra options were changed.
	if wereOptionsAttempted then
		if extraOptions and extraOptions["Debug"] ~= nil and extraOptions.Debug["logMessages"] then
			self.Settings.Debug = extraOptions.Debug
		else
			self.Settings.Debug = baseSettings.Debug
		end

		-- Recursively fixes the settings table with custom logic for certain sections.
		local modified = checkingMethods.settingsCheck(self, extraOptions, baseSettings, "Settings")
		modified = checkingMethods.applyMissing(self, modified, baseSettings)
		local removedUnknownKeys, removalCount = checkingMethods.removeNilChecks(self, modified)

		self.Settings = removedUnknownKeys
		self:_debug("settings_nil_keys_removal", "Removed '" .. removalCount .. "' unknown keys.")
	end

	--/ Configuration Setup \--
	-- Only add "sticks" command when rank sticks is enabled.
	if self.Settings.RankSticks.Enabled == true then
		self:addCommand("sticks", {}, function(Player: Player)
			local staffData = self:_playerIsValidStaff(Player)
			if not staffData or staffData.Rank == nil or staffData.Rank < self.Settings.RankSticks.MinRank then
				return
			end

			local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
			local Character = Player.Character
			if not Character then
				return
			end

			local foundSticks = Table.Filter(
				Table.Assign(Character:GetChildren(), Player.Backpack:GetChildren()),
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

		-- Remove the other commands, that way sticks is the only command possible.
		if not self.Settings.Commands.Enabled then
			self.Settings.Commands.Removed = { "Promote", "Demote", "Fire", "Blacklist", "Unblacklist" }
		end

		-- We need to ensure that the module is indeed setting up
		-- commands, otherwise sticks can never be given.
		self.Settings.Commands.Enabled = true
	end

	if self.Settings.Notifications.Enabled == true then
		self:addCommand("notify", { "notification" }, function(Player: Player, ...: any)
			local Args, addLog, getUsersForCommands = ...

			local Users = getUsersForCommands(Player, string.split(Args[1], ","), true)
			local usernameColor = generateNameColorForNotification(Player.Name):ToHex()
			local prefix = string.format('[<font color="#%s">%s</font>]: ', usernameColor, Player.Name)
			local message = (#Args == 1) and "" or table.concat(Args, " ", 2, #Args)

			if #Users == 0 then
				self:notifyPlayer(Player, "Please specify who you'd like to send a notification to.")
				return
			end

			for _, user in ipairs(Users) do
				self:notifyPlayer(user, prefix .. message)
			end

			addLog(Player, "Notification", "Commands", Users)
		end)
	end

	-- Add rest of the commands when "Commands" is enabled.
	if self.Settings.Commands.Enabled == true then
		self:_setupCommands()
	end

	-- (DEPRECATED)
	-- Useful for when you want to require at the top of a script
	-- and you don't want it to yield as it gathers necessary api data.
	-- ie, fetching group data & external-config
	-- if self.Settings.Misc.isAsync then
	-- 	coroutine.wrap(self._initialize)(self, apiKey)
	-- else
	-- 	self:_initialize(apiKey)
	-- end
	self:_initialize(apiKey)

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

	_privateKeys[self.apiKey] = self._private.clientScriptName
	TestService:Message(string.format("Vibez v%s has successfully been loaded into this server!", _VERSION))

	self.Loaded = true

	-- Cast to the Vibez API Type.
	return self :: Types.vibezApi
end

--[=[
	@function getGlobalsForKey
	Awaits for the Global API to be loaded.
	@param apiKey string
	@return Folder?

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

	awaitGlobals = function(): ()
		warn("[Vibez]: Method 'awaitGlobals' is deprecated, please use 'getGlobalsForKey' instead.")

		-- _G Api is removed in this version.
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

	getGlobalsForKey = function(apiKey: string): Folder?
		local vibezKey: string? = _privateKeys[apiKey]
		return (vibezKey ~= nil) and ServerStorage:FindFirstChild(vibezKey) :: Folder or nil
	end,

	getGUIDFromKey = function(apiKey: string): string?
		return _privateKeys[apiKey] :: string?
	end,

	new = Constructor,
}, {
	__call = function(t: { [any]: any }, apiKey: string, options: Types.vibezSettings?): Types.vibezApi?
		return rawget(t, "new")(apiKey, options)
	end :: Types.vibezConstructorCall,
})

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

-- Commands
--[=[
	@interface commandOptions
	.Enabled boolean
	.useDefaultNames boolean
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.Prefix string
	.Alias {[string]: string}
	.Removed {string?}
	@private
	@within VibezAPI
]=]

-- RankSticks
--[=[
	@interface rankStickOptions
	.Enabled boolean
	.Mode "Default" | "ClickOnPlayer" | "DetectionInFront"
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.sticksModel (Model | Tool)?
	.Removed {string?}
	.Animation { R6: number, R15: number }
	@private
	@within VibezAPI
]=]

-- Notifications
--[=[
	@interface notificationsOptions
	.Enabled boolean
	.Font Enum.Font
	.FontSize number
	.keyboardFontMultiplier number
	.delayUntilRemoval number
	.entranceTweenInfo { Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }
	.exitTweenInfo { Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }
	@private
	@within VibezAPI
]=]

-- Interface
--[=[
	@interface interfaceOptions
	.Enabled boolean
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.maxUsersForSelection number
	.Suggestions { searchPlayersOutsideServer: boolean, outsideServerTagText: string, outsideServerTagColor: BrickColor | Color3 }
	.Activation { Keybind: Enum.KeyCode, iconButtonPosition: "Center" | "Left" | "Right", iconButtonImage: string, iconToolTip: string }
	.nonViewableTabs { string? }
	@private
	@within VibezAPI
]=]

-- Logs
--[=[
	@interface loggingOptions
	.Enabled boolean
	.MinRank number<0-255>
	@private
	@within VibezAPI
]=]

-- Activity Tracker
--[=[
	@interface activityTrackerOptions
	.Enabled boolean
	.MinRank number<0-255>
	.disableWhenInStudio boolean
	.disableWhenInPrivateServer boolean
	.disableWhenAFK boolean
	.delayBeforeMarkedAFK number
	.kickIfFails boolean
	.failMessage string
	@private
	@within VibezAPI
]=]

-- Cooldowns
--[=[
	@interface cooldownOptions
	.Enabled boolean
	.Ranking number
	.Blacklisting number
	@private
	@within VibezAPI
]=]

-- Misc
--[=[
	@interface miscOptions
	.originLoggerText string
	.ignoreWarnings boolean
	.overrideGroupCheckForStudio boolean
	.createGlobalVariables boolean
	@private
	@within VibezAPI
]=]

-- Debug
--[=[
	@interface debugOptions
	.logMessages boolean
	@private
	@within VibezAPI
]=]

-- Base
--[=[
	@interface extraOptionsType
	.Commands commandOptions
	.RankSticks rankStickOptions
	.Notifications notificationsOptions
	.Interface interfaceOptions
	.ActivityTracker activityTrackerOptions
	.Cooldowns cooldownOptions
	.Misc miscOptions
	.Debug debugOptions
	@within VibezAPI
]=]
