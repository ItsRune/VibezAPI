--// Services \\--
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// Constants \\--
local Player = Players.LocalPlayer
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

	local currentClosest = nil
	local function getClosestPlayer(): Player?
		local closest = nil
		local playerChar = Player.Character

		if not playerChar then
			return nil
		end

		for _, player in pairs(Players:GetPlayers()) do
			-- if player == Player then
			-- 	continue
			-- end

			local otherCharacter = player.Character
			if not otherCharacter then
				continue
			end

			if
				(
					closest ~= nil
					and (closest.Character.PrimaryPart.Position - otherCharacter.PrimaryPart.Position).Magnitude
						< 10
				)
				or (
					not closest
					and (playerChar.PrimaryPart.Position - otherCharacter.PrimaryPart.Position).Magnitude < 10
				)
			then
				closest = player
			end
		end

		return closest
	end

	table.insert(
		Maid,
		RunService.RenderStepped:Connect(function()
			local closestPlayer = getClosestPlayer()

			if closestPlayer == currentClosest or not closestPlayer then
				return
			end

			StarterGui:SetCore("AvatarContextMenuTarget", closestPlayer)
		end)
	)
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
	local attrValue = Workspace:GetAttribute("__Vibez UI__")
	if attrValue ~= nil then
		onAttributeChanged(attrValue)
	end

	Workspace:GetAttributeChangedSignal("__Vibez UI__"):Connect(onAttributeChanged)

	Workspace.CurrentCamera.ChildAdded:Connect(function(child)
		if child.Name == "ContextMenuArrow" then
			child:WaitForChild("Union").Color = Color3.fromRGB(251, 189, 226)
		end
	end)
end

--// Main \\--
onStart()
