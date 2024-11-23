--!strict
--[=[
	@class Activity
]=]

local Cache = require(script.Parent.Parent.classes.Cache)
local Types = require(script.Parent.Parent.Types)

local ACTIVITY_REFRESH_RATE = 45 -- Seconds
local Env = {}

--[=[
	Gets a player's current activity for this week (leave blank if you'd like everyone's).
	@param User (Player | string | number)?
	@return (boolean, number)

	@yields
	@within Activity
]=]
---
function Env:Get(User: Types.UserKind?): (boolean, { [any]: any })
	if User ~= nil then
		local userId = self:_verifyUser(User, "UserId")
		assert(userId, "Supplied User was not valid.")

		local cachedData = self.Cache:Get(userId)
		local now = DateTime.now().UnixTimestamp
		if cachedData ~= nil and now - cachedData.Refresh < ACTIVITY_REFRESH_RATE then
			return true, cachedData.Data
		end

		local response = self.base.Utils:Http({
			Url = "/activity/fetch2",
			Method = "Post",
			Body = {
				userId = userId,
			},
		})

		if response.Success then
			self.Cache:Remove(userId)
			self.Cache:Add(userId, {
				Data = response.Body,
				Refresh = now,
			})
		end

		return response.Success, response.Body
	end

	local response = self.base.Utils:Http({
		Url = "/activity/fetch2",
		Method = "Post",
	} :: any)

	return response.Success, response.Body.errorMessage
end

--[=[
	Negates the player's activity seconds & message counts. (Does not clear detailed logs.)
	@param User Player | string | number
	@return (boolean, string)

	```lua
	local isOk, message = Vibez.Activity:Delete("roblox")
	```

	@yields
	@within Activity
]=]
---
function Env:Delete(User: Types.UserKind): (boolean, string)
	local userId = self.base.Utils:verifyUser(User, "UserId")
	assert(userId, "Invalid User was supplied.")

	local activityFetchOk, currentActivity = self:Get(userId)
	assert(activityFetchOk, "Internal Server Error: Failed to fetch User's current activity!")

	return self:Add(userId, -currentActivity.secondsUserHasSpent, -currentActivity.messagesUserHasSent)
end

--[=[
	Saves the player's current activity
	@param User Player | string | number
	@param secondsSpent number
	@param messagesSent (number | { string })?
	@return (boolean, string)

	@yields
	@within Activity
]=]
---
function Env:Add(User: Types.UserKind, secondsSpent: number?, messagesSent: (number | { string })?): (boolean, string)
	local userId = self.base.Utils:verifyUser(User, "Id")
	assert(userId, "Invalid User was supplied.")
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent
		or (typeof(messagesSent) == "number") and messagesSent
		or 0
	secondsSpent = tonumber(secondsSpent) or 0

	local userRank = self.base.Utils:getGroupRankFromUser(self.base.GroupId, userId)
	local response = self.base.Utils:Http({
		Url = "/activity/save2",
		Method = "post",
		Body = {
			userId = userId,
			userRank = userRank,
			secondsUserHasSpent = secondsSpent,
			messagesUserHasSent = messagesSent,
		},
	})

	return response.Success, response.Body.message
end

--[=[
	Removes seconds or messages from a user's activity total.
	@param User Player | string | number
	@param secondsToRemove number
	@param messagesToRemove number
	@return (boolean, string)
	@within Activity
]=]
function Env:Remove(User: Types.UserKind, secondsToRemove: number, messagesToRemove: number): (boolean, string)
	secondsToRemove = tonumber(secondsToRemove) or 0
	messagesToRemove = tonumber(messagesToRemove) or 0

	assert(User ~= nil, "Please specify a User to remove activity from.")
	assert(
		secondsToRemove ~= 0 or messagesToRemove ~= 0,
		"Both 'secondsToRemove' and 'messagesToRemove' parameters are set to 0!"
	)

	if math.abs(secondsToRemove) == secondsToRemove then
		secondsToRemove = -secondsToRemove
	end

	if math.abs(messagesToRemove) == messagesToRemove then
		messagesToRemove = -messagesToRemove
	end

	return self:Add(User, secondsToRemove, messagesToRemove)
end

return function(parent: Types.VibezLightWeight): Types.VibezActivityPackage
	return setmetatable({
		base = parent,
		Cache = Cache.new(),
	}, Env :: any) :: Types.VibezActivityPackage
end
