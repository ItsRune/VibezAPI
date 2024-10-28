--!nocheck
--// Services \\--
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local remoteFunction, remoteEvent
local System = {
	Components = {},
	Maids = {},
	eventHolder = {},
	hasSetup = {},

	afkData = {
		Status = false,
		afkDelay = 30,
	},

	Notifications = {
		Font = "Gotham",

		FontSize = 16,
		delayUntilRemoval = 20,
		keyboardFontSizeMultiplier = 1.25,

		entranceTweenInfo = {
			Direction = "InOut",
			Style = "Quint",
			timeItTakes = 1,
		},

		exitTweenInfo = {
			Direction = "InOut",
			Style = "Quint",
			timeItTakes = 1,
		},
	},

	rankStickMode = "Default",
	isWarningsAllowed = true,
}

--// Modules \\--
local Table = require(script.Modules.Table)
local Tweens = require(script.Modules.TweenService)
local TopbarPlus = require(script.Modules.TopbarPlus)
local buttonClickBubble = require(script.Modules.ButtonClickBubble)

--// Functions \\--
local function _warn(starter: string, ...: string)
	if not System.isWarningsAllowed then
		return
	end

	warn("[" .. starter .. "]: ", ...)
end

local function _debug(starter: string, ...: string): ()
	if not System.areDebugPrintsAllowed then
		return
	end

	local prefix = string.format("[Debug-vibez_client_%s]:", starter)
	print(prefix, ...)
end

local function _findFirstChildWhichIsAByName(parent: Instance, name: string, class: string, tries: number?): Instance?
	local existingAttempts = tries or 0
	if existingAttempts >= 50 then
		return nil
	end

	for _, v in pairs(parent:GetChildren()) do
		if v.Name == name and v:IsA(class) then
			return v
		end
	end

	task.wait(0.25)
	return _findFirstChildWhichIsAByName(parent, name, class, existingAttempts + 1)
end

local function clearAllChildren(Parent: Instance, excludedClassNames: { string? }): ()
	excludedClassNames = excludedClassNames or {}

	for _, child: Instance in ipairs(Parent:GetChildren()) do
		if table.find(excludedClassNames, child.ClassName) ~= nil or child.Name == "Template" then
			continue
		end

		child:Destroy()
	end
end

local function Disconnect(data: { any } | RBXScriptConnection)
	if typeof(data) == "table" then
		for _, v in pairs(data) do
			Disconnect(v)
		end
	elseif typeof(data) == "RBXScriptConnection" then
		data:Disconnect()
	end
end

local function onAttributeChanged()
	local isOk, States = nil, Workspace:GetAttribute(script.Name)
	if not States then
		return
	end

	isOk, States = pcall(HttpService.JSONDecode, HttpService, States)
	if not isOk then
		return
	end

	System.isWarningsAllowed = not States.Misc.ignoreWarnings
	System.areDebugPrintsAllowed = States.Misc.showDebugMessages

	for key: string, data: { [any]: any } in pairs(States) do
		if key == "GroupId" then
			continue
		end

		local componentData = {
			remoteFunction = remoteFunction,
			remoteEvent = remoteEvent,

			GroupId = States.GroupId,
			Data = data,

			TopbarPlus = TopbarPlus,
			clearAllChildren = clearAllChildren,
			Disconnect = Disconnect,
			Tweens = Tweens,
			Table = Table,
			buttonClickBubble = buttonClickBubble,

			_warn = _warn,
			_debug = _debug,
		}

		local associatedModule, moduleName
		for modName: string, moduleData: { [any]: any } in pairs(System.Components) do
			if string.find(string.lower(modName), string.lower(key)) ~= nil then
				associatedModule = moduleData
				moduleName = modName
				break
			end
		end

		if not associatedModule then
			continue
		end

		local moduleHasSetupAlready = (table.find(System.hasSetup, moduleName) ~= nil)
		local Method = "Setup"
		if data.Status == false and moduleHasSetupAlready then
			Method = "Destroy"
		end

		local description = (Method == "Setup") and "Setting up" or "Undoing setup"
		_warn("Vibez Setup", string.format("%s for '%s'", description, moduleName))

		associatedModule[Method](componentData)

		if Method == "Setup" then
			table.insert(System.hasSetup, moduleName)
		end
	end
end

local function onStart()
	remoteFunction = _findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteFunction")
	remoteEvent = _findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteEvent")

	for _, module: Instance in ipairs(script.Components:GetChildren()) do
		if not module:IsA("ModuleScript") then
			continue
		end

		local moduleData = require(module)
		System.Components[module.Name] = moduleData
	end

	Workspace:GetAttributeChangedSignal(script.Name):Connect(onAttributeChanged)
	onAttributeChanged()
end

--// Core \\--
onStart()
