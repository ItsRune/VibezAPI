local fs = require("@lune/fs")
local serde = require("@lune/serde")
local file = fs.readFile("./src/Modules/Settings.lua")

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

local function recursive(data: any)
	local toReturn: any

	if typeof(data) == "table" then
		toReturn = {}

		if data["__TYPE"] ~= nil then
			return data
		end

		for i in data do
			toReturn[i] = recursive(data[i])
		end
	else
		local TYPE = typeof(data)
		toReturn = (data == "settings_check_ignore_nil_tbl") and TYPE .. "?" or TYPE
	end

	return toReturn
end

typesTable = recursive(settings)
local json = serde.encode("json", typesTable, true)
fs.writeFile("./.external/settings.json", json)
