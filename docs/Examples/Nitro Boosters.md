---
sidebar-position: 11
---

### Check if a player is a nitro booster
Where is this useful? You can use this to give nitro boosters special perks in your game.

```lua
local Vibez = require(14946453963)("API Key")

local function onPlayerAdded(Player: Player)
    local isBooster = Vibez:isBooster(Player.UserId)

    if isBooster then
        warn(string.format("%s is a nitro booster!", Player.Name))
    end
end
```