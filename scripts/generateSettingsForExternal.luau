local fs = require("@lune/fs")
local serde = require("@lune/serde")
local file = fs.readFile("./src/Modules/Settings.lua")

-- TODO: Add specific types like Stick/Cooldown Modes
-- Format: [Path] = Type
local specificSettingTypeTable = {
	["RankSticks.Mode"] = "Default | ClickOnPlayer | DetectionInFront",
	["Cooldowns.Mode"] = "Default | PerTarget | PerStaff | Both",
}

-- Convert file's ROBLOX-specific keywords into usable JSON data.
file = file:gsub("Enum%.[a-zA-Z%.]+", function(str)
	print(`Converting Enum: "{str}"`)
	local split = string.split(str, ".")
	return '{ __TYPE = "Enum", __SUBCATEGORY = "' .. split[2] .. '", __ATTR = { "' .. split[3] .. '" } }'
end)
	:gsub("Color3%.[%(a-zA-Z0-9%., ]+%)", function(str)
		print(`Converting Color3: "{str}"`)
		local split = string.split(str, ".")
		local method = string.match(split[#split], "[a-zA-Z]+") :: string
		local gmatch = split[#split]:gmatch("[%d]+")
		local R, G, B = gmatch(), gmatch(), gmatch()
		return '{ __TYPE = "Color3", __SUBCATEGORY = "' .. method .. '", __ATTR = { ' .. `{R}, {G}, {B}` .. " } }"
	end)
	:gsub("game%.[a-zA-Z]+", function(str)
		local split = string.split(str, ".")
		return '{ __TYPE = "game", __SUBCATEGORY = "' .. split[2] .. '", __ATTR = {} }'
	end)

fs.writeFile("./scripts/stage1.luau", file)

local typesTable = {}
local settings = require("stage1")

local function recursive(data: any, path: string?)
	local toReturn: any
	local p = path or ""

	local function addPath(toAdd: string): string
		if string.sub(p, #p, #p) ~= "" and string.sub(p, #p, #p) ~= "." then
			toAdd = "." .. toAdd
		end

		return p .. toAdd
	end

	if typeof(data) == "table" then
		toReturn = {}

		if data["__TYPE"] ~= nil then
			return data
		end

		for i in data do
			local thisPath = p
			thisPath = addPath(i)
			toReturn[i] = recursive(data[i], thisPath)
		end
	else
		toReturn = specificSettingTypeTable[p]

		if not toReturn then
			local TYPE = typeof(data)
			toReturn = (data == "settings_check_ignore_nil_tbl") and TYPE .. "?" or TYPE
		end
	end

	return toReturn
end

typesTable = recursive(settings)
local json = serde.encode("json", typesTable, true)
fs.writeFile("./.external/settings.json", json)
