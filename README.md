# Illusion-HealthScript
Simple Server Script to replace the base health scripts from Player.Character by one single Script 

It's based on Roblox base script but modified to it detects whenever the Character is added to Workspace etc..

To be placed in ServerScriptService.

----

The base constants here you can change in the script
```luau
REGEN_RATE = 1 / 20
REGEN_STEP = 0.01
REGEN_DELAY = 2
```

These three lines here are necessary: When the server start, they will create an instance with the name "health" which will prevent any health script to be added to Player.Character when it's added.
Doing that actually does prevent the script from being created, while just deleting the script means it started running, and it's not a behaviour we would like.
```luau
local replace = Instance.new("IntValue")
replace.Name = "health"
replace.Parent = game:GetService("StarterPlayer").StarterCharacterScripts
```
Rest is basic scripting.
