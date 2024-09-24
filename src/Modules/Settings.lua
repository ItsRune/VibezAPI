-- Commands
--[=[
	@interface commandOptions
	.Enabled boolean
	.useDefaultNames boolean
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.Prefix string
	.Alias {[string]: string}
	.Removed {string?}
	@private
	@within VibezAPI
]=]

-- RankSticks
--[=[
	@interface rankStickOptions
	.Enabled boolean
	.Mode "Default" | "ClickOnPlayer" | "DetectionInFront"
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.sticksModel (Model | Tool)?
	.Removed {string?}
	.Animation { R6: number, R15: number }
	@private
	@within VibezAPI
]=]

-- Notifications
--[=[
	@interface notificationsOptions
	.Enabled boolean
	.Font Enum.Font
	.FontSize number
	.keyboardFontMultiplier number
	.delayUntilRemoval number
	.entranceTweenInfo { Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }
	.exitTweenInfo { Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }
	@private
	@within VibezAPI
]=]

-- Interface
--[=[
	@interface interfaceOptions
	.Enabled boolean
	.MinRank number<0-255>
	.MaxRank number<0-255>
	.maxUsersForSelection number
	.Suggestions { searchPlayersOutsideServer: boolean, outsideServerTagText: string }
	.Activation { Keybind: Enum.KeyCode, allowMobileUsers: boolean, iconButtonPosition: "Center" | "Left" | "Right", iconButtonImage: string, iconToolTip: string }
	.nonViewableTabs { string? }
	@private
	@within VibezAPI
]=]

-- Logs
--[=[
	@interface loggingOptions
	.Enabled boolean
	.MinRank number<0-255>
	@private
	@within VibezAPI
]=]

-- Activity Tracker
--[=[
	@interface activityTrackerOptions
	.Enabled boolean
	.MinRank number<0-255>
	.disableWhenInStudio boolean
	.disableWhenInPrivateServer boolean
	.disableWhenAFK boolean
	.delayBeforeMarkedAFK number
	.kickIfFails boolean
	.failMessage string
	@private
	@within VibezAPI
]=]

-- Misc
--[=[
	@interface miscOptions
	.originLoggerText string
	.ignoreWarnings boolean
	.overrideGroupCheckForStudio boolean
	.createGlobalVariables boolean
	.rankingCooldown number
	@private
	@within VibezAPI
]=]

-- Base
--[=[
	@interface extraOptionsType
	.Commands commandOptions
	.RankSticks rankStickOptions
	.Notifications notificationsOptions
	.Interface interfaceOptions
	.ActivityTracker activityTrackerOptions
	.Misc miscOptions
	@within VibezAPI
]=]

-- Array string: 'settings_check_ignore_nil_tbl' ignores data in table for settings checker.
return {
	Commands = {
		Enabled = false, -- Toggles the Commands module.
		useDefaultNames = true, -- Uses default 'promote', 'demote', 'fire' command names.

		MinRank = 255, -- Minimum rank
		MaxRank = 255, -- Maximum rank

		Prefix = "!", -- Prefix to use when using commands.
		Alias = { "settings_check_ignore_nil_tbl" }, -- Command aliases.
		Removed = { "settings_check_ignore_nil_tbl" }, -- Removes specified commands.
	},

	RankSticks = {
		Enabled = false,
		Mode = "Default",

		MinRank = 255,
		MaxRank = 255,

		sticksModel = nil, -- Uses default
		Removed = { "settings_check_ignore_nil_tbl" }, -- Won't insert if the name is in this table.

		Animation = {
			R6 = 17838471144,
			R15 = 17837716782,
		},
	},

	Notifications = {
		Enabled = true,

		Font = Enum.Font.Gotham,
		FontSize = 16,
		keyboardFontSizeMultiplier = 1.25, -- Multiplier for fontsize keyboard users
		delayUntilRemoval = 10, -- Seconds

		entranceTweenInfo = {
			Style = Enum.EasingStyle.Quint,
			Direction = Enum.EasingDirection.InOut,
			timeItTakes = 1, -- Seconds
		},

		exitTweenInfo = {
			Style = Enum.EasingStyle.Quint,
			Direction = Enum.EasingDirection.InOut,
			timeItTakes = 1, -- Seconds
		},
	},

	Interface = {
		Enabled = false, -- Toggles the Interface module.

		MinRank = 255, -- Minimum rank for the interface to show for.
		MaxRank = 255, -- Maximum rank required for the interface.
		maxUsersForSelection = 5, -- Max users to be selected via the interface. (At once)

		Suggestions = {
			searchPlayersOutsideServer = false, -- Determines whether our interface will allow players outside of the server to be searched.
			outsideServerTagText = "External", -- The text shown when a player is searched outside of the server.
		},

		Activation = {
			Keybind = Enum.KeyCode.RightShift, -- Keybind for the toggle button.

			allowMobileUsers = true, -- Toggles whether people on tablets/phones can use this UI.
			iconButtonPosition = "Center", -- Position of the toggle button. (Left | Right | Center)
			iconButtonImage = "rbxassetid://3610247188", -- The image shown for the toggle button. (Number | String)
			iconToolTip = "Vibez UI", -- The text shown when hovering over the toggle button.
		},

		nonViewableTabs = { "settings_check_ignore_nil_tbl" }, -- Determines which tabs to not view in the Interface. (Not case sensitive)
	},

	Logs = {
		Enabled = false, -- Toggles whether we hold server-specific logs of each interaction.
		MinRank = 255, -- Minimum rank to access logs via Interface.
	},

	ActivityTracker = {
		Enabled = false, -- Toggles the Activity Tracking module.
		MinRank = 255, -- Minimum rank required to start tracking activity.

		disableWhenInStudio = true, -- Determines behavior when player loads into studio play-test.
		disableWhenInPrivateServer = false, -- Determines behavior in private servers.
		disableWhenAFK = false, -- Determines behavior when player is marked AFK.
		delayBeforeMarkedAFK = 30, -- Time until a player is marked AFK after no inputs received for X seconds.
		kickIfFails = false, -- Determines whether we'll kick the player when their tracker fails to initialize.

		-- Message displayed to the player when kicked and their tracker fails to initialize.
		failMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",
	},

	Blacklists = {
		Enabled = false, -- Toggles the Blacklists module.
		userIsBlacklistedMessage = "You have been blacklisted from the game for: <BLACKLIST_REASON>", -- Message displayed when a player is kicked for being blacklisted.
	},

	Misc = {
		originLoggerText = game.Name, -- Text of logger for Vibez provided embeds. (Ranking)
		showDebugMessages = false, -- Allows our wrapper to print to the output any debugging related messages.
		ignoreWarnings = false, -- Ignores debugging outputs.
		overrideGroupCheckForStudio = false, -- Overrides group rank checks for developers.
		createGlobalVariables = false, -- Creates a Folder in ServerStorage providing another script access to the API.
		rankingCooldown = 30, -- How long until a player can be ranked.
		-- isAsync = false, -- Broken
		-- autoReportErrors = false, -- It's best to use this when a developer asks you to within a ticket. (Removed)
		-- checkForUpdates = false, -- Checks github for an updated version of the module. (Removed)
	},
}
