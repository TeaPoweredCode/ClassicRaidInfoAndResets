local function InitializeSettings()

    local defaults = {
        raidInfoButton = 1, -- 1=hide , 2=toggleRaidIcons , 3=showDefualtWindow
        includeZGMadness = true,
        hideForNoneSixty = false,
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
        OptionsPage:Setup()
        RaidIconPanel:Setup()
    end
end)