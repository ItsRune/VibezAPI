--// Services \\--
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local notifGui = script.Notifications
local Maid = {}

--// Functions \\--
local function _fixNotificationStatus(message: string): string
	local statusCodes = {
		["Error"] = '<b><font color = "rgb(255, 90, 90)">%s</font></b>',
		["Warning"] = '<b><font color = "rgb(255, 171, 36)">%s</font></b>',
		["Info"] = '<b><font color = "rgb(70, 163, 255)">%s</font></b>',
		["Success"] = '<b><font color = "rgb(90, 255, 145)">%s</font></b>',
	}

	local words = string.split(message, " ")
	local firstWord = words[1]
	if string.match(firstWord, "[a-zA-Z0-9]:") == nil or #firstWord < 3 then
		return message
	end

	local splitTokens = string.split(firstWord, ":")
	for i, v in pairs(statusCodes) do
		if string.sub(string.lower(splitTokens[1]), 1, 3) == string.sub(string.lower(i), 1, 3) then
			splitTokens[1] = string.format(v, splitTokens[1])
			break
		end
	end

	words[1] = table.concat(splitTokens, ":")
	return table.concat(words, " ")
end

local function _onNotification(componentData: { [any]: any }, dontAllowFormatting: boolean, Message: string)
	local Tweens, Table = componentData.Tweens, componentData.Table

	local Settings = HttpService:JSONDecode(Workspace:GetAttribute(script.Parent.Parent.Name))
	local notificationSettings = Settings.Notifications

	if not dontAllowFormatting then
		Message = _fixNotificationStatus(Message)
	end

	local newItem = Instance.new("TextLabel")
	newItem.Name = "Notification"
	newItem.Text = Message
	newItem.RichText = true

	local isOk, textSize = pcall(
		TextService.GetTextSize,
		TextService,
		newItem.ContentText,
		UserInputService.TouchEnabled and notificationSettings.FontSize
			or notificationSettings.FontSize * notificationSettings.keyboardFontSizeMultiplier,
		notificationSettings.Font,
		notifGui.Holder.AbsoluteSize
	)
	if not isOk then
		warn("Notification failed, message content: " .. Message)
		Debris:AddItem(newItem, 0)
		return
	end

	newItem.Parent = notifGui.Holder
	newItem.TextWrapped = true
	newItem.TextScaled = true
	newItem.Font = notificationSettings.Font
	newItem.TextColor3 = Color3.new(1, 1, 1)
	newItem.Size = UDim2.new(0, textSize.X, 0, 0)
	newItem.Position = UDim2.fromScale(0.5, 1)
	newItem.AnchorPoint = Vector2.new(0.5, 1)
	newItem.BackgroundTransparency = 1

	local tweenInInfo = TweenInfo.new(
		notificationSettings.entranceTweenInfo.timeItTakes,
		Enum.EasingStyle[notificationSettings.entranceTweenInfo.Style],
		Enum.EasingDirection[notificationSettings.entranceTweenInfo.Direction]
	)
	local tweenOutInfo = TweenInfo.new(
		notificationSettings.exitTweenInfo.timeItTakes,
		Enum.EasingStyle[notificationSettings.exitTweenInfo.Style],
		Enum.EasingDirection[notificationSettings.exitTweenInfo.Direction]
	)

	local tweenIn = Tweens(newItem, tweenInInfo, {
		Size = UDim2.fromOffset(textSize.X, textSize.Y),
	})
	local tweenOut = Tweens(newItem, tweenOutInfo, {
		Size = UDim2.fromScale(0, 0),
	})

	tweenIn:Play()

	-- Filter others to move upwards
	local children = Table.Filter(notifGui.Holder:GetChildren(), function(v)
		return v ~= newItem
	end)

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
		tweenOut:setCallback(function(state: Enum.PlaybackState)
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
			_onNotification(componentData, dontAllowFormatting, ...)
		end
	end)
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
