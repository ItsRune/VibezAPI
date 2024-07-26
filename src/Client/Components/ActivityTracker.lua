--// Services \\--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Variables \\--
local Maid = {}

--// Functions \\--
local function onDestroy(componentData: { [any]: any })
	if not Maid then
		return
	end

	componentData.Disconnect(Maid)
	table.clear(Maid)

	pcall(function()
		RunService:UnbindFromRenderStep("Vibez_AFK_Tracker")
	end)
end

local function onSetup(componentData: { [any]: any })
	local remoteFunction = componentData.remoteFunction

	onDestroy(componentData)

	local afkDelayOffset = componentData.afkDelayOffset
	local lastCheck = DateTime.now().UnixTimestamp
	local Counter = 0

	table.insert(
		Maid,
		UserInputService.WindowFocused:Connect(function()
			remoteFunction:InvokeServer("Afk", false)
		end)
	)

	table.insert(
		Maid,
		UserInputService.WindowFocusReleased:Connect(function()
			remoteFunction:InvokeServer("Afk", true)
		end)
	)

	table.insert(
		Maid,
		UserInputService.InputBegan:Connect(function()
			if Counter >= 30 then
				remoteFunction:InvokeServer("Afk", false)
			end

			Counter = 0
		end)
	)

	pcall(function()
		RunService:BindToRenderStep("Vibez_AFK_Tracker", Enum.RenderPriority.Last.Value, function()
			local now = DateTime.now().UnixTimestamp

			if tonumber(afkDelayOffset) == nil then
				afkDelayOffset = 30
			end

			-- Prevent checks from force updating the AFK
			if Counter == afkDelayOffset then
				return
			end

			if now - lastCheck < 1 then
				return
			end

			lastCheck = now
			Counter += 1

			if Counter == afkDelayOffset then
				remoteFunction:InvokeServer("Afk", true)
			end
		end)
	end)
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
