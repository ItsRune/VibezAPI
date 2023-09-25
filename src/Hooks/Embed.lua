--[=[
    @class Embed
    @within Hooks
]=]
local Embed = {}
local Class = {}
Class.__index = Class

local embedTypes = require(script.Parent.Parent.Types)

--[=[
    @function new
	Creates the embed class
    @return Embed
	
	@within Hooks
	@since 0.2.0
]=]
function Embed.new()
	local self = setmetatable({}, Class)

	self.className = "Embed"
	self.data = {
		title = nil,
		description = nil,
		fields = {},
		color = tonumber("0x" .. Color3.fromRGB(244, 146, 255):ToHex()),
	}

	return self
end

--[=[
    Adds a description to the embed.
    @param description string
    @return Embed

    @within Embed
    @since 0.2.0
]=]
function Class:addDescription(description: string): embedTypes.Embed
	self.data.description = description
	return self
end

--[=[
    Adds a title to the embed.
    @param title string
    @return Embed

    @within Embed
    @since 0.2.0
]=]
function Class:addTitle(title: string): embedTypes.Embed
	self.data.title = title
	return self
end

--[=[
    Adds a field to the embed.
    @param name string
    @param value string
    @param isInline boolean
    @return Embed

    @within Embed
    @since 0.2.0
]=]
function Class:addField(name: string, value: string, isInline: boolean?): embedTypes.Embed
	table.insert(self.data.fields, {
		name = name,
		value = value,
		inline = isInline or false,
	})
	return self
end

--[=[
    Clears the fields data.
    @return Embed

    @within Embed
    @since 0.2.0
]=]
function Class:clearFields(): embedTypes.Embed
	table.clear(self.data.fields)
	return self
end

--[=[
    Sets the color of the embed.
    @param color Color3 | string | number
    @return Embed

    @within Embed
    @since 0.2.0
]=]
function Class:setColor(color: Color3 | string | number): embedTypes.Embed
	if typeof(color) == "Color3" then
		color = tonumber("0x" .. color:ToHex())
	end

	self.data.color = color
	return self
end

--[=[
    Resolves the data within the embed to be used for webhooks.
    @return {any}

    @tag Internal
    @within Embed
    @since 0.2.0
]=]
function Class:_resolve(): { any }
	return self.data
end

return Embed
