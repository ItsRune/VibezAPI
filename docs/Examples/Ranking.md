---
sidebar-position: 10
---

## Implementing in-game services
> In game services include ranking commands, ranking UI and the activity tracker.
1. Create a new script in "ServerScriptServices" called "VibezServices"
2. Insert the below code into the script
3. Adjust the settings based on your needs

# The script
```lua
local myKey = "YOUR_API_KEY_HERE"
local VibezRankingAPI = require(14946453963)
local Wrapper = VibezRankingAPI(myKey, {
    -- Activity
    activityTrackingEnabled = true;
    toggleTrackingOfAFKActivity = false;
    rankToStartTrackingActivityFor = 220;

    -- UI OR Commands
    isChatCommandsEnabled = true;
    isUIEnabled = true;

    minRankToUseCommandsAndUI = 255;
    maxRankToUseCommandsAndUI = 255;

    -- Commands Only
    commandPrefix = "!";

    -- Utility
    overrideGroupCheckForStudio = true;
    ignoreWarnings = false;
    nameOfGameForLogging = "Main Game";
})
```

### SetRank
```lua
local Vibez = require(14946453963)("API Key")

local function gradePlayerApplication(Player: Player, application: {any})
    local score = 0

    -- Computation for score

    if score >= application.minScore then
        Vibez:SetRank(Player.UserId, application.Rank)
    end
end
```

### Promotions/Demotions/Firing Staff
```lua
local Vibez = require(14946453963)("API Key")

local function promotePlayer(Player: Player)
    Vibez:Promote(Player.UserId)
end

local function demotePlayer(Player: Player)
    Vibez:Demote(Player.UserId)
end

local function firePlayer(Player: Player)
    Vibez:Fire(Player.UserId)
end
```

### Setting a rank using a custom admin
```lua
--// Services \\--
local Players = game:GetService("Players")

--// Variables \\--
local Prefix = "!"
local Vibez = require(14946453963)("API Key")

--// Functions \\--
local function findPlayers(Player: Player, Argument: string)
    local args = string.split(string.lower(tostring(Argument)), ",")
    local found = {}

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
    Player.Chatted:Connect(function(Message: string)
        -- Permission check
        -- Make your own permission system

        -- Prefix check
        if string.sub(string.lower(Message), 1, #Prefix) ~= Prefix then
            return
        end

        local command = string.split(string.lower(Message), " ")[1]

        -- Inefficient, but it works
        if command == "promote" then
            local users = findPlayers(Player, string.split(Message, " ")[2])

            for _, user in pairs(users) do
                Vibez:PromoteWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)
            end
        elseif command == "demote" then
            local users = findPlayers(Player, string.split(Message, " ")[2])

            for _, user in pairs(users) do
                Vibez:DemoteWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)
            end
        elseif command == "fire" then
            local users = findPlayers(Player, string.split(Message, " ")[2])

            for _, user in pairs(users) do
                Vibez:FireWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)
            end
        elseif command == "setrank" then
            local users = findPlayers(Player, string.split(Message, " ")[2])

            for _, user in pairs(users) do
                Vibez:SetRankWithCaller(user.UserId, tonumber(string.split(Message, " ")[2]), Player.UserId, Player.Name)
            end
        end
    end)
end
```