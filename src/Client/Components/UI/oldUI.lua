--!nocheck
--// Services \\--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local isUIContextEnabled = false
local eventHolder, Maid = {}, {}

--// Functions \\--
local function onSetupUI(componentData: { [any]: any })
	local remoteFunction = componentData.remoteFunction
	if isUIContextEnabled == false then
		isUIContextEnabled = StarterGui:GetCore("AvatarContextMenuEnabled")
	end

	eventHolder["Promote"] = Instance.new("BindableEvent")
	eventHolder["Demote"] = Instance.new("BindableEvent")
	eventHolder["Fire"] = Instance.new("BindableEvent")
	eventHolder["Blacklist"] = Instance.new("BindableEvent")

	local function promote(target)
		remoteFunction:InvokeServer("promote", "Interface", target)
	end

	local function demote(target)
		remoteFunction:InvokeServer("demote", "Interface", target)
	end

	local function fire(target)
		remoteFunction:InvokeServer("fire", "Interface", target)
	end

	local function blacklist(target)
		remoteFunction:InvokeServer("blacklist", "Interface", target)
	end

	Maid = {}
	table.insert(Maid, eventHolder.Promote.Event:Connect(promote))
	table.insert(Maid, eventHolder.Demote.Event:Connect(demote))
	table.insert(Maid, eventHolder.Fire.Event:Connect(fire))
	table.insert(Maid, eventHolder.Blacklist.Event:Connect(blacklist))

	StarterGui:SetCore("AvatarContextMenuEnabled", true)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("AddAvatarContextMenuOption", { "Promote", eventHolder.Promote } :: { any })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Demote", eventHolder.Demote } :: { any })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Fire", eventHolder.Fire } :: { any })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Blacklist", eventHolder.Blacklist } :: { any })

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

			highLight = Instance.new("Highlight") :: any
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
			transparencyCounter += 0.03 * dir

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

local function undoUISetup(componentData: { [any]: any })
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("AddAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Promote")
	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Demote")
	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Fire")
	StarterGui:SetCore("RemoveAvatarContextMenuOption", "Blacklist")

	componentData.Disconnect(Maid)
	Maid = nil

	for _, binds in pairs(eventHolder) do
		binds:Destroy()
	end
	eventHolder = {}

	if isUIContextEnabled == true then
		return
	end

	StarterGui:SetCore("AvatarContextMenuEnabled", false)
end

return {
	Setup = onSetupUI,
	Destroy = undoUISetup,
}
