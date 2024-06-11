--[=[
	Builder for discord embeds.
    
	@class EmbedBuilder
]=]
local Embed = {}
local Class = {}
Class.__index = Class

local embedTypes = require(script.Parent.Parent.Types)
local RoTime = require(script.Parent.Parent.RoTime)

--// Local Functions \\--
local function checkCharLimit(value: string, charLimit: number): boolean
	return (string.len(tostring(value)) <= charLimit)
end

--// Class Functions \\--
--[=[
	@function new
	Creates the embed class
	@return EmbedBuilder

	@within EmbedBuilder
	@since 1.1.0
]=]
---
function Embed.new()
	local self = setmetatable({}, Class)

	self.className = "Embed"
	self._used = false
	self.data = {
		title = nil,
		description = nil,
		type = "rich",
		fields = setmetatable({}, {
			__newindex = function(tbl, index, value)
				if not tonumber(index) then
					warn("[Vibez]: Field index has to be a number.")
					return
				end

				if typeof(value) ~= "table" then
					warn("[Vibez]: Field has to be a type of 'table', not '" .. typeof(value) .. "'")
					return
				end

				if value["name"] == nil or value["value"] == nil then
					warn("[Vibez]: Missing field 'value' or 'name', both are required.")
					return
				end

				if #tbl > 24 then -- Subtract one due to __newindex being middleware to insertions.
					warn("[Vibez]: Fields length is over max 25, truncated to fit newest field.")
					table.remove(tbl, 1)
				end

				rawset(tbl, index, value)
			end,
		}),
		color = tonumber("0x" .. Color3.fromRGB(244, 146, 255):ToHex()),
	}

	return self
end

--[=[
	Updates the _used variable within the class. (Mainly for loggers)
	@return EmbedBuilder

	@within EmbedBuilder
	@since 1.1.0
	@private
]=]
---
function Class:_updateUsed()
	self._used = true
end

--[=[
	Adds a description to the embed.
	@param description string
	@return EmbedBuilder

	@tag Required
	@tag Chainable
	@within EmbedBuilder
	@since 1.1.0
]=]
---
function Class:setDescription(description: string): embedTypes.Embed
	self:_updateUsed()
	if not checkCharLimit(description, 4096) then
		warn("[Vibez]: Setting the embed's description failed due to exceeded character limit of 4096!")
		return self
	end

	self.data.description = description
	return self
end

--[=[
	Adds a title to the embed.
	@param title string
	@return EmbedBuilder

	@tag Required
	@tag Chainable
	@within EmbedBuilder
	@since 1.1.0
]=]
---
function Class:setTitle(title: string): embedTypes.Embed
	self:_updateUsed()
	if not checkCharLimit(title, 256) then
		warn("[Vibez]: Setting the embed's title failed due to exceeded character limit of 256!")
		return self
	end

	self.data.title = title
	return self
end

--[=[
    Adds a field to the embed.
    @param name string
    @param value string
    @param isInline boolean
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:addField(name: string, value: string, isInline: boolean?): embedTypes.Embed
	self:_updateUsed()
	if not checkCharLimit(name, 256) then
		warn("[Vibez]: Insertion of field has stopped due to a higher character limit of 256!")
		return self
	end

	if not checkCharLimit(name, 1024) then
		warn("[Vibez]: Insertion of field has stopped due to a higher character limit of 1024!")
		return self
	end

	self.data.fields[#self.data.fields + 1] = {
		name = name,
		value = value,
		inline = isInline or false,
	}
	return self
end

--[=[
    Clears the fields data.
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:clearFields(): embedTypes.Embed
	table.clear(self.data.fields)
	return self
end

--[=[
    Sets a footer to the embed.
    @param text string
    @param iconUrl string?
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:setFooter(text: string, iconUrl: string?): embedTypes.Embed
	self:_updateUsed()
	if not checkCharLimit(text, 2048) then
		warn("[Vibez]: Insertion of footer has suspended due to exceeding the character limit of 2048!")
		return self
	end

	if iconUrl ~= nil and string.match(string.lower(tostring(iconUrl)), "https://") == nil then
		self._api:_warn("'setFooter' iconURL requires an external roblox image!")
		iconUrl = nil
	end

	self.data.footer = {
		text = text,
		icon_url = iconUrl,
	}
	return self
end

--[=[
    Sets the embed thumbnail.
    @param url string
    @param height number?
    @param width number?
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:setThumbnail(url: string, height: number?, width: number?): embedTypes.Embed
	self:_updateUsed()
	if string.match(string.lower(url), "https://") == nil then
		self._api:_warn("'setThumbnail' requires an external roblox image!")
		return self
	end

	self.data.thumbnail = {
		url = url,
		height = height,
		width = width,
	}
	return self
end

--[=[
    Sets the color of the embed.
    @param color Color3 | string | number
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:setColor(color: Color3 | string | number): embedTypes.Embed
	self:_updateUsed()
	if typeof(color) == "Color3" then
		color = tonumber("0x" .. color:ToHex())
	end

	self.data.color = tonumber(color)
	return self
end

--[=[
    Sets the author of the embed.
    @param name string
    @param url string?
    @param iconUrl string?
    @return EmbedBuilder

    @tag Chainable
    @within EmbedBuilder
    @since 1.1.0
]=]
---
function Class:setAuthor(name: string, url: string?, iconUrl: string): embedTypes.Embed
	self:_updateUsed()
	if not checkCharLimit(name, 256) then
		warn("[Vibez]: Insertion of author name has stopped due to exceeding the character limit of 256!")
		return self
	end

	self.data.author = {
		name = name,
		url = url,
		icon_url = iconUrl,
	}
	return self
end

--[=[
	Sets the timestamp of the embed. (DEPRECATED)
	-- @param timeStamp number | "Auto"
	@return EmbedBuilder

	```lua
	Embed:setTimestamp()
	```

	@tag Chainable
	@within EmbedBuilder
	@since 1.1.0
	@private
]=]
---
function Class:setTimestamp(unixTimeStamp: (number | string | "auto")?): embedTypes.Embed
	unixTimeStamp = unixTimeStamp or "auto"

	if typeof(unixTimeStamp) == "string" then
		unixTimeStamp = string.lower(unixTimeStamp)
	end

	local newTime = RoTime.new()
	if unixTimeStamp ~= "auto" and tonumber(unixTimeStamp) ~= nil then
		newTime:fromUnix(unixTimeStamp)
	end

	self.data.timestamp = newTime:getTimestamp()
	newTime:Destroy()

	return self
end

--[=[
	Resolves the data within the embed to be used for webhooks.
	@return {any}

	@private
	@within EmbedBuilder
	@since 1.1.0
]=]
---
function Class:_resolve(): { any }
	return self._used and self.data or nil
end

return Embed
