--!nocheck
--!nolint
--// Services \\--
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local Player = Players.LocalPlayer
local Maid: { [any]: RBXScriptConnection | { RBXScriptConnection } } = {}

--// Functions \\--
local function _getTempFolder()
	local folder = Workspace:FindFirstChild(script.Name .. "_Temp")

	if not folder then
		local newFolder = Instance.new("Folder")
		newFolder.Name = script.Name .. "_Temp"
		newFolder.Parent = Workspace

		folder = newFolder
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
	local _warn, remoteFunction = componentData._warn, componentData.remoteFunction

	local custScriptName = string.split(script.Parent.Parent.Name, "-")[1]
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local stickDebounce = false

	onDestroy(componentData)

	local function handleStickMode(actionName: string, child: Tool)
		if componentData.rankStickMode == "DetectionInFront" or componentData.rankStickMode == "Default" then -- Default
			local cf, size = Character:GetBoundingBox()
			local newPart = Instance.new("Part")
			local Weld = Instance.new("WeldConstraint")
			local primaryPart = Character.PrimaryPart

			if not primaryPart then
				return false
			end

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
			Weld.Part1 = primaryPart
			Weld.Parent = newPart

			local closestTargets, closestTarget = {}, nil
			local hasReceived, secondsSpent, connection = false, 0, nil

			connection = newPart.Touched:Connect(function()
				hasReceived = true
				local partsWithinPart = Workspace:GetPartsInPart(newPart)

				for _, part in ipairs(partsWithinPart) do
					local ancestorModel = part:FindFirstAncestorWhichIsA("Model")
					if part:IsDescendantOf(child) or not ancestorModel then
						continue
					end

					local possiblePlayer = Players:GetPlayerFromCharacter(ancestorModel)
					if not possiblePlayer then
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
				return false
			end

			for _, target: Player in pairs(closestTargets) do
				local t_char = target.Character
				local c_char = (closestTarget ~= nil) and closestTarget.Character or nil

				if not c_char or not t_char then
					continue
				end

				local localPrimaryPart = Character.PrimaryPart
				local closestPrimaryPart, targetPrimaryPart = c_char.PrimaryPart, t_char.PrimaryPart
				if not localPrimaryPart then
					continue
				end

				if
					closestTarget == nil
					or (
						closestTarget ~= nil
						and (localPrimaryPart.Position - closestPrimaryPart.Position).Magnitude
							> (localPrimaryPart.Position - targetPrimaryPart.Position).Magnitude
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
				return false
			end

			remoteFunction:InvokeServer(string.lower(actionName), "Sticks", closestTarget)
			return true
		elseif componentData.rankStickMode == "ClickOnPlayer" then
			local mouse = Player:GetMouse()
			local mouseTarget = mouse.Target
			local primPart = Character.PrimaryPart

			if not primPart or (mouseTarget and (primPart.Position - mouseTarget.Position).Magnitude > 20) then
				return false
			end

			if not mouseTarget then
				return false
			end

			local player = Players:GetPlayerFromCharacter(mouseTarget.Parent)
			if not player or player == Player then
				return false
			end

			remoteFunction:InvokeServer(string.lower(actionName), "Sticks", player)
			return true
		end

		return false
	end

	table.insert(
		Maid,
		Character.ChildAdded:Connect(function(child: Instance)
			if child:GetAttribute(custScriptName) == "RankSticks" and child:IsA("Tool") then
				local actionName = child.Name
				warn(actionName)

				Maid[actionName] = {
					child.Activated:Connect(function()
						if stickDebounce then
							return
						end

						stickDebounce = true
						componentData.remoteEvent:FireServer("Animate")
						warn("HI")

						local succeeded = handleStickMode(actionName, child)
						if not succeeded then
							stickDebounce = false
							return
						end

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
				local existingMaid = Maid[child.Name] :: { RBXScriptConnection }
				if existingMaid ~= nil then
					for _, v: RBXScriptConnection in pairs(existingMaid) do
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
