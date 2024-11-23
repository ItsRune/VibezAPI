--!strict
--[=[
    @class Blacklists
]=]

local BLACKLIST_REFRESH_RATE = 45 -- Seconds
local Cache = require(script.Parent.Parent.classes.Cache)
local Types = require(script.Parent.Parent.Types)
local Env = {}
Env.__index = Env

--[=[
	Adds a user to the blacklist.

	```lua
	local isOk, message = Vibez.Blacklists:Add("roblox", "Some kind of reason...", "ltsRune")
	```

	@within Blacklists
]=]
function Env:Add(User: Types.UserKind, Reason: string?, blacklistExecutedBy: Types.UserKind?): (boolean, string)
	local userId = self.base.Utils:verifyUser(User, "Id")
	local realReason = not Reason and "Unknown." or Reason
	local blacklistedBy = blacklistExecutedBy and self.base.Utils:verifyUser(blacklistExecutedBy, "Id") or "System"

	if not userId then
		return false, "Invalid User was supplied."
	end

	local response = self.base.Utils:Http({
		Url = "/blacklists/" .. tostring(userId),
		Method = "Put",
		Body = {
			reason = realReason,
			blacklistedBy = blacklistedBy,
		},
	})

	if response.Success then
		self.Cache:Add(userId, {
			Data = {
				Blacklisted = true,
				Reason = realReason,
				blacklistedBy = blacklistedBy,
			},
			Refresh = DateTime.now().UnixTimestamp,
		})
	end

	return response.Success, response.Body.message
end

--[=[
	Deletes an existing blacklist.

	```lua
	local isOk, message = Vibez.Blacklists:Delete("roblox")
	```

	@within Blacklists
]=]
function Env:Delete(userToDelete: Types.UserKind): (boolean, string)
	local userId = self.base.Utils:verifyUser(userToDelete, "Id")
	local response = self.base.Utils:Http({
		Url = "/blacklists/" .. tostring(userId),
		Method = "Delete",
	})

	if response.Success and self.Cache:Has(userId) then
		self.Cache:Remove(userId)
	end

	return response.Success, response.Body.message
end

--[=[
	Returns information on whether a User is blacklisted.
	@param User Player | string | number
	@return { Blacklisted: boolean, Reason: string, blacklistedBy: { userName: string, userId: number } }?
	@within Blacklists
]=]
function Env:Get(
	User: Types.UserKind
): { Blacklisted: boolean, Reason: string, blacklistedBy: { userName: string, userId: number } }?
	local userId = self.base.Utils:verifyUser(User)
	assert(userId, "User parameter is not supplied correctly.")

	if self.Cache:Has(userId) then
		return self.Cache:Get(userId)
	end

	local response = self.base.Utils:Http({
		Url = "/blacklists/" .. tostring(userId),
		Method = "Get",
	})

	if response.Success then
		local data = {
			Blacklisted = response.Body.data.blacklisted,
			Reason = response.Body.data.reason,
			blacklistedBy = response.Body.data.blacklistedBy,
		}

		self.Cache:Add(userId, data)
		return data
	end

	return nil
end

return function(parent: Types.VibezLightWeight): Types.VibezBlacklistsPackage
	return setmetatable({
		base = parent,
		Cache = Cache.new(),
	}, Env :: any) :: Types.VibezBlacklistsPackage
end
