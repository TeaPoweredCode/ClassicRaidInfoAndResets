local _, Addon = ...
local L = Addon.L

RaidIconPanel = {
    IconPanel = nil,
    CustomRaidInfoButton = nil,
    RegionProfiles = {
        [1] = {baseDateTime = 1753196400}, -- US (includes Brazil and Oceania) | Tue Jul 22 2025
        [3] = {baseDateTime = 1752638400} -- Europe (includes Russia) | Wed Jul 16 2025 08:00:00                      
    },
    RaidIds = {
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
        TooltipReset = nil,  
    },
    SavedIDs = nil
}

function RaidIconPanel:ModifyDefaultUI()
    local point, relativeTo, relativePoint, xOfs, yOfs = RaidInfoFrame:GetPoint()
    RaidInfoFrame:ClearAllPoints()
    RaidInfoFrame:SetPoint(point, relativeTo, relativePoint, xOfs + 40, yOfs)

    local copyButton = CreateFrame("Button", nil, RaidFrameRaidInfoButton:GetParent(), "UIPanelButtonTemplate")
    copyButton:SetSize(RaidFrameRaidInfoButton:GetWidth(), RaidFrameRaidInfoButton:GetHeight())
    copyButton:SetText(RaidFrameRaidInfoButton:GetText())
    copyButton:SetPoint("TOP", RaidFrameRaidInfoButton, "TOP", 0, 0)
    local r, g, b, a = RaidFrameRaidInfoButton:GetFontString():GetTextColor()
    copyButton:GetFontString():SetTextColor(r, g, b, a)

    copyButton:SetScript("OnClick", function()
        if (self.IconPanel:IsShown()) then
            self.IconPanel:Hide()
        else 
            self.IconPanel:Show()
        end
    end)

    RaidIconPanel.CustomRaidInfoButton = copyButton;
end

function RaidIconPanel:BuildUI()
    self.IconPanel = CreateFrame("Frame", "RaidIconPanel", FriendsFrame)
    self.IconPanel:SetSize(48, 336)
    self.IconPanel:SetPoint("TOPRIGHT", FriendsFrame, "TOPRIGHT", 46, -23)

    for key,value in pairs(self.RaidIds) do       
        self:CreateIcon(value, (key-1) * -46)
    end

    -- get items cached 
    for key,value in pairs(self.ZGMadness.Bosses) do     
        GetItemInfo(value.item.id)  
    end

    self.IconPanel:Hide()
end

function RaidIconPanel:CreateIcon(raidData,yPos)
    raidData.iconFrame = CreateFrame("Frame", nil, self.IconPanel, BackdropTemplateMixin and "BackdropTemplate")
    raidData.iconFrame:SetSize(48, 48)
    raidData.iconFrame:SetPoint("TOPLEFT", self.IconPanel, "TOPLEFT", 0, yPos)     
    self:SetRaidSaved(raidData, false)

    raidData.iconFrame:SetScript("OnEnter", function(self)
        RaidIconPanel:ShowRaidTooltip(raidData)
    end)

    raidData.iconFrame:SetScript("OnLeave", function(self)
        if raidData.id == 309 and Options.includeZGMadness then -- if ZG
            local reset = RaidIconPanel.ZGMadness.TooltipReset
            local line = _G["GameTooltipTextLeft" .. reset.line]
            if line and reset then
                line:SetFont(reset.font, reset.size, reset.flags)
            end
        end
        GameTooltip:Hide()
    end)
end

function RaidIconPanel:GetResetTime(baseTime, intervalDays)   
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

