local Definitions = require(script.Parent.Parent.Parent.Parent.Definitions)

local function CustomRichText(componentData: Definitions.componentData, message: string): string
	local customFormatCodes: { [string]: string } = {
		["User"] = "Users",
		["Action"] = "Actions",
		["Group"] = "Group",
		["Error"] = "Error",
		["Warn"] = "Warning",
		["Info"] = "Info",
		["Success"] = "Success",
	}

	for i in customFormatCodes do
		-- Puncuation Set: !%?%(%)%*&%%#%$@,%./\\
		local capture = `<{i}>([%w%s!%?%(%)%*&%%#%$@,%./\\]+)</{i}>`
		local matched

		repeat
			matched = message:match(capture)

			if not matched then
				continue
			end

			local newFormat = '<font color="%s">%s</font>'
			local colorName = customFormatCodes[i]
			local colorHex = componentData.customRichTextColors[colorName] or "#000000"

			message = message:gsub(capture, newFormat:format(colorHex, matched))
		until matched == nil
	end

	return message
end

return CustomRichText
