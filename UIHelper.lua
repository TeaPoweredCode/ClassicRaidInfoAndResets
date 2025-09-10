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

function Addon.UIHelper:CreateTextElement(parent, anchorPoint, xPos, yPos, align, text , colour , fontSize)
    local textEle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textEle:SetPoint(anchorPoint, xPos, yPos)
    textEle:SetFont("Fonts\\FRIZQT__.TTF", fontSize or 12)
    textEle:SetJustifyH(align or "LEFT")
    textEle:SetText(text or "")

    if colour then
        textEle:SetTextColor(unpack(colour))
    end

    return textEle
end
