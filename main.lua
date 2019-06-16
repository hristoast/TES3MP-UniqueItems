--[[
   References for unique items in vanilla Morrowind:

       http://en.uesp.net/wiki/Morrowind:Eltonbrand
       http://en.uesp.net/wiki/Morrowind:Goldbrand
       http://en.uesp.net/wiki/Morrowind:Mentor%27s_Ring
       http://en.uesp.net/wiki/Morrowind:Artifacts
       https://en.uesp.net/wiki/Morrowind:Unique_Armor
       http://en.uesp.net/wiki/Morrowind:Unique_Clothing
]]--
local UniqueItems = {}

UniqueItems.scriptName = "UniqueItems"

UniqueItems.defaultConfig = {
   announcePickups = true,
   dbUpdateInterval = 24,
   idleDaysLimit = 30,
   rare_item_ids = {
      "Akatosh Ring", "amulet_aundae", "amulet_berne", "amulet_quarra", "amulet_unity_uniq", "amulet_usheeja",
      "amulet of ashamanu", "amulet of levitating", "amulet of shadows", "amuletfleshmadewhole_uniq",
      "artifact_amulet of heartfire", "artifact_amulet of heartheal", "artifact_amulet of heartrime",
      "artifact_amulet of heartthrum", "aryongloveleft", "aryongloveright", "axe_queen_of_bats_unique",
      "belt of heartfire", "Belt of Northern Knuck Knuck", "belt of the armor of god", "bitter_hand",
      "black_blindfold_glove", "blood ring", "bloodworm_helm_unique", "boots_apostle_unique",
      "boots of blinding speed[unique]", "Caius_pants", "Caius_ring", "caius_shirt", "cephalopod_helm_HTNK",
      "conoon_chodala_boots_unique", "claymore_chrysamere_unique", "claymore_iceblade_unique", "cleaverstfelms",
      "common_glove_l_moragtong", "common_glove_r_moragtong", "common_shoes_02_surefeet", "crosierstllothis",
      "cuirass_savior_unique", "Daedric_special", "daedric_crescent_unique", "daedric_greaves_htab",
      "daedric_helm_clavicusvile", "daedric_cuirass_htab", "daedric_scourge_unique", "dagger_fang_unique",
      "darksun_shield_unique", "dragonbone_cuirass_unique", "dreugh_cuirass_ttrm", "dwarven_hammer_volendrung",
      "ebon_plate_cuirass_unique", "ebony_bow_auriel", "ebony_closed_helm_fghl", "ebony_shield_auriel", "ember hand",
      "erur_dan_cuirass_unique", "expensive_shirt_hair", "fork_horripilation_unique", "gauntlet_fists_l_unique",
      "gauntlet_fists_r_unique", "Gauntlet_of_Glory_left", "gauntlet_of_glory_right", "gauntlet_horny_fist_l",
      "gauntlet_horny_fist_r", "heart ring", "helm_bearclaw_unique", "hort_ledd_robe_unique", "hortatorbelt",
      "hortatorring", "hortatorrobe", "icecap_unique", "imperial_helm_frald_uniq", "katana_bluebrand_unique",
      "katana_goldbrand_unique", "keening", "Left_Hand_of_Zenithar", "longbow_shadows_unique", "longsword_umbra_unique",
      "lords_cuirass_unique", "mace of molag bal_unique", "madstone", "malipu_ataman's_belt", "mehrunes'_razor_unique",
      "misc_vivec_ashmask_01_fake", "misc_vivec_ashmask_01", "moon_and_star", "Mountain Spirit", "peakstar_belt_unique",
      "peakstar_pants_unique", "Right_Hand_of_Zenithar", "ring_denstagmer_unique", "ring_dahrkmezalf_uniq",
      "ring_equity_uniq", "ring_fathasa_unique", "ring_keley", "ring_khajiit_unique", "ring_marara_unique",
      "ring_mentor_unique", "ring_phynaster_unique", "ring_shashev_unique", "ring_surrounding_unique",
      "ring_vampiric_unique", "ring_warlock_unique", "ring_wind_unique", "robe_of_erur_dan", "seizing", "Septim Ring",
      "shadow_shield", "shield of the undaunted", "shoes of st. rilms", "soul ring", "spear_mercy_unique",
      "spell_breaker_unique", "staff_hasedoki_unique", "staff_magnus_unique", "Stendarran Belt", "sunder", "teeth",
      "tenpaceboots", "thong", "towershield_eleidon_unique", "warhammer_crusher_unique", "wraithguard",
      "wraithguard_jury_rig", "Zenithar's_Warning", "Zenithar's_Wiles"
   }
}

