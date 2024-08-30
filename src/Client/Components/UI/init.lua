--!nocheck
--!nolint
--// Services \\--
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
local frameComponents = script.Frames
local Maid = {
	Parent = {},
	Children = {},
}

--// UI Variables \\--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local UI = script.Interface
local Frame = UI.Frame
local Content, Top = Frame.Content, Frame.Top
local currentOpenFrame, isToggled = nil, false
local onSetup, onDestroy, _toggleUI, topBarButton

--// Functions \\--
-- Changes the color of the active topbar button to be a brighter white.
local function _changeSelectorHighlight(Tweens: Tweens, frameName: string)
	-- Selected color: 255, 255, 255
	-- Unselected color: 147, 147, 147

	for _, topButton: TextButton in ipairs(Top.Buttons:GetChildren()) do
		if not topButton:IsA("TextButton") then
			continue
		end

		local colorToShiftTo = (frameName == topButton.Name) and Color3.new(1, 1, 1) or Color3.fromRGB(147, 147, 147)
		local Tween = Tweens(topButton, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			TextColor3 = colorToShiftTo,
		})

		Tween:Play()
	end
end

-- Protected calls to prevent any issues with loading/executing a frame's module.
local function _safelyLoadModuleAndRun(module: ModuleScript, subCommand: string, ...: any)
	local _, requiredModule = pcall(require, module)
	pcall(requiredModule[subCommand], ...)
end

local function _openFrame(componentData: { [any]: any }, frameName: string)
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

		local newCurrentReference = currentOpenFrame
		local previousFrameModule = frameComponents:FindFirstChild(newCurrentReference.Name)

		if previousFrameModule and previousFrameModule:IsA("ModuleScript") then
			_safelyLoadModuleAndRun(previousFrameModule, "Destroy", newCurrentReference, componentData)
		end

		local Tween = Tweens(newCurrentReference, tweenInOutInfo, {
			Position = UDim2.fromScale(-0.5, 0.5),
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

	_safelyLoadModuleAndRun(frameModule, "Setup", newFrame, componentData)
	_changeSelectorHighlight(componentData.Tweens, frameName)
end

-- Safely disconnects and destroys any active frames.
local function _onExitButtonClicked(componentData: { [any]: any }): ()
	_toggleUI(componentData)
end

-- Toggles the 'Enabled' property of the GUI & destroys any existing modular connections.
function _toggleUI(componentData: { [any]: any })
	isToggled = not isToggled

	if not isToggled then
		onDestroy(componentData)
		return
	end

	UI.Enabled = true

	-- Setup top button tab buttons.
	for _, componentButton: TextButton in ipairs(Top.Buttons:GetChildren()) do
		if not componentButton:IsA("TextButton") then
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
	table.insert(Maid.Children, Top.Exit.MouseButton1Click:Connect(_onExitButtonClicked))

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

	-- Ensure the ranking frame is always the first to open.
	_openFrame(componentData, "Ranking")
end

function onDestroy(componentData: { [any]: any })
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
end

function onSetup(componentData: { [any]: any })
	onDestroy(componentData)

	local interfaceData = componentData.Data
	if not componentData.Data.iconAllowMobile or topBarButton ~= nil then
		return
	end

	--stylua: ignore
	componentData.TopbarPlus
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
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
