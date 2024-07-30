-- If you're reading this... Don't even ask..

-- Local Types
type RateLimit = {
	isLimited: boolean,
	_retryAfter: number,
	_counter: number,
	_maxCount: number,
	_counterStartedAt: number,
	_limiterKey: string,
	Check: (self: RateLimit) -> (boolean, string?),
}

type userBlacklistResponse = {
	success: boolean,
	data: {
		blacklisted: boolean,
		reason: string,
	},
}

type fullBlacklists = {
	success: boolean,
	blacklists: { [number | string]: { reason: string, blacklistedBy: number } },
}

type userType = Player | string | number

-- Exported Types
export type vibezDebugTools = {
	stringifyTableDeep: (tbl: { any }, tabbing: number?) -> string,
}

export type blacklistResponse = userBlacklistResponse | fullBlacklists

export type groupIdResponse = {
	success: boolean,
	groupId: number,
}

export type errorResponse = {
	success: boolean,
	errorMessage: string,
}

export type infoResponse = {
	success: boolean,
	message: string,
}

export type activityResponse = {
	secondsUserHasSpent: number,
	messagesUserHasSent: number,
	detailedLogs: {
		{
			timestampLeftAt: number,
			secondsUserHasSpent: number,
			messagesUserHasSent: number,
		}
	},
}

export type rankResponse = {
	success: boolean,
	message: string?,
	newRank: {
		id: number,
		name: string,
		rank: number,
		memberCount: number,
	},
	oldRank: {
		id: number,
		name: string,
		rank: number,
		groupInformation: {
			id: number,
			name: string,
			memberCount: number,
			hasVerifiedBadge: boolean,
		},
	},
}

export type nitroBoosterResponse = {
	success: boolean,
	isBooster: boolean?,
	message: string?,
}

export type responseBody = groupIdResponse | errorResponse | rankResponse | infoResponse | nitroBoosterResponse

export type httpResponse = {
	Body: responseBody,
	Headers: { [string]: any },
	StatusCode: number,
	StatusMessage: string?,
	Success: boolean,
	rawBody: string,
}

export type vibezSettings = {
	Commands: {
		Enabled: boolean,
		useDefaultNames: boolean,

		MinRank: number,
		MaxRank: number,

		Prefix: string,
		Alias: { { any } },
		Removed: { string? },
	},

	RankSticks: {
		Enabled: boolean,
		Mode: "DetectionInFront" | "ClickOnPlayer",

		MinRank: number,
		MaxRank: number,

		sticksModel: Model?,
		sticksAnimation: number?,
	},

	Notifications: {
		Enabled: boolean,

		Font: Enum.Font | string,
		FontSize: number,
		keyboardFontSizeMultiplier: number,
		delayUntilRemoval: number,

		entranceTweenInfo: {
			Style: Enum.EasingStyle | string,
			Direction: Enum.EasingDirection | string,
			timeItTakes: number,
		},

		exitTweenInfo: {
			Style: Enum.EasingStyle | string,
			Direction: Enum.EasingDirection | string,
			timeItTakes: number,
		},
	},

	Interface: {
		Enabled: boolean,

		MinRank: number,
		MaxRank: number,

		maxUsersToSelectForRanking: number,
		activationKeybind: Enum.KeyCode | string,
	},

	ActivityTracker: {
		Enabled: boolean,
		MinRank: number,

		disableWhenInStudio: boolean,
		disableWhenAFK: boolean,
		delayBeforeMarkedAFK: number,
		kickIfFails: boolean,
		failMessage: string,
	},

	-- Widgets: {
	-- 	Enabled: boolean,
	-- },

	Blacklists: {
		Enabled: boolean,
		userIsBlacklistedMessage: string,
	},

	Misc: {
		originLoggerText: string,
		ignoreWarnings: boolean,
		overrideGroupCheckForStudio: boolean,
		createGlobalVariables: boolean,
		isAsync: boolean,
		rankingCooldown: number,
		checkForUpdates: boolean,
		autoReportErrors: boolean,
	},
}

