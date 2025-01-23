--!strict
local ServerStorage = game:GetService("ServerStorage")

local Utils = {}

-- Searches a deep table for a selected key/index.
function Utils.deepFetch(tbl: { any }, index: (string | number)?)
	for k, v in pairs(tbl) do
		if k == index then
			return v
		elseif typeof(v) == "table" then
			return Utils.deepFetch(v)
		end
	end

	return nil
end

-- Changes a deep table's key/index to the new given value.
function Utils.deepChange(tbl: { any }, index: string | number, value: any)
	for k, v in pairs(tbl) do
		if k == index then
			tbl[k] = value
			break
		elseif typeof(v) == "table" then
			tbl[k] = Utils.deepChange(v, index, value)
		end
	end

	return tbl
end

-- Stringifies a table's keys and values for outputting to the console.
function Utils.stringifyTableDeep(tbl: { any }, tabbing: number?, showTypes: boolean?): string
	local tabsToApply = tabbing or 1
	local str = "{\n"

	local function tableHasValues(data: { [any]: any }): boolean
		local x = 0

		for _, _ in data do
			x = 1
			break
		end

		return x > 0
	end

	local function applyTabbing()
		if tabbing == 0 then
			return
		end

		for _ = 1, tabsToApply do
			str ..= "    "
		end
	end

	for index, value in pairs(tbl) do
		applyTabbing()

		if typeof(index) == "string" then
			str ..= string.format('["%s"] = ', index)
		end

		if typeof(value) == "table" then
			if not tableHasValues(value) then
				str ..= "{},\n"
				continue
			end

			str ..= Utils.stringifyTableDeep(value, tabsToApply + 1) .. "," .. (showTypes and "-- table" or "")
		else
			str ..= (typeof(value) == "string" and string.format('"%s"', value) or string.format("%s,", tostring(value))) .. (showTypes and "-- " .. typeof(
				value
			) or "")
		end

		str ..= "\n"
	end

	tabsToApply -= 1
	applyTabbing()

	return str .. "}"
end

-- Returns the temporary folder within ServerStorage, creates one if one doesn't exist.
function Utils.getTemporaryStorage(): Folder
	local folder = ServerStorage:FindFirstChild("Vibez_Storage") :: Folder?

	if not folder then
		local newFolder = Instance.new("Folder") :: Folder
		newFolder.Name = "Vibez_Storage"
		newFolder.Parent = ServerStorage

		return newFolder
	end

	return folder
end

-- Rotates characters for a simple ROT cipher.
function Utils.rotateCharacters(Input: string, Key: number, splitter: string?, shouldDecode: boolean?)
	local splitIndex = splitter or ""
	local bytes = shouldDecode and string.split(Input, splitIndex) or string.split(Input, "")

	for i, v in ipairs(bytes) do
		local num = tonumber(v) :: number
		if shouldDecode and not num then
			continue
		end

		bytes[i] = shouldDecode and string.char(num - Key) or string.byte(v) + Key .. splitIndex
	end

	return table.concat(bytes, "")
end

return Utils
