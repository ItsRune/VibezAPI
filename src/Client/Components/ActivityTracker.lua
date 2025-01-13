--// Services \\--
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Variables \\--
local Maid = {}

--// Functions \\--
local function markAFK(componentData, isAfk: boolean)
	componentData._debug(
		"activity_marking_afk",
		string.format("Marking the LocalPlayer as %s.", isAfk and "AFK" or "not AFK")
	)

	return componentData.remoteFunction:InvokeServer("Afk", isAfk)
end

local function onDestroy(componentData: { [any]: any })
	componentData._debug("activity_destroy", "Destroy method triggered.")
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
	onDestroy(componentData)

	if not componentData.Data.AfkTracker.Status then
		return
	end

	local afkDelayOffset = componentData.Data.AfkTracker.Delay
	local lastCheck = DateTime.now().UnixTimestamp
	local Counter = 0

	componentData._debug("activity_initialization", "Connecting 'onWindowFocus'.")
	table.insert(
		Maid,
		UserInputService.WindowFocused:Connect(function()
			markAFK(componentData, false)
		end)
	)

	componentData._debug("activity_initialization", "Connecting 'onWindowFocusReleased'.")
	table.insert(
		Maid,
		UserInputService.WindowFocusReleased:Connect(function()
			markAFK(componentData, true)
		end)
	)

	componentData._debug("activity_initialization", "Connecting 'onInputBegan'.")
	table.insert(
		Maid,
		UserInputService.InputBegan:Connect(function()
			if Counter >= 30 then
				markAFK(componentData, false)
			end

			Counter = 0
		end)
	)

	componentData._debug("activity_initialization", "Binding to rendering function.")
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
				markAFK(componentData, true)
			end
		end)
	end)
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
