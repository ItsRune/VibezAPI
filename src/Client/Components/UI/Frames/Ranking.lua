--!nocheck
--!nolint
--// Services \\--
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local GroupService = game:GetService("GroupService")

--// Variables \\--
local Player = Players.LocalPlayer
local defaultThumbnail = "rbxasset://textures/AvatarCompatibilityPreviewer/user.png"
local usernameTextBox = nil
local lastPerformedTruncation = 0
local userCache = {}
local groupCache = {}
local selectedUsers = {}
local Maid = {
	Main = {},
	suggestionButtons = {},
}

--// Helper Functions \\--
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

	return Target ~= Player
		and (
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
			local ignoreTween = false

			if hasAppendedTableIndex then
				table.remove(selectedUsers, hasAppendedTableIndex)

				if userInformation.isInGame == false and not _fullCheckForFilter(Target) then
					newTemplate:Destroy()
					ignoreTween = true
				end
			else
				table.insert(selectedUsers, Target.UserId)

				if
					#selectedUsers > componentData.Data.maxUsersToSelectForRanking
					and componentData.Data.maxUsersToSelectForRanking ~= -1
				then
					local removedUserId = table.remove(selectedUsers, 1)
					local existingFrame = templateFrame.Parent:FindFirstChild(tostring(removedUserId))

					if existingFrame then
						existingFrame:Destroy()
						ignoreTween = true
					end
				end

				newTemplate.LayoutOrder = #selectedUsers
			end

			usernameTextBox.Parent.Selected.Text = string.format("%d User(s) Selected", #selectedUsers)

			if ignoreTween then
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
	for _, Inst: any in ipairs(templateFrame.Parent:GetChildren()) do
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

local function _checkTextAfterDelay<A>(
	textLabel: TextLabel | TextBox,
	delayedSeconds: number,
	callback: (...A) -> any,
	...: A
)
	local currentText = textLabel.Text
	task.wait(delayedSeconds)

	if textLabel.Text == currentText then
		callback(...)
	end
end

local function _handleExternalUserSearch(componentData: { [any]: any })
	local Text = usernameTextBox.Text
	local isOk, userId, userInfo

	isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, Text)
	if not isOk or not userId then
		return
	end

	isOk, userInfo = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { userId })
	if not isOk or (typeof(userInfo) == "table" and not userInfo[1]) then
		return
	end

	local fakePlayers = {}

	for i = 1, #userInfo do
		local userData = userInfo[i]

		-- Even with external searches, we still have to prevent the local player from trying to rank themselves.
		if userData.UserId == Player.UserId then
			continue
		end

		local fakePlayer = newproxy(false)
		fakePlayer.Name = userInfo[i].Username
		fakePlayer.UserId = userId
		fakePlayer.DisplayName = userInfo[i].DisplayName
		fakePlayer.isVerified = userInfo[i].HasVerifiedBadge

		table.insert(fakePlayers, fakePlayer)
	end

	_updateUserSuggestions(componentData, fakePlayers)
end

--// Functions \\--
local function onDestroy(Frame: any, componentData: { [any]: any })
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

local function onSetup(Frame: any, componentData: { [any]: any })
	local remoteFunction = componentData.remoteFunction
	usernameTextBox = Frame.User.Username

	-- Destroy first, in case there was an issue destroying previously.
	onDestroy(Frame, componentData)

	Maid = {
		Main = {},
		suggestionButtons = {},
	}

	for _, actionButton: TextButton in ipairs(Frame.Actions.Body:GetChildren()) do
		if not actionButton:IsA("TextButton") then
			continue
		end

		table.insert(
			Maid.Main,
			actionButton.InputBegan:Connect(function(Input: InputObject)
				if
					Input.UserInputType ~= Enum.UserInputType.MouseButton1
					and Input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end

				componentData.buttonClickBubble(actionButton, Input)
			end)
		)

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

			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), _fullCheckForFilter)
			_updateUserSuggestions(componentData, filteredPlayers)
		end)
	)

	table.insert(
		Maid.Main,
		Frame.User.Username:GetPropertyChangedSignal("Text"):Connect(function()
			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), _fullCheckForFilter)

			if #filteredPlayers == 0 then
				_checkTextAfterDelay(Frame.User.Username, 2, _handleExternalUserSearch, componentData)
				return
			end

			_updateUserSuggestions(componentData, filteredPlayers)
		end)
	)

	-- DEBUG: This connection for some reason causes the script to break?
	-- setRank action is in a separate area than the other buttons.

	local setRankButton = Frame.Actions.Body.setRank.Button
	table.insert(
		Maid.Main,
		setRankButton.MouseButton1Click:Connect(function()
			local newRank = setRankButton.Parent.newRank.Text
			if newRank == "" or #selectedUsers == 0 then
				return
			end

			remoteFunction:InvokeServer("SetRank", "Interface", selectedUsers, newRank)
		end)
	)

	table.insert(
		Maid.Main,
		setRankButton.InputBegan:Connect(function(Input: InputObject)
			if
				Input.UserInputType ~= Enum.UserInputType.MouseButton1
				and Input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end

			componentData.buttonClickBubble(setRankButton, Input)
		end)
	)

	-- REVIEW: Future idea?
	-- Add a dropdown for group ranks with the provided attribute "GroupId" on existing attr.
	-- - Will provide easier use of users within the group along with simple suggestions that'll prevent time spent typing role names.
	-- - Cache of group ranks to keep things simple.
	local groupId = tostring(componentData.Data.GroupId)
	local currentGroupCache = groupCache[groupId]

	if currentGroupCache ~= nil or tonumber(groupId) == nil then
		return
	end

	local isOk, groupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, tonumber(groupId))
	if not isOk or typeof(groupInfo) ~= "table" then
		return
	end

	groupCache[groupId] = groupInfo
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
