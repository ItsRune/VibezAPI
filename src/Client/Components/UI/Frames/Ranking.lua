--#selene: allow(unused_variable)
--// Services \\--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Variables \\--
local Player = Players.LocalPlayer
local defaultThumbnail = "rbxasset://textures/AvatarCompatibilityPreviewer/user.png"
local userCache = {}
local selectedUsers = {}
local Maid = {
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
	Tag: string?
)
	local suggestionFrame = textBox.Parent.Suggestions
	local templateFrame = suggestionFrame:FindFirstChild("Template")

	componentData.Disconnect(Maid.suggestionButtons)
	table.clear(Maid.suggestionButtons)

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
		newTemplate.Right.Tag.Text = (Tag ~= nil) and Tag or ""
		newTemplate.Parent = templateFrame.Parent
		newTemplate.Visible = true

		table.insert(
			Maid.suggestionButtons,
			newTemplate.MouseButton1Click:Connect(function()
				local appendedTableIndex = table.find(selectedUsers, Target)
				local tweenDirection = appendedTableIndex and 1 or 0.2

				if appendedTableIndex then
					table.remove(selectedUsers, appendedTableIndex)
					newTemplate.LayoutOrder = 0
				else
					table.insert(selectedUsers, Target)
					newTemplate.LayoutOrder = #selectedUsers
				end

				textBox.Parent.Selected.Text = string.format("%d User(s) Selected", #selectedUsers)
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
end

--selene: allow(unused_variable)
local function _handleExternalUserSearch(textBox: TextBox, componentData: { [any]: any })
	local Text = textBox.Text
	local isOk, userId, realName

	isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, Text)
	warn(isOk, userId)
	if not isOk or not userId then
		return
	end

	isOk, realName = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	warn(isOk, realName)
	if not isOk or not realName then
		return
	end

	local fakePlayer = newproxy(false)
	fakePlayer.Name = realName
	fakePlayer.UserId = userId

	_updateUserSuggestions(textBox, componentData, fakePlayer, '<font color="rgb(200, 50, 50)">[External]</font>')
end

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: { [any]: any })
	table.clear(selectedUsers)

	for _, userFrame: TextButton in ipairs(Frame.User.Suggestions:GetChildren()) do
		if not userFrame:IsA("TextButton") then
			continue
		end

		if userFrame.Name == "Template" then
			userFrame.Visible = false
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
	warn(Frame, componentData)
	onDestroy(Frame, componentData)

	Maid = {
		Main = {},
		suggestionButtons = {},
	}

	local remoteFunction = componentData.remoteFunction
	for _, actionButton: TextButton in ipairs(Frame.Actions:GetChildren()) do
		if not actionButton:IsA("TextButton") then
			continue
		end

		table.insert(
			Maid.Main,
			actionButton.MouseButton1Click:Connect(function()
				if #selectedUsers == 0 then
					return
				end

				remoteFunction:InvokeServer(actionButton.Name, "Interface", selectedUsers)
			end)
		)
	end

	table.insert(
		Maid.Main,
		Frame.User.Username.Focused:Connect(function()
			if Frame.User.Username.Text ~= "" then
				return
			end

			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
				-- return Target ~= Player
			end)

			_updateUserSuggestions(Frame.User.Username, componentData, filteredPlayers)
		end)
	)

	local lastText = Frame.User.Username.Text
	table.insert(
		Maid.Main,
		RunService.RenderStepped:Connect(function()
			local Text = Frame.User.Username.Text
			if lastText == Text then
				return
			end

			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
				return string.sub(string.lower(Text), 0, #Text) == string.sub(string.lower(Target.Name), 0, #Text)
				-- and Target ~= Player
			end)

			_updateUserSuggestions(Frame.User.Username, componentData, filteredPlayers)
			lastText = Text
		end)
	)

	-- table.insert(
	-- 	Maid.Main,
	-- 	Frame.User.Username:GetPropertyChangedSignal("Text"):Connect(function()
	-- 		local Text = Frame.User.Username.Text
	-- 		local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
	-- 			return string.sub(string.lower(Text), 0, #Text) == string.sub(string.lower(Target.Name), 0, #Text)
	-- 			-- and Target ~= Player
	-- 		end)

	-- 		_updateUserSuggestions(Frame.User.Username, componentData, filteredPlayers)
	-- 	end)
	-- )

	-- This connection handles users outside of the game server. (BROKEN)
	-- table.insert(
	-- 	Maid.Main,
	-- 	Frame.User.Username.FocusLost:Connect(function()
	-- 		local Text = Frame.User.Username.Text
	-- 		if Text == "" then
	-- 			return
	-- 		end

	-- 		local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), function(Target: Player)
	-- 			return (string.sub(string.lower(Text), 0, #Text) == string.sub(string.lower(Target.Name), 0, #Text))
	-- 				and Target ~= Player
	-- 		end)

	-- 		if #filteredPlayers ~= 0 then
	-- 			return
	-- 		end

	-- 		_handleExternalUserSearch(Frame.User.Username, componentData)
	-- 	end)
	-- )

	table.insert(
		Maid.Main,
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
