--// Services \\--
local HttpService = game:GetService("HttpService")

--// Types \\--
type httpResponse = {
	Success: boolean,
	StatusCode: number,
	StatusMessage: string?,
	Headers: { [string]: any },
	Body: { any }?,
	rawBody: string?,
}

--// Functions \\--
function Http(Route: string, Method: string?, Headers: { [string]: any }?, Body: { any }?): (boolean, httpResponse)
	local apiToUse = "https://leina.vibez.dev"

	Route = (typeof(Route) == "string") and Route or "/"
	Method = (typeof(Method) == "string") and string.upper(Method) or "GET"
	Headers = (typeof(Headers) == "table") and Headers or { ["Content-Type"] = "application/json" }
	Body = (Method ~= "GET" and Method ~= "HEAD") and Body or nil

	Route = (string.sub(Route, 1, 1) ~= "/") and `/{Route}` or Route

	-- Prevents sending api key to external URLs
	-- Remove from 'Route' extra slash that was added
	-- Make 'apiToUse' an empty string since "Route" and "apiToUse" get concatenated on request.
	if string.match(Route, "[http://]|[https://]") ~= nil then
		Route = string.sub(Route, 2, #Route)
		apiToUse = ""
		Headers["x-api-key"] = nil
	end

	local Options = {
		Url = apiToUse .. Route,
		Method = Method,
		Headers = Headers,
		Body = Body and HttpService:JSONEncode(Body) or nil,
	}

	local success, data = pcall(HttpService.RequestAsync, HttpService, Options)
	local successBody, decodedBody = pcall(HttpService.JSONDecode, HttpService, data.Body)

	if success and successBody then
		data.rawBody = data.Body
		data.Body = decodedBody
	end

	return (success and data.StatusCode >= 200 and data.StatusCode < 300), data
end

return Http
