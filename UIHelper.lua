local _, Addon = ...
local L = Addon.L

Addon.UIHelper = {}

function Addon.UIHelper:Shown(element, show)
    if show then
        element:Show()
    else
        element:Hide()
    end
end

function Addon.UIHelper:CreateLine(parent,pos, size, colour)
    local line = parent:CreateTexture(nil, "ARTWORK")    
    line:SetSize(unpack(size))
    line:SetPoint(unpack(pos))
    line:SetColorTexture(unpack(colour))
    return line
end

function Addon.UIHelper:CreateText(parent, value, pos, size, colour, align)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint(unpack(pos))
    text:SetText(value or "")
    text:SetJustifyH(align or "LEFT")

    if colour then
        text:SetTextColor(unpack(colour))
    end

    if size then
        local fontName, fontHeight, fontFlags = GameFontNormal:GetFont()
        text:SetFont(fontName, size, fontFlags)
    end

    return text
end

function Addon.UIHelper:CreateCheckButton(parent, text, pos, checked, func)
    local CheckButton = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    CheckButton:SetPoint(unpack(pos))
    CheckButton.Text:SetText(text)
    CheckButton:SetChecked(checked)
    CheckButton:SetScript("OnClick", func)

    return CheckButton;
end