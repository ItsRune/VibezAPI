--!strict
--// Modules \\--
local Tweens = require(script.Parent.TweenService)

--// Functions \\--
local function createBubble(Parent: GuiObject, input: InputObject)
	local x = (input.Position.X - Parent.AbsolutePosition.X) / Parent.AbsoluteSize.X
	local y = (input.Position.Y - Parent.AbsolutePosition.Y) / Parent.AbsoluteSize.Y

	local dot = Instance.new("Frame")
	local corner = Instance.new("UICorner")
	local aspect = Instance.new("UIAspectRatioConstraint")

	dot.BackgroundTransparency = 0.75
	dot.Parent = Parent
	dot.Position = UDim2.fromScale(x, y)
	dot.Size = UDim2.fromScale(0, 0)

	aspect.Parent = dot
	corner.Parent = dot
	corner.CornerRadius = UDim.new(1, 0)

	Tweens(dot, TweenInfo.new(0.5), {
		Size = UDim2.new(2, 0, 10, 0),
		Position = UDim2.new(x - 1, 0, y - 5, 0),
		BackgroundTransparency = 1,
	}):onCompleted(function()
		dot:Destroy()
	end):Play()
end

--// Return \\--
return createBubble
