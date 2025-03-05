---
sidebar_position: 2
---

# Ranking Sticks
Every great module always includes ranking sticks. So here's our version of it; you're able to configure it to your needs and ensure it works 99% of the time. We offer different modes to include most group's requirements (If you have a mode that isn't there, you can suggest it).

### Modes
The modes we offer are:

|       Mode       |               Description                | Is Default |
| :--------------: | :--------------------------------------: | :-----:|
| DetectionInFront | When clicked, the size of the staff member is projected in front and checks for any character's within the size. | ✔️ |
| ClickOnPlayer | Only performs the ranking request when a player is clicked on. | ✖️ |

### Setup
**NOTE:** Rank sticks follows the removed <a href="/docs/Features/Commands/About">Commands</a> format to determine whether to add a stick type or not.

```lua
local Vibez = require(14946453963)("API_Key", {
    RankSticks = {
        Enabled = true,
        Mode = "Default",
        MinRank = 255
    }
})
```