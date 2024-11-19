local Result = require(script.Parent.Result)

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
	_http: (self: VibezLite, Options: RequestOptions) -> Result.Result<RequestResponse, string>,
	setRank: (self: VibezLite, userId: string | number, rankId: string | number) -> Result.Result<string, string>,
	Promote: (self: VibezLite, userId: number) -> Result.Result<string, string>,
}

export type VibezLite = typeof(setmetatable({} :: VibezLiteKind, {} :: VibezLiteMetatable))

return nil
