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
    self.Frame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 0, -23)

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

        local raidName = Addon.UIHelper:CreateTextElement(elements.textGroup, "TOPLEFT", 8, -8, "LEFT", Addon.RaidInfoUtility.Raids[key].name)
        raidName:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")

        elements.raidSavedID = Addon.UIHelper:CreateTextElement(elements.textGroup, "TOPRIGHT", -8, -8, "RIGHT", "ID: " .. L["NOT_SAVED"], nil, 10)
        elements.raidTime = Addon.UIHelper:CreateTextElement(elements.textGroup, "TOPLEFT", 8, -25, "LEFT", "TIME", {0.2,0.8,0.2})

        Addon.ViewFull.Sizes.maxTextWidth = math.max(raidName:GetStringWidth() + elements.raidSavedID:GetStringWidth(), Addon.ViewFull.Sizes.maxTextWidth)

        if key == "ZG" then
            elements.textGroup:SetHeight(Addon.ViewFull.Sizes.iconSize + 35)
            elements.zgBoss = Addon.UIHelper:CreateTextElement(elements.textGroup, "TOPLEFT", 8, -40, "LEFT", "MADDNESS_STRING")
            elements.zgTime = Addon.UIHelper:CreateTextElement(elements.textGroup, "TOPLEFT", 8, -58, "LEFT", "MADDNESS_TIME", {0.2,0.8,0.2})
        end

        self.RaidElements[key] = elements
    end
    self.Frame:Hide()
end

function Addon.ViewFull:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()
    self:SetRaidStates(raidsData)

    local yposOffset = Options.includeZGMadness and -35 or 0
    self.RaidElements["ZG"].textGroup:SetHeight(Options.includeZGMadness and (45 + 35) or 45)
    Addon.UIHelper:Shown(self.RaidElements["ZG"].zgBoss,Options.includeZGMadness)
    Addon.UIHelper:Shown(self.RaidElements["ZG"].zgTime,Options.includeZGMadness)

    for i = 4, #Addon.RaidInfoUtility.RaidOrder, 1 do
        local raid = self.RaidElements[Addon.RaidInfoUtility.RaidOrder[i]]
        raid.raidFrame:SetPoint("TOPLEFT", self.Frame, "TOPLEFT" ,0 , (i - 1) * -43 + yposOffset)
        raid.raidFrame:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT" ,0 , (i - 1) * -43 + yposOffset)
    end

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
            self.RaidElements[raid.code].zgBoss:SetText(zgData.formated)
            self.RaidElements[raid.code].zgTime:SetText(L["CHANGES_IN"] ..": " .. zgData.changeIn)
        end
    end

    self.Frame:SetWidth(
        Addon.ViewFull.Sizes.iconSize +
        math.max(Addon.ViewFull.Sizes.maxTextWidth, (Options.includeZGMadness and self.RaidElements["ZG"].zgBoss:GetStringWidth() or 0))
    )
end

function Addon.ViewFull:Hide()
    self.Frame:Hide()
end