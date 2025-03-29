--!nocheck
--// Services \\--
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--// Types \\--
type tweenServiceElement = {
	Play: () -> (),
	Pause: () -> (),
	Cancel: () -> (),
	Destroy: () -> (),
	setCallback: (...(playbackState: Enum.PlaybackState) -> ()) -> (),
}
type Tweens = (Inst: Instance, TweenInfo, { [string]: any }) -> tweenServiceElement

--// Variables \\--
local Definitions = require(script.Parent.Parent.Definitions)
local oldUIData = require(script.oldUI)
local frameComponents = script.Frames
local notifiedAboutBetaUsage = false
local truncHistory, truncMaxFrames = {}, 0
local Maid = {
	Parent = {},
	Children = {},
}

--// UI Variables \\--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local UI = script.Interface
local Frame = UI.Frame
local Content, Top, Buttons = Frame.Content, Frame.Top, Frame.Buttons
local currentOpenFrame, isToggled = nil, false
local onSetup, onDestroy, _toggleUI, topBarButton

--// Functions \\--
-- Changes the color of the active topbar button to be a brighter white.
local function _changeSelectorHighlight(Tweens: Tweens, frameName: string)
	for _, topButton: Instance in ipairs(Buttons.Holder:GetChildren()) do
		if not topButton:IsA("ImageButton") then
			continue
		end

		local transparencyToShiftTo = (frameName == topButton.Name) and 0 or 0.6
		Tweens(topButton.Label, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			TextTransparency = transparencyToShiftTo,
		}):Play()
	end
end

-- Protected calls to prevent any issues with loading/executing a frame's module.
local function _safelyLoadModuleAndRun(module: ModuleScript, subCommand: string, ...: any)
	local _, requiredModule = pcall(require, module)
	pcall(requiredModule[subCommand], ...)
end

local function _openFrame(componentData: Definitions.componentData, frameName: string)
	local newFrame = Content:FindFirstChild(frameName)
	local tweenInOutInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
	local Tweens: Tweens = componentData.Tweens

	-- We can't proceed if there's no frame available.
	if not newFrame then
		componentData._warn("UI Error", "No frame could be found with the name '" .. frameName .. "'!")
		return
	end

	-- Tweens out the frame that's already opened.
	if currentOpenFrame ~= nil then
		-- Since this UI has no frames behind it, we want to ensure the 'frameName'
		-- isn't the same as the one being opened.
		if currentOpenFrame.Name == frameName then
			return
		end

		-- Detect when the opening frame is already being tweened. (Hot fix for when switching tabs quickly)
		local endPosition = UDim2.fromScale(-0.5, 0.5)
		if truncHistory[1] == currentOpenFrame.Name and currentOpenFrame.Position.X.Scale > 0.5 then
			endPosition = UDim2.fromScale(1.5, 0.5)
		end

		local newCurrentReference = currentOpenFrame
		local previousFrameModule = frameComponents:FindFirstChild(newCurrentReference.Name)

		if previousFrameModule and previousFrameModule:IsA("ModuleScript") then
			_safelyLoadModuleAndRun(previousFrameModule, "Destroy", newCurrentReference, componentData)
		end

		local Tween = Tweens(newCurrentReference, tweenInOutInfo, {
			Position = endPosition,
		})

		Tween:setCallback(function(playBackState)
			if playBackState ~= Enum.PlaybackState.Completed then
				return
			end

			newCurrentReference.Position = UDim2.fromScale(1.5, 0.5)
		end)

		Tween:Play()
	end

	local frameModule = frameComponents:FindFirstChild(frameName)
	if not frameModule or not frameModule:IsA("ModuleScript") then
		componentData._warn("UI Error", "No module could be found for page '" .. frameName .. "'!")
		return
	end

	currentOpenFrame = newFrame
	local Tween = Tweens(newFrame, tweenInOutInfo, {
		Position = UDim2.fromScale(0.5, 0.5),
	})

	Tween:Play()

	table.insert(truncHistory, 1, frameName)
	if #truncHistory > truncMaxFrames then
		componentData._debug("interface_tabs", "Truncating tab history...")
		truncHistory = componentData.Table.Truncate(truncHistory, truncMaxFrames)
	end

	_safelyLoadModuleAndRun(frameModule, "Setup", newFrame, componentData)
	_changeSelectorHighlight(componentData.Tweens, frameName)
end

-- Safely disconnects and destroys any active frames.
local function _onExitButtonClicked(componentData: Definitions.componentData): ()
	_toggleUI(componentData)
end

