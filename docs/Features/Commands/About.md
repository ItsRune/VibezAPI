---
sidebar_position: 1
---

### Why did we make commands?
We made commands because we realized that maybe some developers aren't experienced enough to use the API, or they just want a simple way to use the API. Commands were the only way to make this possible. With our commands you can fully control the API while also being secure in doing so.

### How do commands work?
Our commands work by taking the prefix, first checking that it's correct and removing it from the entire command. Then it splits the command into pieces, leaving the command's name and arguments. It then checks if the command exists, and if it does, it runs the command with the arguments. If it doesn't, it will ignore the message and it's contents.

### Can I create my own commands?
Yes! You can create your own commands. Head over to the [Adding Commands](/VibezAPI/docs/Features/Commands/Adding%20Commands) page to learn how to create your own commands.

### Can I create my own shorteners?
Yes! You can create your own shorteners. Head over to the [Command Operation Codes](/VibezAPI/docs/Features/Commands/Command%20Operation%20Codes) page to learn how to create your own shorteners.

### Command Settings
```lua
Enabled = false,
useDefaultNames = true,

MinRank = 255,
MaxRank = 255,

Prefix = "!",
Alias = {},
```

### How can I use the module with another admin system?
We understand that many people use other admin systems that have much more complex features and would prefer to use that instead. Below we have listed a few examples of the top
admin systems and how you can use the module with them. Please make sure you are using the [Global API](/VibezAPI/docs/Features/Global) to use the module with these admin systems.

<details>
<summary>Basic Admin Essentials</summary>
<br />

<details>
<summary>All in one command</summary>
<br />

```lua
local Plugin = function(...)
	local Data = { ... }

	-- Included Functions and Info --
	local remoteEvent = Data[1][1]
	local remoteFunction = Data[1][2]
	local returnPermissions = Data[1][3]
	local Commands = Data[1][4]
	local Prefix = Data[1][5]
	local actionPrefix = Data[1][6]
	local returnPlayers = Data[1][7]
	local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
	-- Practical example, for a gui specifically for a player, from another player
	-- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
	-- Or for a broadcast (something everyone sees, from one person, to nobody specific)
	-- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast

	-- Plugin Configuration --
	local pluginName = 'rank'
	local pluginPrefix = Prefix
	local pluginLevel = 1
	local pluginUsage = "<Type> <User(s)>" -- leave blank if the command has no arguments
	local pluginDescription = "Promotes/Demotes/Sets a player's rank within the group."

	-- Example Plugin Function --
	local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
		local vibezApi = nil

		while vibezApi == nil do
			vibezApi = _G["VibezApi"]
			task.wait(.25)
		end

		local Sender = Args[1]
		local Type = Args[3]
		local Users = {{Name = Args[4], UserId = game.Players:GetUserIdFromNameAsync(Args[4])}}
		local succeeded, failed = {}, {}

		if string.sub(string.lower(Type), 1, 1) == "p" then
			Type = "Promote"
		elseif string.sub(string.lower(Type), 1, 1) == "d" then
			Type = "Demote"
		elseif string.sub(string.lower(Type), 1, 1) == "f" then
			Type = "Fire"
		elseif string.sub(string.lower(Type), 1, 1) == "s" then
			Type = "setRank"

			if not Args[5] then
				remoteEvent:FireClient(Sender, "Hint", "Error", "You need to specify a rank to set the user(s) to.")
				return
			end
		else
			remoteEvent:FireClient(Sender, "Hint", "Error", "Invalid ranking type. We expected 'Promote', 'Demote', 'Fire' or 'SetRank'.")
		end

		for _, User in pairs(Users) do
			local response = vibezApi.Ranking[Type]({}, User.UserId, Args[5])

			if response.success or response.Success then
				table.insert(succeeded, User.Name)
			else
				table.insert(failed, User.Name)
			end
		end

		local firstNames = (#succeeded > 0) and table.concat(succeeded, ", ", 1, math.clamp(#succeeded, 1, 3)) or ""
		local failedNames = (#failed > 0) and table.concat(failed, ", ", 1, math.clamp(#failed, 1, 3)) or ""
		local fixedString = {
			["Promote"] = "Promoted",
			["Demote"] = "Demoted",
			["Fire"] = "Fired",
			["setRank"] = "Set The Rank Of"
		}

		if #succeeded > 3 then
			firstNames ..= " (+" .. #succeeded - 3 .. " others)"
			remoteEvent:FireClient(
				Sender,
				"Hint",
				"Rank - " .. Type,
				string.format(
					"Successfully %s '%s' user(s)%s",
					fixedString[Type],
					firstNames,
					#failed > 0 and " and failed to " .. string.lower(Type) .. " " .. #failed .. " user(s)!" or ""
				)
			)
		elseif #succeeded <= 3 and #succeeded ~= 0 then
			remoteEvent:FireClient(
				Sender,
				"Hint",
				"Rank - " .. Type,
				"Successfully " .. string.lower(fixedString[Type]) .. " '" .. firstNames .. "'!"
			)
		elseif #failed > 0 then
			if #failed > 3 then
				failedNames ..= " (+" .. #failed - 3 .. " others)"
			end

			remoteEvent:FireClient(
				Sender,
				"Hint",
				"Rank - " .. Type,
				"Failed to " .. string.lower(fixedString[Type]) .. " '" .. failedNames .. "'!"
			)
		end
	end

	-- Return Everything to the MainModule --
	local descToReturn
	if pluginUsage ~= "" then
		descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
	else
		descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
	end

	return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin
```

