---
sidebar_position: 1
---

Let's be honest, there's nothing worse than a potential worker doing an application and not being automatically ranked by a system, days or even weeks of them spamming the group wall (or discord DMs) begging for their rank. This is why we have the ranking API. It allows you to rank workers in game without having to do it manually. This is a very simple API to use, and can be used in many different ways.

## How to use
At the moment there are only 4 ranking actions you can perform: `Promote`, `Demote`, `Fire`, and `SetRank`. Each of these actions have the same parameters, except for `SetRank` which has an extra parameter. The parameters are as follows:

| Parameter | Type | Description | setRank Only |
| :---: | :---: | :---: | :---: |
| `Player` | `string` or `number` | The user ID/Name of the worker you want to rank. | ❌ |
| `Rank` | `string` or `number` | The rank ID/Name/RoleId you want to rank the worker to. | ✔ |

## What's the difference between Promote and promoteWithCaller?
Under the hood, the `Promote` method uses `promoteWithCaller` to rank the player. When using `Promote` you'll receive a discord log of "An automatic system has triggered a ranking action." instead of "Username (UserId) has triggered a ranking action.". This is because `Promote` is used for automatic ranking, and `promoteWithCaller` is used for commands/interface/ranking-stick promotions, allowing the API to distinguish between promotions with and without a player manually firing the method.

## Why isn't it working?
There's many reasons why the ranking API may fail, maybe your discord bot is offline, or maybe the worker is already ranked to the rank you're trying to rank them to. If you're having issues with the ranking API, please join our discord below and ask for help in the support channel.

<iframe src="https://discord.com/widget?id=528920896497516554&theme=dark" width="350" height="500" allowtransparency="true" frameborder="0" sandbox="allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts"></iframe>