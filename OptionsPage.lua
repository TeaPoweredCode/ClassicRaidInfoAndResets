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

function Addon.OptionsPage:DrawIconView(pos)
    local groupFrame = CreateFrame("Frame", nil, self.OptionsPanel)
    groupFrame:SetSize(200, 150)

    self:DrawFrame(groupFrame,{100, 150},{"TOPLEFT", 0, 0})
    for i = 0,6,1 do
        self:DrawFrame(groupFrame,{20, 20},{"TOPLEFT", 98, i * -18})
    end
    
    groupFrame:SetPoint(unpack(pos))
    return groupFrame
end

function Addon.OptionsPage:DrawFullView(pos)
    local groupFrame = CreateFrame("Frame", nil, self.OptionsPanel)
    groupFrame:SetSize(200, 150)

    self:DrawFrame(groupFrame,{100, 150},{"TOPLEFT", 0, 0})
    for i = 0,6,1 do
        self:DrawFrame(groupFrame,{20, 20},{"TOPLEFT", 98, i * -18})
        self:DrawFrame(groupFrame,{40, 20},{"TOPLEFT", 116, i * -18})
    end
    
    groupFrame:SetPoint(unpack(pos))
    return groupFrame
end

function Addon.OptionsPage:DrawSimpleView(pos)
    local groupFrame = CreateFrame("Frame", nil, self.OptionsPanel)
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

    Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["INCLUDE_EDGE_OF_MADNESS"], {"TOPLEFT", 15, -105}, Options.includeZGMadness, function(self)
        Options.includeZGMadness = self:GetChecked()
    end)
    Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["HIDE_FOR_NONE_SIXTIES"], {"TOPLEFT", 15, -135}, Options.hideForNoneSixty, function(self)
        Options.hideForNoneSixty = self:GetChecked()
    end)

    Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["SHOW_MAPPIP"], {"TOPLEFT", 15, -165}, Options.minimapPipShown,function(self)
        Options.minimapPipShown = self:GetChecked()
        Addon.UIHelper:Shown(Addon.MiniMapPip.button, Options.minimapPipShown)
    end)


    Addon.UIHelper:CreateText(self.OptionsPanel, L["Select_View"], {"TOPLEFT", 15, -200}, 12, {1, 1, 1})

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["Icon_View"], {"TOPLEFT", 15, -220}, Options.selectedView == 1, function(self)
             Addon.OptionsPage:SelectViewChecked(1)
        end)
    )
    self:DrawIconView({"TOPLEFT", 15, -245});

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["Full_View"], {"TOPLEFT", 215, -220}, Options.selectedView == 2, function(self)
            Addon.OptionsPage:SelectViewChecked(2)
        end)
    )
    self:DrawFullView({"TOPLEFT", 215, -245})

    table.insert(self.ViewCheckBoxs,
        Addon.UIHelper:CreateCheckButton(self.OptionsPanel, L["Simple_View"], {"TOPLEFT", 415, -220}, Options.selectedView == 3, function(self)
            Addon.OptionsPage:SelectViewChecked(3)
        end)
    )
    self:DrawSimpleView({"TOPLEFT", 415, -245})

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