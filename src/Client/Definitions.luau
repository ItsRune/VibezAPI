local _Table = require(script.Parent.Modules.Table)
local _TopbarPlus = require(script.Parent.Modules.TopbarPlus)
local _TweenModule = require(script.Parent.Modules.TweenService)
local _buttonBubbleClick = require(script.Parent.Modules.ButtonClickBubble)

type HexColors = {
	Actions: string,
	Error: string,
	Group: string,
	Info: string,
	Success: string,
	Users: string,
	Warning: string,
}

export type componentData = {
	remoteFunction: RemoteFunction,
	remoteEvent: RemoteEvent,

	GroupId: number,
	Data: { [any]: any },
	Identifier: string,

	TopbarPlus: typeof(_TopbarPlus),
	Tweens: typeof(_TweenModule),
	buttonClickBubble: typeof(_buttonBubbleClick),
	Table: typeof(_Table),

	customRichTextColors: HexColors,
	clearAllChildren: (Parent: Instance, excludedClassNames: { string }?) -> (),
	Disconnect: (data: { [any]: RBXScriptConnection } | RBXScriptConnection) -> (),

	_warn: (starter: string, ...any) -> (),
	_debug: (starter: string, ...any) -> (),
}

return nil
