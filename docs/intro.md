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

<!-- **Due to Roblox taking down our module, this will be the only method while we attempt to get our module back up.** <br /> -->
This method is recommended if you'd like more control over our module. With this method, you also get the autocomplete feature in Roblox Studio.

1. Get the [Module](https://www.roblox.com/library/14946453963/VibezAPI)
2. Rename the module to `VibezAPI`.
3. Insert the module into `ServerScriptService`
4. Use `require(game:GetService("ServerScriptService").VibezAPI)` to fetch the module within your script
    - Anywhere you see `require(14946453963)` in the documentation, replace it with `require(game:GetService("ServerScriptService").VibezAPI)`
5. Done!

<!-- TODO: Update the version everytime you update! -->
<!-- 1. Download the [Module](https://github.com/ItsRune/VibezAPI/releases/download/v0.10.7/VibezAPI.rbxm)
2. Insert the module into `ServerScriptService`
3. Use `require(game:GetService("ServerScriptService").VibezAPI)` to fetch the module within your script
    - Anywhere you see `require(game:GetService("ServerScriptService").VibezAPI)` in the documentation, replace it with `require(game:GetService("ServerScriptService").VibezAPI)`
4. Done! -->

---

### Usage

To begin, open a new `Script` in `ServerScriptService` and require the module with your preferred method:

```lua
local VibezAPI = require(14946453963)
```

From there, you can use the API to create a new Vibez instance:

```lua
local myApiKey = "my-api-key"
local Vibez = require(14946453963)(myApiKey)
```

Alright, now you have a Vibez instance. You can either customize this by following the other API documentation or you can use the default settings.