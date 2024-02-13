---
sidebar_position: 1
---

## Why did we make commands?
We made commands because we realized that maybe some developers aren't experienced enough to use the API, or they just want a simple way to use the API. Commands were the only way to make this possible. With our commands you can fully control the API while also being secure in doing so.

## How do commands work?
Our commands work by taking the prefix, first checking that it's correct and removing it from the entire command. Then it splits the command into pieces, leaving the command's name and arguments. It then checks if the command exists, and if it does, it runs the command with the arguments. If it doesn't, it will ignore the message and it's contents.

## Can I create my own commands?
Yes! You can create your own commands. Head over to the [Adding Commands](/VibezAPI/docs/Features/Commands/Adding%20Commands) page to learn how to create your own commands.

## Can I create my own shorteners?
Yes! You can create your own shorteners. Head over to the [Command Operation Codes](/VibezAPI/docs/Features/Commands/Command%20Operation%20Codes) page to learn how to create your own shorteners.

## Can I use the API with other admin systems?
Yes you can, however you will need to use the [Global API](/VibezAPI/docs/Features/Global) and you'll need to script it yourself.

## Command Settings
```lua
Enabled = false,
useDefaultNames = true,

MinRank = 255,
MaxRank = 255,

Prefix = "!",
Alias = {},
```