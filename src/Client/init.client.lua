--// Services \\--
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Variables \\--
local Player = Players.LocalPlayer
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

--// Functions \\--
local function _warn(starter: string, ...: string)
	if not System.isWarningsAllowed then
		return
	end

	warn("[" .. starter .. "]: ", ...)
end

local function _findFirstChildWhichIsAByName(parent: Instance, name: string, class: string, tries: number?): Instance?
	tries = tries or 0
	if tries >= 50 then
		return nil
	end

	for _, v in pairs(parent:GetChildren()) do
		if v.Name == name and v:IsA(class) then
			return v
		end
	end

	task.wait(0.25)
	return _findFirstChildWhichIsAByName(parent, name, class, tries + 1)
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

	for key: string, data: { [any]: any } in pairs(States) do
		local componentData = {
			remoteFunction = remoteFunction,
			remoteEvent = remoteEvent,

			rankStickMode = System.rankStickMode,
			afkDelayOffset = System.afkData.afkDelay,

			Disconnect = Disconnect,
			Tweens = Tweens,
			Table = Table,
			_warn = _warn,
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

		associatedModule[Method](componentData)

		local description = (Method == "Setup") and "Setting up" or "Undoing setup"
		_warn("Vibez Setup", string.format("%s for '%s'", description, moduleName))

		if Method == "Setup" then
			table.insert(System.hasSetup, moduleName)
		end
	end
end

local function onStart()
	for _, module: ModuleScript in ipairs(script.Components:GetChildren()) do
		if not module:IsA("ModuleScript") then
			continue
		end

		local moduleData = require(module)
		System.Components[module.Name] = moduleData
	end

	Workspace:GetAttributeChangedSignal(script.Name):Connect(onAttributeChanged)
	onAttributeChanged()

	remoteFunction = _findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteFunction")
	remoteEvent = _findFirstChildWhichIsAByName(ReplicatedStorage, script.Name, "RemoteEvent")
end

--// Core \\--
onStart()
