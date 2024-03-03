---
sidebar_position: 4
---

### What does blacklisting do?
Blacklisting a user will prevent them from doing anything that uses your API key. This includes the usage of our application center and ranking center. This is useful in case you have a user that is causing havoc in your games. Think of this as a ban system attached to your API key.

### How do I blacklist a user?
To blacklist a user, you'd just require the module as normal and call the `addBlacklist` method.

```lua
Vibez:addBlacklist(1234567890) -- Adds a new blacklist with an "Unknown" reason
Vibez:addBlacklist(1234567890, "My reason.") -- Adds a new blacklist with a provided reason.
Vibez:addBlacklist(1234567890, "My reason.", 1) -- Adds a new blacklist with a provided reason and says ROBLOX blacklisted them.
```

### How do I remove a blacklist?
To remove a blacklist, you'd just call the `deleteBlacklist` method.

```lua
Vibez:deleteBlacklist(1234567890) -- Removes a blacklist with the provided user id.
```

### How do I check a blacklist?
To check a blacklist, you'd just call the `isUserBlacklisted` method.

```lua
local isBlacklisted, blacklistReason, blacklistedBy = Vibez:isUserBlacklisted(1234567890)
```

### How do I get all blacklists?
To get all blacklists, you'd just call the `getBlacklists` method.

```lua
local blacklists = Vibez:getBlacklists()
```