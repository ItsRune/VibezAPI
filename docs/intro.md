---
sidebar_position: 1
---

# Getting Started

### Installation

You can install by getting the package from the roblox website and requiring the module using the ID of the module. This is the recommended way to install the module as it will automatically update the module when a new version is released.

```lua
local VibezAPI = require(14946453963)("Your API Key")
```

---

### Usage

To begin, open a new `Script` in `ServerScriptService` and require the module:

```lua
local VibezAPI = require(14946453963)("Your API Key")
```

From there, you can use the API to create a new Vibez instance:

```lua
local myApiKey = "my-api-key"
local Vibez = VibezAPI(14946453963)("Your API Key")
```

Alright, now you have a Vibez instance. You can either customize this by following the other API documentation or you can use the default settings.

---

### API Settings
Our api wrapper supports extra options for when creating the class. [These options can be found here](/VibezAPI/docs/Settings).