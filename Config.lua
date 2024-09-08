local ADDON_NAME, namespace = ...
local L = namespace.L

GhostReconDB.Settings = GhostReconDB.Settings or {}

-- GUI draggable ability bar dummy
local abilityDragBar = CreateFrame("Frame", nil, UIParent)
abilityDragBar:SetClampedToScreen(true)
abilityDragBar:Hide()
abilityDragBar.texture = abilityDragBar:CreateTexture(nil, "ARTWORK")
abilityDragBar.texture:SetColorTexture(0, 0, 1, 0.3)
abilityDragBar:EnableMouse(true)
abilityDragBar:SetMovable(true)
abilityDragBar:RegisterForDrag("LeftButton")
abilityDragBar:SetScript("OnDragStart", function(this)
	this:StartMoving()
end)
abilityDragBar:SetScript("OnDragStop", function(this)
	this:StopMovingOrSizing()
	GhostReconDB.Settings.Anchor, _, GhostReconDB.Settings.RelativeAnchor, GhostReconDB.Settings.X, GhostReconDB.Settings.Y = this:GetPoint()
	GhostRecon.abilityBar:SetAllPoints(this)
end)
abilityDragBar:SetScript("OnMouseDown", function(self, button)
	if button == "RightButton" then GRAbilityDragBarToggle() end
end)
abilityDragBar:SetScript("OnMouseWheel", function(self, delta)
	GRScaleChange(delta)
end)

-- the frame itself
local optionsFrame = CreateFrame("Frame", nil, UIParent)
optionsFrame.name = "Ghost: Recon"
optionsFrame:SetWidth(350)
optionsFrame:SetHeight(400)

optionsFrame.okay = function()
	GhostReconDB.Settings.TooltipEnabled = optionsFrame.Tooltip:GetChecked()
	GhostReconDB.Settings.TooltipSpellsEnabled = optionsFrame.TooltipSpells:GetChecked() or false
	GhostReconDB.Settings.TooltipIconsEnabled = optionsFrame.TooltipIcons:GetChecked() or false
	GhostReconDB.Settings.AbilitiesBarEnabled = optionsFrame.AbilitiesBar:GetChecked()
	GhostReconDB.Settings.BarUnit = optionsFrame.BarUnit:GetText()
	GhostReconDB.Settings.GuildSync = optionsFrame.Sync:GetChecked() or false
	GhostReconDB.Settings.ShowMessages = optionsFrame.Messages:GetChecked()
	GhostReconDB.Settings.InstancesOnly = optionsFrame.InstancesOnly:GetChecked()
	GhostReconDB.Settings.Scale = optionsFrame.Scale:GetValue() or 1
	GhostReconDB.Settings.Columns = optionsFrame.Columns:GetValue()
	GhostReconDB.Settings.OutOfCombatAlpha = optionsFrame.OutOfCombatAlpha:GetValue()
	GhostReconDB.Settings.InCombatAlpha = optionsFrame.InCombatAlpha:GetValue()

	GhostRecon:RefreshBar()
end

-- function to sync the frame with the settings
local function ShowCurrentSettings()
	optionsFrame.Tooltip:SetChecked(GhostReconDB.Settings.TooltipEnabled)
	optionsFrame.TooltipSpells:SetChecked(GhostReconDB.Settings.TooltipSpellsEnabled)
	optionsFrame.TooltipIcons:SetChecked(GhostReconDB.Settings.TooltipIconsEnabled)
	optionsFrame.AbilitiesBar:SetChecked(GhostReconDB.Settings.AbilitiesBarEnabled)
	optionsFrame.BarUnit:SetText(GhostReconDB.Settings.BarUnit or "target")

	optionsFrame.Scale:SetValue(GhostReconDB.Settings.Scale or 1)
	optionsFrame.ScaleLabel:SetText(L["Bar Scale: "] .. GhostReconDB.Settings.Scale)

	optionsFrame.Sync:SetChecked(GhostReconDB.Settings.GuildSync)
	optionsFrame.Messages:SetChecked(GhostReconDB.Settings.ShowMessages)
	optionsFrame.InstancesOnly:SetChecked(GhostReconDB.Settings.InstancesOnly)

	optionsFrame.Columns:SetValue(GhostReconDB.Settings.Columns or 18)
	optionsFrame.ColumnsLabel:SetText(L["Columns: "] .. optionsFrame.Columns:GetValue())

	optionsFrame.OutOfCombatAlpha:SetValue(GhostReconDB.Settings.OutOfCombatAlpha or 1)
	optionsFrame.OutOfCombatAlphaLabel:SetText(string.format(L["Out of Combat Alpha: %d%%"], optionsFrame.OutOfCombatAlpha:GetValue() * 100))

	optionsFrame.InCombatAlpha:SetValue(GhostReconDB.Settings.InCombatAlpha or 1)
	optionsFrame.InCombatAlphaLabel:SetText(string.format(L["In-Combat Alpha: %d%%"], optionsFrame.InCombatAlpha:GetValue() * 100))

	if optionsFrame.Tooltip:GetChecked() then
		optionsFrame.TooltipSpells:Enable()
	else
		optionsFrame.TooltipSpells:Disable()
	end