</details>

<details>
<summary>Promote</summary>
<br />

```lua
local Plugin = function(...)
    local Data = { ... }

    -- Included Functions and Info --
    local remoteEvent = Data[1][1]
    local remoteFunction = Data[1][2]
    local returnPermissions = Data[1][3]
    local Commands = Data[1][4]
    local Prefix = Data[1][5]
    local actionPrefix = Data[1][6]
    local returnPlayers = Data[1][7]
    local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
    -- Practical example, for a gui specifically for a player, from another player
    -- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
    -- Or for a broadcast (something everyone sees, from one person, to nobody specific)
    -- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast

    -- Plugin Configuration --
    local pluginName = 'promote'
    local pluginPrefix = Prefix
    local pluginLevel = 1
    local pluginUsage = "<User(s)>" -- leave blank if the command has no arguments
    local pluginDescription = "Promotes a player's rank within the group."

    -- Example Plugin Function --
    local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
        local vibezApi = nil

        while vibezApi == nil do
            vibezApi = _G["VibezApi"]
            task.wait(.25)
        end

        local Sender = Args[1]
        local Users = returnPlayers(Sender, Args[3])
        local succeeded, failed = {}, {}

        if #Users == 0 then
            return remoteEvent:FireClient(Sender, "Hint", "Error", "No user(s) to promote!")
        end

        for _, User in pairs(Users) do
            local response = vibezApi.Ranking:Promote(User.UserId, {
                userName = Sender.Name,
                userId = Sender.UserId
            })

            if response.Success and response.Body and response.Body.success then
                table.insert(succeeded, User.Name)
            else
                table.insert(failed, User.Name)
            end
        end

        local firstNames = (#succeeded > 0) and table.concat(succeeded, ", ", 1, math.clamp(#succeeded, 1, 3)) or ""
		local failedNames = (#failed > 0) and table.concat(failed, ", ", 1, math.clamp(#failed, 1, 3)) or ""

        if #succeeded > 3 then
            firstNames ..= " (+" .. #succeeded - 3 .. " others)"
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Promotion",
                "Successfully promoted '" .. firstNames .. "' user(s)" .. (string.len(failed) > 0 and " and failed to promote " .. string.len(failed) .. " user(s)" or "")
            )
        elseif #succeeded <= 3 and #succeeded ~= 0 then
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Promotion",
                "Successfully promoted '" .. firstNames .. "'!"
            )
        elseif #failed > 0 then
            if #failed > 3 then
                failedNames ..= " (+" .. #failed - 3 .. " others)"
            end
        
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Promotion",
                "Failed to promote '" .. failedNames .. "'!"
            )
        end
    end

    -- Return Everything to the MainModule --
    local descToReturn
    if pluginUsage ~= "" then
        descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
    else
        descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
    end

    return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin
```

</details>

<details>
<summary>Demote</summary>
<br />

