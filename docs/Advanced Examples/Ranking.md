---
sidebar_position: 1
---

<h3>Note: We do have our own custom admin built into the module, if you'd like to use it head to this page </h3>

<!-- <a href="/VibezAPI/docs/APIs/Commands/Adding Command">page</a> -->

These are more intermediate examples for the `Ranking` system, I'm expecting you to understand basic Lua syntax / concepts.

### Setting a rank using a custom admin
```lua
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Prefix = "!"
local Vibez = require(14946453963)("API Key"):waitUntilLoaded()

--// Functions \\--
local function findPlayers(Player: Player, Argument: string)
    local args = string.split(string.lower(tostring(Argument)), ",")
    local found = {}

    -- Loop the arguments to check specific cases
    for _, info in pairs(args) do
        local result = nil
        if info == "me" then
            result = Player
        elseif info == "all" then
            result = Players:GetPlayers()
        elseif info == "others" then
            result = Players:GetPlayers()
            table.remove(result, table.find(result, Player))
        else
            result = Players:FindFirstChild(info)
        end

        if typeof(result) == "Instance" then
            table.insert(found, result)
        elseif typeof(result) == "table" then
            table.insert(found, table.unpack(result))
        end
    end

    return found
end

local function onPlayerAdded(Player: Player)
    -- You can also put a permission check before setting up to handle commands.
    Player.Chatted:Connect(function(Message: string)
        -- Permission check
        -- Make your own permission system

        -- Can be as basic as a rank check or as complex as a custom permission system

        -- Prefix check
        if string.sub(string.lower(Message), 1, #Prefix) ~= Prefix then
            return
        end

        local command = string.split(string.lower(Message), " ")[1]
        local funcs = {
            ["promote"] = "Promote";
            ["demote"] = "Demote";
            ["fire"] = "Fire";
            ["setrank"] = "setRank";
        }

        local methodToUse = funcs[command]
        if not methodToUse then
            return
        end

        local users = findPlayers(Player, string.split(Message, " ")[2])
        for _, user in pairs(users) do
            -- Since we're using '[]' aka '.' notation, we need to pass the table as the first argument
            Vibez[methodToUse](Vibez, user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)
        end
    end)
end
```