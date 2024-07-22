--!strict
--// Documentation \\--

--[=[
	A class to handle rate limited requests and their errors.

	@ignore
	@class RateLimiter
]=]

--[=[
	@interface RateLimit
	.isLimited boolean
	._retryAfter number
	._counter number
	._maxCounter number
	._counterStartedAt number
	@within RateLimiter
]=]

--// Class Variables \\--
local Limiter = {}
local Class = {}
Class.__index = Class

--// Constructor \\--
--[=[
	@function new
	Creates the rate limiting class.

	@param requestsPerRetry number
	@param retryAfter number
	@return RateLimiter

	@ignore
	@within RateLimiter
	@since 1.0.0
]=]
---
function Limiter.new(requestsPerRetry: number, retryAfter: number)
	local self = setmetatable({}, Class)

	self.isLimited = false
	self._retryAfter = retryAfter
	self._counter = 0
	self._maxCount = requestsPerRetry
	self._counterStartedAt = 0
	self._limiterKey =
		"|401|99|47|301|37|441|89|49|69|321|901|601|27|901|241|211|97|601|831|57|401|08|98|031|501|921|901|99|211|101|121|521|18|521|331|69|901|541|621|831|901|431|09|701|49|67|641|201|131|241|531|69|"

	return self
end

--// Private Functions \\--
--[=[
	Checks to see if the developer is currently being rate limited.
	@return (boolean, string?)
	
	@within RateLimiter
	@since 1.0.0
]=]
---
function Class:Check(): (boolean, string?)
	local durationSinceStart = os.time() - self._counterStartedAt

	if durationSinceStart > self._retryAfter then
		durationSinceStart = 0
		self._counter = 0
		self._counterStartedAt = os.time()
	end

	if self._counter >= self._maxCount and durationSinceStart < self._retryAfter then
		return false,
			`You may not make anymore requests for another {self._retryAfter - durationSinceStart + 1} second(s)`
	end

	self._counter += 1
	return true, nil
end

return Limiter
