--// Services \\--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constants \\--
local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild(
	"4bc06805148f173646ac84bff8a02dda70cbe6da-2fada46fb6f0950336a4765018e59d30b4ac5255",
	math.huge
)
local eventHolder = {}
local Maid = {}
local afkConnections = {}
local State = false

--// Functions \\--
local function onSetupUI()
	if State == false then
		State = StarterGui:GetCore("AvatarContextMenuEnabled")
	end

	eventHolder["Promote"] = Instance.new("BindableEvent")
	eventHolder["Demote"] = Instance.new("BindableEvent")
	eventHolder["Fire"] = Instance.new("BindableEvent")

	local function promote(target)
		Remote:InvokeServer("promote", target)
	end

	local function demote(target)
		Remote:InvokeServer("demote", target)
	end

	local function fire(target)
		Remote:InvokeServer("fire", target)
	end

	table.insert(Maid, eventHolder.Promote.Event:Connect(promote))
	table.insert(Maid, eventHolder.Demote.Event:Connect(demote))
	table.insert(Maid, eventHolder.Fire.Event:Connect(fire))

	StarterGui:SetCore("AvatarContextMenuEnabled", true)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("AddAvatarContextMenuOption", { "Promote", eventHolder.Promote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Demote", eventHolder.Demote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Fire", eventHolder.Fire })

	local highLight = nil
	pcall(function()
		RunService:BindToRenderStep("Vibez_Client_HoverEffect", Enum.RenderPriority.Camera.Value + 1, function()
			local Mouse = Players.LocalPlayer:GetMouse()
			local possiblePlayer = (Mouse.Target and Players:GetPlayerFromCharacter(Mouse.Target.Parent))

			if not possiblePlayer then
				if highLight then
					highLight.Enabled = false
				end
				return
			end

			if highLight then
				highLight.Enabled = true
				highLight.Adornee = possiblePlayer.Character
				return
			end

			highLight = Instance.new("Highlight")
			highLight.Parent = script
			highLight.Adornee = possiblePlayer.Character
			highLight.FillTransparency = 1

			highLight.OutlineColor = Color3.fromRGB(255, 100, 255)
			highLight.Enabled = true
		end)
	end)

	local transparencyCounter = 0
	local dir = 1
	pcall(function()
		RunService:BindToRenderStep("Vibez_Client_Highlight_Flash", Enum.RenderPriority.Camera.Value + 1, function()
			if not highLight or not highLight.Enabled then
				return
			end

			dir = (transparencyCounter >= 0.75 and -1) or (transparencyCounter <= 0 and 1) or dir
			transparencyCounter += 0.02 * dir

			highLight.OutlineTransparency = transparencyCounter
		end)
	end)

	table.insert(
		Maid,
		Workspace.CurrentCamera.ChildAdded:Connect(function(child)
			if child.Name == "ContextMenuArrow" then
				child:WaitForChild("Union").Color = Color3.fromRGB(251, 155, 213)
			end
		end)
	)
end

local function undoUISetup()
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Promote")
	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Demote")
	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Fire")

	for _, connections: RBXScriptConnection in pairs(Maid) do
		connections:Disconnect()
	end
	Maid = {}

	for _, binds in pairs(eventHolder) do
		binds:Destroy()
	end
	eventHolder = {}

	if State == true then
		return
	end

	StarterGui:SetCore("AvatarContextMenuEnabled", false)
end

local function setupAFKCheck()
	local lastCheck = DateTime.now().UnixTimestamp
	local Counter = 0

	table.insert(
		afkConnections,
		UserInputService.WindowFocused:Connect(function()
			Remote:InvokeServer("Afk", false)
		end)
	)

	table.insert(
		afkConnections,
		UserInputService.WindowFocusReleased:Connect(function()
			Remote:InvokeServer("Afk", true)
		end)
	)

	table.insert(
		afkConnections,
		UserInputService.InputBegan:Connect(function()
			if Counter >= 30 then
				warn("undid Afk from counter")
				Remote:InvokeServer("Afk", false)
			end

			Counter = 0
		end)
	)

	pcall(function()
		RunService:BindToRenderStep("Vibez_AFK_Tracker", Enum.RenderPriority.Last.Value, function()
			local now = DateTime.now().UnixTimestamp
			local delayOffset = Workspace:GetAttribute(script.Name .. "_AFK_DELAY")

			if tonumber(delayOffset) == nil then
				delayOffset = 30
			end

			-- Prevent checks from force updating the AFK
			if Counter == delayOffset then
				return
			end

			if now - lastCheck < 1 then
				return
			end

			lastCheck = now
			Counter += 1

			if Counter == delayOffset then
				Remote:InvokeServer("Afk", true)
			end
		end)
	end)
end

local function undoAfkCheck()
	for _, v in pairs(afkConnections) do
		v:Disconnect()
	end

	pcall(function()
		RunService:UnbindFromRenderStep("Vibez_AFK_Tracker")
	end)

	table.clear(afkConnections)
end

local function onAfkAttributeChanged()
	local isEnabled = Workspace:GetAttribute(script.Name .. "_AFK")
	if isEnabled then
		setupAFKCheck()
	else
		undoAfkCheck()
	end
end

local function onAttributeChanged()
	local isEnabled = Workspace:GetAttribute(script.Name .. "_UI")
	if isEnabled then
		onSetupUI()
	else
		undoUISetup()
	end
end

local function onStart()
	onAfkAttributeChanged()
	onAttributeChanged()

	-- Attribute Checks
	Workspace:GetAttributeChangedSignal(script.Name .. "_AFK"):Connect(onAfkAttributeChanged)
	Workspace:GetAttributeChangedSignal(script.Name .. "_UI"):Connect(onAttributeChanged)

	if script.Parent.Name ~= "PlayerScripts" then
		task.wait(5)
		script.Parent = Player:WaitForChild("PlayerScripts", math.huge)

		local Clone = script:Clone()
		Clone.Parent = StarterPlayerScripts
	end
end

--// Main \\--
onStart()
