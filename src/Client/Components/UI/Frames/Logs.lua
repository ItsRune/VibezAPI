--// Services \\--

--// Variables \\--
local Maid = {}

--// Functions \\--
local function _removeFrames(Frame: Frame, componentData: { [any]: any }, force: boolean)
	for _, logItem: Frame in ipairs(Frame.Scroll:GetChildren()) do
		if not logItem:IsA("Frame") then
			continue
		end

		if force then
			logItem:Destroy()
			continue
		end

		componentData
			.Tweens(logItem, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				GroupTransparency = 1,
			})
			:onCompleted(function()
				logItem.Visible = false
				logItem:Destroy()
			end)
			:Play()
	end
end

local function _Refresh(componentData: { [any]: any })
	return componentData.remoteFunction:InvokeServer("Logs")
end

local function onDestroy(Frame: Frame, componentData: { [any]: any })
	_removeFrames(Frame)

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
