--// Services \\--
local HttpService = game:GetService("HttpService")

--// Modules \\--
local _Types, Result = require(script.Types), require(script.Result)

--// Variables \\--
--[=[
    @class VibezLite
]=]

local VibezLite = {}
local Class = {}

Class.__index = Class

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
    @return Result<RequestResponse, string>

    @within VibezLite
]=]
function Class:_http(Options: _Types.RequestOptions)
	if not Options.Url then
		return Result.Err("Expected URL, received 'nil'!")
	elseif string.sub(Options.Url, 1, 1) == "/" then
		Options.Url = "https://leina.vibez.dev" .. Options.Url
	end

	Options.Method = string.upper(tostring(Options.Method))
	if Options.Method == "NIL" then
		Options.Method = "GET"
	elseif Options.Method == "GET" or Options.Method == "HEAD" then
		Options.Body = nil
	end

	local isOk, response = pcall(HttpService.RequestAsync, HttpService, Options)
	if not isOk then
		return Result.Err(response)
	end

	return Result.Ok(response)
end

return VibezLite
