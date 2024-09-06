local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local runningTweens = {}
local Class = {}
Class.__index = Class

--// Types \\--
export type tweenService = {
	_id: string,
	_instance: Instance,
	_dontCare: boolean,
	_tween: Tween,
	_callback: (state: Enum.PlaybackState?) -> (),
	_completedCallback: () -> (),
	_connection: RBXScriptConnection?,

	Play: (self: tweenService) -> tweenService,
	Cancel: (self: tweenService) -> tweenService,
	Pause: (self: tweenService) -> tweenService,
	setCallback: (self: tweenService, callback: (state: Enum.PlaybackState?) -> ()) -> tweenService,
	onCompleted: (self: tweenService, callback: () -> ()) -> tweenService,
	Destroy: (self: tweenService) -> (),
}

local function Constructor(Inst: Instance, tweenInfo: TweenInfo, propertyTable: { [any]: any }): tweenService
	local self = setmetatable({}, Class) :: any

	self._id = HttpService:GenerateGUID(false)
	self._instance = Inst
	self._dontCare = propertyTable["ignoreCaching"] or false

	propertyTable["ignoreCaching"] = nil

	self._tween = TweenService:Create(Inst, tweenInfo, propertyTable)
	self._callback = function(state: Enum.PlaybackState?) end
	self._completedCallback = function() end
	self._connection = self._tween.Completed:Connect(function(playBackState)
		if playBackState == Enum.PlaybackState.Completed then
			runningTweens[self._instance] = nil
			self._completedCallback()
		end

		return self._callback(playBackState)
	end)

	return self
end

-- Plays the tween and caches it.
function Class:Play(): tweenService
	self:Pause()
	self._tween:Play()

	if not self._dontCare then
		runningTweens[self._instance] = self
	end

	return self
end

-- Pauses the tween and removes it from cache.
function Class:Pause(): tweenService
	local exist = runningTweens[self._instance]

	if exist == nil or exist._id == self._id then
		self._tween:Pause()
		runningTweens[self._instance] = nil
		return self
	end

	exist:Pause()
	exist:Destroy()

	--if runningTweens[self._instance] ~= nil then
	--	runningTweens[self._instance]._tween:Pause()
	--	runningTweens[self._instance] = nil
	--end
	return self
end

function Class:onCompleted(callback: () -> ()): tweenService
	self._completedCallback = callback
	return self
end

-- Overwrites the callback function when completed.
function Class:setCallback(Func: (playbackState: Enum.PlaybackState) -> ()): any
	assert(typeof(Func) == "function", "'Func' can only be a function!")
	self._callback = Func
	return self
end

-- Destroys the class.
function Class:Destroy()
	self._destroyed = true
	self._tween:Destroy()
	self._connection:Disconnect()

	setmetatable(self, nil)
	table.clear(self :: any)
end

-- Cancels the tween and removes from cache.
function Class:Cancel()
	self._tween:Cancel()
end

return Constructor
