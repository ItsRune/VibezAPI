--[[
	TODO:
    - Developers can specify a Folder/SurfaceGui that add to the cache.
    - Client will update on its own with different widgets specified by the dev.
    - RepStorage will hold information about widget information.
    - Widget Info:
	- "VERIFIED ONLINE MEMBERS" | List of top 20 players online (verified with vibez | usernames, userids, thumbnails, etc)
	- guildName | Name of guild
	- 
]]
--// Services \\--
local PolicyService = game:GetService("PolicyService")

--// Types \\--
type widgetTypes = "Discord" -- Add more if more get added.

--// Modules \\--
-- local Table = require(script.Parent.Table)

--// Variables \\--
local Widgets = {}
local Class = {}
Class.__index = Class

--// Public Functions \--
--[=[
	@ignore
	@class Widgets

	Creates discord embed widgets when given a part. (SurfaceGui) Or a normal screen gui.
]=]
function Widgets.new()
	assert(false, "Not implemented")
	local self = setmetatable({}, Class)

	self._cache = {
		Players = {},
		responseData = {},
	}

	return self
end

--// Private Functions \--
function Class:_updateCache()
	-- For now put sample data.
	local sample = {
		Success = true,
		StatusCode = 200,
		rawBody = "",
		Body = {
			guildName = "Test Guild",
			Members = {
				{
					username = "ROBLOX",
					userId = 1,
				},
			},
		},
	}

	self._cache.responseData = sample
end

function Class:_updateForPlayers()
	--
end

function Class:addForPlayer(Player: Player)
	local isOk, playerPolicy = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, Player)

	if not isOk then
		return
	end

	local allowedLinks, canView, hasChinesePolicies =
		playerPolicy["AllowedExternalLinkReferences"],
		playerPolicy["AreAdsAllowed"],
		playerPolicy["IsSubjectToChinaPolicies"]

	if not canView or hasChinesePolicies then
		return
	end

	self._cache[Player.UserId] = allowedLinks
end

function Class:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

--// Return \--
return setmetatable(Widgets, {
	__call = function(self, ...)
		return rawget(self, "new")(...)
	end,
})
