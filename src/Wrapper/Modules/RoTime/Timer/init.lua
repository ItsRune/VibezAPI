local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Signal = require(script.Signal)

--- @class Timer
--- @ignore

--[=[
    @within Timer
    @interface timerData
    .Completed Signal
    .Changed Signal
    
    .Start (self: Timer) -> nil
    .Pause (self: Timer) -> nil
    .Resume (self: Timer) -> nil
    .Cancel (self: Timer) -> nil
]=]

local Timer = {}
local Class = {}
Class.__index = Class

--// Public Functions \--
--[=[
    Constructs a new timer.
    @param start number
    @param finish number
    @param increment number?
    @return Timer

    @tag Constructor
    @since 1.0.0
    @within Timer
]=]
function Timer.new(start: number, finish: number, increment: number?)
	local self = setmetatable({}, Class)

	self.Changed = Signal.new()
	self.Completed = Signal.new()
	self._start = tonumber(start)
	self._finish = tonumber(finish)
	self._id = HttpService:GenerateGUID(false)
	self._lastCheck = 0
	self._elapsed = 0
	self._increment = increment or 1
	self._running = false
	self._maid = {}

	if typeof(self._start) ~= "number" or typeof(self._finish) ~= "number" then
		self:Destroy()
		assert(false, "Start or Finish has to be of type 'number'!")
	end

	-- Use Heartbeat in case user uses this on the server.
	table.insert(
		self._maid,
		RunService.Heartbeat:Connect(function()
			if not self._running then
				return
			end

			local now = DateTime.now().UnixTimestampMillis / 1000

			if self._lastCheck - now < 0 then
				self._lastCheck = now + self._increment
				self._elapsed += self._increment

				if math.abs(self._elapsed - self._finish) == math.abs(self._start) then
					self.Completed:Fire(self._elapsed, self._start)

					self._elapsed = 0
					self:Pause()
					return
				end

				self.Changed:Fire(self._elapsed)
			end
		end)
	)

	return self
end

--// Public Functions \\--
--[=[
    Starts the timer.
    
    @within Timer
    @since 1.0.0
]=]
--
function Class:Start()
	self._lastCheck = DateTime.now().UnixTimestampMillis + self._increment
	self._running = true
end

--[=[
    Pauses the timer.
    
    @within Timer
    @since 1.0.0
]=]
--
function Class:Pause()
	self._running = false
end

--[=[
    Resumes the timer.
    
    @within Timer
    @since 1.0.0
]=]
--
function Class:Resume()
	self:Start()
end

--[=[
    Cancels the timer.
    
    @within Timer
    @since 1.0.0
]=]
--
function Class:Cancel()
	self._running = false
	self:Destroy()
end

--[=[
    Destroys the timer class.
    @return nil
    
    @within Timer
    @since 1.0.0
]=]
--
function Class:Destroy()
	for _, v: RBXScriptConnection in pairs(self._maid) do
		v:Disconnect()
	end

	self.Changed:Destroy()
	self.Completed:Destroy()

	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

--// Return \--
return setmetatable(Timer, {
	__call = function(self, ...)
		return self.new(...)
	end,
})
