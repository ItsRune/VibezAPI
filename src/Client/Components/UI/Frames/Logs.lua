--// Services \\--
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

--// Types \\--
type LogInformation = {
	calledBy: Player,
	triggeredBy: "Commands" | "Interface" | "RankSticks",

	errorMessage: string?,

	affectedCount: number,
	affectedUsers: { Player },
	extraData: { [any]: any },

	Action: string,
	Timestamp: number,
}

--// Variables \\--
local hasWarned = false
local nextLayoutOrder = 999999
local Maid = {}

--// Functions \\--
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

local function _createErrorLog(logData: { [any]: any }, newError)
	table.insert(logData, {
		Action = "INTERNAL_ERROR",
		errorMessage = '<font color="rgb(200,50,50)">' .. newError .. "</font>",
	})
end

local function _addLog(Frame: Frame, componentData: { [any]: any }, newLog: LogInformation)
	local templateFrame = Frame.Scroll.Template
	local nextNumber = #Frame.Scroll:GetChildren() - 3
	local newTemplate = templateFrame:Clone()
	local message = newLog.Action == "INTERNAL_ERROR" and newLog.errorMessage
		or _fixStringForAction(componentData, newLog)

	local isOk, frameSize = pcall(
		TextService.GetTextSize,
		TextService,
		message,
		newTemplate.UITextSizeConstraint.MaxTextSize / 1.1,
		newTemplate.Font,
		templateFrame.Parent.AbsoluteSize
	)

	if not isOk then
		newTemplate:Destroy()
		return
	end

	newTemplate.Name = "Log"
	newTemplate.Size = UDim2.new(1, 0, 0, frameSize.Y)
	newTemplate.Visible = true
	newTemplate.Parent = Frame.Scroll

	if newLog.Action == "INTERNAL_ERROR" then
		newTemplate.Text = message
		return
	end

	newTemplate.Name = nextNumber
	newTemplate.Text = message
	newTemplate.LayoutOrder = nextLayoutOrder

	nextLayoutOrder -= 1
end

local function onDestroy(Frame: Frame, componentData: { [any]: any })
	nextLayoutOrder = 999999

	componentData.clearAllChildren(Frame.Scroll, { "UIPadding", "UIListLayout" })
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	onDestroy(Frame, componentData)

	if RunService:IsStudio() and not hasWarned then
		hasWarned = true
		Frame.Top.Visible = false

		Frame.Scroll.Size = UDim2.fromScale(1, 1)
		Frame.Scroll.Position = UDim2.fromScale(0, 0)

		componentData._warn("Filters are currently under construction and cannot be used in production.")
	end

	local logData = componentData.remoteFunction:InvokeServer("Logs")

	-- Create an error so that the user knows there's no logs yet.
	if #logData == 0 then
		_createErrorLog(logData, "No Logs to see yet.")
	end

	for i = #logData, 1, -1 do
		_addLog(Frame, componentData, logData[i])
	end

	table.insert(
		Maid,
		componentData.remoteEvent.OnClientEvent:Connect(function(Command: string, ...: any)
			if Command ~= "Logs" then
				return
			end

			_addLog(...)
		end)
	)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
