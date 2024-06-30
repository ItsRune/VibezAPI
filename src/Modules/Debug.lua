local Debug = {}

function Debug.stringifyTableDeep(tbl: { any }, tabbing: number?): string
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
			str ..= Debug.stringifyTableDeep(value, tabbing + 1) .. ","
		else
			str ..= (typeof(value) == "string" and `"{value}"` or tostring(value)) .. ","
		end

		str ..= "\n"
	end

	tabbing -= 1
	applyTabbing()

	return str .. "}"
end

return Debug
