local _, Addon = ...
local L = Addon.L

Addon.RaidInfoTabManager = {
    CustomRaidInfoButton = nil,
}

function Addon.RaidInfoTabManager:ModifyDefaultUI()
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
            self:HideViewFrames()
        end
    end)

    self.CustomRaidInfoButton = copyButton;
end

function Addon.RaidInfoTabManager:HandleRaidInfoButton()
    self.CustomRaidInfoButton:Hide()
    RaidFrameRaidInfoButton:Hide()
    if Options.raidInfoButton == 2 then  -- 2=toggleRaidIcons
        self.CustomRaidInfoButton:Show()
    elseif Options.raidInfoButton == 3 then -- 3=showDefualtWindow
        RaidFrameRaidInfoButton:Show()
    end
end

function Addon.RaidInfoTabManager:ShowViewFrames()
    Addon.RaidInfoUtility:StoreSavedRaidIDs()

    if Options.selectedView == 1 then
        Addon.ViewIcon:Show()
    elseif Options.selectedView == 2 then
        Addon.ViewSimple:Show()
    else
        --Addon.ViewFull:Show()
    end
end

function Addon.RaidInfoTabManager:HideViewFrames()
    Addon.ViewIcon:Hide()
    Addon.ViewSimple:Hide()
end



function Addon.RaidInfoTabManager:UpdateIconVisibility()
    local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame)
    if selectedTab == 4 then
        if UnitLevel("player") >= 60 or not Options.hideForNoneSixty then
            self:ShowViewFrames()
        end
    else
        self:HideViewFrames()
    end
end

function Addon.RaidInfoTabManager:Setup()   

    self:ModifyDefaultUI()

    Addon.ViewIcon:Init()
    Addon.ViewSimple:Init()

    FriendsFrame:HookScript("OnShow", function()
        self:HideViewFrames()
        self:HandleRaidInfoButton()
    end)
    FriendsFrame:HookScript("OnHide", function()
        self:HideViewFrames()
    end)
    hooksecurefunc("FriendsFrame_Update", function()
        C_Timer.After(0.05, function()
            self:UpdateIconVisibility()
        end)
    end)
end