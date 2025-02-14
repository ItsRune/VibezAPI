--!nocheck
--!nolint
--#selene: allow(unused_variable, shadowing, if_same_then_else, empty_if)
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Definitions = require(script.Parent.Parent.Definitions)
local Player = Players.LocalPlayer
local System = {
	Maid = {},
}

--// Functions \\--
local function onDestroy(componentData: Definitions.componentData)
	--
end

local function onSetup(componentData: Definitions.componentData)
	local _warn, remoteEvent, remoteFunction =
		componentData._warn, componentData.remoteEvent, componentData.remoteFunction
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
