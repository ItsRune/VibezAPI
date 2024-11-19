--// Services \\--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// Modules \\--
local _Types = require(script.Types)

--// Variables \\--
--[=[
    @class VibezLite
]=]

local VibezLite = {}
local Class = {}

Class.__index = Class

--// Functions \\--
--[=[
	Gets a player's username by their userId
	@param userId number
	@return string?

	@yields
	@within VibezLite
	@ignore
]=]
---
function getNameById(userId: number): string
	local fixedUserId = tonumber(userId)
	if not fixedUserId then
		return tostring(userId)
	end

	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, fixedUserId)
	return isOk and userName or "Unknown"
end

--[=[
	Gets a player's user identifier via their username.
	@param username string
	@return number?

	@yields
	@within VibezLite
	@ignore
]=]
---
function getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[=[
	Ensures that the parameter returns the proper type associated to the `typeToReturn`
	@param User Player | number | string
	@param typeToReturn "UserId" | "Player" | "Name"
	@return number | string | Player

	@within VibezLite
	@ignore
]=]
function verifyUser(
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
			return (tonumber(User) or getUserIdByName(User))
		elseif typeToReturn == "Name" then
			return User
		elseif typeToReturn == "Player" then
			return Players:FindFirstChild(User) :: Player
		end
	elseif typeof(User) == "number" then
		if typeToReturn == "UserId" or typeToReturn == "Id" then
			return User
		elseif typeToReturn == "Name" then
			return getNameById(User)
		elseif typeToReturn == "Player" then
			return Players:GetPlayerByUserId(User) :: Player
		end
	end

	return User
end

--// Public Methods \\--
--[=[
    Creates a new VibezLite class.
    @param ApiKey string
    @return VibezLite
]=]
function VibezLite.new(ApiKey: string): _Types.VibezLite
	return setmetatable({
		_apiKey = ApiKey,
	}, Class) :: _Types.VibezLite
end

--// Private Methods \\--
--[=[
    Creates an HTTP request with the options provided.
    @param Options RequestOptions
    @return RequestResponse

    @within VibezLite
]=]
function Class:_http(Options: _Types.RequestOptions): _Types.RequestResponse | string
	if not Options.Url then
		error("Expected URL, received 'nil'!")
	elseif string.sub(Options.Url, 1, 1) == "/" then
		Options.Url = "https://leina.vibez.dev" .. Options.Url
	end

	if not Options.Headers then
		Options.Headers = { ["x-api-key"] = self._apiKey }
	else
		Options.Headers["x-api-key"] = self._apiKey
	end

	Options.Method = string.upper(tostring(Options.Method))
	if Options.Method == "NIL" then
		Options.Method = "GET"
	elseif Options.Method == "GET" or Options.Method == "HEAD" then
		Options.Body = nil
	end

	local jsonOk, JSON = pcall(HttpService.JSONEncode, HttpService, Options.Body)
	Options.Body = (jsonOk and JSON or Options.Body)

	local _, response = pcall(HttpService.RequestAsync, HttpService, Options)
	local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, response.Body)

	response.Body = (decodeOk and decoded or response.Body)
	return response
end

--[=[
    Sets the rank of a user.
    @param userId string | number
    @param rankId string | number
    @return (boolean, string) 
]=]
function Class:setRank(userId: string | number, rankId: number): (boolean, string)
	assert(tonumber(rankId), "Please ensure the 'rankId' parameter is a valid number!")

	local userName = verifyUser(userId, "Name")
	local realUserId = verifyUser(userId, "Id")

	local response = self:_http({
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
			userId = tonumber(realUserId),
			rankId = tonumber(rankId),
		},
	})

	return response.Body.Success, response.Body.message
end

--[=[
	Promotes the user within the group.
	@param userId string | number
	@return (boolean, string)
]=]
function Class:Promote(userId: string | number): (boolean, string)
	assert(false, "Not implemented")
end

--[=[
	Demotes the user within the group.
	@param userId string | number
	@return (boolean, string)
]=]
function Class:Demote(userId: string | number): (boolean, string)
	assert(false, "Not implemented")
end

--[=[
	Fires the user within the group.
	@param userId string | number
	@return (boolean, string)
]=]
function Class:Fire(userId: string | number): (boolean, string)
	assert(false, "Not implemented")
end

return VibezLite
