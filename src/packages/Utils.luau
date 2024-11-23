--!strict

--[=[
    @class Utils
]=]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Types = require(script.Parent.Parent.Types)
local Env = {}

--[=[
    Ensures a method with the 'whoCalled' parameter actually exists.

    ```lua
    local whoCalled = Vibez.Utils:ensureWhoCalledExists({ userName = "Hi", userId = 1 })
    local defaultWhoCalled = Vibez.Utils:ensureWhoCalledExists()

    print(whoCalled) --> { userName = "Hi", userId = 1 }
    print(defaultWhoCalled) --> { userName = "SYSTEM", userId = -1 }
    ```

    @within Utils
]=]
function Env:ensureWhoCalledExists(
	whoCalled: { userName: string, userId: number }?
): { userName: string, userId: number }
	if not whoCalled then
		return {
			userName = "SYSTEM",
			userId = -1,
		}
	end

	return whoCalled
end

--[=[
    Ensures that the parameter returns the proper type associated to the `typeToReturn`
    @param User Player | number | string
    @param typeToReturn "UserId" | "Id" | "Player" | "Name"
    @return number | string | Player

    ```lua
    local user = Vibez.Utils:verifyUser("ltsRune", "Id")
    print(user) --> 107392833
    ```

    @within Utils
]=]
function Env:verifyUser(
	User: Player | number | string,
	typeToReturn: "UserId" | "Id" | "Name" | "Player"
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
			return (tonumber(User) or self:getUserIdByName(User))
		elseif typeToReturn == "Name" then
			return User
		elseif typeToReturn == "Player" then
			return Players:FindFirstChild(User) :: Player
		end
	elseif typeof(User) == "number" then
		if typeToReturn == "UserId" or typeToReturn == "Id" then
			return User
		elseif typeToReturn == "Name" then
			return self:getNameById(User)
		elseif typeToReturn == "Player" then
			return Players:GetPlayerByUserId(User) :: Player
		end
	end

	return User
end

--[=[
	Creates an HTTP request with the options provided.
	@param Options RequestOptions
	@return RequestResponse

	@private
	@within Utils
]=]
function Env:Http(Options: Types.RequestOptions): Types.RequestResponse | string
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

	local _, response = pcall(HttpService.RequestAsync, HttpService, Options :: any)
	local decodeOk, decoded = pcall(HttpService.JSONDecode, HttpService, response.Body :: any)

	response.Body = (decodeOk and decoded or response.Body)
	return response :: Types.RequestResponse
end

--[=[
	Gets a player's username by their userId
	@param userId number
	@return string?

	@yields
	@within Utils
]=]
---
function Env:getNameById(userId: number): string
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
	@within Utils
]=]
---
function Env:getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[=[
	Gets the group's ID associated with the api key.
	@return number?
	@yields
	@within Utils
]=]
function Env:getGroupId(): number?
	if self.base.GroupId then
		return self.base.GroupId
	end

	local response = self:Http({
		Url = "/ranking/groupid",
		Method = "Post",
	})

	if response.Success then
		self.base.GroupId = response.Body.groupId
	end

	return response.Body.groupId
end

return function(parent: Types.VibezLightWeight): Types.VibezUtilsPackage
	return setmetatable({
		base = parent,
	}, Env :: any) :: Types.VibezUtilsPackage
end

--[=[
	@interface RequestOptions
	.Url string
	.Method string
	.Headers {[string]: string}
	.Body any
	@within Utils
]=]

--[=[
	@interface RequestResponse
	.Success boolean
	.StatusCode number
	.StatusMessage string
	.Headers {[any]: any}
	.Body string
	@within Utils
]=]
