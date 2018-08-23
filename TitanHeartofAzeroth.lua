-- Description: Titan Panel plugin that tracks Heart of Azeroth Artifact Power
-- Author: Skolyr

local ADDON_NAME, L = ...;
local VERSION = GetAddOnMetadata(ADDON_NAME, "Version")

local Color = {}
Color.WHITE = "|cffffffff"
Color.GREY = "|cffc6c5e2"
Color.CYAN = "|cff00f9ed"
Color.YELLOW = "|cffffd230"
Color.GREEN = "|cff3ddc53"
Color.RED = "|cffe50000"
Color.ARTIFACT = "|cffe6cc80"

local exists = false;
local heart_max = 0;
local session_ap = 0;

local function GetAzeriteInformation(location)
	local level = C_AzeriteItem.GetPowerLevel(location)
	local current, next_level = C_AzeriteItem.GetAzeriteItemXPInfo(location)
	heart_max = next_level;
	return level, current, next_level
end

local function round(num)
   if ((num % 1) < 0.5) then
      return math.floor(num)
   else
      return math.ceil(num)
   end
end

local function GetButtonText(self, id)
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	local level = 0
	local current = 0
	local next_level = 0
	
	if (azeriteItemLocation) then
		exists = true;
		level, current, next_level = GetAzeriteInformation(azeriteItemLocation)
	end
	
	local name = Color.ARTIFACT .. "Heart of Azeroth: |r"


	if (not exists) then
		return name, Color.RED .. "N/A|r"
	end
	
	local text = ""
	
	local showLevel = TitanGetVar(id, "ShowLevel")
	local showCurrent = TitanGetVar(id, "ShowCurrent")
	local showPercent = TitanGetVar(id, "ShowPercent")
	
	if (showLevel) then
		text = text .. Color.CYAN .. level .. "|r "
		if (showCurrent or showPercent) then
			text = text .. " - "
		end
	end
	
	local hideMax = TitanGetVar(id, "HideMax")
	if showCurrent then
		text = text .. Color.GREY .. current .. "|r"

		if not hideMax then
			text = text .. Color.GREY .. "/" .. next_level .. "|r"
		end
	end
	
	if TitanGetVar(id, "ShowPercent") then
		local percent = round((current) * 100 / (next_level))
		if (max == 0) then
			percent = 100
		end

		if (showCurrent) then
			text = text .. Color.GREEN .. "  (" .. percent .. "%)|r" 
		else
			text = text .. Color.GREEN .. percent .. "%|r"
		end
		
	end
		
	return name, text
end

local function GetTooltipText(self, id)
	if (not exists) then
		return Color.RED .. "Sorry, you do not have this item yet.|r\n" ..
			Color.WHITE .. "Reload UI once you have completed the quest |r" ..
			Color.YELLOW .. "[The Heart of Azeroth]|r "
	end

	local text = "Current AP for this session: "
	
	text = text .. session_ap
	
	return text
end

local function updateSessionAP(old, new)
	if (new > old) then
		session_ap = session_ap + (new - old)
	else
		session_ap = session_ap + (heart_max - old) + new
	end
end

local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		TitanPanelButton_UpdateButton(self.registry.id)
	end,
	AZERITE_ITEM_EXPERIENCE_CHANGED = function(self, location, old, new)
		updateSessionAP(old, new)
		TitanPanelButton_UpdateButton(self.registry.id)
	end,		
	AZERITE_ITEM_POWER_LEVEL_CHANGED = function(self)
		TitanPanelButton_UpdateButton(self.registry.id)
	end
}

local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end

local menus = {
	{ type = "space" },
	{ type = "toggle", text = L["ShowLevel"], var = "ShowLevel", def = true, keepShown = true },
	{ type = "toggle", text = L["ShowCurrent"], var = "ShowCurrent", def = true, keepShown = true },
	{ type = "toggle", text = L["ShowPercent"], var = "ShowPercent", def = true, keepShown = true },
	{ type = "toggle", text = L["HideMax"], var = "HideMax", def = false, keepShown = true },
	{ type = "space" },
	{ type = "rightSideToggle" }
}

L.Elib({
	id = "TITAN_HEART_OF_AZEROTH",
	name = L["Heart"],
	tooltip = L["Heart"],
	icon = "Interface\\Icons\\INV_HeartOfAzeroth",
	category = "Information",
	version = VERSION,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	eventsTable = eventsTable,
	menus = menus,
	onClick = OnClick
})


