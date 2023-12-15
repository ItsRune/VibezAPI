---
sidebar_position: 3
---

**Note: This is considered an advanced tutorial, if you don't understand lua/luau, I would not recommend attempting to create your own operations!**

### What are command operation codes?
Command operation codes are `shorteners` that allow you to use less characters when sending commands to the API. For example, instead of saying `game.Teams["myTeam"]` as a command argument, you can send `#myTeam`. Operation codes can be anything you'd like, as long as they don't conflict with any other operation codes. We'd also recommend not using `commas` as your operation code, as it will conflict with the command argument separator.

---

### How do they work?
Command operations work by first splitting the sent command, then checking if the first argument is an operation code. If it is, it will run the operation code function and return the result. If it isn't, it will return the command argument as is. For example, if you sent `#myTeam` as a command argument, it would split the command into `#` and `myTeam`. It would then check if `#` is an operation code, and if it is, it will run the operation code function and return the result. If it isn't, it will return the command argument as is.

---

### How to use
To create a new operation code, you'll use the `:addCommandOperation` method. This method takes **three arguments**: the operation name, the operation code, and the operation function. The operation function must return a `boolean` value, if it does not the operation will not work.

```lua
local VibezAPI = require(14946453963)("myApiKey")

VibezAPI:addCommandOperation("Rank", "r:", function(playerToCheck: Player, incomingArgument: string)
    -- Operation code is automatically removed from the 'incomingArgument'.
    local rank, tolerance = table.unpack(string.split(incomingArgument, ":"))
    
    -- Make sure the rank is a number.
    if not tonumber(rank) then
        return false
    end

    -- Make sure the tolerance is a valid tolerance.
    tolerance = tolerance or "<="

    local isOk, currentPlayerRank = pcall(
        playerToCheck.GetRankInGroup,
        playerToCheck,
        tonumber(rank)
    )
    
    -- Make sure the player is in the group and their rank was fetched.
    if not isOk or currentPlayerRank == 0 then
        return false
    end

    -- Check the tolerances
    if tolerance == "<=" then
        return currentPlayerRank <= tonumber(rank)
    elseif tolerance == ">=" then
        return currentPlayerRank >= tonumber(rank)
    elseif tolerance == "<" then
        return currentPlayerRank < tonumber(rank)
    elseif tolerance == ">" then
        return currentPlayerRank > tonumber(rank)
    elseif tolerance == "==" then
        return currentPlayerRank == tonumber(rank)
    end

    -- If the tolerance is invalid, return false.
    return false
end)
```

Now, you can use the operation code in your commands: `!promote r:3:<=`

---

### How to remove operation codes
To remove an operation code, you'll use the `:removeCommandOperation` method. This method takes **one argument**: the operation name. If you don't like how one operation code performs that was made by us, you can simply remove it. The default operation codes are:

|       Name        | Code |                 Description                 |
|:-----------------:|:----:|:--------------------------------------------|
|       Team        | `%`  | Checks for a given team name                |
|       Rank        | `r:` | Checks the player's rank with a tolerance   |
| shortenedUsername | None | Checks for a portion of a player's username |

```lua
VibezAPI:removeCommandOperation("Rank") -- Removes the default rank operation code.
```