UniqueItems.config = DataManager.loadConfiguration(UniqueItems.scriptName, UniqueItems.defaultConfig)

UniqueItems.defaultData = {}

local lfs = require("lfs")

local cellDataPath = tes3mp.GetModDir() .. "/cell/"
local playerDataPath = tes3mp.GetModDir() .. "/player/"

local idleSecondsLimit = 60 * 60 * 24 * UniqueItems.config.idleDaysLimit
local updateTimeSeconds = 60 * 60 * 24 * UniqueItems.config.dbUpdateInterval

local dbUpdateTimer = tes3mp.CreateTimerEx("UniqueItemDBupdateTimerExpired",
                                           time.seconds(updateTimeSeconds), "i", 0)

local function dbg(msg)
   tes3mp.LogMessage(enumerations.log.VERBOSE, "[ UniqueItems ]: " .. msg)
end

local function warn(msg)
   tes3mp.LogMessage(enumerations.log.WARN, "[ UniqueItems ]: " .. msg)
end

local function info(msg)
   tes3mp.LogMessage(enumerations.log.INFO, "[ UniqueItems ]: " .. msg)
end

local function removeItemValueAndClean(dataTable, playerName, value)
   --[[
      Small wrapper around removing player entries from the DB if they have no uniques.
   ]]--
   dbg("Called \"removeItemValueAndClean\"")
   tableHelper.removeValue(dataTable[playerName]["items"], value)

   -- THANKS: https://stackoverflow.com/a/1252776
   local next = next
   if next(dataTable[playerName]["items"]) == nil then
      dataTable[playerName] = nil
   else
      tableHelper.cleanNils(dataTable[playerName])
   end

   DataManager.saveData(UniqueItems.scriptName, dataTable)
end

local function updateDB(action, playerName, value, dataTable, updateLastSeen)
   --[[
      Small wrapper around inserting a key-value pair into a table, or removing a value from it.
   ]]--
   dbg("Called \"updateDB\" for action \"" .. action .. "\"")

   if dataTable[playerName] == nil then
      dataTable[playerName] = {}
      dataTable[playerName]["items"] = {}
   end

   if action == "insert" then
      dbg("Inserting into the DB: " .. playerName .. ", " .. value)
      if updateLastSeen then
         dataTable[playerName]["lastSeen"] = os.time()
      end

      table.insert(dataTable[playerName]["items"], value)
      DataManager.saveData(UniqueItems.scriptName, dataTable)

   elseif action == "remove" then
      dbg("Removing from the DB: " .. playerName .. ", " .. value)
      if updateLastSeen then
         dataTable[playerName]["lastSeen"] = os.time()
      end

      removeItemValueAndClean(dataTable, playerName, value)
      DataManager.saveData(UniqueItems.scriptName, dataTable)
   end
end

local function whoHoldsItem(data, itemRefId)
   --[[
      Given a data table, return the player name if they hold the given item (by itemRefId.)

      If they do not hold the item, return nil.
   ]]--
   dbg("Called \"whoHoldsItem\" with item: " .. itemRefId)
   for player, _ in pairs(data) do
      if player and tableHelper.containsValue(data[player]["items"], itemRefId) then
         return player
      end
   end
   return nil
end

local function handleDupeUnique(pid, itemName, playerHas)
   --[[
      Called when a player picks up a unique item that's already claimed.
   ]]--
   local player = Players[pid]
   dbg("Called \"handleDupeUnique\" with itemName " .. itemName .. " and player " .. player.accountName .. ".")
   local itemInvIndex = tableHelper.getIndexByNestedKeyValue(player.data.inventory, "refId", itemName)

   if playerHas then
      -- Ensure they have only one.
      warn("Reducing count of " .. itemName .. " on " .. player.accountName .. " to one.")
      player.data.inventory[itemInvIndex].count = 1
   else
      -- Ensure they have none!
      warn("Reducing count of " .. itemName .. " on " .. player.accountName .. " to nil.")
      player.data.inventory[itemInvIndex] = nil
   end

   player:LoadInventory()
   player:LoadEquipment()
end

local function updateLastSeen(pid)
   --[[
      Small wrapper around updating a player's lastSeen value.
   ]]--
   dbg("Called \"updateLastSeen\" for pid " .. pid)
   local dbData = DataManager.loadData(UniqueItems.scriptName, UniqueItems.defaultData)
   local playerName = Players[pid].accountName
   local playerInDB = dbData[playerName] ~= nil

   if playerInDB then
      dbData[playerName]["lastSeen"] = os.time()
      DataManager.saveData(UniqueItems.scriptName, dbData)
   end