```lua
local Plugin = function(...)
    local Data = { ... }

    -- Included Functions and Info --
    local remoteEvent = Data[1][1]
    local remoteFunction = Data[1][2]
    local returnPermissions = Data[1][3]
    local Commands = Data[1][4]
    local Prefix = Data[1][5]
    local actionPrefix = Data[1][6]
    local returnPlayers = Data[1][7]
    local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
    -- Practical example, for a gui specifically for a player, from another player
    -- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
    -- Or for a broadcast (something everyone sees, from one person, to nobody specific)
    -- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast

    -- Plugin Configuration --
    local pluginName = 'demote'
    local pluginPrefix = Prefix
    local pluginLevel = 1
    local pluginUsage = "<User(s)>" -- leave blank if the command has no arguments
    local pluginDescription = "Demotes a player's rank within the group."

    -- Example Plugin Function --
    local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
        local vibezApi = nil

        while vibezApi == nil do
            vibezApi = _G["VibezApi"]
            task.wait(.25)
        end

        local Sender = Args[1]
        local Users = returnPlayers(Sender, Args[3])
        local succeeded, failed = {}, {}

        if #Users == 0 then
            return remoteEvent:FireClient(Sender, "Hint", "Error", "No user(s) to demote!")
        end

        for _, User in pairs(Users) do
            local response = vibezApi.Ranking:Demote(User.UserId, {
                userName = Sender.Name,
                userId = Sender.UserId
            })

            if response.success or response.Success then
                table.insert(succeeded, User.Name)
            else
                table.insert(failed, User.Name)
            end
        end

        local firstNames = (#succeeded > 0) and table.concat(succeeded, ", ", 1, math.clamp(#succeeded, 1, 3)) or ""
		local failedNames = (#failed > 0) and table.concat(failed, ", ", 1, math.clamp(#failed, 1, 3)) or ""

        if #succeeded > 3 then
            firstNames ..= " (+" .. #succeeded - 3 .. " others)"
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Demotion",
                "Successfully demoted '" .. firstNames .. "' user(s)" .. (string.len(failed) > 0 and " and failed to demote " .. string.len(failed) .. " user(s)" or "")
            )
        elseif #succeeded <= 3 and #succeeded ~= 0 then
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Demotion",
                "Successfully demoted '" .. firstNames .. "'!"
            )
        elseif #failed > 0 then
            if #failed > 3 then
                failedNames ..= " (+" .. #failed - 3 .. " others)"
            end
        
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Demotion",
                "Failed to demote '" .. failedNames .. "'!"
            )
        end
    end

    -- Return Everything to the MainModule --
    local descToReturn
    if pluginUsage ~= "" then
        descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
    else
        descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
    end

    return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin
```

</details>

<details>
<summary>Fire</summary>
<br />

```lua
local Plugin = function(...)
    local Data = { ... }

    -- Included Functions and Info --
    local remoteEvent = Data[1][1]
    local remoteFunction = Data[1][2]
    local returnPermissions = Data[1][3]
    local Commands = Data[1][4]
    local Prefix = Data[1][5]
    local actionPrefix = Data[1][6]
    local returnPlayers = Data[1][7]
    local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
    -- Practical example, for a gui specifically for a player, from another player
    -- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
    -- Or for a broadcast (something everyone sees, from one person, to nobody specific)
    -- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast

    -- Plugin Configuration --
    local pluginName = 'fire'
    local pluginPrefix = Prefix
    local pluginLevel = 1
    local pluginUsage = "<User(s)>" -- leave blank if the command has no arguments
    local pluginDescription = "Fires a player the group."

    -- Example Plugin Function --
    local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
        local vibezApi = nil

        while vibezApi == nil do
            vibezApi = _G["VibezApi"]
            task.wait(.25)
        end
        
        local Sender = Args[1]
        local Users = returnPlayers(Sender, Args[3])
        local succeeded, failed = {}, {}

        if #Users == 0 then
            return remoteEvent:FireClient(Sender, "Hint", "Error", "No user(s) to fire!")
        end

        for _, User in pairs(Users) do
            local response = vibezApi.Ranking:Fire(User.UserId, {
                userName = Sender.Name,
                userId = Sender.UserId
            })

            if response.success or response.Success then
                table.insert(succeeded, User.Name)
            else
                table.insert(failed, User.Name)
            end
        end

        local firstNames = (#succeeded > 0) and table.concat(succeeded, ", ", 1, math.clamp(#succeeded, 1, 3)) or ""
		local failedNames = (#failed > 0) and table.concat(failed, ", ", 1, math.clamp(#failed, 1, 3)) or ""

        if #succeeded > 3 then
            firstNames ..= " (+" .. #succeeded - 3 .. " others)"
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Fire",
                "Successfully fired '" .. firstNames .. "' user(s)" .. (string.len(failed) > 0 and " and failed to fire " .. string.len(failed) .. " user(s)" or "")
            )
        elseif #succeeded <= 3 and #succeeded ~= 0 then
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Fire",
                "Successfully fired '" .. firstNames .. "'!"
            )
        elseif #failed > 0 then
            if #failed > 3 then
                failedNames ..= " (+" .. #failed - 3 .. " others)"
            end
        
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "Fire",
                "Failed to fire '" .. failedNames .. "'!"
            )
        end
    end

    -- Return Everything to the MainModule --
    local descToReturn
    if pluginUsage ~= "" then
        descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
    else
        descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
    end

    return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin
```

