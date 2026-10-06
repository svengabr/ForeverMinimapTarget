-- The minimap tracking menu only lists the Target and Focus filters when
-- minimapTrackingShowAll is on (they are in MinimapConstants.CONDITIONAL_FILTERS).
-- The filters themselves still work, so this adds checkboxes for them to the
-- normal menu. The game saves the tracking state per character.

local FILTER_KEYS = { "Target", "Focus" };

local function FindIndex(filterID)
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local filter = C_Minimap.GetTrackingFilter(index);
		if filter and filter.filterID == filterID then
			return index;
		end
	end
end

local function IsActive(filterID)
	local index = FindIndex(filterID);
	local info = index and C_Minimap.GetTrackingInfo(index);
	return info ~= nil and info.active == true;
end

local function Toggle(filterID)
	local index = FindIndex(filterID);
	if index then
		C_Minimap.SetTracking(index, not IsActive(filterID));
	end
end

local function AddCheckbox(rootDescription, filterID, info)
	local desc = rootDescription:CreateCheckbox(info.name, IsActive, Toggle, filterID);
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
	-- With show-all on, Blizzard already lists both entries.
	if C_CVar.GetCVarBool("minimapTrackingShowAll") then
		return;
	end

	local entries = {};
	for _, key in ipairs(FILTER_KEYS) do
		local filterID = Enum.MinimapTrackingFilter[key];
		local index = filterID and FindIndex(filterID);
		if index then
			table.insert(entries, { filterID = filterID, info = C_Minimap.GetTrackingInfo(index) });
		end
	end
	if #entries == 0 then
		return;
	end

	rootDescription:CreateDivider();
	for _, entry in ipairs(entries) do
		AddCheckbox(rootDescription, entry.filterID, entry.info);
	end
end);
