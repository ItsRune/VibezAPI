-- Not as clean as the main module. But it works...
--// Services \\--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constants \\--
local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild(script.Name, math.huge)
local eventHolder = {}
local Maid = {}
local afkDelayOffset = 5
local isUIContextEnabled = false
local Zone = require(script.Zone)

--// Functions \\--
--selene: allow(unused_variable)
local function onSetupWidgets()
	--
end

local function undoRankSticks()
	if Maid["RankSticks"] ~= nil then
		for _, v in pairs(Maid.RankSticks) do
			if typeof(v) == "RBXScriptConnection" then
				v:Disconnect()
			elseif typeof(v) == "table" then
				for _, b in pairs(v) do
					b:Disconnect()
				end
			end
		end
	end

	Maid["RankSticks"] = nil
end

local function onSetupRankSticks()
	local custScriptName = string.split(script.Name, "-")[1]
	local Character = Player.Character or Player.CharacterAdded:Wait()

	undoRankSticks()
	Maid["RankSticks"] = {}

	table.insert(
		Maid.RankSticks,
		Character.ChildAdded:Connect(function(child: Instance)
			if child:GetAttribute(custScriptName) == "RankSticks" and child:IsA("Tool") then
				local actionName = child.Name

				Maid.RankSticks[actionName] = {
					child.Activated:Connect(function()
						local cf, size = Character:GetBoundingBox()
						local newPart = Instance.new("Part")
						local Weld = Instance.new("WeldConstraint")

						newPart.Name = actionName .. "_Checker"
						newPart.Transparency = 0.5
						newPart.CFrame = cf * CFrame.new(0, 0, -size.Z * 2.25)
						newPart.Anchored = false
						newPart.Size = size + Vector3.new(0, 0, size.Z)
						newPart.BrickColor = BrickColor.Red()
						newPart.Massless = true
						newPart.Parent = Character.PrimaryPart

						Weld.Name = newPart.Name
						Weld.Part0 = newPart
						Weld.Part1 = Character.PrimaryPart
						Weld.Parent = newPart

						local zone = Zone.new(newPart)
						local players = zone:getPlayers()

						zone:destroy()
						newPart:Destroy()

						local closestTarget = nil
						for _, target: Player in pairs(players) do
							local t_char = target.Character
							local c_char = closestTarget.Character

							if
								closestTarget == nil
								or (
									closestTarget ~= nil
									and (Character.PrimaryPart.Position - c_char.PrimaryPart.Position).Magnitude
										> (Character.PrimaryPart.Position - t_char.PrimaryPart.Position).Magnitude
								)
							then
								closestTarget = target
							end
						end

						if closestTarget == nil then
							return -- No one close enough
						end

						Remote:InvokeServer(string.lower(actionName), "Sticks", closestTarget)
					end),
				}
			end
		end)
	)

	table.insert(
		Maid.RankSticks,
		Character.ChildRemoved:Connect(function(child: Instance)
			if child:GetAttribute(custScriptName) == "RankSticks" and child:IsA("Tool") then
				if Maid.RankSticks[child.Name] ~= nil then
					for _, v: RBXScriptConnection in pairs(Maid.RankSticks[child.Name]) do
						v:Disconnect()
					end
				end
			end
		end)
	)
end

local function onSetupUI()
	if isUIContextEnabled == false then
		isUIContextEnabled = StarterGui:GetCore("AvatarContextMenuEnabled")
	end

	eventHolder["Promote"] = Instance.new("BindableEvent")
	eventHolder["Demote"] = Instance.new("BindableEvent")
	eventHolder["Fire"] = Instance.new("BindableEvent")

	local function promote(target)
		Remote:InvokeServer("promote", "Interface", target)
	end

	local function demote(target)
		Remote:InvokeServer("demote", "Interface", target)
	end

	local function fire(target)
		Remote:InvokeServer("fire", "Interface", target)
	end

	local function blacklist(target)
		Remote:InvokeServer("blacklist", "Interface", target)
	end

	table.insert(Maid, eventHolder.Promote.Event:Connect(promote))
	table.insert(Maid, eventHolder.Demote.Event:Connect(demote))
	table.insert(Maid, eventHolder.Fire.Event:Connect(fire))
	table.insert(Maid, eventHolder.Blacklist.Event:Connect(blacklist))

	StarterGui:SetCore("AvatarContextMenuEnabled", true)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.InspectMenu)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Friend)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Emote)
	StarterGui:SetCore("RemoveAvatarContextMenuOption", Enum.AvatarContextMenuOption.Chat)

	StarterGui:SetCore("AddAvatarContextMenuOption", { "Promote", eventHolder.Promote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Demote", eventHolder.Demote })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Fire", eventHolder.Fire })
	StarterGui:SetCore("AddAvatarContextMenuOption", { "Blacklist", eventHolder.Blacklist })

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

	if isUIContextEnabled == true then
		return
	end

	StarterGui:SetCore("AvatarContextMenuEnabled", false)
end

local function undoAfkCheck()
	if not Maid["AFK"] then
		return
	end

	for _, v in pairs(Maid.AFK) do
		v:Disconnect()
	end

	pcall(function()
		RunService:UnbindFromRenderStep("Vibez_AFK_Tracker")
	end)

	Maid.AFK = nil
end

local function setupAFKCheck()
	undoAfkCheck()

	local lastCheck = DateTime.now().UnixTimestamp
	local Counter = 0

	Maid["AFK"] = {}
	table.insert(
		Maid.AFK,
		UserInputService.WindowFocused:Connect(function()
			Remote:InvokeServer("Afk", false)
		end)
	)

	table.insert(
		Maid.AFK,
		UserInputService.WindowFocusReleased:Connect(function()
			Remote:InvokeServer("Afk", true)
		end)
	)

	table.insert(
		Maid.AFK,
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

			if tonumber(afkDelayOffset) == nil then
				afkDelayOffset = 30
			end

			-- Prevent checks from force updating the AFK
			if Counter == afkDelayOffset then
				return
			end

			if now - lastCheck < 1 then
				return
			end

			lastCheck = now
			Counter += 1

			if Counter == afkDelayOffset then
				Remote:InvokeServer("Afk", true)
			end
		end)
	end)
end

local function onAttributeChanged()
	local isOk, States = nil, Workspace:GetAttribute(script.Name)

	warn(isOk, States)
	if not States then
		return
	end

	isOk, States = pcall(HttpService.JSONDecode, HttpService, States)
	if not isOk then
		return
	end

	if States.UI.Status == true then
		onSetupUI()
	else
		undoUISetup()
	end

	if States.AFK.Status == true then
		setupAFKCheck()
	else
		undoAfkCheck()
	end

	if States.STICKS.Status == true then
		onSetupRankSticks()
	else
		undoRankSticks()
	end

	afkDelayOffset = States.AFK.Delay
end

local function onStart()
	onAttributeChanged()

	-- Attribute Checks
	Workspace:GetAttributeChangedSignal(script.Name):Connect(onAttributeChanged)

	if script.Parent.Name ~= "PlayerScripts" then
		task.wait(5)
		script.Parent = Player:WaitForChild("PlayerScripts", math.huge)

		local Clone = script:Clone()
		Clone.Parent = StarterPlayerScripts
	end
end

--// Main \\--
onStart()