end

optionsFrame.cancel = function()
	ShowCurrentSettings()
	GhostRecon:RefreshBar()
end

optionsFrame.default = function()
	GhostReconDB.Settings.BarUnit = "target"
	GhostReconDB.Settings.Scale = 1
	GhostReconDB.Settings.TooltipEnabled = true
	GhostReconDB.Settings.TooltipSpellsEnabled = true
	GhostReconDB.Settings.TooltipIconsEnabled = true
	GhostReconDB.Settings.AbilitiesBarEnabled = true
	GhostReconDB.Settings.Anchor, GhostReconDB.Settings.RelativeAnchor = "CENTER", "CENTER"
	GhostReconDB.Settings.X, GhostReconDB.Settings.Y = 0, 0
	GhostReconDB.Settings.GuildSync = true
	GhostReconDB.Settings.ShowMessages = nil
	GhostReconDB.Settings.InstancesOnly = nil
	GhostReconDB.Settings.Columns = 12
	GhostReconDB.Settings.OutOfCombatAlpha = 1
	GhostReconDB.Settings.InCombatAlpha = 1

	ShowCurrentSettings()
	GhostRecon:RefreshBar()
end

-- temp redraw
local function TemporaryRedraw()
	local cols = optionsFrame.Columns:GetValue()
	local rows = math.ceil(18 / cols)

	abilityDragBar:SetWidth(cols * (optionsFrame.Scale:GetValue() * 32) + (cols - 1) * GhostRecon.CONST_PADDING)
	abilityDragBar:SetHeight(rows * (optionsFrame.Scale:GetValue() * 32) + (rows - 1) * GhostRecon.CONST_PADDING)

	GhostRecon.abilityBar:SetAllPoints(abilityDragBar)
end

-- title
optionsFrame.Title = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optionsFrame.Title:SetWidth(340)
optionsFrame.Title:SetHeight(20)
optionsFrame.Title:SetPoint("TOPLEFT", 15, -14)
optionsFrame.Title:SetJustifyH("LEFT")
optionsFrame.Title:SetText("Ghost: Recon " .. C_AddOns.GetAddOnMetadata("GhostRecon", "Version"))

-- tooltip check-box
optionsFrame.Tooltip = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.Tooltip:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -50)
optionsFrame.Tooltip:SetWidth(24)
optionsFrame.Tooltip:SetHeight(24)
optionsFrame.Tooltip:SetScript("OnClick", function()
	if optionsFrame.Tooltip:GetChecked() then
		optionsFrame.TooltipSpells:Enable()
	else
		optionsFrame.TooltipSpells:Disable()
	end
end)

-- tooltip label
optionsFrame.TooltipLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.TooltipLabel:SetWidth(300)
optionsFrame.TooltipLabel:SetHeight(20)
optionsFrame.TooltipLabel:SetPoint("TOPLEFT", 40, -51)
optionsFrame.TooltipLabel:SetJustifyH("LEFT")
optionsFrame.TooltipLabel:SetTextColor(1, 1, 1)
optionsFrame.TooltipLabel:SetText(L["Tooltip enabled"])

