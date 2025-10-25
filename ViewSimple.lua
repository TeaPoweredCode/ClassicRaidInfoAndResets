local _, Addon = ...
local L = Addon.L

Addon.ViewSimple = {
    Frame = nil,
    RaidsText = nil,
}

function Addon.ViewSimple:Init()    
    self.Frame = CreateFrame("Frame", nil, FriendsFrame, "BackdropTemplate")
    self.Frame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", -2, -20)
    self.Frame:SetSize(350, 130)
    self.Frame:SetBackdrop({
        bgFile = "Interface/FrameGeneral/UI-Background-Marble",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    Addon.UIHelper:CreateText(self.Frame, "Classic Raid Info & Resets", {"TOPLEFT", 10, -10}, 14, {1,1,1})
    self.RaidsText = Addon.UIHelper:CreateText(self.Frame, "RAIDS", {"TOPLEFT", 10, -30})

    self.Frame:Hide()
end

function Addon.ViewSimple:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    self:SetRaidStates()
    self.Frame:Show()
end

function Addon.ViewSimple:SetRaidStates()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()

    local unSavedColourString = "|cffffd100%s -|r |cff8d8d8d%s|r"
    local savedColourString = "|cffffd100%s -|r |cffffffff%s|r"

    local raidsStrings = {}

    for key,raid in pairs(raidsData) do
        local raidString = (raid.savedID and savedColourString or unSavedColourString):format(raid.name,(raid.savedID and raid.savedID or L["NOT_SAVED"]))
        table.insert(raidsStrings, raidString)
        table.insert(raidsStrings, ("|cff33cc33%s|r"):format(raid.time))
        if raid.code == "ZG" and Options.includeZGMadness then
            local zgData = Addon.RaidInfoUtility:CalculateZGMaddnessInfo()
            for index,bossData in ipairs(zgData.bosses) do
                if index == zgData.currentBoss or Options.showFullMadnessRotation then
                    table.insert(raidsStrings, ("|cffffffff%s|r"):format(index == zgData.currentBoss and "> " or "- ") .. bossData)
                end
            end
            table.insert(raidsStrings, ("|cff33cc33%s|r"):format(zgData.changeIn))
        end
        table.insert(raidsStrings,"")
    end

    self.RaidsText:SetText(table.concat(raidsStrings, "\n"))

    local setWidth = self.RaidsText:GetStringWidth() + 20  -- + middle gap size + boarder edge
    local setHeight = self.RaidsText:GetStringHeight() + 30 + 10 -- + Title space + bottom boarder edge

    self.Frame:SetSize(setWidth, setHeight)
end

function Addon.ViewSimple:Hide()
    self.Frame:Hide()
end