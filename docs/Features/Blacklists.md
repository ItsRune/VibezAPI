---
sidebar_position: 5
---

## What does blacklisting do?
Blacklisting a user will prevent them from doing anything that uses your API key. This includes the usage of our application center and ranking center. This is useful in case you have a user that is causing havoc in your games. Think of this as a ban system attached to your API key.

## Usage
### [addBlacklist](/Vibez/api/Vibez#addBlacklist)
Adds a new blacklist.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to blacklist. <br />
``reason: string?`` - The reason for blacklisting the user. **OPTIONAL**<br />
``blacklistedBy: number?`` - The user id of the person who blacklisted the user. **OPTIONAL**<br />

Returns: [blacklistResponse](/Vibez/api/Vibez#blacklistResponse)
```lua
local userId = 107392833
local reason = "Spamming the group wall."
local userWhoBlacklisted = 1 -- ROBLOX
Vibez:addBlacklist(userId, userWhoBlacklisted)
```

### [deleteBlacklist](/Vibez/api/Vibez#deleteBlacklist)
Removes a blacklist.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to remove the blacklist of. <br />

Returns: [blacklistResponse](/Vibez/api/Vibez#blacklistResponse)
```lua
local userId = 107392833
Vibez:deleteBlacklist(userId)
```

### [isUserBlacklisted](/Vibez/api/Vibez#isUserBlacklisted)
Checks if a user is blacklisted.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to check if they're blacklisted. <br />

Returns: [(boolean, string?)](/Vibez/api/Vibez#isUserBlacklisted)
```lua
local userId = 107392833
local isBlacklisted, blacklistReason, blacklistedBy = Vibez:isUserBlacklisted(userId)
```

### [getBlacklists](/Vibez/api/Vibez#getBlacklists)
Gets all blacklists.

Returns: [fullBlacklists](/Vibez/api/Vibez#fullBlacklists)
```lua
local blacklists = Vibez:getBlacklists()
```
