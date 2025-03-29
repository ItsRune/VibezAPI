--!strict
-- REVIEW: Maybe make this module a folder and add custom errors underneath for better organization?
--// Services \\--
local HttpService = game:GetService("HttpService")

--// Modules \\--
local Types = require(script.Parent.Types)
local Table = require(script.Parent.Parent.Table)

--// Variables \\--
local clientInterface = script.Parent.Parent.Parent.Client.Components.UI.Interface

--// Functions \\--
local function test(self: Types.vibezApi, expr: boolean, checkName: string): boolean
	if not self.Settings.Debug.logMessages then
		return expr
	end

	self:_debug("settings_check", "Test for '" .. checkName .. "' returned " .. (expr and "✔️" or "✖️"))
	return expr
end

--[[
	Compares a value to a default value and ensures it's type is kept the same.

	```lua
	local Default = { ["Test"] = "Hello!" }
	local Data = { ["Test"] = 1, ["Something"] = "Else!" }

	Data = fixDiscrepencies(VibezApi, Data, Default)
	
	print(Data) --> { ["Test"] = "Hello!" }
	```
]]
local function fixDiscrepencies(self: Types.vibezApi, Data: any, Default: any, path: string): any
	local pathSplit = string.split(path, ".")
	local parentKey = (#pathSplit > 2) and pathSplit[#pathSplit - 1] or "<UNKNOWN_PARENT>"
	local latestKey = (#pathSplit > 1) and pathSplit[#pathSplit] or "<UNKNOWN_CHILD>"

	-- Errors --
	local optionalKeyStarter = string.format("Optional key '%s'", path)
	local optionalKeyInvalidError = string.format("%s is not a valid option.", optionalKeyStarter)

	if typeof(Data) == typeof(Default) then
		-- Notify the developer that all tabs are invisible and the interface is basically useless.
		if
			test(
				self,
				latestKey == "nonViewableTabs" and #Data >= #clientInterface.Frame.Buttons:GetChildren() - 1,
				"interface_viewable_tabs_validator"
			)
		then
			self:_warn(
				optionalKeyStarter
					.. " makes all frame tabs invisible with it's current configuration. Either disable the 'Interface' or make atleast 1 tab visible."
			)
			return Default
		elseif
			test(
				self,
				latestKey == "Removed"
					and parentKey == "RankSticks"
					and #Data >= #HttpService:JSONDecode(self._private.stickTypes),
				"ranksticks_removal"
			)
		then
			local stickTypes = HttpService:JSONDecode(self._private.stickTypes)
			local loweredExcludedNames = Table.Map(Data, function(name: string)
				return string.lower(tostring(name))
			end)

			local filteredModes = Table.Filter(stickTypes, function(stickName: string)
				return table.find(loweredExcludedNames, string.lower(tostring(stickName))) ~= nil
			end)

			if #filteredModes == #stickTypes then
				self:_warn(optionalKeyStarter .. " includes every RankStick name. Did you mean to do this?")
			end

			return Data
		elseif test(self, typeof(Data) == "table" and typeof(Default) == "table", "same_type_tables_key_removal") then
			-- Remove non-existant keys
			for key: string, value: any in pairs(Data) do
				if typeof(Default[key]) == typeof(value) and typeof(value) ~= "table" then
					continue
				end

				self:_debug("settings_check", "Applying checks to nested table '" .. path .. "'.")
				Data[key] = fixDiscrepencies(self, Data[key], Default[key], path .. "." .. key)
			end

			return Data
		end
		-- Custom errors past this point --
	elseif typeof(Data) ~= typeof(Default) then
		if
			test(
				self,
				typeof(Default) == "table" and Default[1] == "settings_check_ignore_nil_tbl",
				"array_removal_of_ignoring_nil_check"
			)
		then
			return ((typeof(Data) == "table" and Data[1] ~= "settings_check_ignore_nil_tbl") or typeof(Data) ~= "table")
					and Data
				or {}
		elseif
			-- Allow BrickColors for tag color
			test(self, latestKey == "outsideServerTagColor" and typeof(Data) == "BrickColor", "tag_color_brickcolor")
		then
			return Data
		elseif test(self, parentKey == "RankSticks" and latestKey == "Model", "ranksticks_model") then
			if Data == nil or typeof(Data) == "Instance" then
				return Data
			end

			local errMessage = string.format(" received '%s'; expected type 'Model', 'Tool', or 'nil'!", typeof(Data))
			self:_warn(optionalKeyStarter .. errMessage)

			return Default
		elseif
			test(
				self,
				typeof(Data) == "string"
					and latestKey == "Mode"
					and (parentKey == "RankSticks" or parentKey == "Cooldowns"),
				"ranksticks_mode_validation"
			)
		then
			if self._private.validModes[parentKey][string.lower(tostring(Data))] then
				return Data
			end

			self:_warn(
				string.format("%s '%s' is not a valid 'Mode' for %s.", optionalKeyStarter, tostring(Data), parentKey)
			)
			return Default
		elseif
			test(self, Default == nil and (parentKey == "Alias" or parentKey == "Removed"), "empty_array_data_return")
		then
			return Data
		elseif test(self, Default == nil, "optional_key_doesnt_exist") then
			self:_warn(optionalKeyInvalidError)
		end
	end

	self:_debug("settings_check", "Returning default value for path '" .. path .. "'")
	return Default
end

local function removeAllIgnoreNilChecks(
	self: Types.vibezApi,
	Data: any,
	currentCount: number?
): ({ [any]: any }?, number)
	local removedCount = currentCount or 0

	if test(self, typeof(Data) == "table", "remove_ignore_checks_table_check") then
		for key: string, value: any in next, Data do
			local result, newCount = removeAllIgnoreNilChecks(self, value, removedCount)

			Data[key] = result
			removedCount = newCount
		end
	elseif test(self, Data == "settings_check_ignore_nil_tbl", "remove_ignore_checks_main_check") then
		removedCount += 1
		return nil, removedCount
	end

	return Data, removedCount
end

local function applyMissing(self: Types.vibezApi, Data: any, Default: { [any]: any })
	for i in Default do
		local TYPE = typeof(Data[i])
		if test(self, TYPE == "table" and Table.Count(Data[i]) ~= 0, "apply_missing_nil_and_length_check") then
			Data[i] = applyMissing(self, Data[i], Default[i])
		elseif
			test(self, (TYPE ~= "table" and TYPE ~= typeof(Default[i])) or TYPE == "nil", "apply_missing_value_check")
		then
			Data[i] = Default[i]
		end
	end

	return Data
end

return {
	settingsCheck = fixDiscrepencies,
	removeNilChecks = removeAllIgnoreNilChecks,
	applyMissing = applyMissing,
}

-- Old Settings check
--[[
for settingSubCategory, value in pairs(extraOptions :: { [any]: any }) do
    if self.Settings[settingSubCategory] == nil then
        self:_warn(`Optional key '{settingSubCategory}' is not a valid option.`)
        continue
    end

    -- Final settings check
    if typeof(value) == "table" then
        -- Handle 'nilCheckIgnore' for tables that can be somewhat-wrongly typed.
        for settingToChange, newSetting in pairs(value) do
            local currentSettingToChange = self.Settings[settingSubCategory][settingToChange]

            -- 'sticksModel' is nil by default.
            if currentSettingToChange == nil and settingToChange ~= "sticksModel" then
                self:_warn(
                    string.format(
                        "Optional key 'Settings.%s.%s' is not a valid option.",
                        settingSubCategory,
                        settingToChange
                    )
                )
                continue
            elseif
                -- Custom logic to validate feature modes.
                self.Settings[settingSubCategory] ~= nil
                and currentSettingToChange ~= nil
                and settingToChange :: string == "Mode"
                and typeof(newSetting) == "string"
            then
                if not self._private.validModes[settingSubCategory] then
                    self:_warn(
                        string.format(
                            "The 'Mode' setting within '%s' is not correctly validated! Please screenshot this message and send it to @ltsRune!",
                            settingSubCategory
                        )
                    )
                    continue
                end

                if self._private.validModes[settingSubCategory][string.lower(tostring(newSetting))] == nil then
                    self:_warn(
                        string.format(
                            "Optional mode '%s' for 'Settings.%s' is not a valid, it's been overwritten to the default of '%s'.",
                            newSetting,
                            settingSubCategory,
                            currentSettingToChange
                        )
                    )
                    continue
                end
            elseif
                -- Write in custom logic for 'Instance' types.
                typeof(currentSettingToChange) ~= typeof(newSetting)
                and (settingToChange == "sticksModel" and typeof(newSetting) ~= "Instance")
            then
                self:_warn(
                    string.format(
                        "Optional key 'Settings.%s.%s' is not the same type as it's default value of '%s'",
                        settingSubCategory,
                        settingToChange,
                        typeof(currentSettingToChange)
                    )
                )
                continue
            end

            self.Settings[settingSubCategory][settingToChange] = newSetting
        end
    else
        self.Settings[settingSubCategory] = value
    end
end
]]
--
