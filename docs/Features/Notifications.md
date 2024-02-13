---
sidebar_position: 5
---

## What are notifications?
Notifications are a way to tell the user if their request went through successfully or not. Their main purpose is to inform the user of the status of their request, however you can trigger a notification yourself using our [Global API](/VibezAPI/docs/Features/Global).

## When are notifications used?
Notifications are mainly used when using the: UI, [Commands](/VibezAPI/docs/Features/Commands/), or RankSticks. Notifications are intended to tell the user if their request went throught successfully or not.

## Notification Settings
```lua
Enabled = true, -- Determins whether or not notifications are enabled.

Font = Enum.Font.Gotham, -- The font for notifications.
FontSize = 16, -- The default font size. (Fit for mobile users)
keyboardFontSizeMultiplier = 1.25, -- Multiplier for fontsize keyboard users
delayUntilRemoval = 20, -- The time it takes for a notification to be removed.

entranceTweenInfo = { -- Tween info for when a notification enters the screen.
    Style = Enum.EasingStyle.Quint, -- Tween easing style.
    Direction = Enum.EasingDirection.InOut, -- Tween easing direction.
    timeItTakes = 1, -- How long the tween takes to complete. (Seconds)
},

exitTweenInfo = { -- Tween info for when a notification exits the screen.
    Style = Enum.EasingStyle.Quint, -- Tween easing style.
    Direction = Enum.EasingDirection.InOut, -- Tween easing direction.
    timeItTakes = 1, -- How long the tween takes to complete. (Seconds)
},
```