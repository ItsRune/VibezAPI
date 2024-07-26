--#selene: allow(unused_variable)
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Player = Players.LocalPlayer
local Maid = {}

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: { [any]: any })
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	onDestroy(componentData)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
