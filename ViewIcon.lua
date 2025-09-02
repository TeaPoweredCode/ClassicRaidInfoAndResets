local _, Addon = ...
local L = Addon.L

Addon.ViewIcon = {
    Frame = nil,
    Icons = {},
    ZGMadnessTooltipReset = nil,
}

function Addon.ViewIcon:Init()
    self.Frame = CreateFrame("Frame", "Icon_View", FriendsFrame)
    self.Frame:SetSize(48, 336)
    self.Frame:SetPoint("TOPRIGHT", FriendsFrame, "TOPRIGHT", 46, -23)

    for index,key in pairs(Addon.RaidInfoUtility.RaidOrder) do       
        local borderSize = 4
        local frameSize = 48

        local iconframe = CreateFrame("Frame", nil, self.Frame, BackdropTemplateMixin and "BackdropTemplate")
        iconframe:SetSize(frameSize, frameSize)
        iconframe:SetPoint("TOPLEFT", self.Frame, "TOPLEFT", 0, (index-1) * -46)

        iconframe:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = borderSize, right = borderSize, top = borderSize, bottom = borderSize },
        })

        self.Icons[key] = iconframe:CreateTexture(nil, "BACKGROUND")
        self.Icons[key]:SetPoint("TOPLEFT", borderSize, -borderSize)
        self.Icons[key]:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)

        self.Icons[key]:SetTexture("Interface\\AddOns\\ClassicRaidInfoAndResets\\images\\" .. key)
        self.Icons[key]:SetTexCoord(0, 0.5, 0, 1)

        iconframe:SetScript("OnEnter", function(self)
            Addon.ViewIcon:ShowRaidTooltip(self,key)
        end)

        iconframe:SetScript("OnLeave", function(self)
            Addon.ViewIcon:HideRaidTooltip(key)
        end)
    end

    self.Frame:Hide()
end

function Addon.ViewIcon:ShowRaidTooltip(iconFrame,raidCode)
    local raid = Addon.RaidInfoUtility:GetRaidData(raidCode)

    GameTooltip:SetOwner(iconFrame, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", iconFrame, "TOPRIGHT")
    GameTooltip:SetText(raid.name, 1, 1, 1)

    if(raid.savedID) then 
        GameTooltip:AddLine("ID: " .. raid.savedID, 0.8, 0.8, 0.8)
    else
        GameTooltip:AddLine("ID: " .. L["NOT_SAVED"], 0.4, 0.4, 0.4)
    end

    GameTooltip:AddLine(L["RESET_IN"] .. ": " .. raid.time, 0.2, 0.8, 0.2)

    if raidCode == "ZG" and Options.includeZGMadness then
        Addon.ViewIcon:AddZGMaddnessTooltipInfo()
    end

    GameTooltip:Show()
end

function Addon.ViewIcon:AddZGMaddnessTooltipInfo()
    local zgData = Addon.RaidInfoUtility:CalculateWZGMaddnessInfo()
    
    GameTooltip:AddLine(" ") 
    GameTooltip:AddLine(("|cffffffff%s|r"):format(L["EDGE_OF_MADNESS"]))
    local maddnessLine = _G["GameTooltipTextLeft" .. GameTooltip:NumLines()]
    if maddnessLine then
        local _font, _size, _flags = maddnessLine:GetFont()
        Addon.ViewIcon.ZGMadnessTooltipReset = {
            line = GameTooltip:NumLines(),
            font = _font,
            size = _size,
            flags = _flags
        }
        maddnessLine:SetFont(_font, 14, _flags)
    end

    local itemName = zgData.item.localName and zgData.item.localName or zgData.item.name
    GameTooltip:AddLine(("|cffff8000%s|r"):format(zgData.boss.name))
    GameTooltip:AddLine(("|T%s:16:16:0:0|t |cff1eff00[%s]|r"):format(zgData.item.icon,itemName))
    GameTooltip:AddLine(L["CHANGES_IN"] ..": " .. zgData.changeIn, 0.2, 0.8, 0.2)
end

function Addon.ViewIcon:HideRaidTooltip(raidCode)
    if raidCode == "ZG" and Options.includeZGMadness then
        local reset = Addon.ViewIcon.ZGMadnessTooltipReset
        local line = _G["GameTooltipTextLeft" .. reset.line]
        if line and reset then
            line:SetFont(reset.font, reset.size, reset.flags)
        end
    end
    GameTooltip:Hide()
end

function Addon.ViewIcon:Show()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()
    local raidsData = Addon.RaidInfoUtility:GetRaidsData()
    self:SetRaidStates(raidsData)
    self.Frame:Show()
end

function Addon.ViewIcon:SetRaidStates(raidsData)
    for key,raid in pairs(raidsData) do
        if raid.savedID == nil then
            self.Icons[raid.code]:SetTexCoord(0.5, 1, 0, 1)
        else
            self.Icons[raid.code]:SetTexCoord(0, 0.5, 0, 1)
        end
    end
end

function Addon.ViewIcon:Hide()
    self.Frame:Hide()
end