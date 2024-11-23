--[=[
	@class Activity
]=]

local Types = require(script.Parent.Parent.Types)
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

		local response = self.base.Utils:Http({
			Url = "/activity/fetch2",
			Method = "Post",
			Body = {
				userId = userId,
			},
		})

		return response.Body.Success, response.Body.errorMessage
	end

	local response = self.base.Utils:Http({
		Url = "/activity/fetch2",
		Method = "Post",
	})

	return response.Body.Success, response.Body.errorMessage
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
	local userId = self:_verifyUser(User, "UserId") :: number
	assert(userId, "Invalid User was supplied.")

	return false, "Not implemented"

	-- Get the current activity and negate the activity to remove it. (Temporary Solution)
	-- local currentActivity = self:Get(userId)
	-- if not currentActivity or not currentActivity["secondsUserHasSpent"] then
	-- 	self:_debug("remove_activity", "Internal server error.")
	-- 	return false
	-- end

	-- local userGroupInformation = self:_getGroupFromUser(self.GroupId, userId)

	-- local secondsSpent = currentActivity.secondsUserHasSpent
	-- local messagesSent = currentActivity.messagesUserHasSent
	-- local fixedSeconds, fixedMessages =
	-- 	(secondsSpent == 0) and 0 or -secondsSpent, (messagesSent == 0) and 0 or -messagesSent

	-- local response: any = self:saveActivity(userId, userGroupInformation.Rank, fixedSeconds, fixedMessages)
	-- return response.success or false
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

	return false, "Not implemented."

	-- local userId = self:_verifyUser(User, "UserId") :: number
	-- messagesSent = (typeof(messagesSent) == "table") and #messagesSent
	-- 	or (tonumber(messagesSent) ~= nil) and messagesSent
	-- 	or nil
	-- userRank = (typeof(userRank) == "number" or tonumber(userRank) ~= nil) and userRank or -1

	-- if not tonumber(messagesSent) then
	-- 	local errMessage = "Cannot save activity with an invalid 'number' as the 'messagesSent' parameter!"
	-- 	self:_warn(errMessage)
	-- 	return {
	-- 		success = false,
	-- 		errorMessage = errMessage,
	-- 	}
	-- elseif not tonumber(secondsSpent) then
	-- 	local errMessage = "Cannot save activity with an invalid 'number' as the 'secondsSpent' parameter!"
	-- 	self:_warn(errMessage)
	-- 	return {
	-- 		success = false,
	-- 		errorMessage = errMessage,
	-- 	}
	-- end

	-- if shouldFetchGroupRank == true then
	-- 	local groupData = self:_getGroupFromUser(self.GroupId, userId)

	-- 	if typeof(groupData) ~= "table" then
	-- 		self:_warn(`Could not fetch group data.`)
	-- 		return
	-- 	end

	-- 	userRank = groupData.Rank
	-- end

	-- secondsSpent, messagesSent = tonumber(secondsSpent), tonumber(messagesSent)

	-- local _, response: any = self:_http("/activity/save2", "post", nil, {
	-- 	userId = userId,
	-- 	userRank = userRank,
	-- 	secondsUserHasSpent = secondsSpent,
	-- 	messagesUserHasSent = messagesSent,
	-- })

	-- return response.Body
end

--[=[
	TODO: Method needs implementation!
	@within Activity
]=]
function Env:Remove(User: Types.UserKind, secondsToRemove: number?, messagesToRemove: number?): (boolean, string)
	secondsToRemove = tonumber(secondsToRemove) or 0
	messagesToRemove = tonumber(messagesToRemove) or 0

	assert(
		secondsToRemove ~= 0 or messagesToRemove ~= 0,
		"Both 'secondsToRemove' and 'messagesToRemove' parameters are set to 0!"
	)

	return false, "Not implemented."
end

return function(parent: Types.VibezLightWeight): Types.VibezActivityPackage
	return setmetatable({
		base = parent,
	}, Env) :: Types.VibezActivityPackage
end
