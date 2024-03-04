-- local Table = require(script.Parent.Parent.Table)
local Types = require(script.Parent.Parent.Types)

return function(self: Types.vibezAPI)
	self:addCommand("ban", {}, function(Player: Player, Args: { string })
		local players = self:_getPlayers(Args[1])

		for _, user in pairs(players) do
			if user == Player then
				continue
			end

			self._private.commandStorage.Bans[user.Name] = user.UserId
		end
	end)

	self:addCommand("unban", {}, function(_: Player, Args: { string })
		local split = string.split(Args[1], ",")
		local unbanned = {}

		for _, userName in pairs(split) do
			for bannedUsername, bannedUserId in pairs(self._private.commandStorage.Bans) do
				if
					(tonumber(userName) ~= nil and tonumber(userName) == bannedUserId)
					or (
						tonumber(userName) == nil
						and string.sub(string.lower(bannedUsername), 1, #userName) == string.lower(userName)
					)
				then
					table.insert(unbanned, bannedUsername)
					self._private.commandStorage.Bans[bannedUsername] = nil
				end
			end
		end

		warn(unbanned)
		-- 'unbanned' has the users that were previously banned and are now unbanned.
	end)
end
