--!strict
local Cooldowns = { _cache = {} }
local Class = {}

Class.__index = Class

type Public = { _user: Player, _tick: number, _waitTime: number, checkResult: number }
type Private = typeof(Class)
export type CooldownsKind = typeof(setmetatable({} :: Public, {} :: Private))

function Cooldowns.new(User: Player, seconds: number?): CooldownsKind
	if Cooldowns._cache[User] then
		return Cooldowns._cache[User]
	end

	local self = setmetatable({}, Class)

	self._user = User
	self._tick = 0
	self._waitTime = seconds or 60
	self.checkResult = 0

	Cooldowns._cache[User] = self
	return self
end

function Cooldowns.Get(User: Player, ...: any): CooldownsKind
	return Cooldowns._cache[User] or Cooldowns.new(User, ...)
end

function Class.Check(self: CooldownsKind)
	local now = DateTime.now().UnixTimestampMillis
	local checkRes = now - self._tick

	self.checkResult = checkRes
	return checkRes > self._waitTime
end

function Class.Update(self: CooldownsKind): ()
	local now = DateTime.now().UnixTimestampMillis
	self._tick = now
end

function Class.Destroy(self: CooldownsKind): ()
	Cooldowns._cache[self._user] = nil
	table.clear(self :: any)
	setmetatable(self :: any, nil)
	self = nil :: any
end

return Cooldowns
