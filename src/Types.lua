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
	success: boolean?,
	message: string?,
	[number]: {
		secondsUserHasSpent: number,
		messagesUserHasSent: number,
		detailedLogs: {
			{
				timestampLeftAt: number,
				secondsUserHasSpent: number,
				messagesUserHasSent: number,
			}
		},
	}?,
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

export type responseBody = groupIdResponse | errorResponse | rankResponse | infoResponse

export type httpResponse = {
	Body: responseBody,
	Headers: { [string]: any },
	StatusCode: number,
	StatusMessage: string?,
	Success: boolean,
	rawBody: string,
}

export type vibezSettings = {
	isChatCommandsEnabled: boolean,
	isUIEnabled: boolean,
	commandPrefix: string,
	minRank: number,
	maxRank: number,
	overrideGroupCheckForStudio: boolean,
	loggingOriginName: string,
	ignoreWarnings: boolean,
}

export type vibezInternalApi = {
	Http: (
		self: vibezApi,
		Route: string,
		Method: string?,
		Headers: { [string]: any },
		Body: { [string]: any }
	) -> httpResponse,
	onPlayerChatted: (Player: Player, message: string) -> nil,
	onPlayerAdded: (Player: Player) -> nil,
	onPlayerRemoved: (Player: Player) -> nil,
	getGroupFromUser: (groupId: number, userId: number) -> { any }?,
	getGroupId: () -> number?,
	_Fire: (userId: string | number, whoCalled: { userName: string, userId: number }) -> rankResponse,
	_Demote: (userId: string | number, whoCalled: { userName: string, userId: number }) -> rankResponse,
	_Promote: (userId: string | number, whoCalled: { userName: string, userId: number }) -> rankResponse,
	_setRank: (
		userId: string | number,
		rankId: string | number,
		whoCalled: { userName: string, userId: number }
	) -> rankResponse,
	_destroy: () -> nil,
	_warn: (...string) -> nil,
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

export type vibezApi = {
	GroupId: number,
	Settings: vibezSettings,

	Promote: (self: vibezApi, userId: string | number) -> responseBody,
	Demote: (self: vibezApi, userId: string | number) -> responseBody,
	Fire: (self: vibezApi, userId: string | number) -> responseBody,
	SetRank: (self: vibezApi, userId: string | number, rankId: string | number) -> responseBody,
	ToggleCommands: (self: vibezApi, override: boolean?) -> nil,
	ToggleUI: (self: vibezApi, override: boolean?) -> nil,
	saveActivity: (
		self: vibezApi,
		userId: string | number,
		secondsSpent: number,
		messagesSent: number | { string }
	) -> httpResponse,
	getActivity: (userId: (string | number)?) -> httpResponse,
	UpdateLoggerTitle: (newTitle: string) -> nil,
	addCommandOperation: (
		self: vibezApi,
		operationName: string,
		operationCode: string,
		operationFunction: (playerToCheck: Player, incomingArgument: string) -> boolean
	) -> vibezApi,
	removeCommandOperation: (self: vibezApi, operationName: string) -> vibezApi,
	Destroy: () -> nil,
}

export type vibezConstructor = (apiKey: string, extraOptions: vibezSettings?) -> vibezApi

return nil
