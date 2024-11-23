--!strict
--[=[
    @class Cache
    @ignore
]=]

local Cache = {}
local Class = {}

Class.__index = Class

--// Types \\--
export type T_CacheContent<T> = {
	_data: { [any]: T },
	_sortMethod: (a: T, b: T) -> boolean,
}

export type T_CacheMetatable<T> = {
	__index: T_CacheMetatable<T>,
	Add: (self: T_Cache<T>, key: any, value: any) -> T_Cache<T>,
	Remove: (self: T_Cache<T>, key: any) -> T,
	Get: (self: T_Cache<T>, key: any) -> T,
	_attemptSort: (self: T_Cache<T>) -> (),
}

export type T_Cache<T> = typeof(setmetatable({} :: T_CacheContent<T>, {} :: T_CacheMetatable<T>))

--// Public Methods \\--
--[=[
    Creates a new cache.
    @return Cache
    @within Cache
]=]
function Cache.new<T>(sortingCallback: ((a: T, b: T) -> boolean)?): T_Cache<T>
	if typeof(sortingCallback) ~= "function" then
		sortingCallback = function(a, b)
			if typeof(a) == "table" or typeof(b) == "table" then
				return false
			end

			local aStr, bStr = tostring(a), tostring(b)
			return string.byte(string.sub(aStr, 1, 1)) < string.byte(string.sub(bStr, 1, 1))
		end
	end

	return setmetatable({
		_data = {},
		_sortMethod = sortingCallback :: (a: T, b: T) -> boolean,
	}, Class) :: T_Cache<T>
end

--[=[
    Creates a new cache from existing data.
    @param ... ...any
    @return Cache
    @within Cache
]=]
function Cache.from<T>(...: T): T_Cache<T>
	local newCache = Cache.new()

	for k, v in { ... } do
		newCache:Add(k, v)
	end

	return newCache
end

--// Private Methods \\--
--[=[
    Adds a new key to the cache, will error if key already exists.
    @param key any
    @param value T
    @return Cache<T>
    @within Cache
]=]
function Class:Add<T>(key: any, value: T): T_Cache<T>
	self._data[key] = value
	self:_attemptSort()
	return self
end

--[=[
    Removes an existing key from the cache.
    @param key any
    @return T
    @within Cache
]=]
function Class:Remove<T>(key: any): T
	local data = self._data[key]

	self[key] = nil
	self:_attemptSort()

	return data
end

--[=[
    Fetches a key from the cache.
    @param key any
    @return T
    @within Cache
]=]
function Class:Get<T>(key: any): T
	return self._data[key]
end

--[=[
    Attempts to sort the data with the sorting method.
    @private
    @within Cache
]=]
function Class:_attemptSort<T>(): ()
	for i, _ in self._data do
		if typeof(i) ~= "number" then
			return -- Don't sort
		end
	end

	table.sort(self._data, self._sortingMethod)
end

--[=[
	Checks whether the cache has an existing key.
	@param key any
	@within Cache
]=]
function Class:Has<T>(key: any): boolean
	return self[key] ~= nil
end

return Cache