-- tooltip spells check-box
optionsFrame.TooltipSpells = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.TooltipSpells:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 232, -50)
optionsFrame.TooltipSpells:SetWidth(24)
optionsFrame.TooltipSpells:SetHeight(24)
-- tooltip spells label
optionsFrame.TooltipSpellsLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.TooltipSpellsLabel:SetWidth(300)
optionsFrame.TooltipSpellsLabel:SetHeight(20)
optionsFrame.TooltipSpellsLabel:SetPoint("TOPLEFT", 262, -51)
optionsFrame.TooltipSpellsLabel:SetJustifyH("LEFT")
optionsFrame.TooltipSpellsLabel:SetTextColor(1, 1, 1)
optionsFrame.TooltipSpellsLabel:SetText(L["Add spells to tooltip"])

-- tooltip icons check-box
optionsFrame.TooltipIcons = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.TooltipIcons:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -75)
optionsFrame.TooltipIcons:SetWidth(24)
optionsFrame.TooltipIcons:SetHeight(24)
-- tooltip icons label
optionsFrame.TooltipIconsLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.TooltipIconsLabel:SetWidth(300)
optionsFrame.TooltipIconsLabel:SetHeight(20)
optionsFrame.TooltipIconsLabel:SetPoint("TOPLEFT", 40, -76)
optionsFrame.TooltipIconsLabel:SetJustifyH("LEFT")
optionsFrame.TooltipIconsLabel:SetTextColor(1, 1, 1)
optionsFrame.TooltipIconsLabel:SetText(L["Show icons in tooltip"])

-- abilities bar check-box
optionsFrame.AbilitiesBar = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.AbilitiesBar:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 232, -75)
optionsFrame.AbilitiesBar:SetWidth(24)
optionsFrame.AbilitiesBar:SetHeight(24)
optionsFrame.AbilitiesBar:SetScript("OnClick", function()
	if not optionsFrame.AbilitiesBar:GetChecked() then
		GhostRecon.abilityBar:Hide()
	end
end)
-- abilities label
optionsFrame.AbilitiesBarLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.AbilitiesBarLabel:SetWidth(300)
optionsFrame.AbilitiesBarLabel:SetHeight(20)
optionsFrame.AbilitiesBarLabel:SetPoint("TOPLEFT", 262, -76)
optionsFrame.AbilitiesBarLabel:SetJustifyH("LEFT")
optionsFrame.AbilitiesBarLabel:SetTextColor(1, 1, 1)
optionsFrame.AbilitiesBarLabel:SetText(L["Show abilities bar"])

-- bar unit
optionsFrame.BarUnit = CreateFrame("EditBox", "GhostReconBarUnit", optionsFrame, "InputBoxTemplate")
optionsFrame.BarUnit:SetPoint("TOPLEFT", 288, -98)
optionsFrame.BarUnit:SetTextInsets(0, 0, 0, 0)
optionsFrame.BarUnit:SetWidth(96)
optionsFrame.BarUnit:SetHeight(32)
optionsFrame.BarUnit:SetAutoFocus(false)
-- bar unit label
optionsFrame.BarUnitLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.BarUnitLabel:SetWidth(128)
optionsFrame.BarUnitLabel:SetHeight(20)
optionsFrame.BarUnitLabel:SetPoint("TOPLEFT", 148, -104)
optionsFrame.BarUnitLabel:SetJustifyH("RIGHT")
optionsFrame.BarUnitLabel:SetTextColor(1, 1, 1)
optionsFrame.BarUnitLabel:SetText(L["Unit for bar"])

