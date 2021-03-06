# TES3MP-UniqueItems

Ensure that unique items stay unique!

Requires [DataManager](https://github.com/tes3mp-scripts/DataManager) and [LuaFileSystem](https://keplerproject.github.io/luafilesystem/) (included in this repo)!

Unique items are now limited to one at a time.  Any extras that happen to be found or spawned in will be zapped out of existence.

Players that haven't logged in for a certain amount of time (30 days by default) will lose any unique items they are holding.

## Usage

1. Place this repository into your `CoreScripts/scripts/custom/` directory.

1. Place [`lib/lfs.so`](lib/) into your `CoreScripts/lib` directory.

1. Add the following to `CoreScripts/scripts/customScripts.lua`:

        require("custom/UniqueItems/main")

## Options

* `announcePickups`

Boolean.  Announce to all players when a unique item is picked up.  Default: `true`

* `dbUpdateInterval`

Integer.  The number of real world hours between database updates.  Set to `0` to disable.  Default: `24`

* `deathDrop`

Boolean.  Set this to `true` if you have another script that causes items to be dropped on player death.  Default: `false`

* `deathDropMsg`

String.  The message that's displayed when a player dies and drops their items.  Default: `"You've lost your held unique items!"`

* `dupeItemMsg`

String.  The message that's displayed when a player picks up an already held unique.  Default: `"The item you found has disintegrated in your hands!"`

* `idleDaysLimit`

Integer.  The number of days before a player is considered idle and their held uniques removed.  Set to `0` to disable.  Default: `30`

* `rare_item_ids`

Table of strings.  The RefId of any item that's to be considered unique.

The below links were used as a reference for the default list:

* http://en.uesp.net/wiki/Morrowind:Eltonbrand
* http://en.uesp.net/wiki/Morrowind:Goldbrand
* http://en.uesp.net/wiki/Morrowind:Mentor%27s_Ring
* http://en.uesp.net/wiki/Morrowind:Artifacts
* https://en.uesp.net/wiki/Morrowind:Unique_Armor
* http://en.uesp.net/wiki/Morrowind:Unique_Clothing
