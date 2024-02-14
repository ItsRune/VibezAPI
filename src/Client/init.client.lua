-- Not as clean as the main module. But it works...
--// Services \\--
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Constants \\--
local Player = Players.LocalPlayer
local remoteFunction, remoteEvent
local eventHolder, Maid, onClientEventBinds = {}, {}, {}
local afkDelayOffset = 5
local isUIContextEnabled, isWarningsAllowed = false, true

--// Modules \\--
local Table = require(script.Table)

--// Functions \\--
local function findFirstChildWhichIsAByName(parent: Instance, name: string, class: string, tries: number?): Instance?
	tries = tries or 0
	if tries >= 50 then
		return nil
	end

	for _, v in pairs(parent:GetChildren()) do
		if v.Name == name and v:IsA(class) then
			return v
		end
	end

	task.wait(0.25)
	return findFirstChildWhichIsAByName(parent, name, class, tries + 1)
end

local function getTempFolder()
	local folder = Workspace:FindFirstChild(script.Name .. "_Temp")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = script.Name .. "_Temp"
		folder.Parent = Workspace
	end

	return folder
end

local function _warn(starter: string, ...: string)
	if not isWarningsAllowed then
		return
	end

	local data = table.concat({ ... }, " ")
	warn("[" .. starter .. "]: " .. data)
end

local function disconnect(data: { any } | RBXScriptConnection)
	if typeof(data) == "table" then
		for _, v in pairs(data) do
			disconnect(v)
		end
	elseif typeof(data) == "RBXScriptConnection" then
		data:Disconnect()
	end
end

local function fixNotificationStatus(message: string): string
	local statusCodes = {
		["Error"] = '<b><font color = "rgb(255, 90, 90)">%s</font></b>',
		["Warning"] = '<b><font color = "rgb(255, 171, 36)">%s</font></b>',
		["Info"] = '<b><font color = "rgb(70, 163, 255)">%s</font></b>',
		["Success"] = '<b><font color = "rgb(90, 255, 145)">%s</font></b>',
	}

	local words = string.split(message, " ")
	local firstWord = words[1]
	if string.match(firstWord, "[a-zA-Z0-9]:") == nil or #firstWord < 3 then
		return message
	end

	local splitTokens = string.split(firstWord, ":")
	for i, v in pairs(statusCodes) do
		if string.sub(string.lower(splitTokens[1]), 1, 3) == string.sub(string.lower(i), 1, 3) then
			splitTokens[1] = string.format(v, splitTokens[1])
			break
		end
	end

	words[1] = table.concat(splitTokens, ":")
	return table.concat(words, " ")
end

local function onNotification(Message: string)
	local Settings = HttpService:JSONDecode(Workspace:GetAttribute(script.Name))
	local notificationSettings = Settings.UI.Notifications
	local playerGui = Player:FindFirstChild("PlayerGui")
	if not playerGui then
		warn("Notification failed, message content: " .. Message)
		return
	end

	local notifGui = playerGui:FindFirstChild(script.Name .. "_NOTIF")
	if not notifGui then
		warn("Notification failed, message content: " .. Message)
		return
	end

	Message = fixNotificationStatus(Message)

	local newItem = Instance.new("TextLabel")
	newItem.Name = "Notification"
	newItem.Text = Message
	newItem.RichText = true

	local isOk, textSize = pcall(
		TextService.GetTextSize,
		TextService,
		newItem.ContentText,
		UserInputService.TouchEnabled and notificationSettings.FontSize
			or notificationSettings.FontSize * notificationSettings.keyboardFontSizeMultiplier,
		notificationSettings.Font,
		notifGui.Holder.AbsoluteSize
	)
	if not isOk then
		warn("Notification failed, message content: " .. Message)
		Debris:AddItem(newItem, 0)
		return
	end

	newItem.Parent = notifGui.Holder
	newItem.TextWrapped = true
	newItem.TextScaled = true
	newItem.Font = notificationSettings.Font
	newItem.TextColor3 = Color3.new(1, 1, 1)
	newItem.Size = UDim2.new(0, textSize.X, 0, 0)
	newItem.Position = UDim2.fromScale(0.5, 1)
	newItem.AnchorPoint = Vector2.new(0.5, 1)
	newItem.BackgroundTransparency = 1

	newItem:TweenSize(
		UDim2.fromOffset(textSize.X, textSize.Y),
		notificationSettings.entranceTweenInfo.Direction,
		notificationSettings.entranceTweenInfo.Style,
		notificationSettings.entranceTweenInfo.timeItTakes
	)

	-- Filter others to move upwards
	local children = Table.Filter(notifGui.Holder:GetChildren(), function(v)
		return v ~= newItem
	end)

	if #children > 0 then
		coroutine.wrap(function()
			for _, v in pairs(children) do
				v:TweenPosition(
					UDim2.new(0.5, 0, 1, v.Position.Y.Offset - textSize.Y),
					notificationSettings.entranceTweenInfo.Direction,
					notificationSettings.entranceTweenInfo.Style,
					notificationSettings.entranceTweenInfo.timeItTakes,
					true
				)
			end
		end)()
	end

	coroutine.wrap(function()
		task.wait(notificationSettings.delayUntilRemoval)
		newItem:TweenSize(
			UDim2.fromScale(0, 0),
			notificationSettings.exitTweenInfo.Direction,
			notificationSettings.exitTweenInfo.Style,
			notificationSettings.exitTweenInfo.timeItTakes,
			false,
			function()
				Debris:AddItem(newItem, 0)
			end
		)
	end)()
