local _, Addon = ...
local L = Addon.L

Addon.SocialRaidTabManager = {
    CustomRaidInfoButton = nil,
    Views = {
        Addon.ViewIcon,        
        Addon.ViewFull,
        Addon.ViewSimple,
    },
}

function Addon.SocialRaidTabManager:ModifyDefaultUI()
    local copyButton = CreateFrame("Button", nil, RaidFrameRaidInfoButton:GetParent(), "UIPanelButtonTemplate")
    copyButton:SetSize(RaidFrameRaidInfoButton:GetWidth(), RaidFrameRaidInfoButton:GetHeight())
    copyButton:SetText(RaidFrameRaidInfoButton:GetText())
    copyButton:SetPoint("TOP", RaidFrameRaidInfoButton, "TOP", 0, 0)
    local r, g, b, a = RaidFrameRaidInfoButton:GetFontString():GetTextColor()
    copyButton:GetFontString():SetTextColor(r, g, b, a)

    copyButton:SetScript("OnClick", function()
        local viewFrame = self.Views[Options.selectedView].Frame
        Addon.UIHelper:Shown(viewFrame,not viewFrame:IsShown())
    end)

    self.CustomRaidInfoButton = copyButton;

    local point, relativeTo, relativePoint, xOfs, yOfs = RaidInfoFrame:GetPoint()
    RaidInfoFrame:ClearAllPoints()
    RaidInfoFrame:SetPoint("TOPRIGHT", relativeTo, "TOPRIGHT", 0, yOfs-1)
    RaidInfoFrame:SetFrameStrata("TOOLTIP")
end

function Addon.SocialRaidTabManager:SetRaidInfoButton()
    Addon.UIHelper:Shown(RaidFrameRaidInfoButton, not Options.useSocialRaidTabView or Options.raidInfoButton == 3) -- Defult buton
    Addon.UIHelper:Shown(self.CustomRaidInfoButton, Options.useSocialRaidTabView and Options.raidInfoButton == 2) -- New button
end

function Addon.SocialRaidTabManager:ShowViewFrames()
    self.Views[Options.selectedView]:Show()
end

function Addon.SocialRaidTabManager:HideViewFrames()
    for i,view in pairs(self.Views) do
        view:Hide()
    end
end

function Addon.SocialRaidTabManager:UpdateViewVisibility()
    local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame)
    if Options.useSocialRaidTabView and selectedTab == 4 then
        if UnitLevel("player") >= 60 or not Options.hideForNoneSixty then
            self:ShowViewFrames()
        end
    else
        self:HideViewFrames()
    end
end

function Addon.SocialRaidTabManager:Setup()   
    self:ModifyDefaultUI()

    for i,view in pairs(self.Views) do
        view:Init()
    end

    FriendsFrame:HookScript("OnShow", function()
        self:HideViewFrames()
        self:SetRaidInfoButton()
    end)
    FriendsFrame:HookScript("OnHide", function()
        self:HideViewFrames()
    end)
    hooksecurefunc("FriendsFrame_Update", function()
        C_Timer.After(0.05, function()
            self:UpdateViewVisibility()
        end)
    end)
end