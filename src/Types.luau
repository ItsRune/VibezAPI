export type VibezLiteKind = {
	_apiKey: string,
}

--[=[
    @interface RequestOptions
    .Url string
    .Method string
    .Headers {[string]: string}
    .Body any
    @within VibezLite
]=]
export type RequestOptions = {
	Url: string,
	Method: string,
	Headers: { [string]: string },
	Body: any,
}

--[=[
    @interface RequestResponse
    .Success boolean
    .StatusCode number
    .StatusMessage string
    .Headers {[any]: any}
    .Body string
    @within VibezLite
]=]
export type RequestResponse = {
	Success: boolean,
	StatusCode: number,
	StatusMessage: string,
	Headers: { [any]: any },
	Body: string,
}

export type VibezLiteMetatable = {
	__index: VibezLiteMetatable,
	_http: (self: VibezLite, Options: RequestOptions) -> RequestResponse | string,
	setRank: (self: VibezLite, userId: string | number, rankId: number) -> (boolean, string),
	Promote: (self: VibezLite, userId: number) -> (boolean, string),
	Demote: (self: VibezLite, userId: number) -> (boolean, string),
	Fire: (self: VibezLite, userId: number) -> (boolean, string),
}

export type VibezLite = typeof(setmetatable({} :: VibezLiteKind, {} :: VibezLiteMetatable))

return nil