export type httpFunction = (
	self: vibezApi,
	Route: string,
	Method: string?,
	Headers: { [string]: any },
	Body: { [string]: any },
	useOldApi: boolean?
) -> (boolean, httpResponse)

export type vibezCommandFunctions = {
	getGroupRankFromName: (self: vibezApi, groupRoleName: string) -> number?,
	getGroupFromUser: (self: vibezApi, groupId: number, userId: number) -> { any }?,
	Http: (
		self: vibezApi,
		Route: string,
		Method: string?,
		Headers: { [string]: any },
		Body: { [string]: any }
	) -> httpResponse,
}

export type vibezApi = {
	-- Misc

	GroupId: number,
	Settings: vibezSettings,
	_debug: vibezDebugTools,
	_private: {
		Event: RemoteEvent?,
		Function: RemoteFunction?,

		_initialized: boolean,
		_lastVersionCheck: number,
		recentlyChangedKey: boolean,

		newApiUrl: string,
		oldApiUrl: string,

		clientScriptName: string,
		rateLimiter: RateLimit,

		externalConfigCheckDelay: number,
		lastLoadedExternalConfig: number,

		inGameLogs: { {}? },
		Maid: { RBXScriptConnection? },
		rankingCooldowns: {},
		Binds: { [string]: { [string]: (result: responseBody) -> () } },

		usersWithSticks: { number? },
		stickTypes: string,

		requestCaches: {
			validStaff: { { any } },
			nitro: { number? },
			groupInfo: { [number]: { any }? },
		},

		commandOperations: {
			{
				Name: string,
				Alias: { string? },
				Enabled: boolean,
				Execute: (
					Player: Player,
					Args: { string },
					addLog: (
						calledBy: Player,
						Action: string,
						affectedUsers: { Player }?,
						...any
					) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }
				) -> (),
			}?
		},
		commandOperationCodes: {
			[string]: {
				Code: string,
				isExternal: boolean?,
				Execute: (Player: Player, playerToCheck: Player, incomingArgument: string) -> boolean,
			}?,
		},
	},

	-- Internal methods
	_buildAttributes: () -> (),
	_setupCommands: () -> (),

	_onInternalErrorLog: (message: string, stack: string) -> (),
	_http: (
		self: vibezApi,
		Route: string,
		Method: string?,
		Headers: { [string]: any }?,
		Body: { any }?,
		useOldApi: boolean?
	) -> (boolean, httpResponse),

	_giveSticks: (self: vibezApi, Player: Player) -> (),
	_playerIsValidStaff: (self: vibezApi, Player: Player | number | string) -> { [number]: any },

	_notifyPlayer: (self: vibezApi, Player: Player, Message: string) -> (),
	_warn: (self: vibezApi, ...string) -> (),
	_addLog: (
		self: vibezApi,
		calledBy: Player,
		Action: string,
		affectedUsers: { { Name: string, UserId: number } }?,
		...any
	) -> (),
	_getGroupRankFromName: (self: vibezApi, groupRoleName: string) -> number?,
	_getGroupFromUser: (
		self: vibezApi,
		groupId: number,
		userId: number,
		force: boolean?
	) -> { Rank: number?, Role: string?, Id: number?, errMessage: string? },
	_getUserIdByName: (self: vibezApi, username: string) -> number,

	_onPlayerRemoved: (self: vibezApi, Player: Player, isPlayerStillInGame: boolean?) -> (),
	_onPlayerAdded: (self: vibezApi, Player: Player) -> (),

	-- Misc methods
	bindToAction: (
		self: vibezApi,
		name: string,
		action: "Promote" | "Demote" | "Fire" | "Blacklist",
		callback: (result: responseBody) -> ()
	) -> vibezApi,
	unbindFromAction: (self: vibezApi, name: string, action: "Promote" | "Demote" | "Fire" | "Blacklist") -> vibezApi,
	updateLoggerName: (self: vibezApi, newTitle: string) -> nil,
	getWebhookBuilder: (self: vibezApi, webhook: string) -> vibezHooks,
	waitUntilLoaded: (self: vibezApi) -> vibezApi?,
	updateKey: (self: vibezApi, newApiKey: string) -> boolean,
	Destroy: (self: vibezApi) -> nil,

	-- Blacklists
	addBlacklist: (
		self: vibezApi,
		userToBlacklist: userType,
		Reason: string?,
		blacklistExecutedBy: userType?
	) -> blacklistResponse | errorResponse,
	deleteBlacklist: (self: vibezApi, userToDelete: userType) -> blacklistResponse | errorResponse,
	getBlacklists: (self: vibezApi, userId: userType) -> blacklistResponse | errorResponse,
	isUserBlacklisted: (self: vibezApi, userId: number | string) -> ...any,

	-- Ranking
	Promote: (
		self: vibezApi,
		userId: userType,
		whoCalled: { userName: string, userId: number }?
	) -> responseBody | errorResponse,
	Demote: (
		self: vibezApi,
		userId: userType,
		whoCalled: { userName: string, userId: number }?
	) -> responseBody | errorResponse,
	Fire: (
		self: vibezApi,
		userId: userType,
		whoCalled: { userName: string, userId: number }?
	) -> responseBody | errorResponse,
	setRank: (
		self: vibezApi,
		userId: userType,
		rankId: string | number,
		whoCalled: { userName: string, userId: number }?
	) -> responseBody | errorResponse,

	--- Ranking Sticks
	giveRankSticks: (self: vibezApi, User: userType, shouldCheckPermissions: boolean?) -> boolean,
	setRankStickModel: (self: vibezApi, tool: Tool | Model) -> (),

	-- Activity
	removeActivity: (self: vibezApi, userId: userType) -> boolean,
	saveActivity: (
		self: vibezApi,
		userId: userType,
		userRank: number,
		secondsSpent: number?,
		messagesSent: (number | { string })?,
		shouldFetchGroupRank: boolean?
	) -> infoResponse | errorResponse,
	getActivity: (self: vibezApi, userId: userType?) -> activityResponse | errorResponse,

	-- Commands
	getUsersForCommands: (self: vibezApi, playerWhoCalled: Player, usernames: { string | number }) -> { Player },
	addCommand: (
		self: vibezApi,
		commandName: string,
		commandAlias: { string }?,
		commandOperation: (
			Player: Player,
			Args: { string },
			addLog: (
				calledBy: Player,
				Action: string,
				affectedUsers: { Player }?,
				...any
			) -> {
				calledBy: Player,
				affectedusers: { Player }?,
				affectedCount: number?,
				Metadata: any,
			}
		) -> ()
	) -> boolean,
	addArgumentPrefix: (
		self: vibezApi,
		operationName: string,
		operationCode: string,
		operationFunction: (playerToCheck: Player, incomingArgument: string) -> boolean
	) -> vibezApi,
	removeArgumentPrefix: (self: vibezApi, operationName: string) -> vibezApi,
}

