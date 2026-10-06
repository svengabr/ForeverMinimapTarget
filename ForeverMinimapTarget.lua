-- The minimap tracking menu only lists the Target and Focus filters when
-- minimapTrackingShowAll is on (they are in MinimapConstants.CONDITIONAL_FILTERS).
-- The filters themselves still work, so this adds checkboxes for them to the
-- normal menu. The game does not keep them on across logins, so the wanted
-- state is saved per character and applied again on every loading screen.

local ADDON_NAME = ...;

local FILTER_KEYS = { "Target", "Focus" };
-- Filters without a saved value are left as the game has them.
local DEFAULTS = { Target = true };

local db;

local function ShowAll()
	return C_CVar.GetCVarBool("minimapTrackingShowAll");
end

local function FindIndex(filterID)
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local filter = C_Minimap.GetTrackingFilter(index);
		if filter and filter.filterID == filterID then
			return index;
		end
	end
end

local function IsActive(key)
	local index = FindIndex(Enum.MinimapTrackingFilter[key]);
	local info = index and C_Minimap.GetTrackingInfo(index);
	return info ~= nil and info.active == true;
end

local function SetActive(key, active)
	local index = FindIndex(Enum.MinimapTrackingFilter[key]);
	if index and IsActive(key) ~= active then
		C_Minimap.SetTracking(index, active);
	end
end

-- With show-all on, Blizzard's own menu manages both filters, so leave them alone.
local function Apply()
	if not db or ShowAll() then
		return;
	end
	for _, key in ipairs(FILTER_KEYS) do
		if db[key] ~= nil then
			SetActive(key, db[key]);
		end
	end
end

local function Toggle(key)
	db[key] = not IsActive(key);
	SetActive(key, db[key]);
end

local function AddCheckbox(rootDescription, key, info)
	local desc = rootDescription:CreateCheckbox(info.name, IsActive, Toggle, key);
	-- Same right-aligned icon as Blizzard's own tracking entries.
	desc:AddInitializer(function(button)
		local icon = button:AttachTexture();
		icon:SetSize(20, 20);
		icon:SetPoint("RIGHT");
		icon:SetTexture(info.texture);

		local fontString = button.fontString;
		fontString:SetPoint("RIGHT", icon, "LEFT");
		return fontString:GetUnboundedStringWidth() + 60, 20;
	end);
end

Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(_, rootDescription)
	if not db or ShowAll() then
		return;
	end

	local entries = {};
	for _, key in ipairs(FILTER_KEYS) do
		local index = FindIndex(Enum.MinimapTrackingFilter[key]);
		if index then
			table.insert(entries, { key = key, info = C_Minimap.GetTrackingInfo(index) });
		end
	end
	if #entries == 0 then
		return;
	end

	rootDescription:CreateDivider();
	for _, entry in ipairs(entries) do
		AddCheckbox(rootDescription, entry.key, entry.info);
	end
end);

local frame = CreateFrame("Frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == ADDON_NAME then
			self:UnregisterEvent("ADDON_LOADED");
			ForeverMinimapTargetCharDB = ForeverMinimapTargetCharDB or {};
			db = ForeverMinimapTargetCharDB;
			for key, value in pairs(DEFAULTS) do
				if db[key] == nil then
					db[key] = value;
				end
			end
		end
	else
		-- The game may reset tracking shortly after the loading screen, so apply twice.
		Apply();
		C_Timer.After(3, Apply);
	end
end);
