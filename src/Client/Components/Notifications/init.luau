--!strict
--// Services \\--
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local Definitions = require(script.Parent.Parent.Definitions)
local notifGui = script.Notifications
local Maid = {}

--// Functions \\--
local function _fixNotificationStatus(componentData: Definitions.componentData, message: string): string
	local customFormatCodes: { [string]: string } = {
		["User"] = "Users",
		["Action"] = "Actions",
		["Group"] = "Group",
		["Error"] = "Error",
		["Warn"] = "Warning",
		["Info"] = "Info",
		["Success"] = "Success",
	}

	for i in customFormatCodes do
		local puncuationSet = "!%?%(%)%*&%%#%$@,%./\\"
		local capture = `<{i}>([%w%s{puncuationSet}]+)</{i}>`
		local matched

		repeat
			matched = message:match(capture)

			if not matched then
				continue
			end

			local newFormat = '<font color="%s">%s</font>'
			local colorName = customFormatCodes[i]
			local colorHex = componentData.Data.Colors[colorName] or "#000000"

			message = message:gsub(capture, newFormat:format(colorHex, matched))
		until matched == nil
	end

	return message
end

local function _verifyDynamicEnum(parentEnum: any, dynamicProperty: string): any
	local enumItem = parentEnum[dynamicProperty]

	if not enumItem then
		return nil
	end

	return enumItem
end

local function _onNotification(componentData: Definitions.componentData, dontAllowFormatting: boolean, Message: string)
	local Tweens, Table = componentData.Tweens, componentData.Table

	local Settings = HttpService:JSONDecode(tostring(Workspace:GetAttribute(script.Parent.Parent.Name)))
	local notificationSettings = Settings.Notifications

	if not dontAllowFormatting then
		Message = _fixNotificationStatus(componentData, Message)
		componentData._debug("notification_formatting_result", Message)
	end

	local notificationFont = Font.new(
		componentData.Data.Font.Family,
		(Enum.FontWeight :: any)[componentData.Data.Font.Weight],
		(Enum.FontStyle :: any)[componentData.Data.Font.Style]
	)

	local newItem = Instance.new("TextLabel")
	newItem.Name = "Notification"
	newItem.Text = Message
	newItem.RichText = true

	local textBoundsParams = Instance.new("GetTextBoundsParams")
	textBoundsParams.Font = notificationFont
	textBoundsParams.Text = newItem.ContentText

	local isOk, textSize = pcall(TextService.GetTextBoundsAsync, TextService, textBoundsParams)
	if not isOk then
		Debris:AddItem(newItem, 0)
		componentData._debug("notification_request", "Failed to resize the TextLabel. Message content: " .. Message)
		return
	end

	newItem.Parent = notifGui.Holder
	newItem.TextWrapped = true
	newItem.TextScaled = true
	newItem.FontFace = notificationFont
	newItem.TextColor3 = Color3.new(1, 1, 1)
	newItem.Size = UDim2.new(0, textSize.X, 0, 0)
	newItem.Position = UDim2.fromScale(0.5, 1)
	newItem.AnchorPoint = Vector2.new(0.5, 1)
	newItem.BackgroundTransparency = 1

	local tweenInInfo = TweenInfo.new(
		notificationSettings.entranceTweenInfo.timeItTakes,
		_verifyDynamicEnum(Enum.EasingStyle, notificationSettings.entranceTweenInfo.Style),
		_verifyDynamicEnum(Enum.EasingDirection, notificationSettings.entranceTweenInfo.Direction)
	)
	local tweenOutInfo = TweenInfo.new(
		notificationSettings.exitTweenInfo.timeItTakes,
		_verifyDynamicEnum(Enum.EasingStyle, notificationSettings.exitTweenInfo.Style),
		_verifyDynamicEnum(Enum.EasingDirection, notificationSettings.exitTweenInfo.Direction)
	)

	local tweenIn = Tweens(newItem, tweenInInfo, {
		Size = UDim2.fromOffset(textSize.X, textSize.Y),
	})
	local tweenOut = Tweens(newItem, tweenOutInfo, {
		Size = UDim2.fromScale(0, 0),
	})

	tweenIn:Play()

	-- Filter others to move upwards
	local children = Table.Filter(notifGui.Holder:GetChildren(), function(v: any)
		return v ~= newItem
	end) :: { any }

	if #children > 0 then
		coroutine.wrap(function()
			for _, v in pairs(children) do
				Tweens(v, tweenInInfo, {
					Position = UDim2.new(0.5, 0, 1, v.Position.Y.Offset - textSize.Y),
				}):Play()
			end
		end)()
	end

	coroutine.wrap(function()
		task.wait(notificationSettings.delayUntilRemoval)
		tweenOut:setCallback(function(state: Enum.PlaybackState?)
			if state ~= Enum.PlaybackState.Completed then
				return
			end

			Debris:AddItem(newItem, 0)
		end)

		tweenOut:Play()
	end)()
end

local function onDestroy(componentData: { [any]: any })
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(componentData: { [any]: any })
	onDestroy(componentData)

	local remoteEvent = componentData.remoteEvent
	remoteEvent.OnClientEvent:Connect(function(Command: string, dontAllowFormatting: boolean, ...: any)
		if Command == "Notify" then
			local data = { ... }

			if typeof(dontAllowFormatting) == "string" then
				table.insert(data, 1, dontAllowFormatting)
			end

			_onNotification(componentData, false, table.unpack(data))
		end
	end)
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
	Notify = _onNotification,
}
