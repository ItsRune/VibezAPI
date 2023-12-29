---
sidebar_position: 1
---

Do our commands not fit your purpose? Well, luckily for you we made this simple to use method that allows you to create your own commands. This method is called `:addCommand`. This method takes **two arguments**: the command name and the command function.

```lua
local VibezAPI = require(14946453963)("myApiKey")

VibezAPI:addCommand("myCommand", function(player: Player, commandArguments: {string})
    -- "player" is the Player who ran the command
    -- "commandArguments" are the extra arguments sent with the command
    warn(player.Name .. " ran the command with the arguments: " .. table.concat(commandArguments, ", "))
end)
```

Now, you can use the command in-game: `!myCommand`... But this command isn't really useful. let's make some changes and use a private method to get the player from the command arguments. The private method we'll be using is `:_getPlayers`. This method takes **two arguments**: the player who ran the command and the command arguments. This method will return a table of players who were found from the command arguments. If no players were found, it will return an empty table.

On a side note, I can't stress this enough. There are many things in the API that are **marked** private, and you **shouldn't** use them. If you do, we are not to blame for anything you accidentally break/leak. If you do want insights on how to use private methods, you can see all private methods when on the API page by clicking the "Show Private" button. Anything starting with an "_" is a private method/variable.

```lua
local VibezAPI = require(14946453963)("myApiKey")

VibezAPI:addCommand("myCommand", function(player: Player, commandArguments: {string})
    -- "player" is the Player who ran the command
    -- "commandArguments" are the extra arguments sent with the command
    if #commandArguments == 0 then
        -- Returning will stop the rest of the function from running.
        return
    end
    
    -- If you want to get players from the command arguments, the method is technically
    -- private, but you can still use it. It's called ":_getPlayers". This method will
    -- use the existing command operations to get players from the command arguments.
    -- example:
    -- local playersFromArgs = VibezAPI:_getPlayers(player, commandArguments)
    
    local users = VibezAPI:_getPlayers(player, commandArguments)

    -- Always check if the user exists before doing anything with it.
    if not users or not users[1] then
        return
    end

    local userActivity = VibezAPI:getActivity(users[1])
    warn(userActivity)
end)
```

Okay, `!myCommand` now gets any player who's in game's activity and warns it into the output... That's not really useful, but it's a start.