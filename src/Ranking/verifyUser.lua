local Players = game:GetService("Players")

local function getNameById(userId: number): string
	if typeof(userId) == "string" and tonumber(userId) == nil then
		return userId
	end

	local isOk, userName = pcall(Players.GetNameFromUserIdAsync, Players, tonumber(userId))
	return isOk and userName or "Unknown"
end

local function getUserIdByName(username: string): number
	local isOk, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
	return isOk and userId or -1
end

function verifyUser(User: Player | number | string, typeToReturn: "UserId" | "Player" | "Name")
	if typeof(User) == "Instance" and User:IsA("Player") then
		return (typeToReturn == "UserId") and User.UserId
			or (typeToReturn == "string") and User.Name
			or (typeToReturn == "Player") and User
	elseif typeof(User) == "string" then
		return (typeToReturn == "UserId") and (tonumber(User) or getUserIdByName(User))
			or (typeToReturn == "Player") and Players:FindFirstChild(tostring(User))
			or (typeToReturn == "Name") and User
	elseif typeof(User) == "number" then
		return (typeToReturn == "UserId") and User
			or (typeToReturn == "Player") and Players:GetPlayerByUserId(User)
			or (typeToReturn == "Name") and getNameById(User)
	end

	return User
end

return verifyUser