end

local function undoNotifications()
	local PlayerGui = Player:WaitForChild("PlayerGui")
	if PlayerGui:FindFirstChild(script.Name .. "_NOTIF") ~= nil then
		Debris:AddItem(PlayerGui:FindFirstChild(script.Name), 0)
	end

	onClientEventBinds["Notify"] = nil
end

local function setupNotifications()
	undoNotifications()
	local newNotif = script.Notifications:Clone()
	newNotif.Parent = Player:WaitForChild("PlayerGui", math.huge)
	newNotif.Name = script.Name .. "_NOTIF"

	onClientEventBinds["Notify"] = onNotification
end

local function undoRankSticks()
	if Maid["RankSticks"] == nil then
		return
	end

	disconnect(Maid["RankSticks"])
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
				local deb = false

				Maid.RankSticks[actionName] = {
					child.Activated:Connect(function()
						if deb then
							return
						end
						deb = true

						local cf, size = Character:GetBoundingBox()
						local newPart = Instance.new("Part")
						local Weld = Instance.new("WeldConstraint")

						newPart.Name = actionName .. "_Checker"
						newPart.Transparency = 1
						newPart.CFrame = cf * CFrame.new(0, 0, -size.Z)
						newPart.Anchored = false
						newPart.Size = size + Vector3.new(size.X / 2, 0, size.Z)
						newPart.BrickColor = BrickColor.Red()
						newPart.Massless = true
						newPart.CanCollide = false
						newPart.Parent = getTempFolder()

						Weld.Name = newPart.Name
						Weld.Part0 = newPart
						Weld.Part1 = Character.PrimaryPart
						Weld.Parent = newPart

						local closestTargets, closestTarget = {}, nil
						local hasReceived, secondsSpent, connection = false, 0, nil

						connection = newPart.Touched:Connect(function()
							hasReceived = true
							local partsWithinPart = Workspace:GetPartsInPart(newPart)

							for _, part in ipairs(partsWithinPart) do
								local ancestorModel = part:FindFirstAncestorWhichIsA("Model")
								local possiblePlayer = Players:FindFirstChild(ancestorModel.Name)
								if
									part:IsDescendantOf(child)
									or not ancestorModel
									or possiblePlayer == nil
									or possiblePlayer == Player
								then
									continue
								end

								table.insert(closestTargets, possiblePlayer)
							end
						end)

						while hasReceived == false do
							if secondsSpent >= 3 then -- max amount of time the part will be active for
								hasReceived = false
								break
							end

							if hasReceived then
								break
							end

							if not connection then
								continue
							end

							task.wait(1)
							secondsSpent += 1
						end

						Debris:AddItem(newPart, 0)

						if not hasReceived or child:IsDescendantOf(Player) then
							return
						end

						for _, target: Player in pairs(closestTargets) do
							local t_char = target.Character
							local c_char = (closestTarget ~= nil) and closestTarget.Character or nil

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

						_warn(
							"Ranking Sticks",
							`Rank sticks found {(closestTarget == nil) and "no players" or closestTarget.Name} to {child.Name}`
						)

						if closestTarget == nil then
							task.wait(0.25)
							deb = false
							return -- No one close enough
						end

						remoteFunction:InvokeServer(string.lower(actionName), "Sticks", closestTarget)

						task.wait(0.25)
						deb = false
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

	Maid["UI"] = {}
	table.insert(Maid["UI"], eventHolder.Promote.Event:Connect(promote))
	table.insert(Maid["UI"], eventHolder.Demote.Event:Connect(demote))
	table.insert(Maid["UI"], eventHolder.Fire.Event:Connect(fire))
	table.insert(Maid["UI"], eventHolder.Blacklist.Event:Connect(blacklist))

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
			transparencyCounter += 0.03 * dir

			highLight.OutlineTransparency = transparencyCounter
		end)
	end)

	table.insert(
		Maid["UI"],
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

	disconnect(Maid["UI"])
	Maid["UI"] = nil

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

	disconnect(Maid["AFK"])
	Maid["AFK"] = nil

	pcall(function()
		RunService:UnbindFromRenderStep("Vibez_AFK_Tracker")
	end)
end

local function setupAFKCheck()
	undoAfkCheck()

	local lastCheck = DateTime.now().UnixTimestamp
	local Counter = 0

	Maid["AFK"] = {}
	table.insert(
		Maid.AFK,
		UserInputService.WindowFocused:Connect(function()
			remoteFunction:InvokeServer("Afk", false)
		end)
	)

	table.insert(
		Maid.AFK,
		UserInputService.WindowFocusReleased:Connect(function()
			remoteFunction:InvokeServer("Afk", true)
		end)
	)

	table.insert(
		Maid.AFK,
		UserInputService.InputBegan:Connect(function()
			if Counter >= 30 then
				warn("undid Afk from counter")
				remoteFunction:InvokeServer("Afk", false)
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
				remoteFunction:InvokeServer("Afk", true)
			end
		end)
	end)
end

local function onAttributeChanged()
	local isOk, States = nil, Workspace:GetAttribute(script.Name)
	if not States then
		return
	end

	isOk, States = pcall(HttpService.JSONDecode, HttpService, States)
	if not isOk then
		return
	end

	isWarningsAllowed = States.MISC.ignoreWarnings

	if States.UI.Notifications.Status == true then
		setupNotifications()
	else
		undoNotifications()
	end

	local isStaff =
		remoteFunction:InvokeServer("isStaff", nil, "Interface", "RankSticks", "Commands", "ActivityTracker")

	if not isStaff then
		return
	end

	if isStaff.Interface and States.UI.Status == true then
		onSetupUI()
	else
		undoUISetup()
	end

	if isStaff.ActivityTracker and States.AFK.Status == true then
		setupAFKCheck()
	else
		undoAfkCheck()
	end

	if isStaff.RankSticks and States.STICKS.Status == true then
		onSetupRankSticks()
	else
		undoRankSticks()
	end

	afkDelayOffset = States.AFK.Delay
end

local function onStart()
	local eventConnection -- In case we decide to do auto updating of module for api route changes.
	remoteFunction = findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteFunction")
	remoteEvent = findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteEvent")

	onAttributeChanged()

	-- Attribute Checks
	Workspace:GetAttributeChangedSignal(script.Name):Connect(onAttributeChanged)

	if script.Parent.Name ~= "PlayerScripts" then
		task.wait(5)
		script.Parent = Player:WaitForChild("PlayerScripts", math.huge)

		local Clone = script:Clone()
		Clone.Enabled = false
		Clone.Parent = StarterPlayerScripts
		Clone.Enabled = true
	end

	eventConnection = remoteEvent.OnClientEvent:Connect(function(Command: string, ...: any)
		if Command == "Disconnect" then
			disconnect(Maid)
			eventConnection:Disconnect()
		elseif onClientEventBinds[Command] ~= nil then
			onClientEventBinds[Command](...)
		end
	end)

	-- Simple way to make sure client is fully connected
	remoteFunction.OnClientInvoke = function()
		return true
	end
end

--// Main \\--
onStart()
