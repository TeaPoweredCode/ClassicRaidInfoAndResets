local _, Addon = ...
local L = Addon.L

RaidInfoUtility = {
    RegionProfiles = {
        [1] = {baseDateTime = 1753196400}, -- US (includes Brazil and Oceania) | Tue Jul 22 2025
        [3] = {baseDateTime = 1752638400} -- Europe (includes Russia) | Wed Jul 16 2025 08:00:00                      
    },
    Raids = {
        {id = 409, name = L["MOLTEN_CORE"], shortHand = "MC", raidDays = 7, iconFrame = nil},
        {id = 249, name = L["ONYXIAS_LAIR"], shortHand = "ONY", raidDays = 5, iconFrame = nil},
        {id = 309, name = L["ZULGURUB"], shortHand = "ZG",  raidDays = 3, iconFrame = nil},
        {id = 469, name = L["BLACKWING_LAIR"], shortHand = "BWL",  raidDays = 7, iconFrame = nil},
        {id = 509, name = L["RUINS_OF_AHNQIRAJ"], shortHand = "AQ20",  raidDays = 3, iconFrame = nil},
        {id = 531, name = L["AHNQIRAJ_TEMPLE"], shortHand = "AQ40",  raidDays = 7, iconFrame = nil},
        {id = 533, name = L["NAXXRAMAS"], shortHand = "NAXX",  raidDays = 7, iconFrame = nil},
    },
    ZGMadness = {
        TimeProfiles = {
            [1] = {regionDateTime = 1751353200},   -- UTC+7
            [3] = {regionDateTime = 1751328000}    -- UTC 
        },
        Bosses = {
            {
                boss = {name="Gri'lek", id = 15082},
                item = {name = "Gri'lek's Blood", id = 19939 , icon = "134806", localName = nil}
            },
            {
                boss = {name="Hazza'rah", id = 15083},
                item = {name = "Hazza'rah's Dream Thread", id = 19942 , icon = "133686", localName = nil}
            },
            {
                boss = {name="Renataki", id = 15084},
                item = {name = "Renataki's Tooth", id = 19940 , icon = "134298", localName = nil}
            },
            {
                boss = {name="Wushoolay", id = 15085},
                item = {name = "Wushoolay's Mane", id = 19941 , icon = "134323", localName = nil}
            }
        },
    },
    SavedIDs = nil
}


function RaidInfoUtility:CalculateResetTime(baseTime, intervalDays)   
    local now = GetServerTime()
    local elapsed = now - baseTime

    local interval = intervalDays * 24 * 60 * 60
    local time_into_cycle = elapsed % interval
    local time_to_next_event = interval - time_into_cycle

    local days = math.floor(time_to_next_event / (24 * 60 * 60))
    local hours = math.floor((time_to_next_event % (24 * 60 * 60)) / 3600)
    local minutes = math.floor((time_to_next_event % 3600) / 60)
    
    local parts = {}
    if days > 0 then table.insert(parts, days .. " " .. L["DAYS"]) end
    if hours > 0 then table.insert(parts, hours .. " " .. L["HRS"]) end
    if minutes > 0 or #parts == 0 then table.insert(parts, minutes .. " " .. L["MINS"]) end
    return table.concat(parts, " ")
end

function RaidInfoUtility:CalculateWZGMaddnessInfo()
    local regionDateTime = self.ZGMadness.TimeProfiles[GetCurrentRegion()].regionDateTime

    local now = GetServerTime()
    local elapsed = now - regionDateTime

    local eightWeeks = 8 * 7 * 24 * 60 * 60
    local twoWeekBlock = 2 * 7 * 24 * 60 * 60

    local timeIntoCycle = elapsed % eightWeeks
    local currentBlock = math.floor(timeIntoCycle / twoWeekBlock) + 1

    local madness = RaidIconPanel.ZGMadness.Bosses[currentBlock]
 
    if madness.item.localName == nil then
        local name = GetItemInfo(madness.item.id)
        if(name) then 
            madness.item.localName = name
            itemName = name
        end
    end

    madness.changeIn = RaidIconPanel:GetResetTime(regionDateTime,14)
    return madness
end





function RaidInfoUtility:GetSavedRaidInfo(index)

    local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers,
          difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(index)
    return instanceId, id
end

function RaidInfoUtility:StoreSavedRaidIDs()
    self.SavedIDs = {}
	for i = 1, GetNumSavedInstances() do
		local raidID, instanceId = self:GetSavedRaidInfo(i)  
        self.SavedIDs[raidID] = instanceId
	end
end

function RaidInfoUtility:GetMapPipData()
    self:StoreSavedRaidIDs()
    local raidData = {}
    for key,value in pairs(RaidInfoUtility.Raids) do        
        local raid = {
            id = value.id,
            name = value.name,
            shortHand = value.shortHand,
            savedID = self.SavedIDs[value.id],
            time = self:CalculateResetTime(self.RegionProfiles[GetCurrentRegion()].baseDateTime , value.raidDays),
        }
        table.insert(raidData, raid)
    end
    local zgData = RaidInfoUtility:CalculateWZGMaddnessInfo()
    return raidData , zgData
end