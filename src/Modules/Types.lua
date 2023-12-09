-- If you're reading this... Don't even ask..

-- Local Types
type RateLimit = {
	isLimited: boolean,
	_retryAfter: number,
	_counter: number,
	_maxCount: number,
	_counterStartedAt: number,
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

-- Exported Types
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
	commandPrefix: string,
	minRankToUseCommandsAndUI: number,
	maxRankToUseCommandsAndUI: number,
	isChatCommandsEnabled: boolean,
	isUIEnabled: boolean,
	disableActivityTrackingInStudio: boolean,
	activityTrackingEnabled: boolean,
	disableActivityTrackingWhenAFK: boolean,
	rankToStartTrackingActivityFor: number,
	delayBeforeMarkedAFK: number,
	nameOfGameForLogging: string,
	overrideGroupCheckForStudio: boolean,
	ignoreWarnings: boolean,
	usePromises: boolean,
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
	GroupId: number,
	Settings: vibezSettings,
	_private: {
		newApiUrl: string,
		oldApiUrl: string,
		Maid: { RBXScriptConnection? },
		validStaff: { [number]: {}? },
		clientScriptName: string,
		rateLimiter: RateLimit,
		commandOperationCodes: { { any }? },
	},

	Promote: (self: vibezApi, userId: string | number) -> responseBody,
	Demote: (self: vibezApi, userId: string | number) -> responseBody,
	Fire: (self: vibezApi, userId: string | number) -> responseBody,
	SetRank: (self: vibezApi, userId: string | number, rankId: string | number) -> responseBody,
	ToggleCommands: (self: vibezApi, override: boolean?) -> nil,
	ToggleUI: (self: vibezApi, override: boolean?) -> nil,
	saveActivity: (
		self: vibezApi,
		userId: string | number,
		userRank: number,
		secondsSpent: number?,
		messagesSent: (number | { string })?,
		shouldFetchGroupRank: boolean?
	) -> httpResponse,
	getActivity: (self: vibezApi, userId: (string | number)?) -> activityResponse,
	UpdateLoggerTitle: (self: vibezApi, newTitle: string) -> nil,
	addCommandOperation: (
		self: vibezApi,
		operationName: string,
		operationCode: string,
		operationFunction: (playerToCheck: Player, incomingArgument: string) -> boolean
	) -> vibezApi,
	removeCommandOperation: (self: vibezApi, operationName: string) -> vibezApi,
	Destroy: (self: vibezApi) -> nil,
	getWebhookBuilder: (self: vibezApi, webhook: string) -> vibezHooks,
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

return nil
