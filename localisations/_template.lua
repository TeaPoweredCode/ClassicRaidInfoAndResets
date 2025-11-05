-- INSTRUCTIONS 
-- Get your language code. | You can say "/script print("Current Locale:", GetLocale())" in game to get your code
-- Rename this file to your language code .lua | e.g. localisations\deDE.lua
-- Add the lanuage code to the check on line 10 | e.g. if GetLocale() ~= "deDE"
-- Translate the values on the left of the '=' on the lines below | e.g L["WRONG_VERSION"] = "Entschuldigung ... "
-- Add the language .lua file to the .toc file under localisations\enUS.lua | e.g. localisations\enUS.lua
--                                                                                 localisations\deDE.lua
-- Delete these INSTRUCTIONS so if GetLocale() ~= "{code}" is on line 1

if GetLocale() ~= ""

local _, Addon = ...
local L = {}
Addon.L = L

L["WRONG_VERSION"] = "Sorry this addon addon does't support version of wow"
L["WRONG_REGION"] = "Sorry this addon does't curretly support your region"

L["SETTINGS"] = "Settings"
L["RAID_INFO_BUTTON"] = "Raid info button"
L["HIDE_BUTTON"] = "Hide button"
L["TOGGLE_RAID_VIEW"] = "Show/Hide view"
L["SHOW_DEFAULT_INFO_WINDOW"] = "Show default info window"
L["INCLUDE_EDGE_OF_MADNESS"] = "Include Edge of Madness for Zul'Gurub"
L["SHOW_EDGE_OF_MADNESS_FULL"] = "Show full Madness rotation"
L["ONLY_SHOW_LEVEL_60"] = "Only show view on level 60s"
L["SHOW_MINIMAP_ICON"] = "Show minimap icon"
L["Select_View"] = "Select view"
L["Icon_View"] = "Icon view"
L["Full_View"] = "Full view"
L["Simple_View"] = "Simple view"
L["SOCIAL_RAID_TAB"] = "Social raid tab"
L["Map_Icon"] = "Minimap icon"

L["MOLTEN_CORE"] = "Molten Core"
L["ONYXIAS_LAIR"] = "Onyxia's Lair"
L["ZULGURUB"] = "Zul'Gurub"
L["BLACKWING_LAIR"] = "Blackwing Lair"
L["RUINS_OF_AHNQIRAJ"] = "Ruins of Ahn'Qiraj"
L["AHNQIRAJ_TEMPLE"] = "Ahn'Qiraj Temple"
L["NAXXRAMAS"] = "Naxxramas"

L["NOT_SAVED"] = "NOT SAVED"
L["CHANGES_IN"] = "Changes in"
L["RESET_IN"] = "Reset in"
L["EDGE_OF_MADNESS"] = "Edge of Madness"

L["DAYS"] = "Days"
L["HRS"] = "Hrs"
L["MINS"] = "Mins"