</details>

<details>
<summary>SetRank</summary>
<br />

```lua
local Plugin = function(...)
    local Data = { ... }

    -- Included Functions and Info --
    local remoteEvent = Data[1][1]
    local remoteFunction = Data[1][2]
    local returnPermissions = Data[1][3]
    local Commands = Data[1][4]
    local Prefix = Data[1][5]
    local actionPrefix = Data[1][6]
    local returnPlayers = Data[1][7]
    local cleanData = Data[1][8] -- cleanData(Sender,Receiver,Data)
    -- Practical example, for a gui specifically for a player, from another player
    -- cleanData(Sender,Receiver,"hi") -- You need receiver because it's being sent to everyone
    -- Or for a broadcast (something everyone sees, from one person, to nobody specific)
    -- cleanData(Sender,nil,"hi") -- Receiver is nil because it is a broadcast

    -- Plugin Configuration --
    local pluginName = 'setrank'
    local pluginPrefix = Prefix
    local pluginLevel = 1
    local pluginUsage = "<User(s)> <NewRank>" -- leave blank if the command has no arguments
    local pluginDescription = "Sets the rank of a player within the group."

    -- Example Plugin Function --
    local function pluginFunction(Args) -- keep the name of the function as "pluginFunction"
        local vibezApi = nil

        while vibezApi == nil do
            vibezApi = _G["VibezApi"]
            task.wait(.25)
        end

        local Sender = Args[1]
        local Users = returnPlayers(Sender, Args[3])
        local succeeded, failed = {}, {}

        if #Users == 0 then
            return remoteEvent:FireClient(Sender, "Hint", "Error", "No user(s) to fire!")
        elseif tonumber(Args[4]) == nil then
            return remoteEvent:FireClient(Sender, "Hint", "Error", "'Rank' has to be of type 'number', NOT '" .. typeof(Args[4]) .. "'!")
        end

        for _, User in pairs(Users) do
            local response = vibezApi.Ranking:setRank(User.UserId, tonumber(Args[4]), {
                userName = Sender.Name,
                userId = Sender.UserId
            })

            if response.success or response.Success then
                table.insert(succeeded, User.Name)
            else
                table.insert(failed, User.Name)
            end
        end

        local firstNames = (#succeeded > 0) and table.concat(succeeded, ", ", 1, math.clamp(#succeeded, 1, 3)) or ""
		local failedNames = (#failed > 0) and table.concat(failed, ", ", 1, math.clamp(#failed, 1, 3)) or ""

        if #succeeded > 3 then
            firstNames ..= " (+" .. #succeeded - 3 .. " others)"
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "SetRank",
                "Successfully set the rank of '" .. firstNames .. "' user(s)" .. (string.len(failed) > 0 and " and failed to fire " .. string.len(failed) .. " user(s)" or "")
            )
        elseif #succeeded <= 3 and #succeeded ~= 0 then
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "SetRank",
                "Successfully set the rank of '" .. firstNames .. "'!"
            )
        elseif #failed > 0 then
            if #failed > 3 then
                failedNames ..= " (+" .. #failed - 3 .. " others)"
            end
        
            remoteEvent:FireClient(
                Sender,
                "Hint",
                "SetRank",
                "Failed to set the rank of '" .. failedNames .. "'!"
            )
        end
    end

    -- Return Everything to the MainModule --
    local descToReturn
    if pluginUsage ~= "" then
        descToReturn = pluginPrefix..pluginName..' '..pluginUsage..'\n'..pluginDescription
    else
        descToReturn = pluginPrefix..pluginName..'\n'..pluginDescription
    end

    return pluginName,pluginFunction,pluginLevel,pluginPrefix,{pluginName,pluginUsage,pluginDescription}
end

return Plugin
```

</details>

</details>

<details>
<summary>Adonis (Untested)</summary>
<br />

