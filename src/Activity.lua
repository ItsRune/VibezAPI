--// Variables \\--
local Activity = { Users = {} }
local Class = {}
Class.__index = Class

--[=[
    @class ActivityTracker
    An OOP class that handles updating/fetching/subtracting a user's timed activity.
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

local Types = require(script.Parent.Types)
local activityRouter = Instance.new("RemoteEvent")

activityRouter.OnServerEvent:Connect(function(Player: Player)
	local existingClass = Activity.Users[Player.UserId]

	if not existingClass then
		return
	end

	existingClass:changeAfkState(not existingClass.isAfk)
end)

--[=[
    Creates a new activity object for the player.
    @param forPlayer Player
    @return ActivityTracker

    @ignore
    @within ActivityTracker
    @since 1.0.0
]=]
---
function Activity.new(VibezAPI: Types.VibezAPI, forPlayer: Player): Types.ActivityTracker
	local self = setmetatable({}, Class)

	self._api = VibezAPI
	self._player = forPlayer
	self._seconds = 0
	self._messages = 0
	self._increment = 1
	self._lastCheck = DateTime.now().UnixTimestamp
	self.isLeaving = false
	self.isAfk = false

	Activity.Users[self._player.UserId] = self
	return self
end

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
		self._api:_warn(self._player.Name .. " is marked AFK and cannot earn activity.")
		return
	end

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
	self.isLeaving = true
	self._api:saveActivity(self._player, self._seconds, self._messages)
end

--[=[
    Toggles if the player is afk or not.
    @param override boolean?
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:changeAfkState(override: boolean?): Types.ActivityTracker
	local isToggled = self.isAfk

	if override ~= nil then
		isToggled = not override -- Flip the boolean so it doesn't cause issues below.
	end

	self.isAfk = not isToggled
end

--[=[
    Destroys the class.
    @return nil

    @within ActivityTracker
    @since 1.0.0
]=]
---
function Class:Destroy()
	Activity.Users[self._player.UserId] = nil

	setmetatable(self, nil)
	self = nil
end

return Activity