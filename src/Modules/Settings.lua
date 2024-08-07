return {
	Commands = {
		Enabled = false,
		useDefaultNames = true,

		MinRank = 255,
		MaxRank = 255,

		Prefix = "!",
		Alias = {},
		Removed = {},
	},

	RankSticks = {
		Enabled = false,
		Mode = "Default",

		MinRank = 255,
		MaxRank = 255,

		sticksModel = nil, -- Uses default
		sticksAnimation = "17837716782|17838471144", -- Uses a very horrible default one.
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
		Enabled = false,

		MinRank = 255,
		MaxRank = 255,
		maxUsersToSelectForRanking = 5,

		Activation = {
			Keybind = Enum.KeyCode.RightShift,

			allowMobileUsers = true, -- Toggles whether people on tablets/phones can use this UI.
			iconButtonPosition = "Center", -- Left | Right | Center
			iconButtonImage = "rbxassetid://3610247188", -- Number | String
			iconToolTip = "Vibez UI",
		},

		visibleFrames = {
			"Logs",
			"Notifications",
			"Ranking",
		},
	},

	Logs = {
		Enabled = false,
		MinRank = 255,
	},

	ActivityTracker = {
		Enabled = false,
		MinRank = 255,

		disableWhenInStudio = true,
		disableWhenAFK = false,
		disableWhenInPrivateServer = false,

		delayBeforeMarkedAFK = 30,

		kickIfFails = false,
		failMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",
	},

	-- Removed due to being in the works. (Maybe)
	-- Widgets = {
	-- 	Enabled = false,
	-- 	useBannerImage = "",
	-- 	useThumbnailImage = ""
	-- },

	Blacklists = {
		Enabled = false,
		userIsBlacklistedMessage = "You have been blacklisted from the game for: <BLACKLIST_REASON>",
	},

	Misc = {
		originLoggerText = game.Name,
		ignoreWarnings = false,
		overrideGroupCheckForStudio = false,
		createGlobalVariables = false,
		isAsync = false,
		rankingCooldown = 30,
		autoReportErrors = false, -- It's best to use this when a developer asks you to within a ticket.
		-- checkForUpdates = false, -- This check is no longer necessary after finding AI moderation issue. (You can enable if you'd like)
	},
}
