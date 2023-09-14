--!strict
local Limiter = {}
local Class = {}
Class.__index = Class

--// Constructor \\--
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
function Class:Check()
	local durationSinceStart = os.time() - self._counterStartedAt

	if durationSinceStart > self._retryAfter then
		durationSinceStart = 0
		self._counter = 0
		self._counterStartedAt = os.time()
	end

	if self._counter >= self._maxCount and durationSinceStart < self._retryAfter then
		return false,
			`You may not make anymore requests for another {self._retryAfter - durationSinceStart + 1} seconds`
	end

	self._counter += 1
	return true, nil
end

return Limiter
