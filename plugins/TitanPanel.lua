local AddonKey, Addon = ...
local L = Addon.L

local TITAN_PLUGIN = AddonKey
local TITAN_BUTTON = "TitanPanel" .. TITAN_PLUGIN .. "Button"
local ADDON_NAME = "Classic Raid Info & Resets"

local function CreateMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_PLUGIN].menuText);
	TitanPanelRightClickMenu_AddControlVars(TITAN_PLUGIN)
end

local function GetButtonText(id)
	return TitanGetVar(TITAN_PLUGIN, "ShowLabelText") and ADDON_NAME or ""
end

local function GetTooltipText()
	Addon.RaidInfoUtility:StoreSavedRaidIDs()
	local raidsData = Addon.RaidInfoUtility:GetRaidsData()

	local unSavedColourString = "|cffffd100%s -|r |cff8d8d8d%s|r"
	local savedColourString = "|cffffd100%s -|r |cffffffff%s|r"

	local raidsStrings = {}
	for key,raid in pairs(raidsData) do
		local raidString = (raid.savedID and savedColourString or unSavedColourString):format(raid.name,(raid.savedID and raid.savedID or L["NOT_SAVED"]))
		table.insert(raidsStrings, raidString .. "\t" .. ("|cff33cc33%s|r"):format(raid.time))
		if raid.code == "ZG" and Options.includeZGMadness then
			local zgData = Addon.RaidInfoUtility:CalculateZGMaddnessInfo()
			for index,bossData in ipairs(zgData.bosses) do
				if index == zgData.currentBoss or Options.showFullMadnessRotation then
					local linedate = index == zgData.currentBoss and {">",bossData,("\t|cff33cc33%s|r"):format(zgData.changeIn)} or {"-",bossData,""}
					table.insert(raidsStrings, ("|cffffffff%s|r %s%s"):format(unpack(linedate)))
				end
			end
		end
	end

    return table.concat(raidsStrings, "\n")
end

local function CreateTitanPlugin()
	local f = CreateFrame("Frame", nil, UIParent)
	local window = CreateFrame("Button", TITAN_BUTTON, f, "TitanPanelComboTemplate")
	window:SetFrameStrata("FULLSCREEN")

	window.registry = {
		id = TITAN_PLUGIN,
		category = "Information",
		version = GetAddOnMetadata(AddonKey, "Version"),
		menuText = ADDON_NAME,
		menuTextFunction = CreateMenu,
		buttonTextFunction = GetButtonText,
		tooltipTitle = ADDON_NAME,
		tooltipTextFunction = GetTooltipText,
		icon = "Interface\\AddOns\\ClassicRaidInfoAndResets\\images\\MapPip",
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true,
			DisplayOnRightSide = true,
		},
		savedVariables = {
			ShowIcon = 1,
			ShowLabelText = 1,
			DisplayOnRightSide = false,
		}
	};	
end

if IsAddOnLoaded("TitanClassic") then
	if _G[TITAN_BUTTON] then
		return -- if already created
	end

	CreateTitanPlugin()
end