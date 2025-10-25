local _, Addon = ...
local L = Addon.L

Addon.OptionsPage = {
    OptionsPanel = nil,
    ViewCheckBoxs = {},
}

function Addon.OptionsPage:CreateRaidInfoDropdown()
    local dropdown = CreateFrame("Frame", nil, self.OptionsPanel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 0, -70)

    local options = {
        {text = L["HIDE_BUTTON"], value = 1},
        {text = L["TOGGLE_RAID_VIEW"], value = 2},
        {text = L["SHOW_DEFAULT_INFO_WINDOW"], value = 3},
    }

    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        Options.raidInfoButton = options[self:GetID()].value
    end

    local function Initialize(self, level)
        local info
        for i, option in ipairs(options) do
            info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.func = OnClick
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)
    UIDropDownMenu_SetWidth(dropdown, 180)
    UIDropDownMenu_SetButtonWidth(dropdown, 200)
    UIDropDownMenu_SetSelectedID(dropdown, Options.raidInfoButton)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
end

function Addon.OptionsPage:DrawIconView(parent,pos)
    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(200, 150)

    self:DrawFrame(groupFrame,{100, 150},{"TOPLEFT", 0, 0})
    for i = 0,6,1 do
        self:DrawFrame(groupFrame,{20, 20},{"TOPLEFT", 98, i * -18})
    end
    
    groupFrame:SetPoint(unpack(pos))
    return groupFrame
end

function Addon.OptionsPage:DrawFullView(parent,pos)
    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(200, 150)

    self:DrawFrame(groupFrame,{100, 150},{"TOPLEFT", 0, 0})
    for i = 0,6,1 do
        self:DrawFrame(groupFrame,{20, 20},{"TOPLEFT", 98, i * -18})
        self:DrawFrame(groupFrame,{40, 20},{"TOPLEFT", 116, i * -18})
    end
    
    groupFrame:SetPoint(unpack(pos))
    return groupFrame
end

function Addon.OptionsPage:DrawSimpleView(parent,pos)
    local groupFrame = CreateFrame("Frame", nil, parent)
    groupFrame:SetSize(200, 150)

    self:DrawFrame(groupFrame,{100, 150},{"TOPLEFT", 0, 0})
    self:DrawFrame(groupFrame,{50, 100},{"TOPLEFT", 98, 0})
    
    groupFrame:SetPoint(unpack(pos))
    return groupFrame
end

function Addon.OptionsPage:DrawFrame(perant,size,point)
    local frame = CreateFrame("Frame", nil, perant,"BackdropTemplate")
    frame:SetSize(unpack(size))
    frame:SetPoint(unpack(point))
    frame:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16})
end

function Addon.OptionsPage:SelectViewChecked(viewID)
    for i, cb in pairs(Addon.OptionsPage.ViewCheckBoxs) do     
        if i ~= viewID then cb:SetChecked(false) end
    end
    Options.selectedView = viewID
end

function Addon.OptionsPage:BuildUI()
    -- title 
    Addon.UIHelper:CreateLine(self.OptionsPanel,{"TOPLEFT", 0, -20}, {213, 1}, {1, 1, 1, 0.5})
    Addon.UIHelper:CreateText(self.OptionsPanel, "Classic Raid Info & Resets", {"TOP", -10, -12}, 16)
    Addon.UIHelper:CreateLine(self.OptionsPanel,{"TOPRIGHT", -15, -20}, {220, 1}, {1, 1, 1, 0.5})

    --settings
    Addon.UIHelper:CreateText(self.OptionsPanel, L["SETTINGS"], {"TOPLEFT", 10, -30}, 12, {1, 1, 1})

    Addon.UIHelper:CreateText(self.OptionsPanel, L["RAID_INFO_BUTTON"], {"TOPLEFT", 20, -60}, 10)
    self:CreateRaidInfoDropdown()

    Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["SHOW_MINIMAP_ICON"], {"TOPLEFT", 15, -105}, Options.minimapPipShown,function(self)
        Options.minimapPipShown = self:GetChecked()
        Addon.UIHelper:Shown(Addon.MiniMapPip.button, Options.minimapPipShown)
    end)

    Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["HIDE_FOR_NONE_SIXTIES"], {"TOPLEFT", 15, -135}, Options.hideForNoneSixty, function(self)
        Options.hideForNoneSixty = self:GetChecked()
    end)

    --ZG 
    local zgFrame = CreateFrame("Frame", nil, self.OptionsPanel)
    zgFrame:SetSize(500, 200)
    zgFrame:SetPoint("TOPLEFT",15, -175)
    Addon.UIHelper:CreateText(zgFrame, L["ZULGURUB"], {"TOPLEFT", 0, 0}, 12, {1, 1, 1})

    Addon.UIHelper:CreateCheckButton(zgFrame, L["INCLUDE_EDGE_OF_MADNESS"], {"TOPLEFT", 0, -25}, Options.includeZGMadness, function(self)
        Options.includeZGMadness = self:GetChecked()
    end)    

    Addon.UIHelper:CreateCheckButton(zgFrame, L["SHOW_EDGE_OF_MADNESS_FULL"], {"TOPLEFT", 0, -55}, Options.showFullMadnessRotation, function(self)
        Options.showFullMadnessRotation = self:GetChecked()
    end)

    --views 
    local viewsFrame = CreateFrame("Frame", nil, self.OptionsPanel)
    viewsFrame:SetSize(500, 300)
    viewsFrame:SetPoint("TOPLEFT",15, -275)

    Addon.UIHelper:CreateText(viewsFrame, L["Select_View"], {"TOPLEFT", 0, 0}, 12, {1, 1, 1})

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(viewsFrame, L["Icon_View"], {"TOPLEFT", 0, -20}, Options.selectedView == 1, function(self)
             Addon.OptionsPage:SelectViewChecked(1)
        end)
    )
    self:DrawIconView(viewsFrame,{"TOPLEFT", 0, -45});

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(viewsFrame, L["Full_View"], {"TOPLEFT", 200, -20}, Options.selectedView == 2, function(self)
            Addon.OptionsPage:SelectViewChecked(2)
        end)
    )
    self:DrawFullView(viewsFrame,{"TOPLEFT", 200, -45})

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(viewsFrame, L["Simple_View"], {"TOPLEFT", 400, -20}, Options.selectedView == 3, function(self)
            Addon.OptionsPage:SelectViewChecked(3)
        end)
    )
    self:DrawSimpleView(viewsFrame,{"TOPLEFT", 400, -45})

    --credits
    Addon.UIHelper:CreateLine(self.OptionsPanel,{"BOTTOMLEFT", 0, 20},{650, 1},{1, 1, 1, 0.5})
    
    local creditsString = string.format("v.%s", GetAddOnMetadata("ClassicRaidInfoAndResets", "Version"))
    Addon.UIHelper:CreateText(self.OptionsPanel, creditsString, {"BOTTOMRIGHT", -20, 5}, nil,  nil , "RIGHT")
end

function Addon.OptionsPage:RegisterCanvas(frame,text,id)
	local cat = Settings.RegisterCanvasLayoutCategory(frame,text,id)
	cat.ID = id
	Settings.RegisterAddOnCategory(cat)
end

function Addon.OptionsPage:Setup()
    self.OptionsPanel = CreateFrame("Frame", "MyAddonOptionsPanel", InterfaceOptionsFramePanelContainer)
    self:BuildUI()
    self:RegisterCanvas(self.OptionsPanel, "Classic Raid Info & Resets", "ClassicRaidInfoAndResets")
end