end

function UniqueItems.OnObjectSpawn(eventStatus, pid, cellDescription)
   --[[
      Remove held uniques from cells when they spawn anew.

      This has to be done here versus in OnCellLoad().
   ]]--
   info("Called \"OnObjectSpawn\" for " .. logicHandler.GetChatName(pid) ..
           " and cell " .. cellDescription)

   local dbData = DataManager.loadData(UniqueItems.scriptName, UniqueItems.defaultData)
   local heldUniques = {}
   local thisCell = LoadedCells[cellDescription]

   for _, player in pairs(dbData) do
      for _, item in pairs(player["items"]) do
         table.insert(heldUniques, item)
      end
   end

   for index, thing in pairs(thisCell.data.objectData) do
      if thing.inventory then
         for iIndex, item in pairs(thing.inventory) do
            if tableHelper.containsValue(heldUniques, item.refId) then

               warn("Removing unique \"" .. item.refId .. "\" from cell \""
                       .. cellDescription .. "\" as it is already held by a player.")

               -- TODO: This leaves the item viewable but not obtainable.
               thisCell.data.objectData[index].inventory[iIndex] = nil
               -- TODO: For now, disable the container if possible.
               logicHandler.RunConsoleCommandOnObject(pid, "Disable", cellDescription, index, true)
               -- TODO: Can the cell be reloaded at this point?
               thisCell:Save()

            end
         end
      end
   end
end

function UniqueItems.OnPlayerAuthentified(eventStatus, pid)
   --[[
      Ensure the player's lastSeen value is updated when they sign on.
   ]]--
   info("Called \"OnPlayerAuthentified\" for pid " .. pid)
   updateLastSeen(pid)
end

function UniqueItems.OnPlayerDisconnect(eventStatus, pid)
   --[[
      Ensure the player's lastSeen value is updated when they sign out.
   ]]--
   info("Called \"OnPlayerDisconnect\" for pid " .. pid)
   updateLastSeen(pid)
end

local function onlyOne(pid, itemName)
   dbg("Called \"onlyOne\" for pid " .. pid .. " and itemName \"" .. itemName .. "\".")
   local player = Players[pid]
   local itemInvIndex = tableHelper.getIndexByNestedKeyValue(player.data.inventory, "refId", itemName)
   if player.data.inventory[itemInvIndex].count > 1 then
      player.data.inventory[itemInvIndex].count = 1
      player:LoadInventory()
      player:LoadEquipment()
   end
end

function UniqueItems.OnPlayerInventory(eventStatus, pid)
   --[[
      When the player opens their inventory UI.
      It's possible for an item to be added this way.
   ]]--
   info("Called \"OnPlayerInventory\" for pid " .. pid)

   local ADD = 1
   local REMOVE = 2

   local dbData = DataManager.loadData(UniqueItems.scriptName, UniqueItems.defaultData)
   local action = tes3mp.GetInventoryChangesAction(pid)

   for num = 0, tes3mp.GetInventoryChangesSize(pid) - 1 do
      local itemName = tes3mp.GetInventoryItemRefId(pid, num)
      local inDB = tableHelper.containsValue(dbData, itemName, true)
      local isUnique = tableHelper.containsValue(UniqueItems.config.rare_item_ids, itemName)

      if inDB and action == ADD then
         local playerHas = whoHoldsItem(dbData, itemName) == Players[pid].accountName
         warn("Player \"" .. Players[pid].accountName ..
                 "\" has picked up a unique item that's already in the DB: \"" .. itemName .. "\".")
         handleDupeUnique(pid, itemName, playerHas)
         break
      end

      if isUnique and action == ADD then
         warn("Player \"" .. Players[pid].accountName .. "\" has picked up \"" .. itemName .. "\".")
         onlyOne(pid, itemName)
         updateDB("insert", Players[pid].accountName, itemName, dbData, true)

         if UniqueItems.config.announcePickups then
            for _pid, _ in pairs(Players) do
               if _pid == pid then
                  tes3mp.MessageBox(pid, -1, "You've picked up a unique item!")
               else
                  tes3mp.MessageBox(pid, -1, Players[pid].name .. " has picked up a unique item!")
               end
            end
         end

         break
      elseif isUnique and action == REMOVE then
         -- TODO: need to make sure the player placing is the player holding the item in the db (????)
         updateDB("remove", Players[pid].accountName, itemName, dbData, true)
         break
      end

   end
end