export type vibezHooks = {
	Api: { any },
	webhook: string,
	toSend: { any? },
	new: (vibezApi: { any }, webhook: string) -> vibezHooks,
	addEmbedWithBuilder: (self: vibezHooks, handler: (embedCreator: embedCreator) -> Embed) -> vibezHooks,
	addEmbed: (self: vibezHooks, data: { [string]: any }) -> vibezHooks,
	_parseWebhook: (self: vibezHooks, webhookToUse: string?) -> { ID: string, Token: string }?,
	Send: (self: vibezHooks) -> vibezHooks,
	setContent: (self: vibezHooks, content: string?) -> vibezHooks,
	setUsername: (self: vibezHooks, username: string?) -> vibezHooks,
	setWebhook: (self: vibezHooks, newWebhook: string) -> vibezHooks,
	setTTS: (self: vibezHooks, override: boolean?) -> vibezHooks,
	Destroy: (self: vibezHooks) -> nil,
}

export type ActivityTracker = {
	changeAfkState: (self: ActivityTracker, override: boolean?) -> ActivityTracker,
	Left: (self: ActivityTracker) -> nil,
	Increment: (self: ActivityTracker) -> nil,
	Destroy: (self: ActivityTracker) -> nil,
}

export type Embed = {
	data: {
		title: string,
		description: string,
		fields: {
			{
				name: string,
				value: string,
				inline: boolean?,
			}?
		},
		color: string | number,
	},
}

