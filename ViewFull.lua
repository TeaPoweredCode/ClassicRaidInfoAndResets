local _, Addon = ...
local L = Addon.L

Addon.ViewFull = {
    Frame = nil,
    RaidElements = {},
    Sizes = {
        maxTextWidth = 0,
        iconSize = 45,
    }
}

function Addon.ViewFull:Init()
    self.Frame = CreateFrame("Frame", "Full_View", FriendsFrame)
    self.Frame:SetSize(220, 400)
    self.Frame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", -2, -20)

    for i,key in pairs(Addon.RaidInfoUtility.RaidOrder) do       
        local elements = {}

        elements.raidFrame = CreateFrame("Frame", "raidFrame"..key, self.Frame, "BackdropTemplate")
        elements.raidFrame:SetHeight(Addon.ViewFull.Sizes.iconSize)
        elements.raidFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT" ,0 , (i - 1) * -43)
        elements.raidFrame:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT" ,0 , (i - 1) * -43)

        local iconframe = CreateFrame("Frame", nil, elements.raidFrame, BackdropTemplateMixin and "BackdropTemplate")
        iconframe:SetSize(Addon.ViewFull.Sizes.iconSize, Addon.ViewFull.Sizes.iconSize)
        iconframe:SetPoint("TOPLEFT", elements.raidFrame, "TOPLEFT", 0, 0)

        local borderSize = 2
        iconframe:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = borderSize, right = borderSize, top = borderSize, bottom = borderSize },
        })

        elements.raidIcon = iconframe:CreateTexture(nil, "BACKGROUND")
        elements.raidIcon:SetPoint("TOPLEFT", borderSize, -borderSize)
        elements.raidIcon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
        elements.raidIcon:SetTexture("Interface\\AddOns\\ClassicRaidInfoAndResets\\images\\" .. key)
        elements.raidIcon:SetTexCoord(0, 0.5, 0, 1)

        elements.textGroup = CreateFrame("Frame", nil, elements.raidFrame, "BackdropTemplate")
        elements.textGroup:SetPoint("TOPLEFT", elements.raidFrame, "TOPLEFT", Addon.ViewFull.Sizes.iconSize-2, 0)
        elements.textGroup:SetPoint("TOPRIGHT", elements.raidFrame, "TOPRIGHT" , Addon.ViewFull.Sizes.iconSize-2 ,0)
        elements.textGroup:SetHeight(Addon.ViewFull.Sizes.iconSize)
        elements.textGroup:SetBackdrop({
            bgFile = "Interface/FrameGeneral/UI-Background-Marble",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })

        local raidName = Addon.UIHelper:CreateText(elements.textGroup, Addon.RaidInfoUtility.Raids[key].name, {"TOPLEFT", 8, -8})
        raidName:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

        elements.raidSavedID = Addon.UIHelper:CreateText(elements.textGroup, L["NOT_SAVED"], {"TOPRIGHT", -8, -8}, 10, nil, "RIGHT")
        elements.raidTime = Addon.UIHelper:CreateText(elements.textGroup, "TIME", {"TOPLEFT", 8, -25}, nil,  {0.2,0.8,0.2})

        Addon.ViewFull.Sizes.maxTextWidth = math.max(raidName:GetStringWidth() + elements.raidSavedID:GetStringWidth(), Addon.ViewFull.Sizes.maxTextWidth)

        if key == "ZG" then
            elements.textGroup:SetHeight(Addon.ViewFull.Sizes.iconSize + 27)
            elements.zgBoss = Addon.UIHelper:CreateText(elements.textGroup, "MADDNESS_STRING", {"TOPLEFT", 8, -40})
        end

        self.RaidElements[key] = elements
    end
    self.Frame:Hide()
end

function Addon.ViewFull:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()
    self:SetRaidStates(raidsData)

    local yposOffset = 0 -- Used for raids after zg if maddness data shown
    if Options.includeZGMadness then
        yposOffset = Options.showFullMadnessRotation and -75 or -30
    end

    self.RaidElements["ZG"].textGroup:SetHeight(45 + (yposOffset*-1))
    Addon.UIHelper:Shown(self.RaidElements["ZG"].zgBoss,Options.includeZGMadness)

    for i = 4, #Addon.RaidInfoUtility.RaidOrder, 1 do
        local raid = self.RaidElements[Addon.RaidInfoUtility.RaidOrder[i]]
        raid.raidFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT" ,0 , (i - 1) * -43 + yposOffset)
        raid.raidFrame:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT" ,0 , (i - 1) * -43 + yposOffset)
    end

    self.Frame:SetWidth(
        Addon.ViewFull.Sizes.iconSize +
        math.max(Addon.ViewFull.Sizes.maxTextWidth, (Options.includeZGMadness and self.RaidElements["ZG"].zgBoss:GetStringWidth() or 0))
    )

    self.Frame:Show()
end

function Addon.ViewFull:SetRaidStates(raidsData)
    for key,raid in pairs(raidsData) do    
        if raid.savedID == nil then
            self.RaidElements[raid.code].raidIcon:SetTexCoord(0.5, 1, 0, 1)
            self.RaidElements[raid.code].raidSavedID:SetText("ID: " .. L["NOT_SAVED"])
            self.RaidElements[raid.code].raidSavedID:SetTextColor(0.5, 0.5, 0.5)
        else
            self.RaidElements[raid.code].raidIcon:SetTexCoord(0, 0.5, 0, 1)
            self.RaidElements[raid.code].raidSavedID:SetText("ID: " .. raid.savedID)
            self.RaidElements[raid.code].raidSavedID:SetTextColor(0.8, 0.8, 0.8)
        end   
        self.RaidElements[raid.code].raidTime:SetText(L["RESET_IN"] .. ": " .. raid.time)

        if raid.code == "ZG" and Options.includeZGMadness then
            local zgData = Addon.RaidInfoUtility:CalculateZGMaddnessInfo()
            local zgStrings = {}
            for index,bossData in ipairs(zgData.bosses) do                
                if index == zgData.currentBoss or Options.showFullMadnessRotation then                    
                    table.insert(zgStrings, ("|cffffffff%s|r"):format(index == zgData.currentBoss and "> " or "- ") .. bossData)
                end
            end
            table.insert(zgStrings, L["CHANGES_IN"] ..": " .. zgData.changeIn)                    
           self.RaidElements[raid.code].zgBoss:SetText(table.concat(zgStrings, "\n"))
        end
    end
end

function Addon.ViewFull:Hide()
    self.Frame:Hide()
end