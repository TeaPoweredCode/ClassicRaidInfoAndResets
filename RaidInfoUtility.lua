local _, Addon = ...
local L = Addon.L

Addon.RaidInfoUtility = {
    RegionProfiles = {
        [1] = {baseDateTime = 1753196400}, -- US (includes Brazil and Oceania) | Tue Jul 22 2025
        [3] = {baseDateTime = 1752638400} -- Europe (includes Russia) | Wed Jul 16 2025 08:00:00                      
    },
    RaidOrder = {"MC","ONY","ZG","BWL","AQ20","AQ40","NAXX"},
    Raids = {
        ["MC"] =   {code = "MC", id = 409, name = L["MOLTEN_CORE"], raidDays = 7},
        ["ONY"] =  {code = "ONY", id = 249, name = L["ONYXIAS_LAIR"], raidDays = 5},
        ["ZG"] =   {code = "ZG", id = 309, name = L["ZULGURUB"],  raidDays = 3},
        ["BWL"] =  {code = "BWL", id = 469, name = L["BLACKWING_LAIR"],  raidDays = 7},
        ["AQ20"] = {code = "AQ20", id = 509, name = L["RUINS_OF_AHNQIRAJ"],  raidDays = 3},
        ["AQ40"] = {code = "AQ40", id = 531, name = L["AHNQIRAJ_TEMPLE"],  raidDays = 7},
        ["NAXX"] = {code = "NAXX", id = 533, name = L["NAXXRAMAS"],  raidDays = 7},
    },
    ZGMadness = {
        TimeProfiles = {
            [1] = {regionDateTime = 1751353200},   -- UTC+7
            [3] = {regionDateTime = 1751320800}    -- UTC-2
        },
        Bosses = {
            {
                boss = {name = "Gri'lek", id = 15082},
                item = {name = "Gri'lek's Blood", id = 19939 , icon = "134806", localName = nil}
            },
            {
                boss = {name = "Hazza'rah", id = 15083},
                item = {name = "Hazza'rah's Dream Thread", id = 19942 , icon = "133686", localName = nil}
            },
            {
                boss = {name = "Renataki", id = 15084},
                item = {name = "Renataki's Tooth", id = 19940 , icon = "134298", localName = nil}
            },
            {
                boss = {name = "Wushoolay", id = 15085},
                item = {name = "Wushoolay's Mane", id = 19941 , icon = "134323", localName = nil}
            }
        },
    },
    SavedIDs = nil
}

function Addon.RaidInfoUtility:CalculateResetTime(baseTime, intervalDays)   
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

function Addon.RaidInfoUtility:GetGMaddnessItemName(bossIndex)
    if self.ZGMadness.Bosses[bossIndex].item.localName == nil then
        local name = GetItemInfo(self.ZGMadness.Bosses[bossIndex].item.id)
        if(name) then 
            self.ZGMadness.Bosses[bossIndex].item.localName = name
        end
    end

    if self.ZGMadness.Bosses[bossIndex].item.localName ~= nil then
        return self.ZGMadness.Bosses[bossIndex].item.localName
    else
        return self.ZGMadness.Bosses[bossIndex].item.name
    end
end

function Addon.RaidInfoUtility:CalculateZGMaddnessInfo()
    local regionDateTime = self.ZGMadness.TimeProfiles[GetCurrentRegion()].regionDateTime

    local now = GetServerTime()
    local elapsed = now - regionDateTime

    local eightWeeks = 8 * 7 * 24 * 60 * 60
    local twoWeekBlock = 2 * 7 * 24 * 60 * 60

    local timeIntoCycle = elapsed % eightWeeks
    local currentBlock = math.floor(timeIntoCycle / twoWeekBlock) + 1

    local data = {
        currentBoss = currentBlock,
        changeIn = self:CalculateResetTime(regionDateTime,14),
        bosses = {}
    }

    for index,bossData in ipairs(self.ZGMadness.Bosses) do 
        local formated = ("|cffff8000%s|r |T%s:16:16:0:0|t |cff1eff00[%s]|r"):format(bossData.boss.name,bossData.item.icon,self:GetGMaddnessItemName(index))
        table.insert(data.bosses, formated)
    end

    return data
end

function Addon.RaidInfoUtility:GetSavedRaidInfo(index)
    local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers,
          difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(index)
    return instanceId, id
end

function Addon.RaidInfoUtility:StoreSavedRaidIDs()
    self.SavedIDs = {}
	for i = 1, GetNumSavedInstances() do
		local raidID, instanceId = self:GetSavedRaidInfo(i)  
        self.SavedIDs[raidID] = instanceId
	end
end

function Addon.RaidInfoUtility:GetRaidsData()
    local allRaids = {}
    for key,value in ipairs(self.RaidOrder) do 
        table.insert(allRaids, self:GetRaidData(value))
    end

    return allRaids
end

function Addon.RaidInfoUtility:GetRaidData(key)
    local data = self.Raids[key]
    return {
        code = data.code,
        id = data.id,
        name = data.name,
        savedID = self.SavedIDs[data.id],
        time = self:CalculateResetTime(self.RegionProfiles[GetCurrentRegion()].baseDateTime , data.raidDays),
    }
end