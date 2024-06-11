---
sidebar_position: 4
---

## What does blacklisting do?
Blacklisting a user will prevent them from doing anything that uses your API key. This includes the usage of our application center and ranking center. This is useful in case you have a user that is causing havoc in your games. Think of this as a ban system attached to your API key.

## Usage
### [addBlacklist](/VibezAPI/api/VibezAPI#addBlacklist)
Adds a new blacklist.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to blacklist. <br />
``reason: string?`` - The reason for blacklisting the user. **OPTIONAL**<br />
``blacklistedBy: number?`` - The user id of the person who blacklisted the user. **OPTIONAL**<br />

Returns: [blacklistResponse](/VibezAPI/api/VibezAPI#blacklistResponse)
```lua
local userId = 107392833
local reason = "Spamming the group wall."
local userWhoBlacklisted = 1 -- ROBLOX
VibezApi:addBlacklist(userId, userWhoBlacklisted)
```

### [deleteBlacklist](/VibezAPI/api/VibezAPI#deleteBlacklist)
Removes a blacklist.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to remove the blacklist of. <br />

Returns: [blacklistResponse](/VibezAPI/api/VibezAPI#blacklistResponse)
```lua
local userId = 107392833
VibezApi:deleteBlacklist(userId)
```

### [isUserBlacklisted](/VibezAPI/api/VibezAPI#isUserBlacklisted)
Checks if a user is blacklisted.

Parameter(s): <br />
``userId: number`` - The user id of the player you want to check if they're blacklisted. <br />

Returns: [(boolean, string?)](/VibezAPI/api/VibezAPI#isUserBlacklisted)
```lua
local userId = 107392833
local isBlacklisted, blacklistReason, blacklistedBy = VibezApi:isUserBlacklisted(userId)
```

### [getBlacklists](/VibezAPI/api/VibezAPI#getBlacklists)
Gets all blacklists.

Returns: [fullBlacklists](/VibezAPI/api/VibezAPI#fullBlacklists)
```lua
local blacklists = VibezApi:getBlacklists()
```
