--!strict
--#selene: allow(unused_variable)
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Definitions = require(script.Parent.Parent.Parent.Parent.Definitions)
local _Player = Players.LocalPlayer
local Maid = {}

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: Definitions.componentData)
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: Frame, componentData: Definitions.componentData)
	onDestroy(Frame, componentData)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
