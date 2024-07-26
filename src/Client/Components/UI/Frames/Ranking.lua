--// Services \\--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--// Variables \\--
local Player = Players.LocalPlayer
local Maid, userCache = {}, {}
local defaultThumbnail = "rbxasset://textures/AvatarCompatibilityPreviewer/user.png"
local selectedPlayer = nil

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

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: { [any]: any })
	selectedPlayer = nil

	for _, userFrame: TextButton in ipairs(Frame.User.Suggestions:GetChildren()) do
		if userFrame.Name == "Template" or not userFrame:IsA("TextButton") then
			continue
		end

		userFrame:Destroy()
	end

	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function onSetup(Frame: Frame, componentData: { [any]: any })
	-- Destroy first, in case there was an issue destroying previously.
	onDestroy(Frame, componentData)

	local remoteFunction = componentData.remoteFunction
	for _, actionButton: TextButton in ipairs(Frame.Actions:GetChildren()) do
		if not actionButton:IsA("TextButton") then
			continue
		end

		table.insert(
			Maid,
			actionButton.MouseButton1Click:Connect(function()
				--
			end)
		)
	end

	local setRankFrame = Frame.Actions.setRank
	table.insert(
		Maid,
		setRankFrame.Button.MouseButton1Click:Connect(function()
			local newRank = setRankFrame.newRank.Text
			remoteFunction:InvokeServer("SetRank", "Interface", selectedPlayer, newRank)
		end)
	)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
