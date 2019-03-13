# TES3MP-UniqueItems

Ensure that unique items stay unique!

Unique items (based on an internal, appendable list) are now limited to one at a time.  Any extras that happen to be found or spawned in will be zapped out of existence.

Players that haven't logged in for a certain amount of time (30 days by default) will lose any unique items they are holding (when the server restarts.)

## Usage

1. Place `UniqueItems.lua` into your `CoreScripts/scripts` directory.  Symlinks are OK.

1. Place the `UniqueItemsDB.json` file into the `CoreScripts/data/UniqueItems`.  Create the directory, symlinks are OK.

1. Add the following to `CoreScripts/scripts/customScripts.lua`:

        require("UniqueItems")

1. Optionally configure the `config.idleDaysLimit` value to suit your liking.
