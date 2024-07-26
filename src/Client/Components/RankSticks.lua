--// Services \\--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local Player = Players.LocalPlayer
local Maid = {}

--// Functions \\--
local function _getTempFolder()
	local folder = Workspace:FindFirstChild(script.Name .. "_Temp")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = script.Name .. "_Temp"
		folder.Parent = Workspace
	end

	return folder
end

local function onDestroy(componentData: { [any]: any })
	if Maid == nil then
		return
	end

	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(componentData: { [any]: any })
	local _warn, remoteEvent, remoteFunction =
		componentData._warn, componentData.remoteEvent, componentData.remoteFunction

	local custScriptName = string.split(script.Parent.Parent.Name, "-")[1]
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local stickDebounce = false

	onDestroy(componentData)

	local function handleStickMode(actionName: string, child: Tool)
		if componentData.rankStickMode == "DetectionInFront" or componentData.rankStickMode == "Default" then -- Default
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
			newPart.Parent = _getTempFolder()

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
				stickDebounce = false
				return -- No one close enough
			end

			remoteFunction:InvokeServer(string.lower(actionName), "Sticks", closestTarget)
		elseif componentData.rankStickMode == "ClickOnPlayer" then
			local mouse = Player:GetMouse()
			local mouseTarget = mouse.Target

			if
				mouseTarget == nil
				or (
					mouseTarget ~= nil
					and (Player.Character.PrimaryPart.Position - mouseTarget.Position).Magnitude > 20
				)
			then
				stickDebounce = false
				return
			end

			local player = Players:GetPlayerFromCharacter(mouseTarget.Parent)
			if not player or player == Player then
				stickDebounce = false
				return
			end

			remoteFunction:InvokeServer(string.lower(actionName), "Sticks", player)
		end

		task.wait(0.25)
		stickDebounce = false
	end

	table.insert(
		Maid,
		Character.ChildAdded:Connect(function(child: Instance)
			if child:GetAttribute(custScriptName) == "RankSticks" and child:IsA("Tool") then
				local actionName = child.Name

				Maid[actionName] = {
					child.Activated:Connect(function()
						if stickDebounce then
							return
						end
						stickDebounce = true

						remoteEvent:FireServer("Animate", "Sticks")
						handleStickMode(actionName, child)

						task.wait(0.25)
						stickDebounce = false
					end),
				}
			end
		end)
	)

	table.insert(
		Maid,
		Character.ChildRemoved:Connect(function(child: Instance)
			if child:GetAttribute(custScriptName) == "RankSticks" and child:IsA("Tool") then
				if Maid[child.Name] ~= nil then
					for _, v: RBXScriptConnection in pairs(Maid[child.Name]) do
						v:Disconnect()
					end
				end
			end
		end)
	)
end

return {
	Setup = onSetup,
	Destroy = onDestroy,
}
