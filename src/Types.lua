export type groupIdResponse = {
	success: boolean,
	groupId: number,
}

export type errorResponse = {
	success: boolean,
	errorMessage: string,
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

export type httpResponse = {
	Body: responseBody,
	Headers: { [string]: any },
	StatusCode: number,
	StatusMessage: string?,
	Success: boolean,
	rawBody: string,
}

export type vibezSettings = {
	apiKey: string,
	isChatCommandsEnabled: boolean,
	isUIEnabled: boolean,
	commandPrefix: string,
	minRank: number,
	maxRank: number,
	overrideGroupCheckForStudio: boolean,
	loggingOriginName: string,
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
}

export type vibezApi = {
	GroupId: number,
	Settings: vibezSettings,

	Promote: (self: vibezApi, userId: string | number) -> responseBody,
	Demote: (self: vibezApi, userId: string | number) -> responseBody,
	Fire: (self: vibezApi, userId: string | number) -> responseBody,
	SetRank: (self: vibezApi, userId: string | number, rankId: string | number) -> responseBody,
	ToggleCommands: (self: vibezApi) -> nil,
	ToggleUI: (self: vibezApi) -> nil,
	saveActivity: (
		self: vibezApi,
		userId: string | number,
		secondsSpent: number,
		messagesSent: number | { string },
		joinTime: number?,
		leaveTime: number?
	) -> responseBody,
}

export type vibezConstructor = (apiKey: string, extraOptions: vibezSettings?) -> vibezApi

return nil