function RaidIconPanel:AddZGMaddnessTooltipInfo()
    local regionDateTime = RaidIconPanel.ZGMadness.TimeProfiles[GetCurrentRegion()].regionDateTime

    local now = GetServerTime()
    local elapsed = now - regionDateTime

    local eightWeeks = 8 * 7 * 24 * 60 * 60
    local twoWeekBlock = 2 * 7 * 24 * 60 * 60

    local timeIntoCycle = elapsed % eightWeeks
    local currentBlock = math.floor(timeIntoCycle / twoWeekBlock) + 1

    local madness = RaidIconPanel.ZGMadness.Bosses[currentBlock]
 
    GameTooltip:AddLine(" ") 
    GameTooltip:AddLine(("|cffffffff%s|r"):format(L["EDGE_OF_MADNESS"]))
    local maddnessLine = _G["GameTooltipTextLeft" .. GameTooltip:NumLines()]
    if maddnessLine then
        local _font, _size, _flags = maddnessLine:GetFont()
        RaidIconPanel.ZGMadness.TooltipReset = {
            line = GameTooltip:NumLines(),
            font = _font,
            size = _size,
            flags = _flags
        }
        maddnessLine:SetFont(_font, 14, _flags)
    end

    GameTooltip:AddLine(("|cffff8000%s|r"):format(madness.boss.name))

    local itemName = madness.item.name
    if(madness.item.localName) then
        itemName = madness.item.localName
    else 
        local name = GetItemInfo(madness.item.id)
        if(name) then 
            madness.item.localName = name
            itemName = name
        end
    end
    GameTooltip:AddLine(("|T%s:16:16:0:0|t |cff1eff00[%s]|r"):format(madness.item.icon,itemName))

    GameTooltip:AddLine(L["CHANGES_IN"] ..": " .. RaidIconPanel:GetResetTime(regionDateTime,14), 0.2, 0.8, 0.2)
end


function RaidIconPanel:ShowRaidTooltip(raidData)
    GameTooltip:SetOwner(raidData.iconFrame, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", raidData.iconFrame, "TOPRIGHT")
    GameTooltip:SetText(raidData.name, 1, 1, 1)

    if(self.SavedIDs[raidData.id]) then 
        GameTooltip:AddLine("ID: " .. self.SavedIDs[raidData.id], 0.8, 0.8, 0.8)
    else
        GameTooltip:AddLine("ID: " .. L["NOT_SAVED"], 0.4, 0.4, 0.4)
    end
    GameTooltip:AddLine(L["RESET_IN"] .. ": " .. self:GetResetTime(self.RegionProfiles[GetCurrentRegion()].baseDateTime , raidData.raidDays), 0.2, 0.8, 0.2)

    if raidData.id == 309 and Options.includeZGMadness then
        self.AddZGMaddnessTooltipInfo()
    end

    GameTooltip:Show()
end

function RaidIconPanel:SetRaidSaved(raidData , saved)
    self:SetRaidIconImage(raidData.iconFrame, raidData.shortHand .. (saved and "" or "_gray"))
end

function RaidIconPanel:SetRaidIconImage(frame, image)
    frame:SetBackdrop({
        bgFile = "Interface\\AddOns\\ClassicRaidInfoAndResets\\images\\" .. image,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
end

function RaidIconPanel:GetSavedRaidInfo(index)
    local name, id, reset, difficulty, locked, extended, instanceIDMostSig, isRaid, maxPlayers,
          difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(index)
    return instanceId, id
end

function RaidIconPanel:SetRaidIcons()
    self.SavedIDs = {}
	for i = 1, GetNumSavedInstances() do
		local raidID, instanceId = self:GetSavedRaidInfo(i)  
        self.SavedIDs[raidID] = instanceId
	end

    for key,value in pairs(self.RaidIds) do       
        self:SetRaidSaved(value, self.SavedIDs[value.id])
    end
end

function RaidIconPanel:UpdateIconVisibility()
    local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame)
    if selectedTab == 4 then
        self:SetRaidIcons()
        if UnitLevel("player") >= 60 or not Options.hideForNoneSixty then 
            self.IconPanel:Show()
        end
    else
        self.IconPanel:Hide()
    end
end

function RaidIconPanel:Setup()   
    self:BuildUI()
    self:ModifyDefaultUI()

    FriendsFrame:HookScript("OnShow", function()
        self.CustomRaidInfoButton:Hide()
        RaidFrameRaidInfoButton:Hide()
        if Options.raidInfoButton == 2 then  -- 2=toggleRaidIcons
            self.CustomRaidInfoButton:Show()
        elseif Options.raidInfoButton == 3 then -- 3=showDefualtWindow
            RaidFrameRaidInfoButton:Show()
        end
    end)
    FriendsFrame:HookScript("OnHide", function()
        self.IconPanel:Hide()
    end)
    hooksecurefunc("FriendsFrame_Update", function()
        C_Timer.After(0.05, function()
            self:UpdateIconVisibility()
        end)
    end)
end