```lua
return function(Vargs)
	local server = Vargs.Server
	local service = Vargs.Service

        --// Add a new command to the Commands table at index "ExampleCommand1"
	server.Commands.Promote = {						--// The index & table of the command
		Prefix = server.Settings.Prefix;					--// The prefix the command will use, this is the ':' in ':ff me'
		Commands = {"Promote"};	--// A table containing the command strings (the things you chat in-game to run the command, the 'ff' in ':ff me')
		Args = {"playerToPromote"};						--// Command arguments, these will be available in order as args[1], args[2], args[3], etc; This is the 'me' in ':ff me'
		Description = "Promotes the rank of a player.";					--// The description of the command
		AdminLevel = 100; -- Moderators						--// The command's minimum admin level; This can also be a table containing specific levels rather than a minimum level: {124, 152, "HeadAdmins", etc};
		--// Alternative option: AdminLevel = "Moderators";
		Filter = true;								--// Should user supplied text passed to this command be filtered automatically? Use this if you plan to display a user-defined message to other players
		Fun = false;								--// Is this command considered as fun?
		Hidden = false;								--// Should this command be hidden from the command list?
		Disabled = false;							--// Should this command be unusable?
		NoStudio = false;							--// Should this command be blocked from being executed in a Studio environment?
		NonChattable = false;							--// Should this command be blocked from being executed via chat?
		CrossServerDenied = false;						--// If true, this command will not be usable via :crossserver
		Function = function(plr: Player, args: {string}, data: {})		--// The command's function; This is the actual code of the command which runs when you run the command
			--// "plr" is the player running the command
			--// "args" is a table containing command arguments supplied by the user
			--// "data" is a table containing information related to the command and the player running it, such as data.PlayerData.Level (the player's admin level)
			local vibezApi = nil

            while vibezApi == nil do
                vibezApi = _G["VibezApi"]
                task.wait(.25)
            end

            vibezApi.Ranking:Promote(args[1], { userName = plr.Name, userId = plr.UserId })
		end
	}

    server.Commands.Demote = {						--// The index & table of the command
		Prefix = server.Settings.Prefix;					--// The prefix the command will use, this is the ':' in ':ff me'
		Commands = {"Demote"};	--// A table containing the command strings (the things you chat in-game to run the command, the 'ff' in ':ff me')
		Args = {"playerToDemote"};						--// Command arguments, these will be available in order as args[1], args[2], args[3], etc; This is the 'me' in ':ff me'
		Description = "Demotes the rank of a player.";					--// The description of the command
		AdminLevel = 100; -- Moderators						--// The command's minimum admin level; This can also be a table containing specific levels rather than a minimum level: {124, 152, "HeadAdmins", etc};
		--// Alternative option: AdminLevel = "Moderators";
		Filter = true;								--// Should user supplied text passed to this command be filtered automatically? Use this if you plan to display a user-defined message to other players
		Fun = false;								--// Is this command considered as fun?
		Hidden = false;								--// Should this command be hidden from the command list?
		Disabled = false;							--// Should this command be unusable?
		NoStudio = false;							--// Should this command be blocked from being executed in a Studio environment?
		NonChattable = false;							--// Should this command be blocked from being executed via chat?
		CrossServerDenied = false;						--// If true, this command will not be usable via :crossserver
		Function = function(plr: Player, args: {string}, data: {})		--// The command's function; This is the actual code of the command which runs when you run the command
			local vibezApi = nil

            while vibezApi == nil do
                vibezApi = _G["VibezApi"]
                task.wait(.25)
            end

            vibezApi.Ranking:Demote(args[1], { userName = plr.Name, userId = plr.UserId })
		end
	}

    server.Commands.setRank = {						--// The index & table of the command
		Prefix = server.Settings.Prefix;					--// The prefix the command will use, this is the ':' in ':ff me'
		Commands = {"setRank"};	--// A table containing the command strings (the things you chat in-game to run the command, the 'ff' in ':ff me')
		Args = {"playerToSetRank", "newRank"};						--// Command arguments, these will be available in order as args[1], args[2], args[3], etc; This is the 'me' in ':ff me'
		Description = "Sets the rank of a player.";					--// The description of the command
		AdminLevel = 100; -- Moderators						--// The command's minimum admin level; This can also be a table containing specific levels rather than a minimum level: {124, 152, "HeadAdmins", etc};
		--// Alternative option: AdminLevel = "Moderators";
		Filter = true;								--// Should user supplied text passed to this command be filtered automatically? Use this if you plan to display a user-defined message to other players
		Fun = false;								--// Is this command considered as fun?
		Hidden = false;								--// Should this command be hidden from the command list?
		Disabled = false;							--// Should this command be unusable?
		NoStudio = false;							--// Should this command be blocked from being executed in a Studio environment?
		NonChattable = false;							--// Should this command be blocked from being executed via chat?
		CrossServerDenied = false;						--// If true, this command will not be usable via :crossserver
		Function = function(plr: Player, args: {string}, data: {})		--// The command's function; This is the actual code of the command which runs when you run the command
			local vibezApi = nil

            while vibezApi == nil do
                vibezApi = _G["VibezApi"]
                task.wait(.25)
            end

            vibezApi.Ranking:SetRank(args[1], args[2], { userName = plr.Name, userId = plr.UserId })
		end
	}
end
```

</details>