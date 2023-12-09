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

export type RoTime = {
	Timer: (start: number, finish: number, increment: number?) -> Timer,

	isLeapYear: (self: RoTime) -> boolean,

	_getTokenInformation: (tokenExpected: { string }) -> { [string]: string | number },
	getCalender: (
	) -> {
		amountOfDays: number,
		year: number,
		isLeapYear: boolean,
		days: {
			{
				dayName: string,
				isToday: boolean,
			}
		},
	},

	addition: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	add: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	subtract: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	sub: (self: RoTime, amount: number, Type: addOrRemoveType) -> RoTime,
	set: (self: RoTime, input: string, format: string) -> RoTime,
	addTimezone: (self: RoTime, timezoneName: string, timezoneOffset: number) -> RoTime,
	removeTimezone: (self: RoTime, timezoneName: string) -> RoTime,
	timezone: (self: RoTime, timezoneName: string) -> RoTime,
	setFormat: (self: RoTime, formattingString: string) -> RoTime,

	toNow: (self: RoTime, input: string, format: string) -> number,
	fromNow: (self: RoTime, input: string, format: string) -> number,

	format: (self: RoTime, format: string) -> string,
	getTime: (self: RoTime) -> string,
	getDate: (self: RoTime) -> string,
	getTimestamp: (self: RoTime) -> string,
}
return nil
