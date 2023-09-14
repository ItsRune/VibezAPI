# Getting Started

## Installation

You can install by getting the package from the roblox website and requiring the module using the ID of the module. This is the recommended way to install the module as it will automatically update the module when a new version is released.

```lua
local VibezAPI = require(6949396225)
```

**OR**

To install, just get the package from the roblox website and drag it into your studio place. Please make sure you parent the modulescript to `ServerStorage` or `ServerScriptService` in order to keep the module out of the hands of exploiters.

## Usage

To begin, open a new `Script` in `ServerScriptService` and require the module:

```lua
local VibezAPI = require(script.Parent.VibezAPI)
```

From there, you can use the API to create a new Vibez instance:

```lua
local myApiKey = "my-api-key"
local Vibez = VibezAPI(myApiKey)
```

Our api wrapper supports extra options for when creating the class. These options can be found [here](/VibezAPI/api/VibezAPI#extraOptionsType).

Once all that's done, you're free to use our API for any means necessary.