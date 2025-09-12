local _, Addon = ...
local L = Addon.L

Addon.ViewSimple = {
    Frame = nil,
    RaidsText = nil,
    TimesText = nil,
}

function Addon.ViewSimple:Init()    
    self.Frame = CreateFrame("Frame", nil, FriendsFrame, "BackdropTemplate")
    self.Frame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 0, -23)
    self.Frame:SetSize(350, 130)
    self.Frame:SetBackdrop({
        bgFile = "Interface/FrameGeneral/UI-Background-Marble",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    Addon.UIHelper:CreateText(self.Frame, "Classic Raid Info & Resets", {"TOPLEFT", 10, -10})
    self.RaidsText = Addon.UIHelper:CreateText(self.Frame, "RAIDS", {"TOPLEFT", 10, -30})
    self.TimesText = Addon.UIHelper:CreateText(self.Frame, "TIMES", {"TOPRIGHT", -10, -30}, nil, nil, "RIGHT")

    self.Frame:Hide()
end


function Addon.ViewSimple:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    self:SetRaidStates()
    self.Frame:Show()
end

function Addon.ViewSimple:SetRaidStates()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()
    local zgData = Addon.RaidInfoUtility:CalculateZGMaddnessInfo()

    local unSavedColourString = "|cffffd100%s -|r |cff8d8d8d%s|r"
    local savedColourString = "|cffffd100%s -|r |cffffffff%s|r"

    local raidsStrings = {}
    local timesStrings = {}

    for key,raid in pairs(raidsData) do
        local raidString = (raid.savedID and savedColourString or unSavedColourString):format(raid.name,(raid.savedID and raid.savedID or L["NOT_SAVED"]))
        table.insert(raidsStrings, raidString)
        table.insert(timesStrings, raid.time)

        if raid.code == "ZG" and Options.includeZGMadness then
            table.insert(raidsStrings, ("|cffffffff%s|r"):format("- ") .. zgData.formated)
            table.insert(timesStrings, zgData.changeIn)
        end
    end

    self.RaidsText:SetText( table.concat(raidsStrings, "\n"))
    self.TimesText:SetText( table.concat(timesStrings, "\n"))

    local setWidth = self.RaidsText:GetStringWidth() + self.TimesText:GetStringWidth() + 30 + 20  -- + middle gap size + boarder edge
    local setHeight = self.RaidsText:GetStringHeight() + 30 + 10 -- + Title space + bottom boarder edge

    self.Frame:SetSize(setWidth, setHeight)
end

function Addon.ViewSimple:Hide()
    self.Frame:Hide()
end