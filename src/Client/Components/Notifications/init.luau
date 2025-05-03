--!strict
--// Services \\--
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local Definitions = require(script.Parent.Parent.Definitions)
local customRichText = require(script.Parent.UI.Modules.CustomRichText)
local notifGui = script.Notifications
local notificationCount = 0
local Maid = {}

--// Functions \\--
local function _verifyDynamicEnum(parentEnum: any, dynamicProperty: string): any
	local enumItem = parentEnum[dynamicProperty]

	if not enumItem then
		return nil
	end

	return enumItem
end

local function _restackFrames(componentData: Definitions.componentData, tweenInInfo: TweenInfo)
	local Tweens = componentData.Tweens
	local children = notifGui.Holder:GetChildren()

	table.sort(children, function(a, b)
		return a.LayoutOrder > b.LayoutOrder
	end)

	local projectedSize = 0
	for i = 1, #children do
		local child = children[i]
		local expected: UDim2 = child:GetAttribute("Destroying") and UDim2.fromScale(0, 0)
			or child:GetAttribute("desiredSize")

		local Tween = Tweens(child, tweenInInfo, {
			Size = expected,
			Position = UDim2.new(0.5, 0, 1, projectedSize),
		})

		Tween:onCompleted(function()
			if not child:GetAttribute("Destroying") then
				return
			end

			child:Destroy()
		end)

		Tween:Play()

		projectedSize -= expected.Y.Offset
	end
end

local function _onNotification(componentData: Definitions.componentData, dontAllowFormatting: boolean, Message: string)
	local Tweens = componentData.Tweens
	local Settings = HttpService:JSONDecode(tostring(Workspace:GetAttribute(script.Parent.Parent.Name)))
	local notificationSettings = Settings.Notifications

	if not dontAllowFormatting then
		Message = customRichText(componentData, Message)
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

	notificationCount += 1

	newItem.Name = "Notification"
	newItem.Parent = notifGui.Holder
	newItem.TextWrapped = true
	newItem.TextScaled = true
	newItem.FontFace = notificationFont
	newItem.LayoutOrder = notificationCount
	newItem.TextColor3 = Color3.new(1, 1, 1)
	newItem.Size = UDim2.new(0, textSize.X, 0, 0)
	newItem.Position = UDim2.fromScale(0.5, 1)
	newItem.AnchorPoint = Vector2.new(0.5, 1)
	newItem.BackgroundTransparency = 1
	newItem:SetAttribute("desiredSize", UDim2.fromOffset(textSize.X, textSize.Y))

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

	_restackFrames(componentData, tweenInInfo)
	tweenIn:Play()

	task.defer(function()
		task.wait(notificationSettings.delayUntilRemoval)
		newItem:SetAttribute("Destroying", true)
		tweenOut:setCallback(function(state: Enum.PlaybackState?)
			if state ~= Enum.PlaybackState.Completed then
				return
			end

			newItem:Destroy()
			_restackFrames(componentData, tweenInInfo)
		end)

		tweenOut:Play()
	end)
end

local function onDestroy(componentData: Definitions.componentData)
	componentData.Table.ForEach(
		componentData.Table.Filter(notifGui.Holder:GetChildren(), function(v)
			return v.Name == "Notification"
		end),
		function(v)
			v:Destroy()
		end
	)

	notificationCount = 0
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
