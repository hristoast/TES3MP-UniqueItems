# TES3MP-UniqueItems

Ensure that unique items stay unique!

Unique items (based on an internal, appendable list) are now limited to one at a time.  Any extras that happen to be found or spawned in will be zapped out of existence.

Players that haven't logged in for a certain amount of time (30 days by default) will lose any unique items they are holding (when the server restarts.)

## Usage

1. Near the top of `serverCore.lua`, below `menuHelper = require("menuHelper")`, add this:

        UniqueItems = require("UniqueItems")

1. In `serverCore.lua`, in the `OnServerPostInit` definition, place this:

        UniqueItems.OnServerPostInit()

    Right below this line:

        ResetAdminCounter()

1. In `serverCore.lua`, in the `OnPlayerConnect` definition, place this:

        UniqueItems.OnPlayerConnect(pid)

    Right below these lines:

        tes3mp.LogAppend(enumerations.log.INFO, "- New player is named " .. playerName)
        eventHandler.OnPlayerConnect(pid, playerName)

1. In `serverCore.lua`, in the `OnPlayerDisconnect` definition, place this:

        UniqueItems.OnPlayerDisconnect(pid)

    Right above this line:

        tes3mp.SendMessage(pid, message, true)

1. In `serverCore.lua`, in the `OnPlayerInventory` definition, place this:

        UniqueItems.OnPlayerInventory(pid)

    Right below this line:

        eventHandler.OnPlayerInventory(pid)

1. In `serverCore.lua`, in the `OnObjectSpawn` definition, place this:

        UniqueItems.OnObjectSpawn(pid, cellDescription)

    Right below this line:

        eventHandler.OnObjectSpawn(pid, cellDescription)

1. Optionally configure the `config.idleDaysLimit` value to suit your liking.
