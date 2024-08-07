--// Services \\--
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")

--// Variables \\--
local defaultThumbnail = "rbxasset://textures/AvatarCompatibilityPreviewer/user.png"
local usernameTextBox = nil
local lastPerformedTruncation = 0
local userCache = {}
local selectedUsers = {}
local Maid = {
	Main = {},
	suggestionButtons = {},
}

--// Functions \\--
local function _truncateUserCache()
	local MAX_ENTRIES = 250

	if #userCache < MAX_ENTRIES or lastPerformedTruncation - DateTime.now().UnixTimestamp < 0 then
		return
	end

	lastPerformedTruncation = DateTime.now().UnixTimestamp + 300 -- 5 minutes

	local maxEntriesDifference = MAX_ENTRIES - #userCache
	local entriesRemoved = 0
	local pointer = #userCache

	while entriesRemoved < maxEntriesDifference do
		local dataAtPointer = userCache[pointer]
		if dataAtPointer.isInGame == true and Players:GetPlayerByUserId(dataAtPointer.UserId) ~= nil then
			pointer -= 1
			continue
		end

		table.remove(userCache, pointer)
		entriesRemoved += 1
	end
end

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

	local isOk, thumbnail, userInfo
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

	isOk, userInfo = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { userId })
	if not isOk then
		return nil
	end

	userInfo = userInfo[1]

	-- Ignore me, I prefer this format.
	userInfo.UserId = userInfo.Id
	userInfo.Id = nil

	userCache[userInfo.UserId] = {
		Name = userInfo.Username,
		UserId = userInfo.UserId,
		DisplayName = userInfo.DisplayName,
		isVerified = userInfo.HasVerifiedBadge,
		isInGame = (Players:GetPlayerByUserId(userInfo.UserId) ~= nil),
		Thumbnail = thumbnail,
		lastUpdated = now,
	}

	_truncateUserCache()
	return userCache[userInfo.UserId]
end

local function _fullCheckForFilter(Target: Player)
	local currentText = usernameTextBox.Text
	return (
		currentText == ""
		or string.sub(string.lower(currentText), 0, #currentText)
			== string.sub(string.lower(Target.Name), 0, #currentText)
	)
end

local function _createTargetTemplate(componentData: { [any]: any }, Target: Player, layoutOrder: number?)
	if not usernameTextBox then
		return
	end

	local templateFrame = usernameTextBox.Parent.Suggestions.Template
	local userInformation = _getUserInformation(Target.UserId)
	local newTemplate = templateFrame:Clone()

	newTemplate.LayoutOrder = layoutOrder or 99999
	newTemplate.Left.Information.Username.Text = Target.Name
	newTemplate.Left.Information.DisplayName.Text = "@" .. Target.DisplayName
	newTemplate.Left.Thumbnail.Image = userInformation.Thumbnail

	--stylua: ignore
	newTemplate.Right.Tag.Text = not userInformation.isInGame and '<font color="rgb(225, 50, 50)">[External]</font>' or ""
	newTemplate.Right.Checkbox.ImageTransparency = (table.find(selectedUsers, Target.UserId) ~= nil) and 0.2 or 1

	newTemplate.Name = Target.UserId
	newTemplate.Parent = templateFrame.Parent
	newTemplate.Visible = true

	table.insert(
		Maid.suggestionButtons,
		newTemplate.MouseButton1Click:Connect(function()
			local hasAppendedTableIndex = table.find(selectedUsers, Target.UserId)
			local tweenDirection = hasAppendedTableIndex and 1 or 0.2

			if hasAppendedTableIndex then
				table.remove(selectedUsers, hasAppendedTableIndex)

				if userInformation.isInGame == false or not _fullCheckForFilter(Target) then
					newTemplate:Destroy()
				end
			else
				table.insert(selectedUsers, Target.UserId)
				newTemplate.LayoutOrder = #selectedUsers
			end

			usernameTextBox.Parent.Selected.Text = string.format("%d User(s) Selected", #selectedUsers)
			if not userInformation.isInGame and hasAppendedTableIndex then
				return
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

local function _updateUserSuggestions(componentData: { [any]: any }, filteredPlayers: { Player })
	local suggestionFrame = usernameTextBox.Parent.Suggestions
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
		_createTargetTemplate(componentData, Target)
	end

	for index: number, targetId: number in ipairs(selectedUsers) do
		local userInfo = _getUserInformation(targetId)
		if not userInfo then
			continue
		end

		_createTargetTemplate(componentData, userInfo, index)
	end

	local existingButtons = {}
	for _, Inst: Instance in ipairs(templateFrame.Parent:GetChildren()) do
		if not Inst:IsA("TextButton") or Inst.Name == "Template" then
			continue
		end

		if table.find(existingButtons, Inst.Left.Information.Username.Text) ~= nil then
			Inst:Destroy()
			continue
		end

		table.insert(existingButtons, Inst.Left.Information.Username.Text)
	end
end

local function onDestroy(Frame: Frame, componentData: { [any]: any })
	table.clear(selectedUsers)
	selectedUsers = {}

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

	Frame.User.Selected.Text = "0 User(s) Selected"
	componentData.Disconnect(Maid)
	table.clear(Maid)
	task.wait()
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	onDestroy(Frame, componentData)

	usernameTextBox = Frame.User.Username
	Frame.User.Suggestions.Template.Visible = false

	Maid = {
		Main = {},
		suggestionButtons = {},
	}

	table.insert(
		Maid.Main,
		Frame.User.Username.Focused:Connect(function()
			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), _fullCheckForFilter)
			_updateUserSuggestions(componentData, filteredPlayers)
		end)
	)

	table.insert(
		Maid.Main,
		Frame.User.Username:GetPropertyChangedSignal("Text"):Connect(function()
			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), _fullCheckForFilter)
			_updateUserSuggestions(componentData, filteredPlayers)
		end)
	)

	table.insert(
		Maid.Main,
		Frame.Actions.Body.Send.MouseButton1Click:Connect(function()
			local Text = Frame.Actions.Body.Message.Text
			if Text == "" then
				return
			end

			componentData.remoteEvent:FireServer("Notifications", selectedUsers, Text)
		end)
	)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
