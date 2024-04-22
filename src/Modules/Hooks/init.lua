--[=[
	Creates an easy way to manage and use discord webhooks.

	@class Webhooks
]=]

--[=[
	@prop toSend {any}
	@private
	@within Webhooks
]=]

--[=[
	@prop Api VibezAPI
	@private
	@within Webhooks
]=]

--[=[
	@prop webhook string
	@private
	@within Webhooks
]=]

--[=[
	@interface httpResponse
	.Body { any }
	.Headers { [string]: any }
	.StatusCode number
	.StatusMessage string?
	.Success boolean
	.rawBody string
	@within Webhooks
	@private
]=]
local Hooks = {}
local Class = {}
Class.__index = Class

local embedClass = require(script.Embed)
local Types = require(script.Parent.Types)

--[=[
	Creates the hook class.
	@param vibezApi vibezApi
	@param webhook string
	@return Webhooks
	
	@ignore
	@within Webhooks
	@since 1.1.0
]=]
---
function Hooks.new(vibezApi: Types.vibezApi, webhook: string): Types.vibezHooks
	local self = setmetatable({}, Class)

	self.webhook = webhook
	self.Api = vibezApi
	self.toSend = {}

	if not self.Api or typeof(self.Api) ~= "table" or self.Api[""] then
		self.Api:_warn("[Vibez]: 'Hooks' module cannot be used without the API wrapper!")
		return nil
	end

	-- HTTP Check will destroy the api class itself, not necessary here.
	self:_parseWebhook() -- Will warn if it cant parse properly

	return self
end

--[=[
	Initializes the 'embeds' table
	@return {any?}

	@private
	@within Webhooks
	@since 1.1.0
]=]
---
function Hooks._createEmbedTable(): { any? }
	return setmetatable({}, {
		__newindex = function(tbl, index, value)
			if #tbl > 9 then
				table.remove(tbl, 1)
				index -= 1
			end

			rawset(tbl, index, value)
		end,
	})
end

--[=[
	Sets the webhook to a new one.
	@param newWebhook string
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:setWebhook(newWebhook: string): Types.vibezHooks
	self.webhook = newWebhook
	self:_parseWebhook()
end

--[=[
	Sets the content of the webhook.
	@param content string
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:setContent(content: string?): Types.vibezHooks
	if string.len(tostring(content)) > 2000 then
		self.Api:_warn("[Vibez]: Setting the webhook's content failed due to exceeded character limit of 2000!")
		return self
	end

	self.toSend.content = content
	return self
end

--[=[
	Sets the username of the webhook.
	@param username string
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:setUsername(username: string?): Types.vibezHooks
	if string.len(tostring(username)) > 80 then
		self.Api:_warn("Setting the webhook's username failed due to exceeded character limit of 80!")
		return self
	end

	self.toSend.username = username
	return self
end

--[=[
	Creates an embed with the embed creator.
	@param ... ...(embedCreator: Embed) -> Embed
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:addEmbedWithBuilder(...: (embedCreator: Types.embedCreator) -> Types.Embed): Types.vibezHooks
	local data = { ... }

	for _, handler in ipairs(data) do
		if typeof(handler) ~= "function" then
			self.Api:_warn("parameter 'handler' expected a 'function' but received a '" .. typeof(handler) .. "'")
			continue
		end

		local createdEmbed = handler(embedClass.new())

		if not createdEmbed then
			self.Api:_warn("Embed handler does not return an embed!")
			continue
		end

		if not self.toSend["embeds"] then
			self.toSend.embeds = Hooks._createEmbedTable()
		end

		if createdEmbed["className"] ~= nil and createdEmbed["className"] == "Embed" then
			self.toSend.embeds[#self.toSend.embeds + 1] = createdEmbed:_resolve()
		end
	end

	return self
end

--[=[
	Creates an embed with table data.
	@param data {[string]: any}
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:addEmbed(data: { [string]: any }): Types.vibezHooks
	if not self.toSend["embeds"] then
		self.toSend.embeds = Hooks._createEmbedTable()
	end

	assert(typeof(data) == "table", "parameter 'handler' expected a 'table' but received a '" .. typeof(table) .. "'")
	data["type"] = "rich"

	self.toSend.embeds[#self.toSend.embeds + 1] = data
	return self
end

--[=[
	Toggles text-to-speech. **Default: Disabled**
	@param override boolean?
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:setTTS(override: boolean?): Types.vibezHooks
	if self.toSend["tts"] == nil then
		self.toSend["tts"] = false
	end

	local isToggled = not self.toSend["tts"]

	if override ~= nil then
		isToggled = override
	end

	self.toSend.tts = isToggled
	return self
end

--[=[
	Sets the data of the webhook. (Overwriting anything specified before)
	@param data { any }
	@return Webhooks

	@tag Chainable
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:setData(data: { any }): Types.vibezHooks
	self.toSend = data
	return self
end

--[=[
	Parses the webhook into the ID and Token.
	@param webhookToUse string?
	@return { ID: string, Token: string }

	@private
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:_parseWebhook(webhookToUse: string?): { ID: string, Token: string }?
	local webhook = (webhookToUse ~= nil) and webhookToUse or self.webhook
	local linkId, linkToken = string.match(webhook, "([0-9]+)%/([a-zA-Z0-9-_]+)$")

	if not linkId or not linkToken then
		self.Api:_warn("Webhook is not a valid link to use.")
		return nil
	end

	return {
		ID = linkId,
		Token = linkToken,
	}
end

--[=[
	Destroys the hook class.
	@return nil

	@within Webhooks
	@since 1.1.0
]=]
---
function Class:Destroy()
	table.clear(self)
	setmetatable(self, nil)
	self = nil

	return nil
end

--[=[
	Posts a new webhook.
	@return httpResponse

	@yields
	@within Webhooks
	@since 1.1.0
]=]
---
function Class:Send(): Types.httpResponse
	local webhookData = self:_parseWebhook()
	local isOk, response =
		self.Api:_http(string.format("/hooks/%s/%s", webhookData.ID, webhookData.Token), "post", nil, self.toSend)

	if not isOk or response.StatusCode ~= 200 then
		self.Api:_warn(response.Body.message)
	end

	return response
end

return Hooks
