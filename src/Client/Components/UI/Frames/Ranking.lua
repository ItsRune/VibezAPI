--// Services \\--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--// Variables \\--
local Player = Players.LocalPlayer
local defaultThumbnail = "rbxasset://textures/AvatarCompatibilityPreviewer/user.png"
local userCache = {}
local selectedUsers = {}
local Maid = { -- TODO: Covert subMaids into the main Maid table.
	Main = {},
	suggestionButtons = {},
}

--// Helper Functions \\--
local function _getUserInformation(userId: number)
	local currentCache = userCache[userId]
	local now = DateTime.now().UnixTimestamp

	if
		userId == nil
		or (
			currentCache ~= nil
			and (
				now - currentCache.lastUpdated < 300
				and currentCache.Name ~= "Loading..."
				and currentCache.Thumbnail == defaultThumbnail
			)
		)
	then
		return currentCache
	end

	local isOk, thumbnail, username
	isOk, thumbnail = pcall(
		Players.GetUserThumbnailAsync,
		Players,
		userId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size100x100
	)
	if not isOk then
		thumbnail = defaultThumbnail
	end

	isOk, username = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	if not isOk then
		username = "Loading..."
	end

	userCache[userId] = {
		Name = username,
		Thumbnail = thumbnail,
		Id = userId,
		lastUpdated = now,
	}

	return userCache[userId]
end

local function _updateUserSuggestions(
	textBox: TextBox,
	componentData: { [any]: any },
	filteredPlayers: { Player },
	tempMaid: { RBXScriptConnection? }
)
	local suggestionFrame = textBox.Parent.Suggestions
	local templateFrame = suggestionFrame:FindFirstChild("Template")

	componentData.Disconnect(tempMaid)
	table.clear(tempMaid)

	if not templateFrame then
		componentData._warn("Vibez Error", "No valid template for user suggestions!")
		return
	end

	for _, item: Instance in ipairs(suggestionFrame:GetChildren()) do
		if item:IsA("UIListLayout") or item.Name == "Template" then
			continue
		end

		item:Destroy()
	end

	for _, Target: Player in ipairs(filteredPlayers) do
		local userInformation = _getUserInformation(Target.UserId)
		local newTemplate = templateFrame:Clone()

		newTemplate.Name = Target.UserId
		newTemplate.Left.Information.Username.Text = Target.Name
		newTemplate.Left.Information.DisplayName.Text = "@" .. Target.DisplayName
		newTemplate.Left.Thumbnail.Image = userInformation.Thumbnail
		newTemplate.Parent = templateFrame.Parent
		newTemplate.Visible = true

		-- DEBUG: Find out why this connection is not working and fix this shit out of it.
		table.insert(
			tempMaid,
			newTemplate.MouseButton1Click:Connect(function()
				warn("Fired checkbox")
				local appendedTableIndex = table.find(selectedUsers, Target)
				local tweenDirection = appendedTableIndex and 1 or 0.2

				if appendedTableIndex then
					table.remove(selectedUsers, appendedTableIndex)
					newTemplate.LayoutOrder = 0
				else
					table.insert(selectedUsers, Target)
					newTemplate.LayoutOrder = #selectedUsers
				end

				componentData
					.Tweens(
						newTemplate.Right.Checkbox,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							ImageTransparency = tweenDirection,
						}
					)
					:Play()
			end)
		)
	end

	return tempMaid
end

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: { [any]: any })
	table.clear(selectedUsers)

	for _, userFrame: TextButton in ipairs(Frame.User.Suggestions:GetChildren()) do
		if userFrame.Name == "Template" or not userFrame:IsA("TextButton") then
			continue
		end

		userFrame:Destroy()
	end

	componentData.Disconnect(Maid)
	table.clear(Maid)
	task.wait()
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	-- Destroy first, in case there was an issue destroying previously.
	onDestroy(Frame, componentData)

	local suggestionsMaid = {}
	local remoteFunction = componentData.remoteFunction

	for _, actionButton: TextButton in ipairs(Frame.Actions:GetChildren()) do
		if not actionButton:IsA("TextButton") then
			continue
		end

		table.insert(
			Maid,
			actionButton.MouseButton1Click:Connect(function()
				if #selectedUsers == 0 then
					return
				end

				remoteFunction:InvokeServer(actionButton.Name, "Interface", selectedUsers)
			end)
		)
	end

	table.insert(
		Maid,
		Frame.User.Username.FocusLost:Connect(function()
			componentData.Disconnect(suggestionsMaid)
			table.clear(suggestionsMaid)
		end)
	)

	table.insert(
		Maid,
		Frame.User.Username.Focused:Connect(function()
			if Frame.User.Username.Text ~= "" then
				return
			end

			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
				return true --Target ~= Player
			end)

			suggestionsMaid =
				_updateUserSuggestions(Frame.User.Username, componentData, filteredPlayers, suggestionsMaid)
		end)
	)

	table.insert(
		Maid,
		Frame.User.Username:GetPropertyChangedSignal("Text"):Connect(function()
			local Text = Frame.User.Username.Text
			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
				return (
					Text == ""
					or string.sub(string.lower(Text), 0, #Text) == string.sub(string.lower(Target.Name), 0, #Text)
				) --and Target ~= Player
			end)

			suggestionsMaid =
				_updateUserSuggestions(Frame.User.Username, componentData, filteredPlayers, suggestionsMaid)
		end)
	)

	table.insert(
		Maid,
		Frame.Actions.setRank.Button.MouseButton1Click:Connect(function()
			local newRank = Frame.Actions.setRank.newRank.Text
			if newRank == "" or #selectedUsers == 0 then
				return
			end

			remoteFunction:InvokeServer("SetRank", "Interface", selectedUsers, newRank)
		end)
	)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
