--!strict
--// Documentation \\--
--[=[
	A class to handle rate limited requests and their errors.

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
