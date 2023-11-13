--[[
    TODO:
    - Developers can specify a Folder/SurfaceGui that add to the cache.
    - Client will update on its own with different widgets specified by the dev.
    - RepStorage will hold information about widget information.
    - Widget Info:
        - Title        |            string             | Top portion of the widget. (20 Chars)
        - Description  |            string             | Small description about what's being shown. (40 Chars)
        - Thumbnail    |            string             | Roblox Image URL
        - Social Links | { Type: string, Url: string } | Links that would be shown on the widget. (Can be copied via TextBox)
]]

type externalLinks = "Discord" | "Twitter" | "YouTube" | "Facebook"

local Widgets = {}
local Class = {}
Class.__index = Class

--// Public Functions \--
function Widgets.new()
	assert(false, "Not implemented")

	local self = setmetatable({}, Class)

	self._cache = {}

	return self
end

--// Private Functions \--
function Class:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	self = nil
end

--// Return \--
return setmetatable(Widgets, {
	__call = function(self, ...)
		return rawget(self, "new")(...)
	end,
})
