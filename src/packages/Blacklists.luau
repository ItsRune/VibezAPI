--[=[
    @class Blacklists
]=]

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
function Env:Add(
	User: Types.UserKind,
	Reason: string?,
	blacklistExecutedBy: (Player | string | number)?
): (boolean, string)
	local userId = self.base.Utils:verifyUser(User, "Id")
	local realReason = not Reason and "Unknown." or Reason
	local blacklistedBy = blacklistExecutedBy and self.base.Utils:verifyUser(blacklistExecutedBy, "Id") or "System"

	if not userId then
		return false, "Invalid User was supplied."
	end

	local response = self.base.Utils:Http({
		Url = "/blacklists/" .. userId,
		Method = "Put",
		Body = {
			reason = realReason,
			blacklistedBy = blacklistedBy,
		},
	})

	return response.Body.Success, response.Body.message
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
		Url = "/blacklists/" .. userId,
		Method = "Delete",
	})

	return response.Body.Success, response.Body.message
end

return function(parent: Types.VibezLightWeight): Types.VibezBlacklistsPackage
	return setmetatable({
		base = parent,
	}, Env) :: Types.VibezBlacklistsPackage
end
