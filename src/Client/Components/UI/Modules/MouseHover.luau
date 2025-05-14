local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local componentsFolder = script:FindFirstAncestor("Components")
local Table = require(componentsFolder.Parent.Modules.Table)

local MouseHover = {}
local Class = {}

Class.__index = Class

type Public = { _toDetect: { { any } }, _activeLabel: TextLabel? }
type Private = typeof(Class)
export type MouseHoverKind = typeof(setmetatable({} :: Public, {} :: Private))

function MouseHover.new(): MouseHoverKind
	local self = setmetatable({}, Class)

	-- _toDetect type: { { Frame, "Text" } }
	self._toDetect = {}
	self._activeLabel = nil

	self:_initialize()

	return self
end

function Class.Add(self: MouseHoverKind, frame: Frame, str: string)
	table.insert(self._toDetect, { frame, str :: any })
end

function Class.Remove(self: MouseHoverKind, frame: Frame)
	local _, index = Table.Find(self._toDetect, function(v)
		return v[1] == frame
	end)

	if not index then
		return
	end

	table.remove(self._toDetect, index)
end

function Class._initialize(self: MouseHoverKind)
	pcall(
		RunService.BindToRenderStep,
		RunService,
		"vibez_interface_mouse_hover",
		Enum.RenderPriority.Last.Value,
		function()
			if #self._toDetect == 0 then
				return
			end

			local Player = Players.LocalPlayer
			local PlayerGui: PlayerGui = Player:FindFirstChild("PlayerGui")

			if not PlayerGui then
				return
			end

			local Mouse = Player:GetMouse()
			local Objects = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)

			for i = 1, #self._toDetect do
				local found = Table.Find(Objects, function(obj: GuiObject)
					return obj.Name == self._toDetect[i][1].Name
				end)

				if
					not found
					or (
						found
						and (
							found.Visible == false
							or (
								found.Position.X.Scale > 1
								or found.Position.X.Scale < 0
								or found.Position.Y.Scale > 1
								or found.Position.Y.Scale < 0
							)
						)
					)
				then
					continue
				end

				local text = self._toDetect[i][2]
				local fontSize, font, frameSize =
					Enum.FontSize.Size18, Enum.Font.GothamMedium, componentsFolder.UI.Interface.Hover.AbsoluteSize / 2

				local textSize = TextService:GetTextSize(text, fontSize.Value, font, frameSize)
				self._activeLabel = Instance.new("TextLabel")

				-- Stupid Luau-LSP, making me write something obviously redundant...
				if not self._activeLabel then
					warn("[Vibez]: Somehow 'MouseHover' rendering loop broke.")
					self._activeLabel = nil
					break
				end

				self._activeLabel.Text = self._toDetect[i][2]
				self._activeLabel.Size = UDim2.fromScale(textSize.X, textSize.Y)
				self._activeLabel.Parent = componentsFolder.UI.Interface.Hover
				self._activeLabel.TextScaled = true
				self._activeLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

				local UICorner = Instance.new("UICorner")
				UICorner.CornerRadius = UDim.new(0.2, 0)
				UICorner.Parent = self._activeLabel

				componentsFolder.UI.Interface.Hover.Visible = true
				return
			end

			-- Afterwards, ensure we destroy the active label.
			if self._activeLabel then
				self._activeLabel:Destroy()
				self._activeLabel = nil
				componentsFolder.UI.Interface.Hover.Visible = false
			end
		end
	)
end

function Class.Destroy(self: MouseHoverKind): ()
	pcall(RunService.UnbindFromRenderStep, RunService, "vibez_interface_mouse_hover")

	table.clear(self :: any)
	setmetatable(self :: any, nil)
	self = nil :: any
end

return MouseHover