export type embedCreator = {
	setTitle: (self: embedCreator, title: string) -> embedCreator,
	setDescription: (self: embedCreator, description: string) -> embedCreator,
	addField: (self: embedCreator, name: string, value: string, isInline: boolean?) -> embedCreator,
	setColor: (self: embedCreator, color: Color3 | string | number) -> embedCreator,
	setAuthor: (self: embedCreator, name: string, url: string?, iconUrl: string) -> embedCreator,
	setThumbnail: (self: embedCreator, url: string, height: number?, width: number?) -> embedCreator,
	setFooter: (self: embedCreator, text: string, iconUrl: string?) -> embedCreator,
	-- setTimestamp: (self: embedCreator, timeStamp: number | "Auto") -> embedCreator,
}

export type vibezConstructor = (apiKey: string, extraOptions: vibezSettings?) -> vibezApi

export type widgetTypes = "" -- Add more if we decide to add more. (Social media platforms)

return nil

--[=[
	@interface extraOptionsType
	.Commands { Enabled: boolean, useDefaultNames: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, Prefix: string, Alias: {string?} }
	.RankSticks { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, SticksModel: Model? }
	.Interface { Enabled: boolean, MinRank: number<0-255>, MaxRank: number<0-255>, activationKey: Enum.KeyCode | string }
	.Notifications { Enabled: boolean, Font: Enum.Font, FontSize: number<1-100>, keyboardFontSizeMultiplier: number, delayUntilRemoval: number, entranceTweenInfo: {Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number}, exitTweenInfo: {Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number} }
	.ActivityTracker { Enabled: boolean, MinRank: number<0-255>, disabledWhenInStudio: boolean, disableWhenInPrivateServer: boolean, disableWhenAFK: boolean, delayBeforeMarkedAFK: number, kickIfFails: boolean, failMessage: string }
	.Misc { originLoggerText: string, ignoreWarnings: boolean, rankingCooldown: number, overrideGroupCheckForStudio: boolean, createGlobalVariables: boolean, isAsync: boolean }
	@within VibezAPI
]=]

--[=[
	@interface groupIdResponse
	.success boolean
	.groupId number?
	@within VibezAPI
]=]

--[=[
	@interface errorResponse
	.success boolean
	.errorMessage string
	@within VibezAPI
]=]

--[=[
	@interface rankResponse
	.success boolean
	.message string
	.data { newRank: { id: number, name: string, rank: number, memberCount: number }, oldRank: { id: number, name: string, rank: number, groupInformation: { id: number, name: string, memberCount: number, hasVerifiedBadge: boolean } } }
	@within VibezAPI
]=]

--[=[
	@interface blacklistResponse
	.success boolean
	.message string
	@within VibezAPI
]=]

--[=[
	@interface fullBlacklists
	.success boolean
	.blacklists: { [number | string]: { reason: string, blacklistedBy: number } }
	@within VibezAPI
]=]

--[=[
	@interface infoResponse
	.success boolean
	.message string
	@within VibezAPI
]=]

--[=[
	@interface activityResponse
	.secondsUserHasSpent number
	.messagesUserHasSent number
	.detailsLogs [ {timestampLeftAt: number, secondsUserHasSpent: number, messagesUserHasSent: number}? ]
	@within VibezAPI
]=]

--[=[
	@type responseBody groupIdResponse | errorResponse | rankResponse
	@within VibezAPI
]=]

--[=[
	@interface httpResponse
	.Body responseBody
	.Headers { [string]: any }
	.StatusCode number
	.StatusMessage string?
	.Success boolean
	.rawBody string
	@within VibezAPI
]=]

--[=[
	@interface vibezDebugTools
	.stringifyTableDeep (tbl: { any }, tabbing: number?) -> string
	@private
	@within VibezAPI
]=]
