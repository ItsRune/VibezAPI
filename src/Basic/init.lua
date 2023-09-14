--[[
		 _   _ ___________ _____ ______
		| | | |_   _| ___ \  ___|___  /
		| | | | | | | |_/ / |__    / / 
		| | | | | | | ___ \  __|  / /  
		\ \_/ /_| |_| |_/ / |___./ /___
		 \___/ \___/\____/\____/\_____/

	Author: ltsRune
	Link: https://www.roblox.com/users/107392833/profile
	Discord: ltsrune // 352604785364697091
	Created: 9/11/2023 15:01 EST
	Updated: 9/12/2023 14:01 EST
	
	Note: If you don't know what you're doing, I would
	not	recommend messing with anything.
]]
--

--// Services \\--
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--// Constants \\--
local Types = require(script.Types)
local RateLimit = require(script.RateLimit)
local api = {}
local baseSettings = {
	overrideGroupCheckForStudio = false,
	loggingOriginName = game.Name,
}

--// Private Functions \\--
--[[
	* Sends an HTTP request to the appropriate route and api.
	 - Socket hang up is possible if the api key is invalid when trying to make a request!
	* Params Route<string>, Method<string?>, Headers<{[string]: any}?>, Body<{any}?>, useNewApi<boolean?>
	* Returns Success<boolean>, Response<{any}>
]]
--
function api:Http(
	Route: string,
	Method: string?,
	Headers: { [string]: any }?,
	Body: { any }?,
	useNewApi: boolean?
): (boolean, Types.httpResponse)
	local canContinue, err = self._private.rateLimiter:Check()
	if not canContinue then
		local message = `You're being rate limited! {err}`

		return {
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

	Route = (typeof(Route) == "string") and Route or "/"
	Method = (typeof(Method) == "string") and string.upper(Method) or "GET"
	Headers = (typeof(Headers) == "table") and Headers or { ["Content-Type"] = "application/json" }
	Body = (Method ~= "GET" and Method ~= "HEAD") and Body or nil

	if Body then
		Body["origin"] = self.Settings.loggingOriginName
	end

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route

	Headers["x-api-key"] = self.Settings.apiKey

	local apiToUse = (useNewApi == true) and self._private.newApiUrl or self._private.apiUrl
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

	return (success or (data.StatusCode >= 200 and data.StatusCode < 300)), data
end

--[[
	* Fetches the group associated with the api key.
	* Returns groupId<number> - a number symbolizing the group identifier attached to the api key.
]]
--
function api:getGroupId()
	if self.GroupId ~= -1 then
		return self.GroupId
	end

	local isOk, res = self:Http("/ranking/groupid", "post", nil, nil, true)
	local Body: groupIdResponse = res.Body

	return isOk and Body.groupId or -1
end

--[[
	* Gets player's user identifers without needing to be in game.
	* Params username<string>
	* Returns userId<number?>
]]
--
function api:getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

--[[
	* Gets player's username.
	* Params userId<number>
	* returns username<string?>
]]
function api:getNameById(userId: number): string?
	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	return isOk and userName or "Unknown"
end

--[[
	* Sets the rank of a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, rankId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
function api:_setRank(
	userId: string | number,
	rankId: string | number,
	whoCalled: { userName: string, userId: number }?
): Types.rankResponse
	local userName = self:getNameById(userId)

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

	local _, response = self:Http("/ranking/changerank", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
		rankId = tostring(rankId),
	}, true)

	return response
end

--[[
	* Promotes a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
function api:_Promote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

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

	local _, response = self:Http("/ranking/promote", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[[
	* Demotes a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
function api:_Demote(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

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

	local _, response = self:Http("/ranking/demote", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[[
	* Fires a player and creates a fake "whoCalled" parameter if none is supplied.
	* Params userId<string | number>, whoCalled<{ userName: string, userId: number }?>
	* Returns 
]]
function api:_Fire(userId: string | number, whoCalled: { userName: string, userId: number }?): Types.rankResponse
	local userName = self:getNameById(userId)

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

	local _, response = self:Http("/ranking/fire", "post", nil, {
		userToRank = {
			userId = tostring(userId),
			userName = userName,
		},
		userWhoRanked = whoCalled,
		userId = tostring(userId),
	}, true)

	return response
end

--[[
	* Destroys the class and sets it up to be GC'ed.
]]
function api:_destroy()
	setmetatable(self, nil)
	self = nil
end

--// Public Functions \\--
-- Sets the rank of an employee
function api:SetRank(userId: string | number, rankId: string | number): Types.rankResponse
	return self:_setRank(userId, rankId)
end

-- Promotes an employee
function api:Promote(userId: string | number): Types.rankResponse
	return self:_Promote(userId)
end

-- Demotes an employee
function api:Demote(userId: string | number): Types.rankResponse
	return self:_Demote(userId)
end

-- Fires an employee
function api:Fire(userId: string | number): Types.rankResponse
	return self:_Fire(userId)
end

-- Updates the origin name
function api:UpdateLoggerTitle(newTitle: string): nil
	self.Settings.loggingOriginName = tostring(newTitle)
end

-- Destroys the class
function api:Destroy()
	return self:_destroy()
end

-- Updates the api key
function api:UpdateKey(newApiKey: string): boolean
	local savedKey = table.clone(self.Settings).apiKey

	self.Settings.apiKey = newApiKey
	local groupId = self:getGroupId()

	if groupId == -1 and savedKey ~= nil then
		self.Settings.apiKey = savedKey
		warn(debug.traceback(`[Vibez]: New api key "{newApiKey}" was invalid and was reverted to the previous one!`, 2))
		return
	elseif groupId == -1 and not savedKey then
		warn(
			debug.traceback(
				`[Vibez]: Api key "{newApiKey}" was invalid! Please make sure there are no special characters or spaces in your key!`,
				2
			)
		)
		return
	end

	self.GroupId = groupId
end

-- Gets the player's current activity (Route has been said to be buggy)
-- function api:getActivity(userId: string | number)
-- 	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:getUserIdByName(userId) or userId

-- 	local _, response = self:Http("/activty/get", "post", nil, {
-- 		playerId = userId,
-- 	}, true)

-- 	return response
-- end

-- Saves the player's current activity
function api:saveActivity(
	userId: string | number,
	secondsSpent: number,
	messagesSent: (number | { string })?,
	joinTime: number?,
	leaveTime: number?
): Types.httpResponse
	userId = (typeof(userId) == "string" and not tonumber(userId)) and self:getUserIdByName(userId) or userId
	messagesSent = (typeof(messagesSent) == "table") and #messagesSent or (messagesSent == nil) and 0 or messagesSent
	joinTime = (typeof(joinTime) == "number") and joinTime or DateTime.now().UnixTimestamp
	leaveTime = (typeof(leaveTime) == "number") and leaveTime or DateTime.now().UnixTimestamp

	if not tonumber(messagesSent) then
		warn(debug.traceback(`[Vibez]: Cannot save activity with an invalid 'number' as the 'messagesSent'!`, 2))
		return
	end

	if not tonumber(secondsSpent) then
		warn(debug.traceback(`[Vibez]: 'secondsSpent' parameter is required for this function!`, 2))
		return
	end

	if joinTime == leaveTime then
		joinTime -= secondsSpent
	end

	secondsSpent, messagesSent = tonumber(secondsSpent), tonumber(messagesSent)
	local _, response = self:Http("/activity/save", "post", nil, {
		playerId = userId,
		playtime = secondsSpent,
		messageCount = messagesSent,
		joinTime = joinTime,
		leaveTime = leaveTime,
	}, true)

	return response
end

--// Constructor \\--
function Constructor(apiKey: string, extraOptions: Types.vibezSettings?): Types.vibezApi
	if RunService:IsClient() then
		return nil
	end

	api.__index = api
	local self = setmetatable({}, api)

	self.GroupId = -1
	self.Settings = table.clone(baseSettings)
	self._private = {
		newApiUrl = "https://leina.vibez.dev",
		apiUrl = "https://api.vibez.dev/api",
		rateLimiter = RateLimit.new(60, 60),
	}

	extraOptions = extraOptions or {}
	for key, value in pairs(extraOptions) do
		if self.Settings[key] == nil then
			warn(`[Vibez]: Optional key '{key}' is not a valid option.`)
			continue
		elseif typeof(self.Settings[key]) ~= typeof(value) then
			warn(`[Vibez]: Optional key '{key}' is not the same as it's defined value of {typeof(self.Settings[key])}!`)
			continue
		end

		self.Settings[key] = value
	end

	-- Update the api key using the public function, in case of errors it'll log them.
	self:UpdateKey(apiKey)

	return self
end

return Constructor :: Types.vibezConstructor
