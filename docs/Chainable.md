---
sidebar_position: 3
---

### What is chainable?
Chainablility is a feature that allows you to chain methods together. For example, instead of doing this:

```lua
local VibezAPI = require(script.VibezAPI)("myApiKey")

VibezAPI:removeCommandOperation("Team")
VibezAPI:removeCommandOperation("Rank")
```

You can do this:

```lua
local VibezAPI = require(script.VibezAPI)("myApiKey")

VibezAPI:removeCommandOperation("Team"):removeCommandOperation("Rank")
```

Which not only saves lines but also makes it easier to read, by preventing your eyes from jumping to different lines.

---

### How does it work?
Chainability works by returning the class instance after every method call. This allows you to call another method on the class instance without having to create a new variable. For example, if you wanted to remove an operation code then immediately promote someone, you could do this:

```lua
local VibezAPI = require(script.VibezAPI)("myApiKey")
local playerToRank = game.Players:GetPlayers()[1]

VibezAPI:removeCommandOperation("Team"):SetRank(playerToRank, 1)
```

---

### How do I know if a method is chainable?
If a method is chainable, it will be marked with a `Chainable` tag in the documentation. For example, the `:removeCommandOperation` method is chainable, so it will be marked with a `Chainable` tag in the documentation.