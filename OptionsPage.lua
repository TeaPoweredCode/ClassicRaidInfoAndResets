local _, Addon = ...
local L = Addon.L

OptionsPage = {OptionsPanel = nil}

function OptionsPage:CreateLine(pos, size, colour)
  local line = self.OptionsPanel:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(colour.r, colour.g, colour.b, colour.a)
  line:SetSize(size.w, size.h)
  line:SetPoint(pos.a, pos.x, pos.y)
  return line
end

function OptionsPage:CreateText(value, fontTemplate, pos, size, colour)
  local text = self.OptionsPanel:CreateFontString(nil, "OVERLAY", fontTemplate)
  text:SetPoint(pos.a,pos.x,pos.y)
  text:SetText(value)

  if colour then
    text:SetTextColor(colour.r,colour.g, colour.b, colour.a)
  end

  if size then
    local fontName, fontHeight, fontFlags = GameFontNormal:GetFont()
    text:SetFont(fontName, size, fontFlags)
  end

  return text
end

function OptionsPage:dropdown()
    local dropdown = CreateFrame("Frame", nil, self.OptionsPanel, "UIDropDownMenuTemplate")
  dropdown:SetPoint("TOPLEFT", 0, -70)

  -- Define your dropdown options
  local options = {
      { text = L["HIDE_BUTTON"], value = 1},
      { text = L["TOGGLE_RAID_ICONS"], value = 2},
      { text = L["SHOW_DEFAULT_INFO_WINDOW"], value = 3}
  }

  -- When an option is clicked
  local function OnClick(self)
      UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
      Options.raidInfoButton = options[self:GetID()].value

  end

  -- Initialize the dropdown
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

  -- Setup dropdown appearance
  UIDropDownMenu_Initialize(dropdown, Initialize)
  UIDropDownMenu_SetWidth(dropdown, 180)
  UIDropDownMenu_SetButtonWidth(dropdown, 200)
  UIDropDownMenu_SetSelectedID(dropdown, Options.raidInfoButton)
  UIDropDownMenu_JustifyText(dropdown, "LEFT")
end

function OptionsPage:CreateCheckButton(text,pos,checked,func)
  local CheckButton = CreateFrame("CheckButton", nil, self.OptionsPanel, "InterfaceOptionsCheckButtonTemplate")
  CheckButton:SetPoint(pos.a,pos.x,pos.y)
  CheckButton.Text:SetText(text)
  CheckButton:SetChecked(checked)
  CheckButton:SetScript("OnClick", func)

  return CheckButton;
end


function OptionsPage:BuildUI()

  -- title 
  self:CreateLine({a="TOPLEFT", x=0, y=-20},{w=213, h=1},{r=1, g=1, b=1, a=0.5})
  self:CreateText("Classic Raid Info & Resets", "GameFontNormalLarge", {a="TOP", x=-10, y=-12})
  self:CreateLine({a="TOPRIGHT", x=-15, y=-20},{w=220, h=1},{r=1, g=1, b=1, a=0.5})

  --settings
  self:CreateText(L["SETTINGS"],"GameFontNormal",{a="TOPLEFT",x=10,y=-30},12,{r=1, g=1, b=1, a=1})

  self:CreateText(L["RAID_INFO_BUTTON"],"GameFontNormal",{a="TOPLEFT",x=20,y=-60},10)
  self:dropdown()

  self:CreateCheckButton(L["INCLUDE_EDGE_OF_MADNESS"],{a="TOPLEFT", x=15, y=-105},Options.includeZGMadness,function(self)
      Options.includeZGMadness = self:GetChecked()
  end)
  self:CreateCheckButton(L["HIDE_FOR_NONE_SIXTIES"],{a="TOPLEFT", x=15, y=-135},Options.hideForNoneSixty,function(self)
      Options.hideForNoneSixty = self:GetChecked()
  end)

  self:CreateCheckButton(L["SHOW_MAPPIP"],{a="TOPLEFT", x=15, y=-165},Options.minimapPipShown,function(self)
      Options.minimapPipShown = self:GetChecked()

      if Options.minimapPipShown then
        Addon.MiniMapPip.button:Show()
      else 
        Addon.MiniMapPip.button:Hide()
      end
  end)

  --credits
  self:CreateLine({a="BOTTOMLEFT", x=0, y=20},{w=650, h=1},{r=1, g=1, b=1, a=0.5})

  local version = GetAddOnMetadata("ClassicRaidInfoAndResets", "Version")
  local creditsString = string.format("v.%s", version, soruceURL)

  local credits = self:CreateText(creditsString,"GameFontNormal",{a="BOTTOMRIGHT",x=-20,y=5})
  credits:SetJustifyH("RIGHT")

end

function OptionsPage:RegisterCanvas(frame,text,id)
	local cat = Settings.RegisterCanvasLayoutCategory(frame,text,id)
	cat.ID = id
	Settings.RegisterAddOnCategory(cat)
end

function OptionsPage:Setup()
  self.OptionsPanel = CreateFrame("Frame", "MyAddonOptionsPanel", InterfaceOptionsFramePanelContainer)
  self:BuildUI()
  self:RegisterCanvas(self.OptionsPanel, "Classic Raid Info & Resets", "ClassicRaidInfoAndResets")
end