-- Toggles the 'Enabled' property of the GUI & destroys any existing modular connections.
function _toggleUI(componentData: Definitions.componentData)
	isToggled = not isToggled

	if not isToggled then
		onDestroy(componentData)
		return
	end

	UI.Enabled = true

	-- Setup top button tab buttons.
	for _, componentButton: TextButton in ipairs(Buttons.Holder:GetChildren()) do
		if not componentButton:IsA("ImageButton") or not componentButton.Visible then
			continue
		end

		table.insert(
			Maid.Children,
			componentButton.MouseButton1Click:Connect(function()
				_openFrame(componentData, componentButton.Name)
			end)
		)
	end

	-- Exit button
	table.insert(
		Maid.Children,
		Top.Exit.MouseButton1Click:Connect(function()
			_onExitButtonClicked(componentData)
		end)
	)

	-- Main frame's dragging mechanics
	do
		local isDragging = false
		local startX, startY, startFramePos
		table.insert(
			Maid.Children,
			Top.Drag.MouseButton1Down:Connect(function()
				isDragging = true

				startX, startY = Mouse.X, Mouse.Y
				startFramePos = Frame.Position
			end)
		)

		table.insert(
			Maid.Children,
			Top.Drag.MouseButton1Up:Connect(function()
				isDragging = false
			end)
		)

		table.insert(
			Maid.Children,
			Mouse.Move:Connect(function()
				if not isDragging then
					return
				end

				local distX, distY = startX - Mouse.X, startY - Mouse.Y
				componentData
					.Tweens(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = startFramePos - UDim2.fromOffset(distX, distY),
					})
					:Play()
			end)
		)
	end

	-- Resize mobile user's text size to hopefully fit better.
	-- I don't want to hear that this is a bad solution.
	if UserInputService.TouchEnabled then
		for _, uiTextConstraint: UITextSizeConstraint in ipairs(UI:GetDescendants()) do
			if not uiTextConstraint:IsA("UITextSizeConstraint") then
				continue
			end

			uiTextConstraint.MaxTextSize -= 8
		end

		Frame.Size = UDim2.fromScale(1, 0.45)
	end

	local visibleFrames = componentData.Table.Filter(Buttons.Holder:GetChildren(), function(button: GuiBase2d)
		return button:IsA("ImageButton") and button.Visible == true
	end)

	local foundFrameThatsVisible = visibleFrames[1]
	if not foundFrameThatsVisible then
		return -- Odd, why enable the UI if you have no tabs to open?
	end

	truncMaxFrames = #visibleFrames

	-- CANCEL: Ensure the ranking frame is always the first to open.
	-- - If developers can remove tabs, why hard-code 'Ranking' frame?
	_openFrame(componentData, foundFrameThatsVisible.Name)
end

function onDestroy(componentData: Definitions.componentData)
	if not componentData.Data.useBeta then
		return oldUIData.Destroy
	end

	UI.Enabled = false
	UI.Frame.Position = UDim2.fromScale(0.5, 0.5)

	componentData.Disconnect(Maid.Children)
	table.clear(Maid.Children)

	if currentOpenFrame == nil then
		return
	end

	_safelyLoadModuleAndRun(frameComponents:FindFirstChild(currentOpenFrame.Name), "Destroy", componentData)

	currentOpenFrame.Position = UDim2.fromScale(1.5, 0.5)
	currentOpenFrame = nil

	return
end

function onSetup(componentData: Definitions.componentData)
	local staffInformation = componentData.remoteFunction:InvokeServer("staffCheck", "Interface")
	if
		typeof(staffInformation) ~= "table"
		or not staffInformation.Rank
		or staffInformation.Rank < componentData.Data.MinRank
	then
		componentData._debug("staff_check", "Staff check failed for Interface.")
		return
	end

	if not componentData.Data.useBeta then
		componentData._warn("Vibez Setup", "Setting up V1 Interface.")

		oldUIData.Setup(componentData)
		return
	end

	onDestroy(componentData)

	if notifiedAboutBetaUsage == false then
		notifiedAboutBetaUsage = nil
		componentData._warn(
			"Vibez Beta",
			"Your group owner has opted to use our in-development UI, please keep in mind that this UI is still being worked on and can contain bugs!"
		)
	end

	local interfaceData = componentData.Data
	if topBarButton ~= nil then
		componentData._debug(
			"interface_initialization",
			"Initialization of topbar button failed due to one already existing."
		)
		return
	end

	for _, viewableTab: string in ipairs(componentData.Data.nonViewableTabs) do
		local debugView = table.create(#componentData.Data.nonViewableTabs)

		for _, tab: GuiLabel in ipairs(Buttons.Holder:GetChildren()) do
			if string.lower(viewableTab) == string.lower(tab.Name) then
				table.insert(debugView, tab.Name)
				tab.Visible = false
			end
		end

		componentData._debug(
			"interface_tabs_view",
			"Disabled " .. #debugView .. " tabs. (" .. table.concat(debugView, ", ") .. ")"
		)
	end

	--stylua: ignore
	topBarButton = componentData.TopbarPlus
		.new()
		:setImage(interfaceData.iconImageId)
		:setCaption(interfaceData.iconToolTip)
		:align(interfaceData.iconPosition)
		:bindToggleKey(Enum.KeyCode[interfaceData.iconKeybind])
		.toggled:Connect(function(state: boolean)
			if state then
				_toggleUI(componentData)
				return
			end

			_onExitButtonClicked(componentData)
		end)

	componentData._debug("interface_initialization", "Setup completed.")

	-- Apply group name as the title.
	local groupNameLabel = Top.Left.Title
	local isOk, groupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, componentData.GroupId)

	groupNameLabel.Text = isOk and groupInfo.Name or ""

	-- Rojo doesn't recognize the .Wraps property on UIListLayouts...
	-- - Turns out it also doesn't like using the specified fonts...
	Content.Ranking.Actions.Body.UIListLayout.Wraps = true
	return
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
