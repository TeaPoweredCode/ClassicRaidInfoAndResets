local _, Addon = ...
local L = Addon.L

Addon.MiniMapPip = {
    button = nil,
    dragging = false,
}

function Addon.MiniMapPip:Setup()

    local minimapButton = CreateFrame("Button", "Classic Raid Info & Resets", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", Options.minimapPipPostion.x, Options.minimapPipPostion.y)

    local background = minimapButton:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture(136467)
    background:SetPoint("TOPLEFT", 7, -5)    

    local icon = minimapButton:CreateTexture(nil, "ARTWORK")
    icon:SetSize(17, 17)
    icon:SetTexture("Interface\\AddOns\\ClassicRaidInfoAndResets\\images\\MapPip.tga")
    icon:SetPoint("TOPLEFT", 7, -6)

    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)	
    overlay:SetTexture(136430)
    overlay:SetPoint("TOPLEFT")

    minimapButton:SetHighlightTexture(136477)

	minimapButton.icon = icon -- used by hiding bar
    
    minimapButton:RegisterForClicks("LeftButtonUp")
    minimapButton:SetScript("OnMouseDown", function(self, button)
        if self:GetParent() == Minimap then -- check to see if pip is on minimap and not something like "HidingBar"
            Addon.MiniMapPip.dragging = true
            self:SetScript("OnUpdate", function(self)
                local mx, my = Minimap:GetCenter()
                local cx, cy = GetCursorPosition()
                local scale = UIParent:GetEffectiveScale()
                cx, cy = cx / scale, cy / scale
                local angle = math.atan2(cy - my, cx - mx)
                local radius = 80
                local x = math.cos(angle) * radius
                local y = math.sin(angle) * radius
                self:ClearAllPoints()
                self:SetPoint("CENTER", Minimap, "CENTER", x, y)            
                Options.minimapPipPostion = {["x"]=x, ["y"]=y}
            end)
        end
    end)

    minimapButton:SetScript("OnMouseUp", function(self)
        if Addon.MiniMapPip.dragging then
            self:SetScript("OnUpdate", nil)
            Addon.MiniMapPip.dragging = false
        end
    end)

    minimapButton:SetScript("OnEnter", function(self)
        local raidData , zgData = Addon.RaidInfoUtility:GetMapPipData()

        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText("Classic Raid Info & Resets", 1, 1, 1)
        local unSavedColourString = "|cffffd100%s -|r |cff8d8d8d%s|r"
        local savedColourString = "|cffffd100%s -|r |cffffffff%s|r"
        for key,value in pairs(raidData) do
            local raidString = (value.savedID and savedColourString or unSavedColourString):format(value.name,(value.savedID and value.savedID or L["NOT_SAVED"]))
            GameTooltip:AddDoubleLine(raidString, value.time, 1, 1, 1, 0.2, 0.8, 0.2)
            if value.code == "ZG" and Options.includeZGMadness then
                local zgString = ("- |cffff8000%s|r |T%s:16:16:0:0|t |cff1eff00[%s]|r"):format(zgData.boss.name,zgData.item.icon,zgData.item.localName and zgData.item.localName or zgData.item.name)
                GameTooltip:AddDoubleLine(zgString, zgData.changeIn, 1, 1, 1, 0.2, 0.8, 0.2)
            end
        end
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    if Options.minimapPipShown then
        minimapButton:Show()
    else 
        minimapButton:Hide()
    end
    
    self.button = minimapButton
end