local function readCellData()
   --[[
      Read the cell data files and ensure the appropriate status of uniques.
   ]]--
   -- TODO: make this OnCellLoad(eventStatus, pid, cellDescription)
   dbg("Called \"readCellData\"")

   local cellData
   local dbData = DataManager.loadData(UniqueItems.scriptName, UniqueItems.defaultData)
   local cellFiles = {}
   local heldUniques = {}

   for _, player in pairs(dbData) do
      for _, item in pairs(player["items"]) do
         table.insert(heldUniques, item)
      end
   end

   for f in lfs.dir(cellDataPath) do
      if string.match(f, ".json") then
         cellData = jsonInterface.load("/cell/" .. f)

         for index, thing in pairs(cellData.objectData) do
            if thing.inventory then
               for iIndex, item in pairs(thing.inventory) do
                  if tableHelper.containsValue(heldUniques, item.refId) then

                     warn("Removing unique \"" .. item.refId .. "\" from cell \"" .. f ..
                             "\" as it is already held by a player.")
                     cellData.objectData[index].inventory[iIndex] = nil
                  end
               end

            elseif thing.refId and tableHelper.containsValue(heldUniques, thing.refId) then
               warn("Removing unique \"" .. thing.refId .. "\" from cell \"" .. f:gsub(".json", "") ..
                       "\" as it is already held by a player.")
               cellData.objectData[index] = nil
            end
         end

         jsonInterface.save("/cell/" .. f, cellData)
      end
   end
end

local function readPlayerData()
   --[[
      Read the player data files and ensure the appropriate status of uniques.
   ]]--
   dbg("Called \"readPlayerData\"")

   if UniqueItems.config.idleDaysLimit > 0 then

      local dbData = DataManager.loadData(UniqueItems.scriptName, UniqueItems.defaultData)
      local playerFiles = {}

      for f in lfs.dir(playerDataPath) do
         if string.match(f, ".json") then
            local playerData = logicHandler.GetPlayerByName(f:gsub(".json", "")).data
            local playerName = playerData.login.name
            local playerInDB = dbData[playerName] ~= nil
            local uniquesToRemove

            if playerInDB then
               uniquesToRemove = {}
               local withinIdleLimit = os.time() - dbData[playerName]["lastSeen"] < idleSecondsLimit

               for _, itemName in pairs(dbData[playerName]["items"]) do

                  if not tableHelper.containsValue(playerData.equipment, itemName, true)
                  and not tableHelper.containsValue(playerData.inventory, itemName, true) then
                     warn("Removing the item \"" .. itemName .. "\" from inventory of player \"" .. playerName ..
                          "\" because they do not actually have it.")
                     table.insert(uniquesToRemove, itemName)

                  else
                     dbg("Item \"" .. itemName .. "\" still held by player \"" .. playerName .. "\".")

                     if withinIdleLimit then
                        dbg("Not removing the item \"" .. itemName .. "\" from inventory of player \"" ..
                               playerName .. "\".")
                     else
                        warn("Removing the item \"" .. itemName .. "\" from inventory of player \"" .. playerName ..
                                "\" due to idle expiry.")
                        table.insert(uniquesToRemove, itemName)
                     end
                  end

               end
            end

            if uniquesToRemove then
               for _, item in pairs(uniquesToRemove) do
                  local index = tableHelper.getIndexByNestedKeyValue(playerData.inventory, "refId", item)
                  playerData.inventory[index] = nil
                  jsonInterface.save("/players/" .. f, playerData)
                  updateDB("remove", playerName, item, dbData, nil)
               end
            end

         end
      end
   else
      info("Unique ownership expiry has been disabled!")
   end
end

local function updateDatabase()
   readPlayerData()
   readCellData()
   if UniqueItems.config.dbUpdateInterval > 0 then
      tes3mp.StartTimer(dbUpdateTimer)
   else
      warn("Scheduled DB updates are disabled!")
   end
end

function UniqueItemDBupdateTimerExpired()
   dbg("Timer expired!  Re-running...")
   updateDatabase()
end

function UniqueItems.OnServerPostInit()
   info("Called \"OnServerPostInit\"")

   updateDatabase()
end


customEventHooks.registerHandler("OnPlayerAuthentified", UniqueItems.OnPlayerAuthentified)
customEventHooks.registerHandler("OnPlayerInventory", UniqueItems.OnPlayerInventory)
customEventHooks.registerHandler("OnServerPostInit", UniqueItems.OnServerPostInit)

customEventHooks.registerValidator("OnObjectSpawn", UniqueItems.OnObjectSpawn)
customEventHooks.registerValidator("OnPlayerDisconnect", UniqueItems.OnPlayerDisconnect)
