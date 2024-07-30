--#selene: allow(unused_variable)
--// Services \\--

--// Types \\--
type LogInformation = {
	calledBy: Player,
	triggeredBy: "Commands" | "Interface" | "RankSticks",

	affectedCount: number,
	affectedUsers: { Player },
	extraData: { [any]: any },

	Action: string,
	Timestamp: number,
}

--// Variables \\--
local nextLayoutOrder = 999999
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

local function _fixStringForAction(componentData: { [any]: any }, logInfo: LogInformation): string
	local userNamesAndIds = componentData.Table.Map(componentData.affectedUsers, function(Target: Player)
		return string.format("%s (%d)", Target.Name, Target.UserId)
	end)

	local fixedString = (#userNamesAndIds > 3) and table.concat(userNamesAndIds, ", ", 1, 3) .. "..."
		or table.concat(userNamesAndIds, ", ")

	local baseString = string.format("%s used action '%s' on %s", logInfo.calledBy.Name, logInfo.Action, fixedString)
	local extraData

	if logInfo.Action == "Blacklist" then
		extraData = string.format(" for: '%s'", logInfo.extraData.Reason)
	end

	return baseString .. (extraData ~= nil and extraData or "")
end

local function _addLog(Frame: Frame, componentData: { [any]: any }, newLog: LogInformation)
	local templateFrame = Frame.Scroll.Template
	local nextNumber = #Frame.Scroll:GetChildren() - 3
	local newTemplate = templateFrame:Clone()

	newTemplate.Name = nextNumber
	newTemplate.Text = _fixStringForAction(componentData, newLog)
	newTemplate.LayoutOrder = nextLayoutOrder
	newTemplate.Visible = true
	newTemplate.Parent = Frame.Scroll

	nextLayoutOrder -= 1
end

local function onDestroy(Frame: Frame, componentData: { [any]: any })
	nextLayoutOrder = 999999
	_removeFrames(Frame)

	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	onDestroy(componentData)

	table.insert(
		Maid,
		componentData.remoteEvent.OnClientEvent:Connect(function(Command: string, ...: any)
			if Command ~= "Logs" then
				return
			end

			_addLog(...)
		end)
	)

	local logData = componentData.remoteFunction:InvokeServer("Logs")
	warn(logData)

	for i = #logData, 1, -1 do
		_addLog(Frame, componentData, logData[i])
	end
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
