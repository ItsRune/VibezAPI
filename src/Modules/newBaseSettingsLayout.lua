return {
	Commands = {
		Enabled = false,
		MinRank = 255,
		MaxRank = 255,

		Prefix = "!",
	},

	RankSticks = {
		Enabled = false,
		MinRank = 255,
		MaxRank = 255,

		SticksModel = nil, -- Uses default
	},

	Interface = {
		Enabled = false,
		MinRank = 255,
		MaxRank = 255,
	},

	ActivityTracker = {
		Enabled = false,
		MinRank = 255,

		disableWhenInStudio = true,
		disableWhenAFK = false,
		delayBeforeMarkedAFK = 30,
		shouldKickIfActivityTrackerFails = false,
		trackerFailedMessage = "Uh oh! Looks like there was an issue initializing the activity tracker for you. Please try again later!",
	},

	Misc = {
		originLoggerText = game.Name,
		ignoreWarnings = false,
		overrideGroupCheckForStudio = false,
		isAsync = false,
		usePromises = false, -- Broken
	},
}
