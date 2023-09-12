--// Services \\--
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

	Maid.Promote.Event:Connect(promote)
	Maid.Demote.Event:Connect(demote)
	Maid.Fire.Event:Connect(fire)
	
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

local Remote = nil
repeat
	task.wait()
	Remote = ReplicatedStorage:FindFirstChild("__Vibez API__")
until Remote ~= nil

Remote.OnClientInvoke = function(Action: string)
	if Action == "Setup" then
		onSetup()
	elseif Action == "Reset" then
		undoSetup()
	end
end

Workspace.CurrentCamera.ChildAdded:Connect(function(child)
	if child.Name == "ContextMenuArrow" then
		child:WaitForChild("Union").Color = Color3.fromRGB(251, 189, 226)
	end
end)