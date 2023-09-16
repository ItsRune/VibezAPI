--// Services \\--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

--// Constants \\--
local eventHolder = {}
local Maid = {}
local State = false

--// Functions \\--
local function onSetup()
	if State == false then
		State = StarterGui:GetCore("AvatarContextMenuEnabled")
	end

	eventHolder["Promote"] = Instance.new("BindableEvent")
	eventHolder["Demote"] = Instance.new("BindableEvent")
	eventHolder["Fire"] = Instance.new("BindableEvent")

	local function promote(target)
		game.ReplicatedStorage.__VibezEvent__:InvokeServer("promote", target)
	end

	local function demote(target)
		game.ReplicatedStorage.__VibezEvent__:InvokeServer("demote", target)
	end

	local function fire(target)
		game.ReplicatedStorage.__VibezEvent__:InvokeServer("fire", target)
	end

	eventHolder.Promote.Event:Connect(promote)
	eventHolder.Demote.Event:Connect(demote)
	eventHolder.Fire.Event:Connect(fire)

	StarterGui:SetCore("AvatarContextMenuEnabled", true)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("AddAvatarContextMenuOption", { "Promote", eventHolder.Promote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Demote", eventHolder.Demote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Fire", eventHolder.Fire })
end

local function undoSetup()
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

local function onAttributeChanged(isEnabled: boolean)
	local Action = isEnabled and "Setup" or "Reset"
	if Action == "Setup" then
		onSetup()
	elseif Action == "Reset" then
		undoSetup()
	end
end

local function onStart()
	if StarterGui:FindFirstChild(script.Name) == nil then
		script:Clone().Parent = StarterGui
	end

	local attrValue = Workspace:GetAttribute(script.Name)
	if attrValue ~= nil then
		onAttributeChanged(attrValue)
	end

	Workspace:GetAttributeChangedSignal(script.Name):Connect(onAttributeChanged)

	local highLight = nil
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

	local transparencyCounter = 0
	local dir = 1
	RunService:BindToRenderStep("Vibez_Client_Highlight_Flash", Enum.RenderPriority.Camera.Value + 1, function()
		if not highLight or not highLight.Enabled then
			return
		end

		dir = (transparencyCounter >= 0.75 and -1) or (transparencyCounter <= 0 and 1) or dir
		transparencyCounter += 0.02 * dir

		highLight.OutlineTransparency = transparencyCounter
	end)

	Workspace.CurrentCamera.ChildAdded:Connect(function(child)
		if child.Name == "ContextMenuArrow" then
			child:WaitForChild("Union").Color = Color3.fromRGB(251, 155, 213)
		end
	end)
end

--// Main \\--
onStart()
