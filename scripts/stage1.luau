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

		Model = nil, -- Uses default
		Removed = { "settings_check_ignore_nil_tbl" }, -- Won't insert if the name is in this table.

		clickOnPlayerRadius = 20, -- If 'mode' is on 'ClickOnPlayer' then this setting will be used.

		Animation = {
			R6 = 17838471144,
			R15 = 17837716782,
		},
	},

	Notifications = {
		Enabled = true,

		Font = { __TYPE = "Enum", __SUBCATEGORY = "Font", __ATTR = { "Gotham" } },
		FontSize = 16,
		keyboardFontSizeMultiplier = 1.25, -- Multiplier for fontsize keyboard users
		delayUntilRemoval = 10, -- Seconds

		entranceTweenInfo = {
			Style = { __TYPE = "Enum", __SUBCATEGORY = "EasingStyle", __ATTR = { "Quint" } },
			Direction = { __TYPE = "Enum", __SUBCATEGORY = "EasingDirection", __ATTR = { "Out" } },
			timeItTakes = 0.75, -- Seconds
		},

		exitTweenInfo = {
			Style = { __TYPE = "Enum", __SUBCATEGORY = "EasingStyle", __ATTR = { "Quint" } },
			Direction = { __TYPE = "Enum", __SUBCATEGORY = "EasingDirection", __ATTR = { "In" } },
			timeItTakes = 0.75, -- Seconds
		},
	},

	Interface = {
		Enabled = false, -- Toggles the Interface module.
		useBetaUI = false, -- Determines whether you'd like to use our newer Interface.

		MinRank = 255, -- Minimum rank for the interface to show for.
		MaxRank = 255, -- Maximum rank required for the interface.
		maxUsersForSelection = 5, -- Max users to be selected via the interface. (At once)

		Suggestions = {
			searchPlayersOutsideServer = false, -- Determines whether our interface will allow players outside of the server to be searched.
			outsideServerTagText = "External", -- The text shown when a player is searched outside of the server.
			outsideServerTagColor = { __TYPE = "Color3", __SUBCATEGORY = "fromRGB", __ATTR = { 255, 50, 50 } }, -- The tag's color for a player searched outside of the server.
		},

		Logs = {
			Enabled = false, -- Toggles whether we hold server-specific logs of each interaction.
			MinRank = 255, -- Minimum rank to access logs via Interface.
		},

		Activation = {
			Keybind = { __TYPE = "Enum", __SUBCATEGORY = "KeyCode", __ATTR = { "RightShift" } }, -- Keybind for the toggle button.

			allowMobileUsers = true, -- Toggles whether people on tablets/phones can use this UI.
			iconButtonPosition = "Center", -- Position of the toggle button. (Left | Right | Center)
			iconButtonImage = "rbxassetid://3610247188", -- The image shown for the toggle button. (Number | String)
			iconToolTip = "Vibez UI", -- The text shown when hovering over the toggle button.
		},

		nonViewableTabs = { "settings_check_ignore_nil_tbl" }, -- Determines which tabs to not view in the Interface. (Not case sensitive)
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
		userIsBlacklistedMessage = "You have been blacklisted from the game by <BLACKLIST_BY> for: <BLACKLIST_REASON>", -- Message displayed when a player is kicked for being blacklisted.
	},

	Cooldowns = {
		Enabled = false, -- Toggles whether cooldowns should be enabled.
		Ranking = 15, -- A single user cannot be re-ranked every X seconds.
		Blacklisting = 15, -- A single user cannot be blacklisted/unblacklisted for X seconds.
	},

	Misc = {
		originLoggerText = { __TYPE = "game", __SUBCATEGORY = "Name", __ATTR = {} }, -- Text of logger for Vibez provided embeds. (Ranking)
		ignoreWarnings = false, -- Ignores warning messages from different features.
		overrideGroupCheckForStudio = false, -- Overrides group rank checks for developers.
		createGlobalVariables = false, -- Creates a Folder in ServerStorage providing another script access to the API.
		-- rankingCooldown = 30, -- How long until a player can be ranked.
		-- isAsync = false, -- Broken
		-- autoReportErrors = false, -- It's best to use this when a developer asks you to within a ticket. (Removed)
		-- checkForUpdates = false, -- Checks github for an updated version of the module. (Removed)
	},

	Debug = {
		logMessages = false, -- Toggles whether we dump the console full of information about what's happening behind the scenes.
		logClientMessages = false, -- Toggles dump-age of the client's console.
	},
}
