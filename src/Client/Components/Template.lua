--!nocheck
--!nolint
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Player = Players.LocalPlayer
local System = {
	Maid = {},
}

--// Functions \\--
local function onDestroy(componentData: { [any]: any })
	--
end

local function onSetup(componentData: { [any]: any })
	local _warn, remoteEvent, remoteFunction =
		componentData._warn, componentData.remoteEvent, componentData.remoteFunction
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
