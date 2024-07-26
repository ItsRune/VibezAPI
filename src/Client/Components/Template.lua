--// Services \\--
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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
