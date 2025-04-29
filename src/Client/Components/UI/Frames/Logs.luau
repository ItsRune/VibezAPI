--!strict
--// Services \\--
local UserInputService = game:GetService("UserInputService")

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
local Definitions = require(script.Parent.Parent.Parent.Parent.Definitions)
local customRichText = require(script.Parent.Parent.Modules.CustomRichText)
local hasWarned = false
local nextLayoutOrder = 999999
local Maid = {}

--// Functions \\--
local function _fixStringForAction(componentData: Definitions.componentData, logInfo: LogInformation): string
	local userNamesAndIds = componentData.Table.Map(logInfo.affectedUsers, function(Target: Player)
		return string.format("%s (%d)", Target.Name, Target.UserId)
	end)

	local extraData
	local fixedString = (#userNamesAndIds > 3) and table.concat(userNamesAndIds, ", ", 1, 3) .. "..."
		or table.concat(userNamesAndIds, ", ")

	local baseString = customRichText(
		componentData,
		string.format(
			"<User>%s</User> used action '<Action>%s</Action>' on player(s) '<User>%s</User>'",
			logInfo.calledBy.Name,
			logInfo.Action,
			fixedString
		)
	)

	if logInfo.Action == "Blacklist" then
		extraData = string.format(" for: '%s'", logInfo.extraData[1] or "Unknown.")
	end

	return baseString .. (extraData ~= nil and extraData or "")
end

local function _createErrorLog(newError: string)
	return {
		Action = "INTERNAL_ERROR",
		errorMessage = newError,
		Timestamp = DateTime.now().UnixTimestamp,
	}
end

local function _addLog(Frame: any, componentData: Definitions.componentData, newLog: LogInformation)
	local templateFrame = Frame.Scroll.Template
	local nextNumber = #Frame.Scroll:GetChildren() - 3
	local newTemplate = templateFrame:Clone()

	local isErrLog = newLog.Action:lower():match("error") ~= nil
	local iconType = isErrLog and "Error" or "Info"
	local message = isErrLog and newLog.errorMessage or _fixStringForAction(componentData, newLog)

	if UserInputService.TouchEnabled then
		newTemplate.UITextSizeConstraint.MaxTextSize /= 1.5
	end

	newTemplate.Name = nextNumber
	newTemplate.Parent = Frame.Scroll
	newTemplate.Visible = true

	newTemplate.Message.Text = message
	newTemplate.Message.Timestamp.Text = DateTime.fromUnixTimestamp(newLog.Timestamp):FormatLocalTime("LT", "en-us")

	-- Pcall for testing
	pcall(function()
		newTemplate.Icon[iconType].Visible = true
	end)

	newTemplate.LayoutOrder = nextLayoutOrder

	nextLayoutOrder -= 1
end

local function _updateSearchParams(Frame: any, componentData: Definitions.componentData)
	local Table = componentData.Table

	Table.ForEach(Frame.Scroll:GetChildren(), function(item: TextLabel)
		if item.Name == "Template" then
			return
		end

		local isOk, bool = pcall(function()
			return string.match(string.lower(item.Text), string.lower(Frame.Top.Search.Box.Text)) ~= nil
		end)

		if not isOk then
			return
		elseif not bool then
			item.Visible = false
		else
			item.Visible = true
		end
	end)
end

local function _setupSearchBox(Frame: any, componentData: Definitions.componentData)
	local searchBoxTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local searchFrame = Frame.Top.Search
	local searchBox = searchFrame.Box
	local searchImg = searchFrame.Img

	table.insert(
		Maid,
		searchBox.Focused:Connect(function()
			local boxTween = componentData.Tweens(searchFrame.UIAspectRatioConstraint, searchBoxTweenInfo, {
				AspectRatio = 5.3,
			})

			local searchTween = componentData.Tweens(searchBox.UIPadding, searchBoxTweenInfo, {
				PaddingRight = UDim.new(0, 0),
				PaddingLeft = UDim.new(0.15, 0),
			})

			local imgTween = componentData.Tweens(searchImg, searchBoxTweenInfo, {
				Position = UDim2.fromScale(0.05, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
			})

			boxTween:Play()
			searchTween:Play()
			imgTween:Play()
		end)
	)

	table.insert(
		Maid,
		searchBox.FocusLost:Connect(function()
			if string.match(searchBox.Text, "[a-zA-Z0-9%[%]%(%)%?!@#$%%%^&%*%-_]") then
				return
			end

			searchBox.Text = ""
			local boxTween = componentData.Tweens(searchFrame.UIAspectRatioConstraint, searchBoxTweenInfo, {
				AspectRatio = 1,
			})

			local searchTween = componentData.Tweens(searchBox.UIPadding, searchBoxTweenInfo, {
				PaddingRight = UDim.new(0.2, 0),
				PaddingLeft = UDim.new(0.2, 0),
			})

			local imgTween = componentData.Tweens(searchImg, searchBoxTweenInfo, {
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
			})

			boxTween:Play()
			searchTween:Play()
			imgTween:Play()
		end)
	)

	table.insert(
		Maid,
		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			_updateSearchParams(Frame, componentData)
		end)
	)
end

local function onDestroy(Frame: any, componentData: Definitions.componentData)
	componentData._debug("interface_logs_destroy", "Destroy method triggered.")
	nextLayoutOrder = 999999

	componentData.clearAllChildren(Frame.Scroll, { "UIPadding", "UIListLayout" })
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: any, componentData: Definitions.componentData)
	onDestroy(Frame, componentData)

	if not hasWarned then
		hasWarned = true
		Frame.Top.Filter.Visible = false

		componentData._warn("Logs Interface", "General filters are not available at this time.")
	end

	local logCompData = componentData.Data.Logs
	local staffData = componentData.remoteFunction:InvokeServer("staffCheck")

	_setupSearchBox(Frame, componentData)

	if not staffData or logCompData.Status == false or staffData.Rank < logCompData.MinRank then
		local fakeError: any = _createErrorLog("You don't have permission to view these logs.")
		_addLog(Frame, componentData, fakeError)
		return
	end

	componentData._debug("interface_logs_initialization", "Fetching log data.")
	local logData = componentData.remoteFunction:InvokeServer("Logs")

	-- Create an error so that the user knows there's no logs yet.
	if #logData == 0 then
		table.insert(logData, _createErrorLog("No Logs to see yet."))
	end

	for i = 1, #logData do
		_addLog(Frame, componentData, logData[i])
	end

	componentData._debug("interface_logs_initialization", "Connecting client event for receiving new logs.")
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