-- 'scale' slider
optionsFrame.Scale = CreateFrame("Slider", nil, optionsFrame, "OptionsSliderTemplate")
optionsFrame.Scale:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -152)
optionsFrame.Scale:SetWidth(350)
optionsFrame.Scale:SetHeight(16)
optionsFrame.Scale:SetOrientation("HORIZONTAL")
optionsFrame.Scale:SetMinMaxValues(0.5, 3)
optionsFrame.Scale:SetValueStep(0.01)
optionsFrame.Scale:SetObeyStepOnDrag(true)
optionsFrame.Scale:SetScript("OnValueChanged", function()
	local tempval
	tempval = math.ceil(math.floor(optionsFrame.Scale:GetValue() * 1000) / 10) / 100
	optionsFrame.Scale:SetValue(tempval)
	--	if optionsFrame:IsVisible() then
	TemporaryRedraw()
	optionsFrame.ScaleLabel:SetText(L["Bar Scale: "] .. tempval)
	--	end
	GhostReconDB.Settings.Scale = tempval or 1
	GhostRecon:RefreshBar()
	--	GhostRecon:RefreshSpells(GhostReconDB.Settings.BarUnit)
end)

optionsFrame.Scale:SetScript("OnMouseWheel", function(self, delta)
	GRScaleChange(delta)
end)

-- scale label
optionsFrame.ScaleLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.ScaleLabel:SetWidth(350)
optionsFrame.ScaleLabel:SetHeight(20)
optionsFrame.ScaleLabel:SetPoint("TOPLEFT", 20, -132)
optionsFrame.ScaleLabel:SetJustifyH("CENTER")
optionsFrame.ScaleLabel:SetTextColor(1, 1, 1)

-- 'columns' slider
optionsFrame.Columns = CreateFrame("Slider", nil, optionsFrame, "OptionsSliderTemplate")
optionsFrame.Columns:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -199)
optionsFrame.Columns:SetWidth(350)
optionsFrame.Columns:SetHeight(16)
optionsFrame.Columns:SetOrientation("HORIZONTAL")
optionsFrame.Columns:SetMinMaxValues(1, 18)
optionsFrame.Columns:SetValueStep(1)
optionsFrame.Columns:SetObeyStepOnDrag(true)
optionsFrame.Columns:SetScript("OnValueChanged", function()
	if optionsFrame:IsVisible() then
		TemporaryRedraw()
		optionsFrame.ColumnsLabel:SetText(L["Columns: "] .. optionsFrame.Columns:GetValue())
	end
	GhostReconDB.Settings.Columns = optionsFrame.Columns:GetValue()
	GhostRecon:RefreshBar()
end)
optionsFrame.Columns:SetScript("OnMouseWheel", function(self, delta)
	local current = optionsFrame.Columns:GetValue()
	if (delta > 0) and (current < 18) then
		optionsFrame.Columns:SetValue(current + 1)
	elseif (delta < 0) and (current > 1) then
		optionsFrame.Columns:SetValue(current - 1)
	end
end)

-- columns label
optionsFrame.ColumnsLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.ColumnsLabel:SetWidth(350)
optionsFrame.ColumnsLabel:SetHeight(20)
optionsFrame.ColumnsLabel:SetPoint("TOPLEFT", 20, -179)
optionsFrame.ColumnsLabel:SetJustifyH("CENTER")
optionsFrame.ColumnsLabel:SetTextColor(1, 1, 1)

-- 'out of combat alpha' slider
optionsFrame.OutOfCombatAlpha = CreateFrame("Slider", nil, optionsFrame, "OptionsSliderTemplate")
optionsFrame.OutOfCombatAlpha:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -246)
optionsFrame.OutOfCombatAlpha:SetWidth(350)
optionsFrame.OutOfCombatAlpha:SetHeight(16)
optionsFrame.OutOfCombatAlpha:SetOrientation("HORIZONTAL")
optionsFrame.OutOfCombatAlpha:SetMinMaxValues(0, 1)
optionsFrame.OutOfCombatAlpha:SetValueStep(0.01)
optionsFrame.OutOfCombatAlpha:SetObeyStepOnDrag(true)
optionsFrame.OutOfCombatAlpha:SetScript("OnValueChanged", function()
	if optionsFrame:IsVisible() then
		optionsFrame.OutOfCombatAlphaLabel:SetText(string.format(L["Out of Combat Alpha: %d%%"], optionsFrame.OutOfCombatAlpha:GetValue() * 100))
	end
	GhostReconDB.Settings.OutOfCombatAlpha = optionsFrame.OutOfCombatAlpha:GetValue()
	GhostRecon:RefreshSpells(GhostReconDB.Settings.BarUnit)
end)
optionsFrame.OutOfCombatAlpha:SetScript("OnMouseWheel", function(self, delta)
	local current = optionsFrame.OutOfCombatAlpha:GetValue()
	if (delta > 0) and (current < 1) then
		optionsFrame.OutOfCombatAlpha:SetValue(current + 0.01)
	elseif (delta < 0) and (current > 0) then
		optionsFrame.OutOfCombatAlpha:SetValue(current - 0.01)
	end
end)

