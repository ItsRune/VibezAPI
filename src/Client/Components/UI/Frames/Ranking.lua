--!strict
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
local selectedUsers = {}
local Maid = {
	Main = {},
	suggestionButtons = {},
}

--// Types \\--
type cachedUserContent = {
	Name: string,
	DisplayName: string,
	UserId: number,
	isVerified: boolean,
	isInGame: boolean,
	Thumbnail: string,
	lastUpdated: number,
}

type userInfoResponse = {
	Id: number,
	DisplayName: string,
	Username: string,
	HasVerifiedBadge: boolean,
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

local function _getUserInformation(userId: number): cachedUserContent?
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

	local userData = userInfo[1] :: userInfoResponse
	userCache[userData.Id] = {
		Name = userData.Username,
		UserId = userData.Id,
		DisplayName = userData.DisplayName,
		isVerified = userData.HasVerifiedBadge,
		isInGame = (Players:GetPlayerByUserId(userData.Id) ~= nil),
		Thumbnail = thumbnail,
		lastUpdated = now,
	}

	_truncateUserCache()
	return userCache[userData.Id]
end

local function _fullCheckForFilter(Target: Player | cachedUserContent)
	local currentText = usernameTextBox.Text

	return Target ~= Player
		and (
			currentText == ""
			or string.sub(string.lower(currentText), 0, #currentText)
				== string.sub(string.lower(Target.Name), 0, #currentText)
		)
end

local function _createTargetTemplate(
	componentData: { [any]: any },
	Target: Player | cachedUserContent,
	layoutOrder: number?
)
	if not usernameTextBox then
		return
	end

	local templateFrame = usernameTextBox.Parent.Suggestions.Template
	local userInformation = _getUserInformation(Target.UserId)
	local newTemplate = templateFrame:Clone()
	local tagText = string.format(
		'<font color="rgb(%s)">[%s]</font>',
		componentData.Data.Suggestions.externalSearchTagColor,
		componentData.Data.Suggestions.externalSearchTagText
	)

	if not userInformation then
		newTemplate:Destroy()
		return
	end

	newTemplate.LayoutOrder = layoutOrder or 99999
	newTemplate.Left.Information.Username.Text = Target.Name
	newTemplate.Left.Information.DisplayName.Text = "@" .. Target.DisplayName
	newTemplate.Left.Thumbnail.Image = userInformation.Thumbnail

	--stylua: ignore
	newTemplate.Right.Tag.Text = not userInformation.isInGame and tagText or ""
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
	if not isOk or typeof(userInfo) ~= "table" or userInfo[1] == nil then
		return
	end

	local fakePlayers = {}
	for i = 1, #userInfo do
		local userData = userInfo[i]

		-- Even with external searches, we still have to prevent the local player from trying to rank themselves.
		if userData.Id == Player.UserId then
			continue
		end

		local fakePlayer = newproxy(true)
		local Metatable = getmetatable(fakePlayer)
		local Internal = {}

		Internal.Name = userData[i].Username
		Internal.UserId = userId
		Internal.DisplayName = userData[i].DisplayName
		Internal.isVerified = userData[i].HasVerifiedBadge

		Metatable.__index = Internal
		Metatable.__tostring = function(self): string
			return rawget(self, "Name")
		end

		table.insert(fakePlayers, fakePlayer)
	end

	_updateUserSuggestions(componentData, fakePlayers)
end

--// Functions \\--
local function onDestroy(Frame: any, componentData: { [any]: any })
	componentData._debug("interface_ranking_destroy", "Destroy method triggered.")
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

	componentData._debug(
		"interface_ranking_initialization",
		"Connecting action button connections 'onInputBegan' & 'onMouseButton1Click'."
	)
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

	componentData._debug("interface_ranking_initialization", "Connecting username textbox 'onFocus'.")
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

	componentData._debug("interface_ranking_initialization", "Connecting username textbox 'onTextChanged'.")
	table.insert(
		Maid.Main,
		Frame.User.Username:GetPropertyChangedSignal("Text"):Connect(function()
			local filteredPlayers = componentData.Table.Filter(Players:GetPlayers(), _fullCheckForFilter)

			if #filteredPlayers == 0 and componentData.Data.Suggestions.allowExternalPlayerSearch then
				_checkTextAfterDelay(Frame.User.Username, 1, _handleExternalUserSearch, componentData)
				return
			end

			_updateUserSuggestions(componentData, filteredPlayers)
		end)
	)

	local setRankFrame = Frame.Actions.Body.setRank
	local setRankButton = setRankFrame.Button

	componentData._debug("interface_ranking_initialization", "Connecting setRankButton 'onMouseButton1Click'.")
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

	componentData._debug("interface_ranking_initialization", "Connecting setRankButton 'onInputBegan'.")
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
	local groupId = tonumber(componentData.GroupId) :: number
	local rankTextBox = setRankFrame.newRank
	local suggestionLabel = rankTextBox.Suggestion
	local rankIdSuggestionLabel = rankTextBox.numSuggestion
	local isOk, groupInfo = pcall(GroupService.GetGroupInfoAsync, GroupService, groupId)

	if not isOk or typeof(groupInfo) ~= "table" then
		return
	end

	componentData._debug("interface_ranking_initialization", "Connecting textbox 'onTextChanged'.")
	table.insert(
		Maid.Main,
		rankTextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if rankTextBox.Text == "" then
				suggestionLabel.Text = ""
				rankIdSuggestionLabel.Text = ""
				return
			end

			if tonumber(rankTextBox.Text) then
				local filteredByRank = componentData.Table.Filter(groupInfo.Roles, function(role: any)
					return role.Rank == tonumber(rankTextBox.Text) or role.Id == tonumber(rankTextBox.Text)
				end)

				if #filteredByRank == 0 then
					rankIdSuggestionLabel.Text = '<font color="rgb(255,55,55)">(Unknown Rank)</font>'
					return
				end

				rankIdSuggestionLabel.Text = string.format("(%s)", filteredByRank[1].Name)
				return
			end

			local filteredByName = componentData.Table.Filter(groupInfo.Roles, function(role: any)
				return string.sub(string.lower(role.Name), 1, #rankTextBox.Text) == string.lower(rankTextBox.Text)
			end)

			if #filteredByName == 0 then
				local erroringLetter = string.sub(rankTextBox.Text, #rankTextBox.Text, #rankTextBox.Text)
				suggestionLabel.Text = string.sub(rankTextBox.Text, 1, #rankTextBox.Text - 1)
					.. '<font color="rgb(255,55,55)">'
					.. erroringLetter
					.. "</font>"
				return
			end

			suggestionLabel.Text = rankTextBox.Text
				.. string.sub(filteredByName[1].Name, #rankTextBox.Text + 1, #filteredByName[1].Name)
		end)
	)

	componentData._debug("interface_ranking_initialization", "Connecting textbox 'onFocusLost'.")
	table.insert(
		Maid.Main,
		rankTextBox.FocusLost:Connect(function()
			if suggestionLabel.Text ~= "" then
				rankTextBox.Text = suggestionLabel.ContentText
			end
		end)
	)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
