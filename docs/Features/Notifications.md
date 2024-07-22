---
sidebar_position: 5
---

### What are notifications?
Notifications are a way to tell the user if their request went through successfully or not. Their main purpose is to inform the user of the status of their request.

### When are notifications used?
Notifications are mainly used when using the: UI, [Commands](/VibezAPI/docs/Features/Commands/About/), or RankSticks. Notifications are intended to tell the user if their request went throught successfully or not.

### Can I send custom notifications?
At this time, you cannot access notifications directly with our API. However, you can access them via the [Global API](/VibezAPI/docs/Features/Global).

### Notification Settings
```lua
Enabled = true, -- Determines whether or not notifications are enabled.

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