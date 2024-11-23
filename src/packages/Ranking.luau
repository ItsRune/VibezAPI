--[=[
    @class Ranking
]=]

local Types = require(script.Parent.Parent.Types)
local Env = {}

--[=[
	Sets the rank of a user.
	@param User string | number
	@param whoCalled { userName: string, userId: number }?
	@param rankId string | number
	@return (boolean, string)

	```lua
	local isOk, message = Vibez.Ranking:setRank("roblox", 1)
	```

	@within Ranking
]=]
function Env:setRank(
	User: string | number,
	rankId: number,
	whoCalled: { userName: string, userId: number }?
): (boolean, string)
	assert(tonumber(rankId), "Please ensure the 'rankId' parameter is a valid number!")

	local userName = self.base:verifyUser(User, "Name")
	local userId = self.base:verifyUser(User, "Id")

	local response = self.base.Utils:Http({
		Url = "/ranking/changerank",
		Method = "post",
		Body = {
			userToRank = {
				userId = tonumber(userId),
				userName = userName,
			},
			userWhoRanked = {
				userName = "SYSTEM",
				userId = -1,
			},
			userId = tonumber(userId),
			rankId = tonumber(rankId),
		},
	})

	return response.Body.Success, response.Body.message
end

--[=[
	Promotes the user within the group.
	@param User string | number
	@param whoCalled { userName: string, userId: number }?
	@return (boolean, string)

	```lua
	local isOk, message = Vibez.Ranking:Promote("roblox")
	```
	
	@within Ranking
]=]
function Env:Promote(User: string | number, whoCalled: { userName: string, userId: number }?): (boolean, string)
	local userId = self.base:verifyUser(User, "Id")
	local response = self.base.Utils:Http({
		Url = "/ranking/promote",
		Method = "Post",
		Body = {
			userId = userId,
		},
	})

	return response.Body.Success, response.Body.message
end

--[=[
	Demotes the user within the group.
	@param User string | number
	@param whoCalled { userName: string, userId: number }?
	@return (boolean, string)

	```lua
	local isOk, message = Vibez.Ranking:Demote("roblox")
	```
	
	@within Ranking
]=]
function Env:Demote(User: string | number, whoCalled: { userName: string, userId: number }?): (boolean, string)
	local userId = self.base:verifyUser(User, "Id")
	local response = self.base.Utils:Http({
		Url = "/ranking/demote",
		Method = "Post",
		Body = {
			userId = userId,
		},
	})

	return response.Body.Success, response.Body.message
end

--[=[
	Fires the user within the group.
	@param User string | number
	@param whoCalled { userName: string, userId: number }?
	@return (boolean, string)

	```lua
	local isOk, message = Vibez.Ranking:Fire("roblox")
	```
	
	@within Ranking
]=]
function Env:Fire(User: string | number, whoCalled: { userName: string, userId: number }?): (boolean, string)
	local userId = self.base:verifyUser(User, "Id")
	local response = self.base.Utils:Http({
		Url = "/ranking/fire",
		Method = "Post",
		Body = {
			userId = userId,
		},
	})

	return response.Body.Success, response.Body.message
end

return function(parent: Types.VibezLightWeight): Types.VibezRankingPackage
	return setmetatable({
		base = parent,
	}, Env) :: Types.VibezRankingPackage
end
