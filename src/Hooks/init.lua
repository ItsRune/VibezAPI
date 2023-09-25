--[=[
    @class Hooks
    Creates easy to use webhook creation / usage.
]=]

--[=[
    @interface httpResponse
	.Body { any }
	.Headers { [string]: any }
	.StatusCode number
	.StatusMessage string?
	.Success boolean
	.rawBody string
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
    @return Hooks

	@within Hooks
	@since 0.2.0
]=]
---
function Hooks.new(vibezApi: Types.vibezApi, webhook: string): Types.vibezHooks
	local self = setmetatable({}, Class)

	self.webhook = webhook
	self.Api = vibezApi
	self.toSend = {}

	if not self.Api or typeof(self.Api) ~= "table" or self.Api[""] then
		warn("[Vibez]: 'Hooks' module cannot be used without the API wrapper!")
		return nil
	end

	-- HTTP Check will destroy the api class itself, not necessary here.
	self:_parseWebhook() -- Will warn if it cant parse properly

	return self
end

--[=[
	Sets the webhook to a new one.
	@param newWebhook string
	@return Hooks

	@within Hooks
	@since 0.2.0
]=]
---
function Class:setWebhook(newWebhook: string): Types.vibezHooks
	self.webhook = newWebhook
	self:_parseWebhook()
end

--[=[
	Sets the content of the webhook.
	@param content string
	@return Hooks

	@within Hooks
	@since 0.2.0
]=]
function Class:setContent(content: string?)
	self.toSend.content = content
	return self
end

--[=[
	Creates an embed with the embed creator.
	@param handler (embedCreator: Embed) -> Embed
	@return Hooks

	@within Hooks
	@since 0.2.0
]=]
---
function Class:addEmbedWithCreator(handler: (embedCreator: Types.embedCreator) -> Types.Embed): Types.vibezHooks
	assert(
		typeof(handler) == "function",
		"parameter 'handler' expected a 'function' but received a '" .. typeof(handler) .. "'"
	)

	local createdEmbed = handler(embedClass.new())

	if not self.toSend["embeds"] then
		self.toSend.embeds = {}
	end

	if createdEmbed["className"] ~= nil and createdEmbed["className"] == "Embed" then
		table.insert(self.toSend.embeds, createdEmbed:_resolve())
	end

	return self
end

--[=[
	Creates an embed with table data.
	@param data {[string]: any}
	@return Hooks

	@within Hooks
	@since 0.2.0
]=]
---
function Class:addEmbedWithoutCreator(data: { [string]: any }): Types.vibezHooks
	if not self.toSend["embeds"] then
		self.toSend.embeds = {}
	end

	table.insert(self.toSend.embeds, data)
	return self
end

--[=[
	Parses the webhook into the ID and Token.
	@param webhookToUse string?
	@return { ID: string, Token: string }

	@within Hooks
	@since 0.2.0
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
    Posts a new webhook.
	@return Hooks

	@yields
	@within Hooks
	@since 0.2.0
]=]
---
function Class:Post()
	local webhookData = self:_parseWebhook()

	warn(self.toSend)
	local isOk, response =
		self.Api:Http(string.format("/hooks/%s/%s", webhookData.ID, webhookData.Token), "post", nil, self.toSend)

	if not isOk then
		self.Api:_warn(response.Body.message)
	end

	return self
end

return Hooks
