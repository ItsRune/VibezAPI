--#selene: allow(unused_variable)
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
local Player = Players.LocalPlayer
local frameComponents = script.Frames
local Maid = {}

--// UI Variables \\--
local UI = script.Interface
local Frame = UI.Frame
local Content, Top, Bottom = Frame.Content, Frame.Top, Frame.Bottom
local currentOpenFrame = nil

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
		Tweens(topButton, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			TextColor3 = colorToShiftTo,
		}):Play()
	end
end

-- Protected calls to prevent any issues with loading/executing a frame's module.
local function _safelyLoadModuleAndRun(module: ModuleScript, subCommand: string, ...: any)
	local _, requiredModule = pcall(require, module)
	pcall(requiredModule[subCommand], ...)
end

local function _openFrame(componentData: { [any]: any }, frameName: string)
	local newFrame = Content:FindFirstChild(frameName)
	local tweenOutInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local tweenInInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
	local Tweens: Tweens = componentData.Tweens

	-- We can't proceed if there's no frame available.
	if not newFrame then
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

		Tweens(newCurrentReference, tweenInInfo, {
			Position = UDim2.fromScale(-0.5, 0.5),
		}):setCallback(function(playBackState)
			if playBackState ~= Enum.PlaybackState.Completed then
				return
			end

			newCurrentReference.Position = UDim2.fromScale(1.5, 0.5)
		end):Play()
	end

	Tweens(newFrame, tweenOutInfo, {
		Position = UDim2.fromScale(0.5, 0.5),
	}):Play()

	local frameModule = frameComponents:FindFirstChild(frameName)
	if not frameModule or not frameModule:IsA("ModuleScript") then
		componentData._warn("UI Error", "No module could be found for page '" .. frameName .. "'!")
		return
	end

	_safelyLoadModuleAndRun(frameModule, "Setup", newFrame, componentData)
	_changeSelectorHighlight(componentData.Tweens, frameName)
end

local function onDestroy(componentData: { [any]: any })
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(componentData: { [any]: any })
	onDestroy(componentData)

	for _, componentButton: TextButton in ipairs(Top.Buttons:GetChildren()) do
		if not componentButton:IsA("TextButton") then
			continue
		end

		table.insert(
			Maid,
			componentButton.MouseButton1Click:Connect(function()
				_openFrame(componentData, componentButton.Name)
			end)
		)
	end

	table.insert(
		Maid,
		Top.Exit.MouseButton1Click:Connect(function()
			warn("Close frame. (PLACEHOLDER)")
		end)
	)

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
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
