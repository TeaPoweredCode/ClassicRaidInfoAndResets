local _, Addon = ...
local L = Addon.L

Addon.RaidInfoFrames = {
    CustomRaidInfoButton = nil,
}

function Addon.RaidInfoFrames:ModifyDefaultUI()
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

    self.CustomRaidInfoButton = copyButton;
end

function Addon.RaidInfoFrames:HandleRaidInfoButton()
    self.CustomRaidInfoButton:Hide()
    RaidFrameRaidInfoButton:Hide()
    if Options.raidInfoButton == 2 then  -- 2=toggleRaidIcons
        self.CustomRaidInfoButton:Show()
    elseif Options.raidInfoButton == 3 then -- 3=showDefualtWindow
        RaidFrameRaidInfoButton:Show()
    end
end

function Addon.RaidInfoFrames:HideViewFrames()
    Addon.ViewIcon:Hide()
    -- self.Full_View:Hide()
    -- self.Simple_View:Hide()
end



function Addon.RaidInfoFrames:UpdateIconVisibility()
    local selectedTab = PanelTemplates_GetSelectedTab(FriendsFrame)
    if selectedTab == 4 then
        Addon.RaidInfoUtility:StoreSavedRaidIDs()
        -- self:SetRaidIcons()
        if UnitLevel("player") >= 60 or not Options.hideForNoneSixty then
            Addon.RaidInfoUtility:StoreSavedRaidIDs()
            Addon.ViewIcon:Show()
        end
    else
        Addon.ViewIcon:Hide()
    end
end

function Addon.RaidInfoFrames:Setup()   

    -- get items cached 
    -- for key,value in pairs(self.ZGMadness.Bosses) do     
    --     GetItemInfo(value.item.id)  
    -- end

    --self:BuildIconView()
    -- self:BuildUI()
    self:ModifyDefaultUI()

    Addon.ViewIcon:Init()

    FriendsFrame:HookScript("OnShow", function()
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