---
sidebar_position: 7
---

### What are Actions?
Actions are like commands that you'd use with our commands/interface/rank sticks. Every time you use one of these products, you're essentially running an action. Actions are the building blocks of our products and are what make them so powerful.

### What's the point to binding a function to them?
Binding a function to an action allows you to run a function every time the action is used. This is useful for things like logging or even just to run a function when a command is used (There's many more use cases than these).

### How do I bind a function to an action?
To bind a function to an action, you'll need to use the `bindToAction` method. This method takes 3 parameters: a unique identifier for the bound action, the action to bind to, and the function to bind to the action.

```lua
Vibez:bindToAction("uniqueIdentifier", "promote", function(response)
    print("Promote action was used!")
end)
```

### Why do I need a unique identifier?
We allow for the developer to unbind actions, and you'd pass this in with the `unbindFromAction` method as a parameter. This is why it's important to have a unique identifier for each bound action.

### How do I unbind a function from an action?
To unbind a function from an action, you'll need to use the `unbindFromAction` method. This method takes 2 parameters: the unique identifier for the bound action, and the action to unbind from.

```lua
Vibez:unbindFromAction("uniqueIdentifier", "promote")
```

### What actions can I bind to?
Currently you can only bind to 4 actions: `Promote`, `Fire`, `Demote` & `Blacklist`. We plan to add more actions in the future, but for now these are the only actions you can bind to.