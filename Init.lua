local _, Addon = ...
local L = Addon.L

local function InitializeSettings()

    local defaults = {
        lastRanVersion = GetAddOnMetadata("ClassicRaidInfoAndResets", "Version"),
        raidInfoButton = 1, -- 1=Hide , 2=ToggleRaidIcons , 3=ShowDefualtWindow
        includeZGMadness = true,
        showFullMadnessRotation = true,
        hideForNoneSixty = false,
        minimapPipShown = true,
        minimapPipPostion = {x=-73,y=30},
        selectedView = 1 , -- 1=IconView , 2=FullView , 3=SimpleView        
        useSocialRaidTabView = true,
    }

    if type(Options) ~= "table" then
        Options = {}
    end

    for k, v in pairs(defaults) do
        if Options[k] == nil then
            Options[k] = v
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)

    if addonName == "ClassicRaidInfoAndResets" then       
        local title =  GetAddOnMetadata("ClassicRaidInfoAndResets", "Title")
        if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
            print(("|cffffd100 [%s]|r |cffff0000 ~ %s|r"):format(title,L["WRONG_VERSION"]))
            return
        end

        local regionId = GetCurrentRegion()
        if regionId ~= 1 and regionId ~= 3 then -- 1=US , 3=Europe
            print(("|cffffd100 [%s]|r |cffff0000 ~ %s|r"):format(title,L["WRONG_REGION"]))
            return
        end

        InitializeSettings()

        local version = GetAddOnMetadata("ClassicRaidInfoAndResets", "Version")
        -- if Options.lastRanVersion != version then  -- for when i need it 
        -- end
        Options.lastRanVersion = version

        Addon.OptionsPage:Setup()
        Addon.MiniMapPip:Setup()
        Addon.SocialRaidTabManager:Setup()
    end
end)