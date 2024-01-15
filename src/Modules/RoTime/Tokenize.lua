--!strict
--// Types \\--
type token = {
	code: string,
	expected: string,
	tokenType: string,
	indexStart: number,
	indexEnd: number,
}

--// Variables \\--
local Settings = require(script.Parent.Settings)

--// Functions \\--
local function tokenize(input: string): { { token }? }
	input = tostring(input)

	local isCapturing = false
	local currentCapture = ""
	local captureStartedAt, captureEndedAt, strIndex, strLen = 0, 0, 0, string.len(input)
	local tokens = {}

	local function resetCaptureGroup()
		if #currentCapture == 0 then
			currentCapture = ""
			captureStartedAt, captureEndedAt = 0, 0
			return
		end

		local pattern = Settings.Patterns[currentCapture]
		if not pattern then
			table.insert(tokens, {
				code = "Unknown",
				expected = currentCapture,
				tokenType = "string",
				indexStart = captureStartedAt,
				indexEnd = captureEndedAt,
			})
			return
		end

		local requiresFormatting = table.find(Settings.tokensRequiringFormatting, pattern.expectedType) ~= nil
		table.insert(tokens, {
			code = currentCapture,
			expected = pattern.expectedType,
			tokenType = pattern.Type,
			indexStart = captureStartedAt,
			indexEnd = captureEndedAt,
			needsFormatting = requiresFormatting,
		})

		currentCapture = ""
		captureStartedAt, captureEndedAt = 0, 0
	end

	while strIndex < strLen + 1 do
		strIndex += 1

		local character = string.sub(input, strIndex, strIndex)

		if character == "" then
			character = "♥"
		end

		if character == Settings.Tokenizer.toFormat then
			if isCapturing then
				resetCaptureGroup()
			end

			captureStartedAt = strIndex + 1
			isCapturing = true
			continue
		end

		if isCapturing then
			local newCode = currentCapture .. character
			local hasPossibility = false

			for codeToCheck: string, _ in pairs(Settings.Patterns) do
				if string.sub(newCode, 1, #newCode) == string.sub(codeToCheck, 1, #newCode) then
					hasPossibility = true
				end
			end

			if not hasPossibility then
				captureEndedAt = strIndex - 1
				resetCaptureGroup()
				isCapturing = false

				if Settings.Tokenizer.resultShouldIncludeUnknownTokens and strIndex ~= strLen + 1 then
					table.insert(tokens, {
						code = character,
						expected = "Unknown",
						Type = "string",
						indexStart = strIndex,
						indexEnd = strIndex,
					})
				end
				continue
			end

			currentCapture = newCode
		end
	end

	return tokens
end

return tokenize
