local _Table = require(script.Parent.Modules.Table)
local _TopbarPlus = require(script.Parent.Modules.TopbarPlus)
local _TweenModule = require(script.Parent.Modules.TweenService)
local _buttonBubbleClick = require(script.Parent.Modules.ButtonClickBubble)
local _Graphing = require(script.Parent.Modules.Graphing)
local _MouseHover = require(script.Parent.Components.UI.Modules.MouseHover)

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

	customRichTextColors: HexColors,
	GroupId: number,
	Data: { [any]: any },
	Identifier: string,

	clearAllChildren: (Parent: Instance, excludedClassNames: { string }?) -> (),
	Disconnect: (data: { [any]: RBXScriptConnection } | RBXScriptConnection) -> (),

	TopbarPlus: typeof(_TopbarPlus),
	Tweens: typeof(_TweenModule),
	buttonClickBubble: typeof(_buttonBubbleClick),
	Table: typeof(_Table),
	Graphing: typeof(_Graphing),
	MouseHover: _MouseHover.MouseHoverKind,

	_warn: (starter: string, ...any) -> (),
	_debug: (starter: string, ...any) -> (),
}

return nil
