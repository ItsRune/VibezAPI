local Table = require(script.Parent.Modules.Table)
local TopbarPlus = require(script.Parent.Modules.TopbarPlus)
local TweenModule = require(script.Parent.Modules.TweenService)
local buttonBubbleClick = require(script.Parent.Modules.ButtonClickBubble)

export type componentData = {
	remoteFunction: RemoteFunction,
	remoteEvent: RemoteEvent,

	GroupId: number,
	Data: { [any]: any },

	TopbarPlus: typeof(TopbarPlus),
	Tweens: typeof(TweenModule),
	buttonClickBubble: typeof(buttonBubbleClick),
	Table: typeof(Table),

	clearAllChildren: (Parent: Instance, excludedClassNames: { string }?) -> (),
	Disconnect: (data: { [any]: RBXScriptConnection } | RBXScriptConnection) -> (),

	_warn: (starter: string, ...any) -> (),
	_debug: (starter: string, ...any) -> (),
}

return nil
