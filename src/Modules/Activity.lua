--!nocheck
--// Services \\--
local RunService = game:GetService("RunService")

--// Variables \\--
local Activity = { Keys = {}, Processing = {} }
local Class = {}
Class.__index = Class

--[=[
    @class ActivityTracker
    Main tracker for player instances, holding information like when they're AFK and how long they've been in game.
]=]

--[=[
    @prop _api VibezAPI
    @private
    @within ActivityTracker
]=]

--[=[
    @prop _player Player
    @private
    @within ActivityTracker
]=]

--[=[
    @prop _seconds number
    @private
    @within ActivityTracker
]=]

--[=[
    @prop _messages number
    @private
    @within ActivityTracker
]=]

--[=[
    @prop _increment number
    @private
    @within ActivityTracker
]=]

--[=[
    @prop isLeaving boolean
    @readonly
    @within ActivityTracker
]=]

--[=[
    @prop isAfk boolean
    @readonly
    @within ActivityTracker
]=]

local Types = require(script.Parent.Internal.Types)

--[=[
	Creates a new activity object for the player.
	@param VibezAPI VibezAPI
	@param forPlayer Player
	@return ActivityTracker

	@yields
	@within ActivityTracker
	@since 1.0.0
]=]
---
function Activity.new(VibezAPI: Types.vibezApi, forPlayer: Player): Types.ActivityTracker?
	if typeof(VibezAPI) ~= "table" or VibezAPI["isVibez"] ~= true then
		return nil
	end

	-- Await a random number to ensure processing is in effect at different load-times.
	local RNG = Random.new(tick())
	task.wait(RNG:NextNumber())

	-- This should prevent the creation of multiple activity trackers for 1 player.
	local existsInTable = table.find(Activity.Processing, forPlayer.UserId)
	if existsInTable then
		repeat
			task.wait(1)
			existsInTable = table.find(Activity.Processing, forPlayer.UserId)
		until not existsInTable
	end

	-- Rotate the characters within the key to prevent any bad-actors. (If this module ends up in a client-replicated service)
	local reversedKey = VibezAPI._private._modules.Utils.rotateCharacters(string.reverse(VibezAPI.Settings.apiKey), 128)
	local keyTracker = Activity.Keys[reversedKey] or {}
	local existingTracker = keyTracker[forPlayer.UserId]

	-- We need to ensure the API Key matches both version of the wrapper that was provided
	if existingTracker and existingTracker._token == reversedKey then
		return existingTracker
	end

	table.insert(Activity.Processing, forPlayer.UserId)

	local self = setmetatable({}, Class)

	self.isLeaving = false
	self.isAfk = false

	self._token = reversedKey
	self._api, self._player = VibezAPI, forPlayer
	self._seconds, self._messages, self._afkCounter, self._increment = 0, 0, 0, 1
	self._lastCheck = DateTime.now().UnixTimestamp
	self._groupData = self._api:_getGroupFromUser(self._api.GroupId, forPlayer.UserId)

	if not self._groupData then
		self._api:_warn(
			string.format(
				"Activity tracker failed to load group rank for %s! This has resulted in activity not tracking this user!",
				tostring(forPlayer)
			)
		)

		if self._api.Settings.shouldKickPlayerIfActivityTrackerFails == true then
			forPlayer:Kick("[Activity Tracker]: " .. self._api.Settings.activityTrackerFailedMessage)
		end

		self:Destroy()
		table.remove(Activity.Processing, table.find(Activity.Processing, forPlayer.UserId))
		return nil
	end

	self._api:_warn(string.format("Setting up activity tracking for %s.", tostring(forPlayer)))

	keyTracker[self._player.UserId] = self
	Activity.Keys[reversedKey] = keyTracker

	table.insert(self._api._private.Binds._internal["Afk"], function(Player: Player, override: boolean?)
		local existingClass = Activity.Keys[reversedKey][Player.UserId]
		if not existingClass then
			return
		end

		if override == nil then
			override = not existingClass.isAfk
		end

		existingClass.isAfk = override
	end)

	table.remove(Activity.Processing, table.find(Activity.Processing, forPlayer.UserId))
	return self
end

--// Public Methods \\--
--[=[
    Increments the player's seconds.
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:Increment()
	if self.isLeaving or DateTime.now().UnixTimestamp - self._lastCheck < 1 then
		return
	end

	self._lastCheck = DateTime.now().UnixTimestamp

	if self.isAfk then
		self._afkCounter += 1

		if self._afkCounter ~= 0 and self._afkCounter % 30 == 0 then
			self._api:_warn(self._player.Name .. " has been marked AFK for " .. self._afkCounter .. " seconds!")
		end
		return
	end

	self._afkCounter = 0
	self._seconds += self._increment
end

--[=[
    Increments the player's chat messages.
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:Chatted()
	self._messages += 1
end

--[=[
    Sets the player's state to 'Leaving'.
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:Left()
	if self.isLeaving then
		return
	end

	self.isLeaving = true

	if RunService:IsStudio() and self._api.Settings.ActivityTracker.disableWhenInStudio == true then
		self._api:_warn(
			string.format(
				"Saving activity has been disabled when playing in studio. Here's what we tracked\nUser: %s (%d)\nSeconds spent: %d\nMessages sent: %d",
				self._player.Name,
				self._player.UserId,
				self._seconds,
				self._messages
			)
		)
		return
	end

	self._api:saveActivity(self._player.UserId, self._groupData.Rank, self._seconds, self._messages)
	self._api:_warn(string.format("User left and sent activity data for %s.", tostring(self._player)))
	self:Destroy()
end

--[=[
    Destroys the class.
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:Destroy()
	Activity.Keys[self._token][self._player.UserId] = nil

	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

return Activity
