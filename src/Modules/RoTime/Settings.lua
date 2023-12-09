return {
	Tokenizer = {
		toFormat = "#", -- Prefix before tokenizing | "#H:#M:#S" -> {"#H", "#M", "#S"}

		resultShouldIncludeUnknownTokens = true,
	},

	RegularExpressions = {
		"[%d%d%d%d]%-[%d%d]%-[%d%d]T[%d%d]:[%d%d]:[%d%d]Z", -- 2020-01-02T10:30:45Z
	},

	timesTable = {
		Second = 1,
		Minute = 60,
		Hour = 3600,
		Day = 86400,
		Week = 604800,
		Month = 2628000,
		Year = 31536000,
	},

	addOrRemoveTypes = {
		"second",
		"seconds",
		"minute",
		"minutes",
		"hour",
		"hours",
		"day",
		"days",
		"week",
		"weeks",
		"month",
		"months",
		"year",
		"years",
	},

	Patterns = {
		["h"] = { expectedType = "hour_12", Type = "number" },
		["hh"] = { expectedType = "hour_24", Type = "number" },
		["m"] = { expectedType = "minute", Type = "number" },
		["s"] = { expectedType = "second", Type = "number" },
		["ms"] = { expectedType = "millis", Type = "number" },
		["mm"] = { expectedType = "month", Type = "number" },
		["mmm"] = { expectedType = "month_short", Type = "string" },
		["mmmm"] = { expectedType = "month_long", Type = "string" },
		["dd"] = { expectedType = "day_short", Type = "number" },
		["dddd"] = { expectedType = "day_long", Type = "string" },
		["yd"] = { expectedType = "year_day", Type = "number" },
		["yy"] = { expectedType = "year_short", Type = "number" },
		["yyyy"] = { expectedType = "year_long", Type = "number" },
		["z"] = { expectedType = "timezone", Type = "string" },
		["w"] = { expectedType = "week_day", Type = "number" },
		["ww"] = { expectedType = "week_year", Type = "number" },
		["u"] = { expectedType = "unix", Type = "number" },
		["uu"] = { expectedType = "unix_ms", Type = "number" },
	},

	Timezones = {
		-- Format: [timeZoneName] = to_add_to_GMT
		-- Types: [string] = number
		["UTC"] = 0,
		["GMT"] = 0,
		["CDT"] = 0,
		["PDT"] = -5,
		["EDT"] = -8,
		["CET"] = 1,

		["America/Philidolphia"] = 0,
		["America/New_York"] = -6,
		["America/Los_Angeles"] = -7,

		["Europe/London"] = 1,
		["Europe/Berlin"] = 1,
		["Europe/Netherlands"] = 2,
		["Europe/Paris"] = 2,

		["Australia/Perth"] = 8,
		["Australia/Sydney"] = 9.5,
		["Australia/Darwin"] = 9.5,
		["Australia/Victoria"] = 10,
		["Australia/Tasmania"] = 10,
		["Australia/Queensland"] = 10,

		["Asia/India"] = 5.5,
		["Asia/Zhongshan"] = 6,
		["Asia/Singapore"] = 8,
		["Asia/Shanghai"] = 8,
		["Asia/Japan"] = 9,

		["Africa/Western"] = 1,
		["Africa/Central"] = 2,
		["Africa/Eastern"] = 3,
	},

	Names = {
		weekDays = {
			"Sunday",
			"Monday",
			"Tuesday",
			"Wednesday",
			"Thursday",
			"Friday",
			"Saturday",
		},

		Months = {
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December",
		},
	},
}
