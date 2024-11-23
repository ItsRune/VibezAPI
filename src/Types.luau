local Cache = require(script.Parent.classes.Cache)

export type RequestOptions = {
	Url: string,
	Method: string,
	Headers: { [string]: string }?,
	Body: any?,
}

export type RequestResponse = {
	Success: boolean,
	StatusCode: number,
	StatusMessage: string,
	Headers: { [any]: any },
	Body: string,
}

export type UserKind = Player | number | string

export type VibezActivityPackage = typeof(setmetatable(
	{} :: { base: VibezLightWeight },
	{} :: {
		Delete: (self: VibezBlacklistsPackage, User: UserKind) -> (boolean, string),
		Get: (self: VibezBlacklistsPackage, User: UserKind?) -> (boolean, { [any]: any }),
		Add: (
			self: VibezBlacklistsPackage,
			User: UserKind,
			secondsSpent: number,
			messagesSent: (number | { string })?
		) -> (boolean, string),
		Remove: (
			self: VibezBlacklistsPackage,
			User: UserKind,
			secondsToRemove: number,
			messagesToRemove: number
		) -> (boolean, string),
	}
))

export type VibezBlacklistsPackage = typeof(setmetatable(
	{} :: { base: VibezLightWeight, Cache: Cache.T_Cache<any> },
	{} :: {
		Add: (
			self: VibezBlacklistsPackage,
			User: UserKind,
			Reason: string?,
			blacklistExecutedBy: UserKind?
		) -> (boolean, string),
		Delete: (self: VibezBlacklistsPackage, userToDelete: UserKind) -> (boolean, string),
	}
))

export type VibezRankingPackage = typeof(setmetatable(
	{} :: { base: VibezLightWeight },
	{} :: {
		setRank: (self: VibezRankingPackage, User: UserKind, rankId: number | string) -> (boolean, string),
		Promote: (self: VibezRankingPackage, User: UserKind) -> (boolean, string),
		Demote: (self: VibezRankingPackage, User: UserKind) -> (boolean, string),
		Fire: (self: VibezRankingPackage, User: UserKind) -> (boolean, string),
	}
))

export type VibezUtilsPackage = typeof(setmetatable(
	{} :: { base: VibezLightWeight },
	{} :: {
		ensureWhoCalledExists: (
			self: VibezUtilsPackage,
			whoCalled: { userName: string, userId: number }?
		) -> { userName: string, userId: number },
		Http: (self: VibezUtilsPackage, Options: RequestOptions) -> RequestResponse | string,
		getNameById: (self: VibezUtilsPackage, userId: number) -> string,
		getUserIdByName: (self: VibezUtilsPackage, username: string) -> number,
		verifyUser: (
			self: VibezUtilsPackage,
			User: Player | number | string,
			typeToReturn: "UserId" | "Id" | "Name" | "Player"
		) -> Player | number | string,
		getGroupId: () -> number?,
	}
))

export type VibezLightWeightKind = {
	_apiKey: string,
	GroupId: number,
	Activity: VibezActivityPackage,
	Blacklists: VibezBlacklistsPackage,
	Ranking: VibezRankingPackage,
	Utils: VibezUtilsPackage,
}

export type VibezLightWeightMetatable = {
	__index: VibezLightWeightMetatable,
}

export type VibezLightWeight = typeof(setmetatable({} :: VibezLightWeightKind, {} :: VibezLightWeightMetatable))

return nil
