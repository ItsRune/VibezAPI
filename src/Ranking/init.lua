--[=[
	@class VibezRanking
	A sub-class that allows for ranking services despite VibezAPI, being taken down.
]=]
---

--[=[
	@interface successfulResponse
	.success: boolean
	.message: string
	.data: { any }?

	@within VibezRanking
]=]
---

--[=[
	@interface errorResponse
	.success boolean
	.errorMessage string

	@within VibezRanking
]=]
---

--[=[
	@type Response errorResponse | successfulResponse
	@within VibezRanking
]=]
---

--[=[
	@type User Player | string | number
	@within VibezRanking
]=]
---

--// Services \\--
local HttpService = game:GetService("HttpService")

--// Modules \\--
local Types = require(script.Types)
local verifyUser = require(script.verifyUser)
local Http = require(script.Http)

--// Variables \\--
local Class = {}
Class.__index = Class

--// Private Functions \\--
local function Constructor(apiKey: string): Types.rankingModule
	local self = setmetatable({}, Class)

	self._apiKey = apiKey

	return self
end

--// Class Methods \\--
--[=[
	Gets the role id of a rank.
	@param rank number | string
	@return number?

	@yields
	@private
	@within VibezRanking
	@since 0.1.0
]=]
---
function Class:_getRoleIdFromRank(rank: number | string): number?
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
	Handles API request calls to Vibez servers.
	@return number?

	@yields
	@private
	@within VibezRanking
	@since 0.1.0
]=]
---
function Class:_http(...: any): Types.Response
	local data = { ... }
	local headers = data[3]

	if typeof(headers) ~= "table" then
		headers = {}
	end

	headers["x-api-key"] = self._apiKey
	data[3] = headers

	return Http(table.unpack(data))
end

--[=[
	Sets the rank of a defined user.
	@param User User
	@return Response

	@within VibezRanking
	@since 0.1.0
	@yields
]=]
---
function Class:setRank(
	User: Types.User,
	newRank: number | string,
	whoCalled: { userName: string, userId: number }?
): Types.Response
	local userId = verifyUser(User, "UserId")
	local userName = verifyUser(User, "Name")
	local roleId = self:_getRoleIdFromRank(newRank)

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

	local isOk, response = self:_http("/ranking/changerank", "post", nil, body)

	if isOk and response.Body and response.Body["success"] == true then
		coroutine.wrap(self._checkPlayerForRankChange)(self, userId)
	end

	return response.Body
end

--[=[
	Promotes a player within a group.
	@param userId User
	@return Response

	@yields
	@within VibezRanking
	@since 0.1.0
]=]
---
function Class:Promote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.Response
	userId = verifyUser(userId, "UserId")

	local userName = verifyUser(userId, "Name")

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

	return response
end

--[=[
	Demotes a player and `whoCalled` (Optional) is used for logging purposes.
	@param userId User
	@return rankResponse

	@yields
	@within VibezRanking
	@since 0.1.0
]=]
---
function Class:Demote(userId: Types.User, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	userId = verifyUser(userId, "UserId")

	local userName = verifyUser(userId, "Name")

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

	return response
end

--[=[
	Fires a player and `whoCalled` (Optional) is used for logging purposes.
	@param userId User
	@return rankResponse

	@yields
	@within VibezRanking
	@since 0.1.0
]=]
---
function Class:Fire(userId: Types.User, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	userId = verifyUser(userId, "UserId")

	local userName = verifyUser(userId, "Name")

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

	return response
end

return Constructor
