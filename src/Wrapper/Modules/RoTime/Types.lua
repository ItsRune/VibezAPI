export type addOrRemoveType =
	"second"
	| "seconds"
	| "minute"
	| "minutes"
	| "hour"
	| "hours"
	| "day"
	| "days"
	| "week"
	| "weeks"
	| "month"
	| "months"
	| "year"
	| "years"

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<T...> = {
	Fire: (self: Signal<T...>, T...) -> (),
	FireDeferred: (self: Signal<T...>, T...) -> (),
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	DisconnectAll: (self: Signal<T...>) -> (),
	GetConnections: (self: Signal<T...>) -> { Connection },
	Destroy: (self: Signal<T...>) -> (),
	Wait: (self: Signal<T...>) -> T...,
}

export type Timer = {
	Changed: Signal,
	Completed: Signal,

	_start: number,
	_finish: number,
	_id: string,
	_lastCheck: number,
	_elapsed: number,
	_increment: number,
	_running: boolean,
	_maid: { RBXScriptConnection? },

	Start: (self: Timer) -> (),
	Pause: (self: Timer) -> (),
	Resume: (self: Timer) -> (),
	Cancel: (self: Timer) -> (),
	Destroy: (self: Timer) -> (),
}

export type Timer = {
	Start: (self: Timer) -> (),
	Pause: (self: Timer) -> (),
	Resume: (self: Timer) -> (),
	Cancel: (self: Timer) -> (),
	Destroy: (self: Timer) -> (),

	Changed: RBXScriptSignal,
	Completed: RBXScriptSignal,
}

export type RoTime = {
	Timer: {
		new: (start: number, finish: number, increment: number?) -> Timer,
	},

	_warn: (self: RoTime, ...any) -> (),
	_getDayOfTheYear: (self: RoTime) -> { currentCount: number, fullYear: number },
	_addZeroInFront: (self: RoTime, value: any) -> string,
	_getTokenInformation: (self: RoTime, tokenExpected: { string }) -> { [string]: string | number },

	getHumanTimestamp: (
		self: RoTime,
		firstUnix: number,
		secondUnix: number,
		Options: { formattingType: "default" | "full"?, removeZeros: boolean? }?
	) -> string,
	getLocalTimezone: (self: RoTime) -> string,
	isLeapYear: (self: RoTime) -> boolean,
	fromNow: (self: RoTime, input: string, format: string) -> number,
	toNow: (self: RoTime, input: string, format: string) -> number,
	getDateTime: (self: RoTime) -> DateTime,
	getDate: (self: RoTime) -> string,
	getTime: (self: RoTime) -> string,
	get: (self: RoTime, ...string) -> ...string,
	getTimestamp: (self: RoTime) -> string,
	getCalender: (
		self: RoTime
	) -> {
		amountOfDays: number,
		isLeapYear: boolean,
		days: { { dayName: string, Day: number, isToday: boolean } },
		year: number,
	},
	format: (self: RoTime, input: string) -> string,

	Destroy: (self: RoTime) -> nil,

	set: (self: RoTime, input: string, format: string?) -> RoTime,
	addition: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	subtract: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	timezone: (self: RoTime, newTimezone: string) -> RoTime,
	addTimezone: (self: RoTime, timezoneName: string, timezoneOffset: number) -> RoTime,
	removeTimezone: (self: RoTime, timezoneName: string) -> RoTime,
}
return nil
