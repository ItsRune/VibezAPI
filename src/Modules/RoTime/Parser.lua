--!strict
type token = {
	code: string,
	expected: string,
	tokenType: string,
	indexStart: number,
	indexEnd: number,
}

type Return = {
	{
		value: (number | string)?,
		code: string,
	}?
}

local function Parse(input: string, returnUnknownCharacters: boolean?, tokens: { token }): Return
	local parsed = {}

	local inputIndex = 0
	local tokenIndex = 1
	local takenFromString = ""

	while inputIndex <= string.len(input) do
		inputIndex += 1

		local currentToken = tokens[tokenIndex]
		local character = string.sub(input, inputIndex, inputIndex)

		if currentToken == nil then
			break
		end

		if currentToken.expected == "Unknown" then
			if returnUnknownCharacters then
				table.insert(parsed, {
					value = character,
					code = "Unknown",
				})
			end

			tokenIndex += 1
			continue
		elseif currentToken.tokenType == "number" then
			local num = tonumber(character)

			if num == nil then
				num = tonumber(takenFromString)

				table.insert(parsed, {
					value = num,
					code = currentToken.code,
				})

				takenFromString = ""
				tokenIndex += 1
				inputIndex -= 1

				continue
			end

			takenFromString ..= character
		elseif currentToken.tokenType == "string" then
			local isOk = string.match(character, "[a-zA-Z]") ~= nil

			if not isOk then
				table.insert(parsed, {
					value = takenFromString,
					code = currentToken.code,
				})

				takenFromString = ""
				tokenIndex += 1
				inputIndex -= 1

				continue
			end

			takenFromString ..= character
		end
	end

	return parsed
end

return Parse
