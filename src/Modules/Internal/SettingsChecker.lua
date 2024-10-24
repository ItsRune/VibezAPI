-- REVIEW: Maybe make this module a folder and add custom errors underneath for better organization?

--// Services \\--
local HttpService = game:GetService("HttpService")

--// Modules \\--
local Types = require(script.Parent.Types)
local Table = require(script.Parent.Parent.Table)

--// Variables \\--
local clientInterface = script.Parent.Parent.Parent.Client.Components.UI.Interface

--// Functions \\--
--[[
	Compares a value to a default value and ensures it's type is kept the same.

	```lua
	local Default = { ["Test"] = "Hello!" }
	local Data = { ["Test"] = 1, ["Something"] = "Else!" }

	Data = fixDiscrepencies(_, Data, Default)
	
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
		if latestKey == "nonViewableTabs" and #Data >= #clientInterface.Frame.Top.Buttons:GetChildren() - 1 then
			self:_warn(
				optionalKeyStarter
					.. " makes all frame tabs invisible with it's current configuration. Either disable the 'Interface' or make atleast 1 tab visible."
			)
			return Default
		elseif
			latestKey == "Removed"
			and parentKey == "RankSticks"
			and #Data >= #HttpService:JSONDecode(self._private.stickTypes)
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
		elseif typeof(Data) == "table" and typeof(Default) == "table" then
			-- Remove non-existant keys
			for key: string, value: any in pairs(Default) do
				if typeof(Data[key]) == typeof(value) and typeof(value) ~= "table" then
					continue
				end

				Data[key] = fixDiscrepencies(self, Data[key], value, path .. "." .. key)
			end

			return Data
		end
		-- Custom errors past this point --
	elseif typeof(Data) ~= typeof(Default) then
		if typeof(Default) == "table" and Default[1] == "settings_check_ignore_nil_tbl" then
			return ((typeof(Data) == "table" and Data[1] ~= "settings_check_ignore_nil_tbl") or typeof(Data) ~= "table")
					and Data
				or {}
		elseif latestKey == "outsideServerTagColor" and typeof(Data) == "BrickColor" then -- Allow BrickColors for tag color
			return Data
		elseif parentKey == "RankSticks" and latestKey == "sticksModel" then
			if Data == nil or typeof(Data) == "Instance" then
				return Data
			end

			local errMessage = string.format(" received '%s'; expected type 'Model', 'Tool', or 'nil'!", typeof(Data))
			self:_warn(optionalKeyStarter .. errMessage)

			return Default
		elseif typeof(Data) == "string" and latestKey == "Mode" and parentKey == "RankSticks" then
			if self._private.validModes[string.lower(tostring(Data))] then
				return Data
			end

			self:_warn(
				string.format("%s '%s' is not a valid 'Mode' for RankSticks.", optionalKeyStarter, tostring(Data))
			)
			return Default
		elseif Default == nil and (parentKey == "Alias" or parentKey == "Removed") then
			return Data
		elseif Default == nil then
			self:_warn(optionalKeyInvalidError)
		end
	end

	return Default
end

local function removeAllIgnoreNilChecks(Data: any): any
	if typeof(Data) == "table" then
		for key: string, value: any in next, Data do
			Data[key] = removeAllIgnoreNilChecks(value)
		end
	elseif Data == "settings_check_ignore_nil_tbl" then
		return nil
	end

	return Data
end

return {
	settingsCheck = fixDiscrepencies,
	removeNilChecks = removeAllIgnoreNilChecks,
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
