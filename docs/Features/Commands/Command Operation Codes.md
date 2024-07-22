---
sidebar_position: 3
---

# Argument Prefixes

**Note: This is considered an advanced tutorial, if you don't understand lua/luau, I would not recommend attempting to create your own prefixes!**

### What are argument prefixes?
Argument prefixes are `shorteners` that allow you to use less characters when using commands. For example, instead of saying `game.Teams["myTeam"]` as a command argument, you can send `#myTeam`. Operation codes can be anything you'd like, as long as they don't conflict with any other operation codes. We'd also recommend not using `commas` as your operation code, as it will conflict with the existing argument separator.

---

### Default Codes
|       Name        | Prefix |                 Description                 |
|:-----------------:|:------:|:-------------------------------------------:|
|       Team        |   `%`  | Checks for a given team name                |
|       Rank        |  `r:`  | Checks the player's rank with a tolerance   |
| shortenedUsername |  None  | Checks for a portion of a player's username |
|     External      |  `e:`  | Gets a player that is not in the server     |
|      UserId       |  `id:` | Gets a player that is not in the server     |

---

### How do they work?
Argument prefixes work by first splitting the sent command, then checking if the first argument is an existing prefix. If it is, it will run the prefix's function and return the result. If it isn't, it will return the command argument as is.

---

### How to use
To create a new operation code, you'll use the `:addArgumentPrefix` method. This method takes **three arguments**: the operation name, the operation prefix, and the operation function. The operation function must return a `boolean` value, if it does not the operation will not work.

```lua
local VibezAPI = require(14946453963)("myApiKey")

VibezAPI:addArgumentPrefix("Rank", "r:", function(playerToCheck: Player, incomingArgument: string)
    -- Operation code is automatically removed from the 'incomingArgument'.
    -- incomeArgument would look something like this: "3:<="
    local rank, tolerance = table.unpack(string.split(incomingArgument, ":"))
    
    -- Make sure the rank is a number.
    if not tonumber(rank) then
        return false
    end

    -- Make sure the tolerance is a valid tolerance.
    tolerance = tolerance or "<="

    -- Convert 'rank' to a number.
    rank = tonumber(rank)

    -- 'GetRankInGroup' caches when it's first called, this will not update if their rank changes.
    local isOk, currentPlayerRank = pcall(
        playerToCheck.GetRankInGroup,
        playerToCheck,
        rank
    )
    
    -- Make sure the player is in the group and their rank was fetched.
    if not isOk or currentPlayerRank == 0 then
        return false
    end

    -- Check the tolerances
    if tolerance == "<=" then
        return currentPlayerRank <= rank
    elseif tolerance == ">=" then
        return currentPlayerRank >= rank
    elseif tolerance == "<" then
        return currentPlayerRank < rank
    elseif tolerance == ">" then
        return currentPlayerRank > rank
    elseif tolerance == "==" then
        return currentPlayerRank == rank
    end

    -- If the tolerance is invalid, return false.
    return false
end)
```

Now, you can use the operation code in your commands: `!promote r:3:<=`

---

### How to remove operation codes
To remove an operation code, you'll use the `:removeArgumentPrefix` method. This method takes **one argument**: the operation name. If you don't like how one operation code performs that was made by us, you can simply remove it.

```lua
VibezAPI:removeArgumentPrefix("Rank") -- Removes the default rank operation code.
```