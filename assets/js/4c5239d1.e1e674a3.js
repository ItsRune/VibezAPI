"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[144],{7970:e=>{e.exports=JSON.parse('{"functions":[{"name":"_setupCommands","desc":"Sets up the in-game commands.","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","private":true,"source":{"line":514,"path":"src/init.lua"}},{"name":"_setupGlobals","desc":"~~Sets up the _G API.~~ **Creates RemoteFunctions within ServerStorage under a direct folder with that specific wrapper.**","params":[],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","since":"0.4.0","private":true,"source":{"line":734,"path":"src/init.lua"}},{"name":"_http","desc":"Uses `RequestAsync` to fetch required assets to make this API wrapper work properly. Automatically handles the API key and necessary headers associated with different routes.","params":[{"name":"Route","desc":"","lua_type":"string"},{"name":"Method","desc":"","lua_type":"any"},{"name":"Headers","desc":"","lua_type":"{ [string]: any }?"},{"name":"Body","desc":"","lua_type":"{ any }?"}],"returns":[{"desc":"","lua_type":"boolean, httpResponse?"}],"function_type":"method","since":"1.0.0","private":true,"yields":true,"source":{"line":859,"path":"src/init.lua"}},{"name":"_getGroupRankFromName","desc":"Fetches the group\'s role name\'s rank value.\\n\\nAllows for partial naming, example:\\n```lua\\n-- Using Frivo\'s group ID\\nlocal rankNumber = VibezAPI:_getGroupRankFromName(\\"facili\\") --\x3e Expected: 250 (Facility Developer)\\n```","params":[{"name":"groupRoleName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"number?"}],"function_type":"method","since":"0.1.0","private":true,"yields":true,"source":{"line":950,"path":"src/init.lua"}},{"name":"_getGroupFromUser","desc":"Uses roblox\'s group service to get a player\'s rank.","params":[{"name":"groupId","desc":"","lua_type":"number"},{"name":"userId","desc":"","lua_type":"number"},{"name":"force","desc":"","lua_type":"boolean?\\r\\n"}],"returns":[{"desc":"","lua_type":"{ Rank: number?, Role: string?, Id: number?, errMessage: string? }"}],"function_type":"method","since":"0.1.0","private":true,"yields":true,"source":{"line":982,"path":"src/init.lua"}},{"name":"_onPlayerAdded","desc":"Handles players joining the game and checks for if commands/ui are enabled.","params":[{"name":"Player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","since":"0.5.0","private":true,"source":{"line":1057,"path":"src/init.lua"}},{"name":"_onPlayerRemoved","desc":"Handles players leaving the game and disconnects any events.","params":[{"name":"Player","desc":"","lua_type":"Player"},{"name":"isPlayerStillInGame","desc":"","lua_type":"boolean?"}],"returns":[],"function_type":"method","since":"0.5.0","private":true,"source":{"line":1165,"path":"src/init.lua"}},{"name":"_getUserIdByName","desc":"Gets a player\'s user identifier via their username.","params":[{"name":"username","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"number?"}],"function_type":"method","since":"0.1.0","private":true,"yields":true,"source":{"line":1219,"path":"src/init.lua"}},{"name":"_fixFormattedString","desc":"Fixes a string that requires formatting.","params":[{"name":"String","desc":"","lua_type":"string"},{"name":"Player","desc":"","lua_type":"Player | { Name: string, UserId: number }?"},{"name":"Custom","desc":"","lua_type":"{ onlyApplyCustom: boolean, Codes: { { code: string, equates: string }? } }?"}],"returns":[{"desc":"","lua_type":"string"}],"function_type":"method","since":"0.10.4","private":true,"yields":true,"source":{"line":1237,"path":"src/init.lua"}},{"name":"_getNameById","desc":"Gets a player\'s username by their userId","params":[{"name":"userId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"string?"}],"function_type":"method","since":"0.1.0","private":true,"yields":true,"source":{"line":1284,"path":"src/init.lua"}},{"name":"_createRemote","desc":"Creates / Fetches a remote function in replicated storage for client communication.","params":[],"returns":[{"desc":"","lua_type":"RemoteFunction"}],"function_type":"method","since":"0.1.0","private":true,"source":{"line":1303,"path":"src/init.lua"}},{"name":"_getRoleIdFromRank","desc":"Gets the role id of a rank.","params":[{"name":"rank","desc":"","lua_type":"number | string"}],"returns":[{"desc":"","lua_type":"number?"}],"function_type":"method","since":"0.2.1","private":true,"yields":true,"source":{"line":1355,"path":"src/init.lua"}},{"name":"notifyPlayer","desc":"Sends a notification to a player.","params":[{"name":"Player","desc":"","lua_type":"Player"},{"name":"Message","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"number?"}],"function_type":"method","since":"0.11.0","yields":true,"source":{"line":1398,"path":"src/init.lua"}},{"name":"getUsersForCommands","desc":"Gets the closest match to a player\'s username who\'s in game.","params":[{"name":"playerWhoCalled","desc":"","lua_type":"Player"},{"name":"usernames","desc":"","lua_type":"{string}"},{"name":"ignoreExternal","desc":"","lua_type":"boolean"}],"returns":[{"desc":"","lua_type":"{Player}"}],"function_type":"method","since":"0.4.0","yields":true,"source":{"line":1419,"path":"src/init.lua"}},{"name":"_giveSticks","desc":"Gives a Player the ranking sticks.","params":[{"name":"Player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","since":"0.9.0","private":true,"yields":true,"source":{"line":1523,"path":"src/init.lua"}},{"name":"_removeSticks","desc":"Removes ranking sticks from a player.","params":[{"name":"Player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"method","since":"0.9.0","private":true,"yields":true,"source":{"line":1562,"path":"src/init.lua"}},{"name":"giveRankSticks","desc":"Gives the ranking sticks to the player. Succession depends on whether they pass permissions check OR if permissions check is turned off","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"shouldCheckPermissions","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","tags":["Chainable"],"since":"0.9.1","yields":true,"source":{"line":1598,"path":"src/init.lua"}},{"name":"setRankStickTool","desc":"Sets the ranking stick\'s tool.","params":[{"name":"tool","desc":"","lua_type":"Tool | Model"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","tags":["Chainable"],"since":"0.9.1","yields":true,"source":{"line":1626,"path":"src/init.lua"}},{"name":"_onPlayerChatted","desc":"Handles the main chatting event for commands.","params":[{"name":"Player","desc":"","lua_type":"Player"},{"name":"message","desc":"","lua_type":"string"}],"returns":[],"function_type":"method","since":"0.1.0","private":true,"yields":true,"source":{"line":1692,"path":"src/init.lua"}},{"name":"_checkPlayerForRankChange","desc":"Disconnects and reconnects player events to fix permissions within servers.","params":[{"name":"userId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","since":"0.8.0","private":true,"yields":true,"source":{"line":1753,"path":"src/init.lua"}},{"name":"_warn","desc":"Displays a warning to the output.","params":[{"name":"...","desc":"","lua_type":"...string"}],"returns":[],"function_type":"method","since":"1.0.2","private":true,"source":{"line":1777,"path":"src/init.lua"}},{"name":"_debug","desc":"Displays a debug message to the output.","params":[{"name":"starter","desc":"","lua_type":"string"},{"name":"...","desc":"","lua_type":"...string"}],"returns":[],"function_type":"method","since":"1.0.2","private":true,"source":{"line":1795,"path":"src/init.lua"}},{"name":"_addLog","desc":"Adds an entry into the in-game logs.","params":[{"name":"calledBy","desc":"","lua_type":"Player"},{"name":"Action","desc":"","lua_type":"string"},{"name":"triggeringAction","desc":"","lua_type":"\\"Commands\\" | \\"Interface\\" | \\"RankSticks\\""},{"name":"affectedUsers","desc":"","lua_type":"{ { Name: string, UserId: number } }"},{"name":"extraData","desc":"","lua_type":"any?\\r\\n"}],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","since":"0.7.0","private":true,"source":{"line":1813,"path":"src/init.lua"}},{"name":"_buildAttributes","desc":"Builds the attributes of the settings for workspace.","params":[],"returns":[],"function_type":"method","since":"0.9.0","private":true,"source":{"line":1847,"path":"src/init.lua"}},{"name":"_playerIsValidStaff","desc":"Returns the staff member\'s cached data.","params":[{"name":"Player","desc":"","lua_type":"Player | number | string"}],"returns":[{"desc":"","lua_type":"{ User: Player, Rank: number }?"}],"function_type":"method","since":"0.3.0","private":true,"source":{"line":1980,"path":"src/init.lua"}},{"name":"_verifyUser","desc":"Ensures that the parameter returns the proper type associated to the `typeToReturn`","params":[{"name":"User","desc":"","lua_type":"Player | number | string"},{"name":"typeToReturn","desc":"","lua_type":"\\"UserId\\" | \\"Player\\" | \\"Name\\""}],"returns":[{"desc":"","lua_type":"number | string | Player"}],"function_type":"method","since":"0.9.2","private":true,"source":{"line":1995,"path":"src/init.lua"}},{"name":"getGroupId","desc":"Fetches the group associated with the api key.","params":[],"returns":[{"desc":"","lua_type":"number | -1"}],"function_type":"method","since":"0.1.0","yields":true,"source":{"line":2041,"path":"src/init.lua"}},{"name":"setRank","desc":"Sets the rank of a player and `whoCalled` (Optional) is used for logging purposes.","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"rankId","desc":"","lua_type":"string | number"},{"name":"whoCalled","desc":"","lua_type":"{ userName: string, userId: number }?"}],"returns":[{"desc":"","lua_type":"rankResponse"}],"function_type":"method","since":"0.1.0","yields":true,"source":{"line":2088,"path":"src/init.lua"}},{"name":"Promote","desc":"Promotes a player and `whoCalled` (Optional) is used for logging purposes.","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"whoCalled","desc":"","lua_type":"{ userName: string, userId: number }?"}],"returns":[{"desc":"","lua_type":"rankResponse"}],"function_type":"method","since":"0.1.0","yields":true,"source":{"line":2150,"path":"src/init.lua"}},{"name":"Demote","desc":"Demotes a player and `whoCalled` (Optional) is used for logging purposes.","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"whoCalled","desc":"","lua_type":"{ userName: string, userId: number }?"}],"returns":[{"desc":"","lua_type":"rankResponse"}],"function_type":"method","since":"0.1.0","yields":true,"source":{"line":2199,"path":"src/init.lua"}},{"name":"Fire","desc":"Fires a player and `whoCalled` (Optional) is used for logging purposes.","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"whoCalled","desc":"","lua_type":"{ userName: string, userId: number }?"}],"returns":[{"desc":"","lua_type":"rankResponse"}],"function_type":"method","since":"0.1.0","yields":true,"source":{"line":2248,"path":"src/init.lua"}},{"name":"addCommand","desc":"Creates a new command within our systems.","params":[{"name":"commandName","desc":"","lua_type":"string"},{"name":"commandAliases","desc":"","lua_type":"{string}?"},{"name":"commandOperation","desc":"","lua_type":"(Player: Player, Args: { string }, addLog: (calledBy: Player, Action: string, affectedUsers: {Player}?, ...any) -> { calledBy: Player, affectedUsers: { Player }?, affectedCount: number?, Metadata: any }) -> ()"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","since":"0.3.1","source":{"line":2294,"path":"src/init.lua"}},{"name":"addArgumentPrefix","desc":"Adds a command operation code.\\n\\n:::caution\\nThis method will not work if there\'s already an existing operation name!\\n:::","params":[{"name":"operationName","desc":"","lua_type":"string"},{"name":"operationCode","desc":"","lua_type":"string"},{"name":"operationFunction","desc":"","lua_type":"(playerToCheck: Player, incomingArgument: string, internalFunctions: { getGroupRankFromName: (groupRoleName: string) -> number?, getGroupFromUser: (groupId: number, userId: number) -> {any}?, Http: (Route: string, Method: string?, Headers: {[string]: any}, Body: {any}) -> httpResponse, addLog: ( calledBy: Player, Action: string, affectedUsers: {{ Name: string, UserId: number }}?, ...: any) -> () }) -> boolean"},{"name":"metaData","desc":"","lua_type":"{ [string]: boolean }?\\r\\n"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","tags":["Chainable"],"since":"0.3.1","source":{"line":2361,"path":"src/init.lua"}},{"name":"removeArgumentPrefix","desc":"Removes a command operation code.\\n\\n```lua\\nVibez:removeArgumentPrefix(\\"Team\\")\\n```","params":[{"name":"operationName","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","tags":["Chainable"],"since":"0.3.1","source":{"line":2415,"path":"src/init.lua"}},{"name":"updateLoggerName","desc":"Updates the logger\'s origin name.","params":[{"name":"newTitle","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Types.vibezApi\\r\\n"}],"function_type":"method","tags":["Chainable"],"since":"0.1.0","source":{"line":2428,"path":"src/init.lua"}},{"name":"updateKey","desc":"Updates the api key.","params":[{"name":"newApiKey","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","since":"0.2.0","yields":true,"source":{"line":2443,"path":"src/init.lua"}},{"name":"isPlayerABooster","desc":"Checks if the user is currently a nitro booster. (Only specific guilds have this feature)","params":[{"name":"User","desc":"","lua_type":"number | string | Player"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","since":"0.1.1","private":true,"yields":true,"source":{"line":2480,"path":"src/init.lua"}},{"name":"Destroy","desc":"Destroys the VibezAPI class.","params":[],"returns":[],"function_type":"method","since":"0.1.0","source":{"line":2519,"path":"src/init.lua"}},{"name":"getWebhookBuilder","desc":"Initializes the Hooks class with the specified webhook.","params":[{"name":"webhook","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Webhooks"}],"function_type":"method","since":"0.5.0","source":{"line":2581,"path":"src/init.lua"}},{"name":"addBlacklist","desc":"Adds a blacklist to your api key.","params":[{"name":"userToBlacklist","desc":"","lua_type":"(Player string | number)"},{"name":"Reason","desc":"","lua_type":"string?"},{"name":"blacklistExecutedBy","desc":"","lua_type":"(Player string | number)?"}],"returns":[{"desc":"","lua_type":"blacklistResponse"}],"function_type":"method","since":"0.6.0","source":{"line":2597,"path":"src/init.lua"}},{"name":"deleteBlacklist","desc":"Deletes a blacklist from your api key.","params":[{"name":"userToDelete","desc":"","lua_type":"(Player string | number)"}],"returns":[{"desc":"","lua_type":"blacklistResponse"}],"function_type":"method","since":"0.6.0","source":{"line":2640,"path":"src/init.lua"}},{"name":"getBlacklists","desc":"Gets either a full list of blacklists or checks if a player is currently blacklisted.","params":[{"name":"userId","desc":"","lua_type":"(string | number | Player)?"}],"returns":[{"desc":"","lua_type":"blacklistResponse"}],"function_type":"method","since":"0.6.0","source":{"line":2671,"path":"src/init.lua"}},{"name":"isUserBlacklisted","desc":"Gets either a full list of blacklists or checks if a player is currently blacklisted.","params":[{"name":"User","desc":"","lua_type":"Player | string | number"}],"returns":[{"desc":"","lua_type":"(boolean, string?, string?)"}],"function_type":"method","since":"0.6.0","source":{"line":2722,"path":"src/init.lua"}},{"name":"waitUntilLoaded","desc":"Gets a player\'s or everyone\'s current activity","params":[],"returns":[{"desc":"","lua_type":"VibezAPI?"}],"function_type":"method","tags":["Chainable"],"since":"0.8.0","deprecated":{"version":"v0.10.9","desc":null},"source":{"line":2749,"path":"src/init.lua"}},{"name":"getActivity","desc":"Gets a player\'s or everyone\'s current activity","params":[{"name":"User","desc":"","lua_type":"Player | string | number"}],"returns":[{"desc":"","lua_type":"activityResponse"}],"function_type":"method","since":"0.3.0","source":{"line":2777,"path":"src/init.lua"}},{"name":"removeActivity","desc":"Negates the player\'s activity seconds & message counts. (Does not clear detail logs array.)","params":[{"name":"User","desc":"","lua_type":"Player | string | number"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"method","since":"0.11.0","yields":true,"source":{"line":2805,"path":"src/init.lua"}},{"name":"saveActivity","desc":"Saves the player\'s current activity","params":[{"name":"User","desc":"","lua_type":"Player | string | number"},{"name":"userRank","desc":"","lua_type":"number"},{"name":"secondsSpent","desc":"","lua_type":"number"},{"name":"messagesSent","desc":"","lua_type":"(number | { string })?"},{"name":"shouldFetchGroupRank","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"httpResponse"}],"function_type":"method","since":"0.3.0","yields":true,"source":{"line":2844,"path":"src/init.lua"}},{"name":"bindToAction","desc":"Binds a custom function to a specific internal method.","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"action","desc":"","lua_type":"string<Promote | Demote | Fire | Blacklist>"},{"name":"callback","desc":"","lua_type":"(result: responseBody) -> ()"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","since":"0.9.0","source":{"line":2907,"path":"src/init.lua"}},{"name":"unbindFromAction","desc":"Unbinds a custom function from a method.","params":[{"name":"name","desc":"","lua_type":"string"},{"name":"action","desc":"","lua_type":"string<Promote | Demote | Fire | Blacklist>"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"method","since":"0.9.0","source":{"line":2936,"path":"src/init.lua"}},{"name":"_initialize","desc":"Initializes the entire module.","params":[{"name":"apiKey","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"()"}],"function_type":"method","since":"1.0.1","private":true,"source":{"line":2965,"path":"src/init.lua"}},{"name":"new","desc":":::caution Notice\\nThis method can be used as a normal function or invoke the \\".new\\" function:    \\n`require(game:GetService(\\"ServerScriptService\\").VibezAPI)(\\"API Key\\")`\\n`require(game:GetService(\\"ServerScriptService\\").VibezAPI).new(\\"API Key\\")`\\n:::\\n\\nConstructs the main Vibez API class.\\n\\n```lua\\nlocal myKey = \\"YOUR_API_KEY_HERE\\"\\nlocal VibezAPI = require(game:GetService(\\"ServerScriptService\\").VibezAPI)\\nlocal Vibez = VibezAPI(myKey)\\n```","params":[{"name":"apiKey","desc":"Your Vibez API key.","lua_type":"string"},{"name":"extraOptions","desc":"Extra settings to configure the api to work for you.","lua_type":"extraOptionsType"}],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"static","realm":["Server"],"since":"1.0.1","source":{"line":3079,"path":"src/init.lua"}},{"name":"awaitGlobals","desc":"Awaits for the Global API to be loaded.\\n\\n```lua\\nlocal globals = VibezAPI.awaitGlobals()\\n```","params":[],"returns":[{"desc":"","lua_type":"VibezAPI"}],"function_type":"static","since":"0.1.0","deprecated":{"version":"0.10.9","desc":null},"yields":true,"source":{"line":3492,"path":"src/init.lua"}},{"name":"getGlobalsForKey","desc":"Awaits for the Global API to be loaded.\\n\\n```lua\\nlocal globals = VibezAPI.getGlobalsForKey(\\"API KEY\\")\\nglobals.Notifications:Invoke(Player, \\"Hello World!\\")\\n```","params":[{"name":"apiKey","desc":"","lua_type":"string"}],"returns":[{"desc":"","lua_type":"Folder?"}],"function_type":"static","since":"0.11.0","source":{"line":3508,"path":"src/init.lua"}}],"properties":[{"name":"Version","desc":"A string containing the current loaded version of the wrapper.\\n\\t","lua_type":"string","since":"0.11.0","source":{"line":3110,"path":"src/init.lua"}},{"name":"isVibez","desc":"A boolean to determine whether the wrapper is indeed related to Vibez.\\n\\t","lua_type":"boolean","since":"0.11.0","source":{"line":3118,"path":"src/init.lua"}},{"name":"Loaded","desc":"Determines whether the API has loaded.\\n\\t","lua_type":"boolean","since":"0.4.0","source":{"line":3126,"path":"src/init.lua"}},{"name":"GroupId","desc":"Holds the groupId associated with the API Key.\\n\\t","lua_type":"number","since":"0.2.0","source":{"line":3134,"path":"src/init.lua"}},{"name":"Settings","desc":"Holds a copy of the settings for the API.\\n\\t","lua_type":"extraOptionsType","since":"0.1.0","source":{"line":3142,"path":"src/init.lua"}},{"name":"_private","desc":"From caches to simple booleans/instances/numbers, this table holds all the information necessary for this API to work. \\n\\t","lua_type":"{Event: RemoteEvent?, Function: RemoteFunction?, _initialized: boolean, _lastVersionCheck: number, recentlyChangedKey: boolean, newApiUrl: string, clientScriptName: string, rateLimiter: RateLimit, externalConfigCheckDelay: number, lastLoadedExternalConfig: boolean, Maid: {[number]: {RBXScriptConnection?}}, rankingCooldowns: {[number]: number}, usersWithSticks: {number}, stickTypes: string, requestCaches: {nitro: {any}, validStaff: {number}, groupInfo: {[number]: {any}?}}, commandOperations: {any}, commandOperationCodes: {[string]: {Code: string, Execute: (playerWhoFired: Player, playerToCheck: Player, incomingArgument: string) -> boolean}}, Binds: {[string]: {[string]: (...any) -> any?}}}","since":"0.1.0","private":true,"source":{"line":3151,"path":"src/init.lua"}}],"types":[{"name":"groupIdResponse","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"groupId","lua_type":"number?","desc":""}],"source":{"line":3555,"path":"src/init.lua"}},{"name":"errorResponse","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"errorMessage","lua_type":"string","desc":""}],"source":{"line":3562,"path":"src/init.lua"}},{"name":"rankResponse","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"message","lua_type":"string","desc":""},{"name":"data","lua_type":"{ newRank: { id: number, name: string, rank: number, memberCount: number }, oldRank: { id: number, name: string, rank: number, groupInformation: { id: number, name: string, memberCount: number, hasVerifiedBadge: boolean } } }","desc":""}],"source":{"line":3570,"path":"src/init.lua"}},{"name":"blacklistResponse","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"message","lua_type":"string","desc":""}],"source":{"line":3577,"path":"src/init.lua"}},{"name":"fullBlacklists","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"blacklists:","lua_type":"{ [number | string]: { reason: string, blacklistedBy: number } }","desc":""}],"source":{"line":3584,"path":"src/init.lua"}},{"name":"infoResponse","desc":"","fields":[{"name":"success","lua_type":"boolean","desc":""},{"name":"message","lua_type":"string","desc":""}],"source":{"line":3591,"path":"src/init.lua"}},{"name":"activityResponse","desc":"","fields":[{"name":"secondsUserHasSpent","lua_type":"number","desc":""},{"name":"messagesUserHasSent","lua_type":"number","desc":""},{"name":"detailsLogs","lua_type":"[ {timestampLeftAt: number, secondsUserHasSpent: number, messagesUserHasSent: number}? ]","desc":""}],"source":{"line":3599,"path":"src/init.lua"}},{"name":"responseBody","desc":"","lua_type":"groupIdResponse | errorResponse | rankResponse","source":{"line":3604,"path":"src/init.lua"}},{"name":"httpResponse","desc":"","fields":[{"name":"Body","lua_type":"responseBody","desc":""},{"name":"Headers","lua_type":"{ [string]: any }","desc":""},{"name":"StatusCode","lua_type":"number","desc":""},{"name":"StatusMessage","lua_type":"string?","desc":""},{"name":"Success","lua_type":"boolean","desc":""},{"name":"rawBody","lua_type":"string","desc":""}],"source":{"line":3615,"path":"src/init.lua"}},{"name":"commandOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"useDefaultNames","lua_type":"boolean","desc":""},{"name":"MinRank","lua_type":"number<0-255>","desc":""},{"name":"MaxRank","lua_type":"number<0-255>","desc":""},{"name":"Prefix","lua_type":"string","desc":""},{"name":"Alias","lua_type":"{[string]: string}","desc":""},{"name":"Removed","lua_type":"{string?}","desc":""}],"private":true,"source":{"line":3629,"path":"src/init.lua"}},{"name":"rankStickOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"Mode","lua_type":"\\"Default\\" | \\"ClickOnPlayer\\" | \\"DetectionInFront\\"","desc":""},{"name":"MinRank","lua_type":"number<0-255>","desc":""},{"name":"MaxRank","lua_type":"number<0-255>","desc":""},{"name":"sticksModel","lua_type":"(Model | Tool)?","desc":""},{"name":"Removed","lua_type":"{string?}","desc":""},{"name":"Animation","lua_type":"{ R6: number, R15: number }","desc":""}],"private":true,"source":{"line":3643,"path":"src/init.lua"}},{"name":"notificationsOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"Font","lua_type":"Enum.Font","desc":""},{"name":"FontSize","lua_type":"number","desc":""},{"name":"keyboardFontMultiplier","lua_type":"number","desc":""},{"name":"delayUntilRemoval","lua_type":"number","desc":""},{"name":"entranceTweenInfo","lua_type":"{ Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }","desc":""},{"name":"exitTweenInfo","lua_type":"{ Style: Enum.EasingStyle, Direction: Enum.EasingDirection, timeItTakes: number }","desc":""}],"private":true,"source":{"line":3657,"path":"src/init.lua"}},{"name":"interfaceOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"MinRank","lua_type":"number<0-255>","desc":""},{"name":"MaxRank","lua_type":"number<0-255>","desc":""},{"name":"maxUsersForSelection","lua_type":"number","desc":""},{"name":"Suggestions","lua_type":"{ searchPlayersOutsideServer: boolean, outsideServerTagText: string, outsideServerTagColor: BrickColor | Color3 }","desc":""},{"name":"Activation","lua_type":"{ Keybind: Enum.KeyCode, iconButtonPosition: \\"Center\\" | \\"Left\\" | \\"Right\\", iconButtonImage: string, iconToolTip: string }","desc":""},{"name":"nonViewableTabs","lua_type":"{ string? }","desc":""}],"private":true,"source":{"line":3671,"path":"src/init.lua"}},{"name":"loggingOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"MinRank","lua_type":"number<0-255>","desc":""}],"private":true,"source":{"line":3680,"path":"src/init.lua"}},{"name":"activityTrackerOptions","desc":"","fields":[{"name":"Enabled","lua_type":"boolean","desc":""},{"name":"MinRank","lua_type":"number<0-255>","desc":""},{"name":"disableWhenInStudio","lua_type":"boolean","desc":""},{"name":"disableWhenInPrivateServer","lua_type":"boolean","desc":""},{"name":"disableWhenAFK","lua_type":"boolean","desc":""},{"name":"delayBeforeMarkedAFK","lua_type":"number","desc":""},{"name":"kickIfFails","lua_type":"boolean","desc":""},{"name":"failMessage","lua_type":"string","desc":""}],"private":true,"source":{"line":3695,"path":"src/init.lua"}},{"name":"miscOptions","desc":"","fields":[{"name":"originLoggerText","lua_type":"string","desc":""},{"name":"ignoreWarnings","lua_type":"boolean","desc":""},{"name":"overrideGroupCheckForStudio","lua_type":"boolean","desc":""},{"name":"createGlobalVariables","lua_type":"boolean","desc":""},{"name":"rankingCooldown","lua_type":"number","desc":""}],"private":true,"source":{"line":3707,"path":"src/init.lua"}},{"name":"debugOptions","desc":"","fields":[{"name":"logMessages","lua_type":"boolean","desc":""}],"private":true,"source":{"line":3715,"path":"src/init.lua"}},{"name":"extraOptionsType","desc":"","fields":[{"name":"Commands","lua_type":"commandOptions","desc":""},{"name":"RankSticks","lua_type":"rankStickOptions","desc":""},{"name":"Notifications","lua_type":"notificationsOptions","desc":""},{"name":"Interface","lua_type":"interfaceOptions","desc":""},{"name":"ActivityTracker","lua_type":"activityTrackerOptions","desc":""},{"name":"Misc","lua_type":"miscOptions","desc":""},{"name":"Debug","lua_type":"debugOptions","desc":""}],"source":{"line":3728,"path":"src/init.lua"}}],"name":"VibezAPI","desc":":::info\\nHey there! We recommend beginning at the introduction page! [Click Here](/docs/intro)\\n:::\\n\\t","source":{"line":3098,"path":"src/init.lua"}}')}}]);