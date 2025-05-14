local Table = require(script.Parent.Table)
local TweenService = require(script.Parent.TweenService)

local Graph = {}
local Class = {}

Class.__index = Class

type Public = {
	StartAtZero: boolean,

	Frame: any,
	_points: { [string]: { number } },
	_connections: { RBXScriptConnection },
	_components: any,
}
type Private = typeof(Class)
export type GraphKind = typeof(setmetatable({} :: Public, {} :: Private))

local function generateUniqueColorForName(name: string): Color3
	local split = name:split("")
	local allBytes = Table.Reduce(split, function(acc: number, val: string)
		return acc + tostring(val):byte()
	end, 0)

	local rand = Random.new(allBytes)
	local hue, sat = rand:NextNumber(), rand:NextNumber()
	return Color3.fromHSV(hue, sat, 1)
end

function Graph.new(componentData: any, Frame: any, Activity: { [string]: {} }): GraphKind
	local self = setmetatable({}, Class)

	self.Frame = Frame
	self.StartAtZero = true
	self._components = componentData
	self._points = Activity
	self._connections = {}

	return self
end

function Class.Render(self: GraphKind)
	local Min, Max = math.huge, -math.huge

	Table.ForEach(self._points, function(v)
		Min = math.min(Min, math.min(table.unpack(v)))
		Max = math.max(Max, math.max(table.unpack(v)))
	end)

	if self.StartAtZero then
		Min, Max = 0, Max * 1.75
	end

	local Range = Max - Min
	for i = 0, 1, 0.2 do
		local Label = Instance.new("TextLabel")
		Label.BackgroundTransparency = 1
		Label.Parent = self.Frame.Range
		Label.Name = tostring(1 - i)
		Label.Size = UDim2.fromScale(0.95, 0.1)

		Label.TextScaled = true
		Label.TextXAlignment = Enum.TextXAlignment.Right
		Label.TextColor3 = Color3.new(1, 1, 1)
		Label.Text = tostring(math.floor(Min + (Range * i)))
	end

	-- FIXME: Mixed points keys with both messages and seconds, should just take 1 and plot 2 points on the bar.
	-- self._points: { [string]: { number } }
	local iter = 0
	for Key, Points in self._points do
		local keyColor = generateUniqueColorForName(Key)
		iter += 1

		for i = 1, #Points do
			local Column = self.Frame.Columns[i]
			local Value = Points[i]
			local YScale = Range == 0 and 0.9 or 0.9 - (((Value - Min) / Range) * 0.9)
			local Bar = Column.Bar

			if iter ~= 1 then
				Bar = Column.Bar:Clone()
				Bar.ZIndex = iter * -1
			end

			Bar.Point.BackgroundColor3 = keyColor
			self._components.MouseHover:Add(Bar.Point, `{Value} {string.lower(Key)}`)

			TweenService(Bar, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(0.2, YScale + 0.05),
			}):Play()
			task.wait(0.1)
		end
	end
end

function Class.Destroy(self: GraphKind): ()
	for i in self._connections do
		self._connections[i]:Disconnect()
	end

	local children = self.Frame.Columns:GetChildren()
	for _ = 1, children do
		children.Bar.Size = UDim2.fromScale(0.2, 0.05)
	end

	table.clear(self :: any)
	setmetatable(self :: any, nil)
	self = nil :: any
end

return Graph
