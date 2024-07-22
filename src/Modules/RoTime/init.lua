--[=[
	@ignore
	@class RoTime
]=]

--[=[
	@prop Timer (start: number, finish: number, increment: number?) -> Timer
	@within RoTime
]=]

--// Services \\--
local RunService = game:GetService("RunService")

--// Variables \\--
local Settings = require(script.Settings)
local Tokenizer = require(script.Tokenize)
local Parser = require(script.Parser)
local Types = require(script.Types)
local Table = require(script.Table)
local Timer = require(script.Timer)

--// Module Setup \\--
local RoTime = {}
local Class = {}
Class.__index = Class

--// Documentation Types \\--
--[=[
	@type additionSubtractionInterface "second" | "minute" | "hour" | "day" | "week" | "month" | "year"
	@within RoTime
]=]

--// Functions \\--
function getTimezoneData(timezoneName: string): { name: string, offset: number }?
	local data = {}

	for timezoneNameToCheck: string, timezoneOffset: number in pairs(Settings.Timezones) do
		if string.lower(timezoneNameToCheck) == string.lower(timezoneName) then
			data.name = timezoneNameToCheck
			data.offset = timezoneOffset
			break
		end
	end

	return (data["name"] ~= nil) and data or nil
end

local function getIncrementFromTimesTable(Type: string)
	Type = tostring(Type)

	local beforeCheckDataType = string.upper(string.sub(Type, 1, 1)) .. string.lower(string.sub(Type, 2, #Type))
	local dataType = (string.sub(beforeCheckDataType, #beforeCheckDataType, #beforeCheckDataType) == "s")
			and string.sub(beforeCheckDataType, 0, #beforeCheckDataType - 1)
		or beforeCheckDataType

	return Settings.timesTable[dataType]
end

--// Public Functions \\--
--[=[
	Constructs a new class.
	@return RoTime

	@tag Constructor
	@since 2.0.0
	@within RoTime
]=]
function RoTime.new(): Types.RoTime
	local self = setmetatable({}, Class)

	self._dt = DateTime.now()
	self._timezone = {
		name = "UTC",
		offset = 0,
	}

	self.Timer = setmetatable({}, {
		__call = function(tbl, ...)
			local timer = Timer.new(...)
			rawset(tbl, timer._id, timer)
			return timer :: Types.Timer
		end,
	})

	return self
end

--[=[
	Gets the amount of time between two numbers. (Seconds)
	@param firstUnix number
	@param secondUnix number
	@param Options { formattingType: "default" | "full", removeZeros: boolean }?
	@return string

	@since 2.0.0
	@within RoTime
]=]
function RoTime.getHumanTimestamp(
	firstUnix: number,
	secondUnix: number,
	Options: {
		formattingType: "default" | "full"?,
		removeZeros: boolean?,
	}?
)
	Options = Options or {}

	if not Options["formattingType"] then
		Options.formattingType = "default"
	end

	if not Options["removeZeros"] then
		Options["removeZeros"] = false
	end

	if not Options["In"] then
		Options["In"] = "all"
	end

	local formattingType, removeZeros = Options["formattingType"], Options["removeZeros"]
	local diff = math.abs(firstUnix - secondUnix)
	local finalStr = {}

	-- Default version: 1h 16m 52s
	-- Full version: 1 hour 16 minutes 52 seconds
	for i = 1, #Settings.timesTable do
		local longWording, shortWording, timeInterval = table.unpack(Settings.timesTable[i])

		local div = math.floor(diff / timeInterval)
		local format

		if removeZeros and div == 0 then
			continue
		end

		if formattingType == "default" then
			format = shortWording
		elseif formattingType == "full" then
			format = string.format(" %s%s", string.lower(longWording), (div > 1) and "s" or "")
		end

		diff -= timeInterval * div
		table.insert(finalStr, div .. format)
	end

	return table.concat(finalStr, " ")
end

Class.getHumanTimestamp = RoTime.getHumanTimestamp

--// Private Functions \\--
--[=[
	Warns to the console with a the script name as the prefix.

	@private
	@since 2.0.0
	@within RoTime
]=]
function Class:_warn(...: string)
	warn("[RoTime]:", ...)
end

--[=[
	Gets the current day out of a full year. ex: 100/365
	@return { currentDay: number, fullYear: 365 | 366 }

	@private
	@since 2.0.0
	@within RoTime
]=]
function Class:_getDayOfTheYear(): { currentCount: number, fullYear: number }
	local formatted = self:format("#mm #dd")
	local split = string.split(formatted, " ")
	local currentMonthNum, currentDayNum = tonumber(split[1]), tonumber(split[2])
	local isLeapYear = self:isLeapYear()
	local dayNum = 0
	local monthsAndTheirTotalDays = {
		[1] = 31,
		[2] = 28,
		[3] = 31,
		[4] = 30,
		[5] = 31,
		[6] = 30,
		[7] = 31,
		[8] = 31,
		[9] = 30,
		[10] = 31,
		[11] = 30,
		[12] = 31,
	}

	for definedMonthNumber = 1, currentMonthNum do
		if definedMonthNumber == currentMonthNum then
			dayNum += currentDayNum
			break
		end

		local fetchedDays = monthsAndTheirTotalDays[definedMonthNumber]
		if definedMonthNumber == 2 and isLeapYear then
			fetchedDays += 1
		end

		dayNum += fetchedDays
	end

	return {
		currentCount = dayNum,
		fullYear = isLeapYear and 366 or 365,
	}
end

--[=[
	Adds a zero in front of a number. (Used for formatting)
	@return string

	@private
	@since 2.0.0
	@within RoTime
]=]
function Class:_addZeroInFront(value: any): string
	if tonumber(value) == nil then
		return value
	end

	if tonumber(value) < 10 and tonumber(value) >= 0 then
		value = "0" .. value
	end

	return value
end

--[=[
	Gets a token's information.
	@return { [string]: string }

	@private
	@since 2.0.0
	@within RoTime
]=]
function Class:_getTokenInformation(tokenExpected: { string }): { [string]: string | number }
	local new = {}

	local function insert(index: string, value: any)
		if new[index] ~= nil then
			return
		end

		new[index] = value
	end

	local timeWithZone = self:getDateTime()
	local timeValueTable = timeWithZone:ToUniversalTime()
	local weekDayNumber = (math.floor(timeWithZone.UnixTimestampMillis / 86400) + 1) % 7

	for _, token in pairs(tokenExpected) do
		if token == "hour_12" then
			local result = (timeValueTable.Hour + 1) % 12
			insert(token, tostring((result == 0) and 12 or result))
		elseif token == "hour_24" then
			insert(token, tostring(timeValueTable.Hour))
		elseif token == "minute" then
			insert(token, tostring(timeValueTable.Minute))
		elseif token == "second" then
			insert(token, tostring(timeValueTable.Second))
		elseif token == "millis" then
			insert(token, tostring(timeValueTable.Millisecond))
		elseif token == "day_short" then
			insert(token, tostring(timeValueTable.Day))
		elseif token == "day_long" then
			insert(token, tostring(Settings.Names.weekDays[weekDayNumber]))
		elseif token == "year_long" then
			insert(token, tostring(timeValueTable.Year))
		elseif token == "year_short" then
			local str = tostring(timeValueTable.Year)
			insert(token, tostring(string.sub(str, #str - 1, #str)))
		elseif token == "month" then
			insert(token, tostring(timeValueTable.Month))
		elseif token == "month_long" then
			insert(token, tostring(Settings.Names.Months[timeValueTable.Month]))
		elseif token == "month_short" then
			insert(token, tostring(string.sub(Settings.Names.Months[timeValueTable.Month], 1, 3)))
		elseif token == "week_day" then
			insert(token, tostring(weekDayNumber))
		elseif token == "timezone" then
			insert(token, tostring(self._timezone.name))
		elseif token == "week_year" then
			local daysOfTheYear = self:_getDayOfTheYear()
			insert(token, tostring(math.ceil(daysOfTheYear.currentCount / 7)))
		elseif token == "year_day" then
			local daysOfTheYear = self:_getDayOfTheYear()
			insert(token, tostring(daysOfTheYear.currentCount))
		elseif token == "max_year_days" then
			local daysOfTheYear = self:_getDayOfTheYear()
			insert(token, tostring(daysOfTheYear.fullYear))
		elseif token == "unix" then
			insert(token, tostring(self._dt.UnixTimestamp))
		elseif token == "unix_ms" then
			insert(token, tostring(self._dt.UnixTimestampMillis))
		else
			insert(token, tostring(token))
		end
	end

	return new
end

--[=[
	Sets the timezone to the specified timezone.
	@return RoTime

	@since 2.0.0
	@within RoTime
]=]
function Class:timezone(newTimezone: string)
	local timezoneData = getTimezoneData(newTimezone)

	if not timezoneData then
		self:_warn(
			'"' .. newTimezone .. '"',
			'is not a valid timezone. You can add a new one with the ":addTimezone" method.'
		)
	end

	self._timezone = timezoneData
	return self
end

--[=[
	Creates a new timezone with the designated offset.
	@param timezoneName string
	@param timezoneOffset number
	@return RoTime

	@since 2.0.0
	@within RoTime
]=]
function Class:addTimezone(timezoneName: string, timezoneOffset: number)
	if not tonumber(timezoneOffset) then
		self:_warn("The new timezone offset has to be of type 'number'.")
	end

	Settings.Timezones[timezoneName] = timezoneOffset
	return self
end

--[=[
	Removes a timezone by it's name.
	@param timezoneName string
	@return RoTime

	@tag Chainable
	@since 2.0.0
	@within RoTime
]=]
function Class:removeTimezone(timezoneName: string)
	Settings.Timezones[timezoneName] = nil
	return self
end

--[=[
	Gets the local timezone, if ran from the server, you'll get the server's timezone and vice versa for the client.
	@return string | "Unknown"

	```lua
	warn(RoTime:getLocalTimezone()) --> 'EDT'
	```

	@since 2.1.0
	@within RoTime
]=]
function Class:getLocalTimezone(): string
	assert(RunService:IsClient(), "'getLocalTimezone' can only be ran on the client!")

	local rawUniverse = DateTime.now():ToUniversalTime()
	local rawUserTime = DateTime.now():ToLocalTime()

	-- Since timezones are just offsets of minutes & hours, we can do the difference to find theirs.
	local theirTimezoneOffset = tonumber(
		string.format("%d.%d", rawUserTime.Hour - rawUniverse.Hour, (rawUniverse.Minute - rawUserTime.Minute) / 60)
	)

	for timezoneName: string, timezoneOffset: number in pairs(Settings.Timezones) do
		if theirTimezoneOffset ~= timezoneOffset then
			continue
		end

		return timezoneName
	end

	return "Unknown"
end

--[=[
	Checks if the current time is a leap year.
	@return boolean

	@since 2.0.0
	@within RoTime
]=]
function Class:isLeapYear(): boolean
	local year = self:getDateTime():ToUniversalTime().Year
	return ((year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0))
end

--[=[
	Takes a future time and calculates the difference, returning time duration.
	@param input string
	@param format string?
	@return number

	@since 2.0.0
	@within RoTime
]=]
function Class:fromNow(input: string, format: string): number
	local newTime = RoTime.new()
	newTime:timezone(self._timezone.name):set(input, format)

	local nowUnix = self:getDateTime().UnixTimestamp
	local futureUnix = newTime:getDateTime().UnixTimestamp

	if nowUnix > futureUnix then
		return 0
	end

	newTime:Destroy()
	return math.abs(futureUnix - nowUnix)
end

--[=[
	Takes a past time and calculates the difference, returning time duration.
	@param input string
	@param format string?
	@return number

	@since 2.0.0
	@within RoTime
]=]
function Class:toNow(input: string, format: string): number
	local newTime = RoTime.new()
	newTime:timezone(self._timezone.name):set(input, format)

	local nowUnix = self:getDateTime().UnixTimestamp
	local pastUnix = newTime:getDateTime().UnixTimestamp

	if nowUnix < pastUnix then
		return 0
	end

	newTime:Destroy()
	return math.abs(nowUnix - pastUnix)
end

--[=[
	Gets the DateTime Instance.
	@return DateTime

	@since 2.0.0
	@within RoTime
]=]
function Class:getDateTime()
	return DateTime.fromUnixTimestampMillis(self._dt.UnixTimestampMillis + (60 * 60 * self._timezone.offset * 1000))
end

--[=[
	Gets the Date.
	@return string

	@since 2.0.0
	@within RoTime
]=]
function Class:getDate()
	return self:format("#dd/#mm/#yyyy")
end

--[=[
	Gets the Time.
	@return string

	@since 2.0.0
	@within RoTime
]=]
function Class:getTime()
	return self:format("#hh:#m:#s")
end

--[=[
	Gets a specific formatting code's value.

	@since 2.0.0
	@within RoTime
]=]
function Class:get(...: { string }): ...string
	local codes = { ... }
	local vals = {}

	for _, v in pairs(codes) do
		local code = (string.sub(v, 1, 1) == "#") and v or "#" .. v

		local tokens = Tokenizer(code)
		local information = self:_getTokenInformation(Table.Map(tokens, function(value)
			return (value.expected == "Unknown") and value.code or value.expected
		end))

		table.insert(vals, table.unpack(Table.Values(information)))
	end

	return table.unpack(vals)
end

--[=[
	Gets the format used for timestamps.
	@return string

	@since 2.1.0
	@within RoTime
]=]
function Class:getTimestamp()
	local dateData = self:getDateTime():ToUniversalTime()

	local formatted = string.format(
		"%d-%d-%dT%d:%d:%d.%dZ",
		dateData.Year,
		self:_addZeroInFront(dateData.Month),
		self:_addZeroInFront(dateData.Day),
		self:_addZeroInFront(dateData.Hour),
		self:_addZeroInFront(dateData.Minute),
		self:_addZeroInFront(dateData.Second),
		dateData.Millisecond
	)

	return formatted
end

--[=[
	Gets the calender for the month.
	@return { amountOfDays: number, year: number, isLeapYear: boolean, month: { Name: string, Number: number }, days: { { Name: string, isToday: boolean } } }

	@since 2.0.1
	@within RoTime
]=]
function Class:getCalender(): {
	amountOfDays: number,
	isLeapYear: boolean,
	days: { { dayName: string, Day: number, isToday: boolean } },
	year: number,
}
	local dateTime = self:getDateTime()
	local universal = dateTime:ToUniversalTime()
	local isLeapYear = self:isLeapYear()
	local currentMonth = universal.Month
	local daysCount = 31

	-- Feburary is a stupid month tbh.
	if currentMonth == 2 then
		daysCount = isLeapYear and 29 or 28
	end

	local calender = {
		amountOfDays = daysCount,
		year = universal.Year,
		isLeapYear = self:isLeapYear(),
		month = {
			Name = Settings.Names.Months[currentMonth],
			Number = currentMonth,
		},
		days = {},
	}

	for i = 1, calender.amountOfDays do
		-- A little hacky, but it will suffice.
		local dayName = (Settings.Names.weekDays)[os.date(
			"*t",
			os.time({ year = calender.year, month = universal.Month, day = i })
		).wday]

		calender.days[i] = {
			Name = dayName,
			isToday = (i == universal.Day),
		}
	end

	return calender
end

--// Setters \\--
--[=[
	Adds an amount of time based on the addition/subtraction type.
	@param amount number
	@param Type additionSubtractionInterface
	@return RoTime

	:::info HEY
	`RoTime:add(amount, Type)` also works with this method.
	:::

	@tag Chainable
	@since 2.0.0
	@within RoTime
]=]
function Class:addition(amount: number, Type: Types.addOrRemoveType)
	local increment = getIncrementFromTimesTable(Type)

	if not increment then
		self:_warn("Hmm.. An unexpected issue occurred.")
		return
	end

	self._dt = DateTime.fromUnixTimestamp(((amount + self._timezone.offset) * increment))
	return self
end
Class.add = Class.addition

--[=[
	Subtracts an amount of time based on the addition/subtraction type.
	@param amount number
	@param Type additionSubtractionInterface
	@return RoTime

	:::info HEY
	`RoTime:sub(amount, Type)` also works with this method.
	:::

	@tag Chainable
	@since 2.0.0
	@within RoTime
]=]
function Class:subtract(amount: number, Type: Types.addOrRemoveType)
	local increment = getIncrementFromTimesTable(Type)

	if not increment then
		self:_warn("Hmm.. An unexpected issue occurred.")
		return
	end

	self._dt = DateTime.fromUnixTimestamp(((amount - self._timezone.offset) * increment))
	return self
end
Class.sub = Class.subtract

--[=[
	Sets the time to the specified input and format.
	@param input string
	@param format string? Defaults to '#mm/#dd/#yyyy #hh:#m:#s'
	@return RoTime

	@tag Chainable
	@since 2.0.0
	@within RoTime
]=]
function Class:set(input: string, format: string?)
	assert(
		typeof(input) == "string",
		string.format("Input string for ':set' expected 'string', got '%s'", typeof(input))
	)

	format = format or "#mm/#dd/#yyyy #hh:#m:#s"

	local tokens = Tokenizer(format)
	local parsed = Parser(input, false, tokens)

	local current = self:getDateTime():ToUniversalTime()
	local tbl = {
		year = current.Year,
		month = current.Month,
		day = current.Day,
		hour = current.Hour,
		minute = current.Minute,
		second = current.Second,
		millisecond = current.Millisecond,
	}

	local unsupportedTokens = {
		"hour_12",
		"month_long",
		"month_short",
		"ampm",
		"timezone",
		"week_year", -- Not implemented
		"year_day", -- To complicated to do atm.
	}

	for _, data: { value: string | number, code: string } in pairs(parsed) do
		local patternData = Settings.Patterns[data.code]

		if not patternData then
			continue
		end

		local token = patternData.expectedType

		if table.find(unsupportedTokens, token) then
			self:_warn(`"{token}" is not supported for ":set"!`)
			continue
		end

		if token == "hour_24" then
			tbl.hour = math.clamp(data.value - self._timezone.offset, 0, 23)
		elseif token == "minute" then
			tbl.minute = math.clamp(data.value, 0, 60)
		elseif token == "second" then
			tbl.second = math.clamp(data.value, 0, 60)
		elseif token == "day_short" or token == "day_long" then
			tbl.day = math.clamp(data.value, 0, 31)
		elseif token == "year_short" then
			tbl.year = (data.value + 2000)
		elseif token == "year_long" then
			tbl.year = data.value
		elseif token == "month" then
			tbl.month = math.clamp(data.value, 1, 12)
		elseif token == "millis" then
			tbl.millisecond = math.clamp(data.value, 1, 999)
		end
	end

	self._dt =
		DateTime.fromUniversalTime(tbl.year, tbl.month, tbl.day, tbl.hour, tbl.minute, tbl.second, tbl.millisecond)
	return self
end

--[=[
	Formats the current time with certain formatting parameters.
	@param input string
	@return string

	@since 2.0.0
	@within RoTime
]=]
function Class:format(input: string): string
	local tokens = Tokenizer(input)

	local bulkData = self:_getTokenInformation(Table.Map(tokens, function(value)
		return (value.expected == "Unknown") and value.code or value.expected
	end))

	local resultingData = Table.Map(tokens, function(value)
		local result = bulkData[(value.expected == "Unknown") and value.code or value.expected]

		if value["needsFormatting"] ~= true then
			return result
		end

		if value.tokenType == "number" then
			result = self:_addZeroInFront(result)
		end

		return result
	end)

	return table.concat(resultingData, "")
end

--[=[
	Destroys the module and cleans methods.
	@return nil

	@since 2.0.0
	@within RoTime
]=]
function Class:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

return setmetatable(RoTime, {
	__call = function(tbl, ...)
		return tbl.new(...)
	end,
})