-- 'out of combat alpha' label
optionsFrame.OutOfCombatAlphaLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.OutOfCombatAlphaLabel:SetWidth(350)
optionsFrame.OutOfCombatAlphaLabel:SetHeight(20)
optionsFrame.OutOfCombatAlphaLabel:SetPoint("TOPLEFT", 20, -226)
optionsFrame.OutOfCombatAlphaLabel:SetJustifyH("CENTER")
optionsFrame.OutOfCombatAlphaLabel:SetTextColor(1, 1, 1)

-- 'in combat alpha' slider
optionsFrame.InCombatAlpha = CreateFrame("Slider", nil, optionsFrame, "OptionsSliderTemplate")
optionsFrame.InCombatAlpha:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, -293)
optionsFrame.InCombatAlpha:SetWidth(350)
optionsFrame.InCombatAlpha:SetHeight(16)
optionsFrame.InCombatAlpha:SetOrientation("HORIZONTAL")
optionsFrame.InCombatAlpha:SetMinMaxValues(0, 1)
optionsFrame.InCombatAlpha:SetValueStep(0.01)
optionsFrame.InCombatAlpha:SetObeyStepOnDrag(true)
optionsFrame.InCombatAlpha:SetScript("OnValueChanged", function()
	if optionsFrame:IsVisible() then
		optionsFrame.InCombatAlphaLabel:SetText(string.format(L["In-Combat Alpha: %d%%"], optionsFrame.InCombatAlpha:GetValue() * 100))
	end
	GhostReconDB.Settings.InCombatAlpha = optionsFrame.InCombatAlpha:GetValue()
	GhostRecon:RefreshSpells(GhostReconDB.Settings.BarUnit)
end)
optionsFrame.InCombatAlpha:SetScript("OnMouseWheel", function(self, delta)
	local current = optionsFrame.InCombatAlpha:GetValue()
	if (delta > 0) and (current < 1) then
		optionsFrame.InCombatAlpha:SetValue(current + 0.01)
	elseif (delta < 0) and (current > 0) then
		optionsFrame.InCombatAlpha:SetValue(current - 0.01)
	end
end)

-- 'in of combat alpha' label
optionsFrame.InCombatAlphaLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.InCombatAlphaLabel:SetWidth(350)
optionsFrame.InCombatAlphaLabel:SetHeight(20)
optionsFrame.InCombatAlphaLabel:SetPoint("TOPLEFT", 20, -273)
optionsFrame.InCombatAlphaLabel:SetJustifyH("CENTER")
optionsFrame.InCombatAlphaLabel:SetTextColor(1, 1, 1)

-- guild sync
optionsFrame.Sync = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.Sync:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -340)
optionsFrame.Sync:SetWidth(24)
optionsFrame.Sync:SetHeight(24)
optionsFrame.Sync:SetChecked(true)

-- messages label
optionsFrame.SyncLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.SyncLabel:SetWidth(300)
optionsFrame.SyncLabel:SetHeight(20)
optionsFrame.SyncLabel:SetPoint("TOPLEFT", 40, -341)
optionsFrame.SyncLabel:SetJustifyH("LEFT")
optionsFrame.SyncLabel:SetTextColor(1, 1, 1)
optionsFrame.SyncLabel:SetText(L["Synchronize with guild members"])

-- messages check-box
optionsFrame.Messages = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.Messages:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -365)
optionsFrame.Messages:SetWidth(24)
optionsFrame.Messages:SetHeight(24)
optionsFrame.Messages:SetChecked(true)

