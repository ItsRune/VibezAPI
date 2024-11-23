local HttpService = game:GetService("HttpService")
--// Modules \\--
local _Types = require(script.Types)

--// Variables \\--
--[=[
    @class Constructor
]=]

local VibezLightWeight = {}
local baseClass = {}

baseClass.__index = baseClass

--// Public Methods \\--
--[=[
	Performs a simple http check.
	@within Constructor
]=]
function VibezLightWeight.httpCheck(): boolean
	local isOk = pcall(HttpService.GetAsync, HttpService, "https://google.com/")
	return isOk
end

--[=[
	Creates a new lightweight Vibez class.
	@param ApiKey string
	@return Constructor
	@within Constructor
]=]
function VibezLightWeight.new(ApiKey: string): _Types.VibezLightWeight
	assert(VibezLightWeight.httpCheck(), "Ensure you have HTTP Enabled on your experience.")

	local self = setmetatable({
		_apiKey = ApiKey,
	}, baseClass)
	local ranking, activity, blacklists, utils =
		require(script.packages.Ranking),
		require(script.packages.Activity),
		require(script.packages.Blacklists),
		require(script.packages.Utils)

	self.Ranking = ranking(self)
	self.Activity = activity(self)
	self.Blacklists = blacklists(self)
	self.Utils = utils(self)

	return self :: _Types.VibezLightWeight
end

return VibezLightWeight

--[=[
	@prop Activity Activity
	@within Constructor
]=]

--[=[
	@prop Blacklists Blacklists
	@within Constructor
]=]

--[=[
	@prop Ranking Ranking
	@within Constructor
]=]

--[=[
	@prop Utils Utils
	@within Constructor
]=]
