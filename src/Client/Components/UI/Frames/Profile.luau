--!strict
--// Services \\--
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

--// Variables \\--
local Definitions = require(script.Parent.Parent.Parent.Parent.Definitions)
local _Player = Players.LocalPlayer
local Maid = {}

--// Types \\--
type WidgetType = "Activity" | "User" | "Group"

--// Functions \\--
local function onDestroy(Frame: Frame, componentData: Definitions.componentData)
	componentData.Disconnect(Maid)
	table.clear(Maid)
end

local function _loadWidgets(Frame: any, componentData: Definitions.componentData, ignoredWidgets: { string })
	local allWidgets = Frame.Widgets:GetChildren()

	for i = 1, #allWidgets do
		local widget = allWidgets[i]
		if not widget:IsA("Frame") or widget.Name == "Buffer" then
			continue
		end

		if widget.Name == "Activity" then
			-- local graph = componentData.Graphing.new(widget.Graph)
			local activity = componentData.remoteFunction:InvokeServer("ActivityRequest")

			print(activity)
		elseif widget.Name == "User" then
			local Player = Players.LocalPlayer
			widget.Body.DisplayName.Text = `Nickname: {Player.DisplayName}`
			widget.Body.UserName.Text = `Name: {Player.Name}`
			widget.Body.UserId.Text = `Identifier: {Player.UserId}`
		elseif widget.Name == "Group" then
			widget.Body.GroupIdentifier.Text = `Identifier: {componentData.GroupId}`

			local function loadGroupInfo(info: { [any]: any }?)
				widget.Body.GroupName.Text = info and `Name: {info.Name}` or "Name: Unknown"
				widget.Body.GroupRole.Text = info and `Role: {info.Role} ({info.Rank})` or "Role: Unknown"
			end

			local isOk, playerGroups = pcall(GroupService.GetGroupsAsync, GroupService, Players.LocalPlayer.UserId)
			if not isOk then
				loadGroupInfo()
				return
			end

			local playerGroup = componentData.Table.Find(playerGroups, function(g)
				return g.Id == componentData.GroupId
			end)

			if not playerGroup then
				loadGroupInfo()
				return
			end

			loadGroupInfo(playerGroup)
		end
	end
end

local function onSetup(Frame: Frame, componentData: Definitions.componentData)
	local profileFrameCustomization = componentData.Data.Pages.Profile

	onDestroy(Frame, componentData)

	_loadWidgets(Frame, componentData, profileFrameCustomization.disabledWidgets)
end

--// Core \\--
return {
	Setup = onSetup,
	Destroy = onDestroy,
}
