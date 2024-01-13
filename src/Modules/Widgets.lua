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

--[=[
	@class Widgets
]=]
--// Services \\--
local HttpService = game:GetService("HttpService")
local PolicyService = game:GetService("PolicyService")

--// Modules \\--
local Table = require(script.Parent.Table)
local Types = require(script.Parent.Types)

--// Variables \\--
local takenWidgets = {}
local Widgets = {}
local Class = {}
Class.__index = Class

--// Public Functions \--
--[=[
	Creates discord embed widgets when given a part. (SurfaceGui) Or a normal screen gui.
	@param api VibezAPI
	@return Widgets

	@since 2.3.7
]=]
function Widgets.new(api: Types.vibezApi, Type: Types.widgetTypes)
	local self = setmetatable({}, Class)

	if takenWidgets[Type] ~= nil then
		self:Destroy()
		return takenWidgets[Type]
	end

	self._api = api
	self._cache = {
		Settings = {
			backgroundColor = Color3.fromRGB(33, 33, 33),
			foregroundColor = Color3.fromRGB(196, 130, 196),
			textColor = Color3.fromRGB(255, 255, 255),
		},
		widgetName = table.concat(string.split(string.upper(HttpService:GenerateGUID(false))), ""),
		Players = {},
		cachedData = {},
		widgetUIs = {},
		filteredCache = {
			--[[
				{
					text = "",
					type = "username" | "playing"
				}
			]]
		},
	}

	return self
end

--// Local Functions \\--
local function create(instanceName: string, props: { [string]: any })
	local new = Instance.new(instanceName)

	for i, v in pairs(props) do
		if i == "Attributes" and typeof(v) == "table" then
			for attrName, attrValue in pairs(v) do
				pcall(new.SetAttribute, new, attrName, attrValue)
			end
			continue
		end

		pcall(function()
			new[i] = v
		end)
	end

	return new
end

--// Public Functions \--
--[=[
	Adds a new widget onto the associated 'base' part.
	@param base Part | MeshPart | UnionOperation
	@return boolean

	@within Widgets
	@since 2.3.7
]=]
function Class:addWidget(base: Part | MeshPart | UnionOperation): boolean
	assert(typeof(base) == "Instance", "'Instance' expected for widget base, got '" .. typeof(base) .. "'!")
	assert(base:IsA("Part") or base:IsA("MeshPart") or base:IsA("UnionOperation"), "Invalid type for base widget part!")

	local newWidget = create("SurfaceGui", {
		Parent = base,
		Name = self.widgetName,
		Attributes = {
			isLoaded = false,
		},
	})

	local mainFrame = create("Frame", {
		Parent = newWidget,
		Name = "MainFrame",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})

	local headerFrame = create("Frame", {
		Parent = mainFrame,
		Name = "Header",
		BackgroundColor3 = Color3.fromRGB(155, 55, 255),
		Size = UDim2.fromScale(1, 0.1),
	})

	local headerText = create("TextLabel", {
		Parent = headerFrame,
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.9, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5) + UDim2.fromOffset(5, 0),
		Text = "Loading...",
		TextColor3 = Color3.new(1, 1, 1),
	})

	local bodyFrame = create("Frame", {
		Parent = newWidget,
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0.9),
		Position = UDim2.fromScale(0, 0.1),
	})

	local memberList = create("ScrollingFrame", {
		Parent = bodyFrame,
		Size = UDim2.fromScale(0.95, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
	})

	local memberCount = create("TextLabel", {
		Parent = bodyFrame,
		Size = UDim2.new(0.975, 0, 0, 18),
		BackgroundTransparency = 1,
		TextScaled = true,
		TextColor3 = Color3.fromRGB(55, 55, 55),
	})

	table.insert(self._cache.widgetUIs, newWidget)
end

--[=[
	Changes the theme colors of the widgets.
	@param backgroundColor (Color3 | string)?
	@param foregroundColor (Color3 | string)?
	@param textColor (Color3 | string)?
	@return ()

	@within Widgets
	@since 2.3.7
]=]
function Class:updateTheme(
	backgroundColor: (Color3 | string)?,
	foregroundColor: (Color3 | string)?,
	textColor: (Color3 | string)?
)
	local function checkAndPlaceIntoSetting(settingName: string, newValue: any)
		local expected = self._cache.Settings[settingName]

		if typeof(expected) ~= typeof(newValue) and (typeof(expected) == "Color3" and typeof(newValue) == "string") then
			return
		end

		if typeof(newValue) == "string" and typeof(expected) == "Color3" then
			local isOk, newColor = pcall(Color3.fromHex, newValue)
			if not isOk then
				return
			end

			newValue = newColor
		end

		self._cache.Settings[settingName] = newValue
	end

	checkAndPlaceIntoSetting("backgroundColor", backgroundColor)
	checkAndPlaceIntoSetting("foregroundColor", foregroundColor)
	checkAndPlaceIntoSetting("textColor", textColor)
end

--[=[
	Adds a new player to show the widget to.
	@param Player Player
	@return ()

	:::note
	This method checks the player's policy to make sure games don't show widgets to users who aren't supposed to view them. Read up more on [PolicyService](https://create.roblox.com/docs/reference/engine/classes/PolicyService#GetPolicyInfoForPlayerAsync) to learn more!
	:::

	@yields
	@within Widgets
	@since 2.3.7
]=]
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

--// Private Functions \\--
function Class:_updateCache()
	-- For now put sample data.
	local sample = {
		Success = true,
		StatusCode = 200,
		rawBody = "",
		Body = {
			onlineCount = 597,
			onlineMembers = {
				{
					username = "JustLemonPlays",
					status = "online",
					playing = "Google Chrome",
				},

				{
					username = "k...",
					status = "idle",
					playing = "ROBLOX",
				},

				{
					username = "Kemaxni",
					status = "dnd",
					playing = "Call of Duty©",
				},
			},
		},
	}

	-- local Response = self._api:Http("/widgets")

	self._cache.cachedData = sample.Body
end

--[=[
	Updates for all players who have the policy allowing them to see the specified widget.
	@return ()

	@within Widgets
	@since 2.3.7
]=]
function Class:_updateForPlayers()
	--
end

--[=[
	Destroys the class and disconnects any used [RBXScriptConnections](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection).
	@return ()

	@within Widgets
	@since 2.3.7
]=]
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