-- messages label
optionsFrame.MessagesLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.MessagesLabel:SetWidth(300)
optionsFrame.MessagesLabel:SetHeight(20)
optionsFrame.MessagesLabel:SetPoint("TOPLEFT", 40, -366)
optionsFrame.MessagesLabel:SetJustifyH("LEFT")
optionsFrame.MessagesLabel:SetTextColor(1, 1, 1)
optionsFrame.MessagesLabel:SetText(L["Display information messages"])

-- instances check-box
optionsFrame.InstancesOnly = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.InstancesOnly:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -390)
optionsFrame.InstancesOnly:SetWidth(24)
optionsFrame.InstancesOnly:SetHeight(24)
optionsFrame.InstancesOnly:SetChecked(true)

-- instances label
optionsFrame.InstancesOnlyLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.InstancesOnlyLabel:SetWidth(300)
optionsFrame.InstancesOnlyLabel:SetHeight(20)
optionsFrame.InstancesOnlyLabel:SetPoint("TOPLEFT", 40, -391)
optionsFrame.InstancesOnlyLabel:SetJustifyH("LEFT")
optionsFrame.InstancesOnlyLabel:SetTextColor(1, 1, 1)
optionsFrame.InstancesOnlyLabel:SetText(L["Record instances/raids only"])

-- locked check-box
optionsFrame.Locked = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
optionsFrame.Locked:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 310, -390)
optionsFrame.Locked:SetWidth(24)
optionsFrame.Locked:SetHeight(24)
optionsFrame.Locked:SetChecked(true)

-- locked label
optionsFrame.LockedLabel = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optionsFrame.LockedLabel:SetWidth(300)
optionsFrame.LockedLabel:SetHeight(20)
optionsFrame.LockedLabel:SetPoint("TOPLEFT", 340, -391)
optionsFrame.LockedLabel:SetJustifyH("LEFT")
optionsFrame.LockedLabel:SetTextColor(1, 1, 1)
optionsFrame.LockedLabel:SetText(L["Locked"])
optionsFrame.Locked:SetScript("OnClick", function()
	GRAbilityDragBarToggle()
end)

function GRAbilityDragBarToggle()
	local cols = optionsFrame.Columns:GetValue()
	local rows = math.ceil(18 / cols)
	if abilityDragBar:IsVisible() then
		abilityDragBar:Hide()
		optionsFrame.Locked:SetChecked(true)
	else
		abilityDragBar:SetPoint(GhostReconDB.Settings.Anchor or "CENTER", UIParent, GhostReconDB.Settings.RelativeAnchor or "CENTER", GhostReconDB.Settings.X or 0, GhostReconDB.Settings.Y or 0)
		abilityDragBar:SetWidth(cols * (optionsFrame.Scale:GetValue() * 32) + (cols - 1) * GhostRecon.CONST_PADDING)
		abilityDragBar:SetHeight(rows * (optionsFrame.Scale:GetValue() * 32) + (rows - 1) * GhostRecon.CONST_PADDING)
		abilityDragBar.texture:SetAllPoints(abilityDragBar)
		abilityDragBar:Show()
		optionsFrame.Locked:SetChecked(false)
	end
end

function GRScaleChange(delta)
	local current = optionsFrame.Scale:GetValue()
	if (delta > 0) and (current < 3) then
		optionsFrame.Scale:SetValue(current + 0.01)
	elseif (delta < 0) and (current > 0.5) then
		optionsFrame.Scale:SetValue(current - 0.01)
	end
end

-- tidy ups
optionsFrame:Hide()

-- register the frame with WoW
local category, _ = Settings.RegisterCanvasLayoutCategory(optionsFrame, optionsFrame.name)
optionsFrame.settingsCategory = category
Settings.RegisterAddOnCategory(category)

-- make the frame available to the slash command handler
GhostRecon.optionsFrame = optionsFrame
GhostRecon.abilityDragBar = abilityDragBar

local function OnEvent(frame, event, whichAddon)
	if event == "ADDON_LOADED" and whichAddon == "GhostRecon" then
		ShowCurrentSettings()
	end
end

optionsFrame:RegisterEvent("ADDON_LOADED")
optionsFrame:SetScript("OnEvent", OnEvent)
