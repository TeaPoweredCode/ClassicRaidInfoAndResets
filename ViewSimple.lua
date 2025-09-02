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

    local title = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 10, -10)
    title:SetText("Classic Raid Info & Resets")

    self.RaidsText = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.RaidsText:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 10, -30)
    self.RaidsText:SetJustifyH("LEFT")
    self.RaidsText:SetText("RAIDS")

    self.TimesText = self.Frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.TimesText:SetPoint("TOPRIGHT", self.Frame, "TOPRIGHT", -10, -30)
    self.TimesText:SetJustifyH("RIGHT")
    self.TimesText:SetText("TIMES")

    self.Frame:Hide()
end


function Addon.ViewSimple:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    self:SetRaidStates()
    self.Frame:Show()
end

function Addon.ViewSimple:SetRaidStates()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()
    local zgData = Addon.RaidInfoUtility:CalculateWZGMaddnessInfo()

    local unSavedColourString = "|cffffd100%s -|r |cff8d8d8d%s|r"
    local savedColourString = "|cffffd100%s -|r |cffffffff%s|r"

    local raidsStrings = {}
    local timesStrings = {}

    for key,raid in pairs(raidsData) do
        local raidString = (raid.savedID and savedColourString or unSavedColourString):format(raid.name,(raid.savedID and raid.savedID or L["NOT_SAVED"]))
        table.insert(raidsStrings, raidString)
        table.insert(timesStrings, raid.time)

        if raid.code == "ZG" and Options.includeZGMadness then
            local zgString = ("- |cffff8000%s|r |T%s:16:16:0:0|t |cff1eff00[%s]|r"):format(zgData.boss.name,zgData.item.icon,zgData.item.localName and zgData.item.localName or zgData.item.name)
            table.insert(raidsStrings, zgString)
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