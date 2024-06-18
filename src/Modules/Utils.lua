local ServerStorage = game:GetService("ServerStorage")

local Utils = {}

-- Searches a deep table for a selected key/index.
function Utils.deepFetch(tbl: { any }, index: string | number)
	for k, v in pairs(tbl) do
		if k == index then
			return v
		elseif typeof(v) == "table" then
			return Utils.deepFetch(v)
		end
	end
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
function Utils.stringifyTableDeep(tbl: { any }, tabbing: number?): string
	tabbing = tabbing or 1
	local str = "{\n"

	local function applyTabbing()
		if tabbing == 0 then
			return
		end

		for _ = 1, tabbing do
			str ..= "    "
		end
	end

	for index, value in pairs(tbl) do
		applyTabbing()

		if typeof(index) == "string" then
			str ..= string.format('["%s"] = ', index)
		end

		if typeof(value) == "table" then
			str ..= Utils.stringifyTableDeep(value, tabbing + 1) .. ","
		else
			str ..= (typeof(value) == "string" and string.format('"%s"', value) or string.format("%s,", tostring(value)))
		end

		str ..= "\n"
	end

	tabbing -= 1
	applyTabbing()

	return str .. "}"
end

-- Returns the temporary folder within ServerStorage, creates one if one doesn't exist.
function Utils.getTemporaryStorage(): Folder
	local folder = ServerStorage:FindFirstChild("Vibez_Storage")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Vibez_Storage"
		folder.Parent = ServerStorage
	end

	return folder
end

return Utils
