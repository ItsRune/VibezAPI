-- If you're reading this... Don't even ask..

export type RateLimit = {
	isLimited: boolean,
	_retryAfter: number,
	_counter: number,
	_maxCount: number,
	_counterStartedAt: number,
	_limiterKey: string,
	Check: (self: RateLimit) -> (boolean, string?),
}

export type userBlacklistResponse = {
	success: boolean,
	data: {
		blacklisted: boolean,
		reason: string,
	},
}

export type fullBlacklists = {
	success: boolean,
	blacklists: { [number | string]: { reason: string, blacklistedBy: number } },
}

export type userType = Player | string | number

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
	rawBody: string?,
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

		Activation: {
			Keybind: string,

			allowMobileUsers: boolean,
			iconButtonImage: string | number,
			iconButtonPosition: "Left" | "Right" | "Center",
			iconToolTip: string,
		},

		VisibleFrames: { string },
	},

	Logs: {
		Enabled: boolean,
		MinRank: number,
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

export type vibezInternalApi = {
	__index: vibezApi,
	_initialize: (self: vibezApi, apiKey: string) -> (),
	_buildAttributes: (self: vibezApi) -> (),
	_setupCommands: (self: vibezApi) -> (),
	_createRemote: (self: vibezApi) -> (),
	_getNameById: (self: vibezApi, userId: number) -> (),
	_setupGlobals: (self: vibezApi) -> (),
	_fixFormattedString: (
		self: vibezApi,
		String: string,
		Player: { Name: string, UserId: number } | Player,
		Custom: { onlyApplyCustom: boolean, Codes: { { code: string, equates: string } } }
	) -> (),

	_getRoleIdFromRank: (self: vibezApi, rank: number | string) -> number?,

	_onInternalErrorLog: (self: vibezApi, message: string, stack: string) -> (),
	_http: (
		self: vibezApi,
		Route: string,
		Method: any,
		Headers: { [string]: any },
		Body: { [any]: any }?,
		useOldApi: boolean?
	) -> (boolean, httpResponse),

	_onPlayerChatted: (self: vibezApi, Player: Player, message: string) -> (),
	_checkPlayerForRankChange: (self: vibezApi, userId: number) -> (),
	_verifyUser: (
		self: vibezApi,
		User: Player | number | string,
		typeToReturn: "UserId" | "Player" | "Name" | "Id"
	) -> (Player | number | string)?,

	_giveSticks: (self: vibezApi, Player: Player) -> (),
	_removeSticks: (self: vibezApi, Player: Player) -> (),
	_playerIsValidStaff: (self: vibezApi, Player: any) -> { [any]: any },
	_notifyPlayer: (self: vibezApi, Player: Player, Message: string) -> (),
	_warn: (self: vibezApi, ...any) -> (),
	_addLog: (
		self: vibezApi,
		calledBy: Player,
		Action: string,
		triggeringAction: "Commands" | "Interface" | "RankSticks",
		affectedUsers: { { Name: string, UserId: number } },
		extraData: any?
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
}

export type vibezPrivate = {
	Event: RemoteEvent,
	Function: RemoteFunction,

	_initialized: boolean,
	_lastVersionCheck: number,
	_rotateIndex: number,
	_modules: { [any]: any },

	recentlyChangedKey: boolean,
	newApiUrl: string,
	oldApiUrl: string,

	clientScriptName: string,
	rateLimiter: RateLimit,

	externalConfigCheckDelay: number,
	lastLoadedExternalConfig: number,

	Maid: { RBXScriptConnection? },
	rankingCooldowns: {},

	usersWithSticks: { number? },
	stickTypes: string,

	requestCaches: {
		validStaff: { { any } },
		nitro: { number? },
		groupInfo: { [number]: { any }? },
	},

	Binds: {
		promote: { [any]: any },
		demote: { [any]: any },
		fire: { [any]: any },
		setrank: { [any]: any },
		addblacklist: { [any]: any },
		_internal: { Afk: { [any]: any } },
	},

	validModes: {
		RankSticks: {
			detectioninfront: "DetectionInFront",
			clickonplayer: "ClickOnPlayer",
		},
	},

	actionStorage: {
		Bans: { [any]: any },
		Logs: {
			{
				Action: string,
				Timestamp: number,
				affectedCount: number,
				affectedUsers: {
					[number]: {
						Name: string,
						UserId: number,
					},
				},
				calledBy: { Name: string, UserId: number },
				extraData: any,
				triggeredBy: string,
			}
		},
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
}

export type vibezProperties = {
	GroupId: number,
	isVibez: boolean,
	Settings: vibezSettings & {
		apiKey: string,
	},

	_debug: vibezDebugTools,
	_private: vibezPrivate,
}

export type vibezPublicApi = {
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

	setRankStickTool: (self: vibezApi, tool: any) -> vibezApi,
	getGroupId: (self: vibezApi) -> number,

	isPlayerABooster: (self: vibezApi, User: number | string | Player) -> boolean?,

	-- Blacklists
	addBlacklist: (
		self: vibezApi,
		userToBlacklist: Player | string | number,
		Reason: string?,
		blacklistExecutedBy: Player | string | number
	) -> (blacklistResponse | errorResponse | infoResponse)?,
	deleteBlacklist: (
		self: vibezApi,
		userToDelete: Player | string | number
	) -> (blacklistResponse | errorResponse | infoResponse)?,
	getBlacklists: (self: vibezApi, userId: userType) -> (blacklistResponse | errorResponse | infoResponse)?,
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
		userId: string | number,
		userRank: number,
		secondsSpent: number?,
		messagesSent: (number | { string })?,
		shouldFetchGroupRank: boolean?
	) -> (infoResponse | errorResponse)?,
	getActivity: (self: vibezApi, userId: string | number) -> activityResponse?,

	-- Commands
	getUsersForCommands: (self: vibezApi, playerWhoCalled: Player, usernames: { string | number }) -> { Player },
	addCommand: (
		self: vibezApi,
		commandName: string,
		commandAliases: { string },
		commandOperation: (
			Player: Player,
			Args: { string },
			addLog: (
				calledBy: Player,
				Action: string,
				affectedUsers: { Player }?,
				...any
			) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }
		) -> ()
	) -> boolean,
	addArgumentPrefix: (
		self: vibezApi,
		operationName: string,
		operationCode: string,
		operationFunction: (
			playerWhoExecuted: Player,
			otherPlayer: Player,
			incomingArgument: string,
			internalFunctions: vibezCommandFunctions
		) -> boolean,
		metaData: { [string]: boolean }?
	) -> vibezApi,
	removeArgumentPrefix: (self: vibezApi, operationName: string) -> vibezApi,
}

export type vibezApi = any

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
		author: {
			name: string?,
			url: string?,
			icon_url: string?,
		},
		thumbnail: {
			url: string?,
			height: number?,
			width: number?,
		},
		fields: {
			{
				name: string,
				value: string,
				inline: boolean?,
			}?
		},
		color: string | number,
		footer: {
			text: string,
			icon_url: string?,
		},
	},
	url: string,
	_api: vibezApi,
	_used: boolean,
}

export type embedCreator = Embed & {
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