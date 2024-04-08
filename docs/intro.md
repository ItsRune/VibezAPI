---
sidebar_position: 1
---

# Getting Started

### Installation

#### Method 1 (Recommended)

The main pro of this method is that you get auto-updates and you don't have to worry about updating the module yourself.

1. Get the [Module](https://www.roblox.com/library/14946453963/VibezAPI)
2. Use `require(14946453963)` to fetch the module
3. Done!

#### Method 2

This method is recommended if you'd like more control over our module. With this method, you also get the autocomplete feature in Roblox Studio.

1. Get the [Module](https://www.roblox.com/library/14946453963/VibezAPI)
2. Insert the module into `ServerScriptService`
3. Use `require(game:GetService("ServerScriptService").VibezAPI)` to fetch the module within your script
4. Done!

---

### Usage

To begin, open a new `Script` in `ServerScriptService` and require the module with your preferred method:

```lua
local VibezAPI = require(14946453963)
```

From there, you can use the API to create a new Vibez instance:

```lua
local myApiKey = "my-api-key"
local Vibez = VibezAPI(14946453963)(myApiKey)
```

Alright, now you have a Vibez instance. You can either customize this by following the other API documentation or you can use the default settings.

---

### API Settings
Our api wrapper supports extra options for when creating the class. [These options can be found here](/VibezAPI/docs/Settings).