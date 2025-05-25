local ADDON_NAME, namespace = ...
local L = namespace.L

GhostRecon.CONST_PADDING = 1

local nextId = 1
local masterSpellFrame = nil
local nextRefreshTime = nil
local inCombat = false

local mobsInCombat = {}
local CooldownFrame_SetTimer = CooldownFrame_Set

local function CreateSpellFrame(spellId, parent)
  local rc = CreateFrame("Button", "GhostReconSpell" .. nextId, parent, "UIPanelButtonTemplate")

  rc.altSpellIds = {}

  rc.spellImage = rc:CreateTexture(nil, "ARTWORK")
  rc.spellImage:SetAllPoints(rc)

  rc.cooldownFrame = CreateFrame("Cooldown", "GhostReconSpell" .. nextId .. "Cooldown", rc, "CooldownFrameTemplate")
  rc.cooldownFrame.texture = rc.cooldownFrame:CreateTexture(nil, "ARTWORK")
  rc.cooldownFrame.texture:SetAllPoints(rc)
  rc.cooldownFrame.texture:SetTexture(0, 0, 0, 0)
  rc.cooldownFrame.texture:Show()

  rc.dispelFrame = rc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  rc.dispelFrame:SetAllPoints(rc)
  rc.dispelFrame:SetJustifyV("BOTTOM")
  rc.dispelFrame:SetJustifyH("RIGHT")
  rc.dispelFrame:SetShadowColor(0, 0, 0)
  rc.dispelFrame:SetShadowOffset(-1, 1)
  rc.dispelFrame:SetTextColor(0.3, 1, 0.3)
  rc.dispelFrame:Hide()

  rc:EnableMouse(true)
  rc:RegisterForClicks("LeftButtonUp")

  rc:SetScript("OnMouseDown", function(this)
    if IsShiftKeyDown() then
      if ChatFrame1EditBox:IsVisible() then
        ChatFrame1EditBox:Insert(this.hyperlink)
      else
        GhostRecon:Announce(this.hyperlink)
      end
    end
    if IsAltKeyDown() then
      GhostRecon:ReportCurrentAbilities()
    end
  end)

  rc:SetScript("OnEnter", function(this)
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetHyperlink(this.hyperlink)
    GameTooltip:Show()
  end)

  rc:SetScript("OnLeave", function(this)
    GameTooltip:FadeOut()
  end)

  function rc:SetSize(value)
    rc:SetWidth(value)
    rc:SetHeight(value)
  end

  rc.SetSpell = function(this, spellInfo)
    this.spellImage:SetTexture(spellInfo.iconID)
    this.spellId = spellInfo.spellId
    this.hyperlink = C_Spell.GetSpellLink(spellInfo.spellId)

    if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[spellInfo.spellId] then
      local dbInfo = GhostReconDB.SpellInfo[spellInfo.spellId]
      -- 统一处理D 驱散 和H 治疗 标志
      local dispelText = ""
      if dbInfo.removable then
        dispelText = dispelText .. "D"
      end
      if dbInfo.healType ~= nil then
        dispelText = dispelText .. "H"
      end

      if dispelText ~= "" then
        this.dispelFrame:SetText(dispelText)
        this.dispelFrame:Show()
      else
        this.dispelFrame:Hide()
      end
    else
      this.dispelFrame:Hide()
    end
  end

  rc:SetSize((GhostReconDB.Settings.Scale or 1) * 32)

  rc.FrameRepresentsSpell = function(this, spellId)
    local retCode

    if this.spellId == spellId then
      retCode = true
    elseif this.altSpellIds then
      retCode = this.altSpellIds[spellId]
    end

    return retCode
  end

  nextId = nextId + 1

  return rc
end

local function CreateSpellBar()
  local rc = CreateFrame("Frame", "GhostCCSpellBar", UIParent)

  -- preview bar
  rc.spellCount = 0
  rc.spellFrames = {}

  rc.LayoutSpells = function(this)
    local curX = 0
    local curY = 0
    local curCol = 1
    local curRow = 1

    for i = 1, this.spellCount do
      local v = this.spellFrames[i]

      curX = (curCol - 1) * (((GhostReconDB.Settings.Scale or 1) * 32) + GhostRecon.CONST_PADDING)
      curY = (curRow - 1) * (((GhostReconDB.Settings.Scale or 1) * 32) + GhostRecon.CONST_PADDING)

      v:SetPoint("TOPLEFT", rc, "TOPLEFT", curX, -curY)
      v.spellImage:SetAllPoints(v)
      v:SetSize((GhostReconDB.Settings.Scale or 1) * 32)
      v:Show()

      curCol = curCol + 1

      if curCol > (GhostReconDB.Settings.Columns or 18) then
        curCol = 1
        curRow = curRow + 1
      end
    end

    local maxCols = math.min(this.spellCount, GhostReconDB.Settings.Columns or 18)
    local maxRows = math.floor(this.spellCount / maxCols)

    if (this.spellCount / maxCols) % 1 > 0 then
      maxRows = maxRows + 1
    end

    if GhostReconDB.Settings.BarAlignment == nil then
      rc:SetWidth(maxCols * ((GhostReconDB.Settings.Scale or 1) * 32) + (maxCols - 1) * GhostRecon.CONST_PADDING)
      rc:SetHeight(maxRows * ((GhostReconDB.Settings.Scale or 1) * 32) + (maxRows - 1) * GhostRecon.CONST_PADDING)
    else
      local dispCols = GhostReconDB.Settings.Columns or 18
      local dispRows = math.floor(18 / dispCols)

      rc:SetWidth(dispCols * ((GhostReconDB.Settings.Scale or 1) * 32) + (dispCols - 1) * GhostRecon.CONST_PADDING)
      rc:SetHeight(dispRows * ((GhostReconDB.Settings.Scale or 1) * 32) + (dispRows - 1) * GhostRecon.CONST_PADDING)
    end
  end

  rc.SetSpells = function(this, spells)
    local posn = 1
    local namesSeen = {}

    if spells then
      for _, info in pairs(spells) do
        local curSpellFrame = this.spellFrames[posn]

        if not namesSeen[info.name] then
          namesSeen[info.name] = true

          if not curSpellFrame then
            curSpellFrame = CreateSpellFrame(info.spellId, this)
            table.insert(this.spellFrames, curSpellFrame)
          end

          curSpellFrame:SetSpell(info)
          curSpellFrame:Show()
          posn = posn + 1
        else
          this.spellFrames[posn - 1].altSpellIds[info.spellId] = true
        end
      end
    end

    for j = posn, this.spellCount do
      if this.spellFrames[j] then
        this.spellFrames[j]:Hide()
      end
    end

    this.spellCount = posn - 1
    this:LayoutSpells()

    if this.spellCount == 0 or not GhostReconDB.Settings.AbilitiesBarEnabled then
      this:Hide()
    end
  end

  rc.SetCooldown = function(this, spellId, startTime, duration, enabled)
    -- find the spell
    for i, v in pairs(this.spellFrames) do
      if v:FrameRepresentsSpell(spellId) then
        -- found it
        CooldownFrame_SetTimer(v.cooldownFrame, startTime, duration, enabled)
        break
      end
    end
  end

  rc.StopCooldowns = function(this)
    for i = 1, this.spellCount do
      CooldownFrame_SetTimer(this.spellFrames[i].cooldownFrame, 0, 0, 0)
    end
  end

  rc.StopSpell = function(this, mobGuid, mobName, spellId)
    local posnToRemove

    if mobsInCombat[mobGuid] then
      for i, info in pairs(mobsInCombat[mobGuid]) do
        if info.spellId == spellId then
          if info.mobGuid == mobGuid then
            posnToRemove = i
            break
          end
        end
      end

      if posnToRemove then
        table.remove(mobsInCombat, posnToRemove)

        if mobGuid == this.mobGuid then
          this:SetCooldown(spellId, 0, 0, 0)
        end
      end
    end
  end

  rc.SawSpell = function(this, mobGuid, mobName, spellId, startTime, duration)
    local info = {}

    info.radarType = "COOLDOWN"
    info.spellId = spellId
    info.startTime = startTime
    info.duration = duration
    info.mobGuid = mobGuid
    info.mobName = mobName

    mobsInCombat[mobGuid] = mobsInCombat[mobGuid] or {}
    table.insert(mobsInCombat[mobGuid], info)

    -- start the cooldown immediately if the mob we just saw a
    -- spell for is the one the ability bar currently references
    if mobGuid == this.mobGuid then
      this:SetCooldown(spellId, startTime, duration, 1)
    end
  end

  return rc
end

local function SpellsForMob(unitId)
  local where = GhostRecon:WhereAmI()
  local whereInfo = GhostReconDB.Instances[where] or {}
  local mobInfo = whereInfo[UnitName(unitId)] or {}
  local t = {}

  if mobInfo.spells then
    -- 使用局部变量缓存常用值
    local scale = GhostReconDB.Settings.Scale or 1
    local size = scale * 32

    for spellId, _ in pairs(mobInfo.spells) do
      local spellInfo = C_Spell.GetSpellInfo(spellId)
      if spellInfo and spellInfo.name then
        table.insert(t, {
          spellId = spellId,
          name = spellInfo.name,
          -- 缓存iconID避免重复查询
          iconID = spellInfo.iconID,
          -- 可以添加其他需要的字段
          spellInfo = spellInfo, -- 或者直接缓存整个表
        })
      end
    end

    -- Lua的字符串比较已足够健壮,直接比较name字段，Lua的字符串比较会自动处理nil情况
    table.sort(t, function(a, b)
      return a.name < b.name
    end)
  end

  return t
end

local function UpdateSpellBar(spells)
  masterSpellFrame:SetSpells(spells)

  if GhostReconDB.Settings.AbilitiesBarEnabled then
    masterSpellFrame:Show()
    masterSpellFrame:SetAlpha(masterSpellFrame.preferredAlpha or GhostReconDB.Settings.OutOfCombatAlpha or 1)
  end
end

function GhostRecon:RefreshSpells(unitId)
  local spells = SpellsForMob(unitId)

  UpdateSpellBar(spells)

  -- stop existing effects
  masterSpellFrame:StopCooldowns()

  -- now, reset all the cooldowns in progress for the mob the bar is showing
  local spellInfo = mobsInCombat[masterSpellFrame.mobGuid]

  if spellInfo then
    for i, v in pairs(spellInfo) do
      if v.radarType == "COOLDOWN" then
        masterSpellFrame:SetCooldown(v.spellId, v.startTime, v.duration, 1)
      end
    end
  end
end

local function BarUnitChanged()
  if UnitExists(GhostReconDB.Settings.BarUnit) and not UnitIsFriend("player", GhostReconDB.Settings.BarUnit) and not UnitPlayerControlled(GhostReconDB.Settings.BarUnit) then
    masterSpellFrame.mobGuid = UnitGUID(GhostReconDB.Settings.BarUnit)
    masterSpellFrame.mobName = UnitName(GhostReconDB.Settings.BarUnit)
    GhostRecon:RefreshSpells(GhostReconDB.Settings.BarUnit)

    if masterSpellFrame.spellCount == 0 then
      GhostRecon:SendQuery(masterSpellFrame.mobGuid, masterSpellFrame.mobName, GhostRecon:WhereAmI())
    end
  else
    if masterSpellFrame then
      masterSpellFrame:Hide()
      masterSpellFrame.mobGuid = nil
    end
  end
end

local function OnEvent(frame, event, whoChangedTargets)
  if event == "PLAYER_TARGET_CHANGED" and GhostReconDB.Settings.BarUnit == "target" then
    BarUnitChanged()
  elseif event == "PLAYER_FOCUS_CHANGED" and GhostReconDB.Settings.BarUnit == "focus" then
    BarUnitChanged()
  elseif event == "UNIT_TARGET" then
    if string.len(GhostReconDB.Settings.BarUnit) > string.len(whoChangedTargets) then
      if string.sub(GhostReconDB.Settings.BarUnit, 1, string.len(whoChangedTargets)) == whoChangedTargets then
        BarUnitChanged()
      end
    end
  end

  if event == "ADDON_LOADED" then
    local whichAddon = whoChangedTargets

    if whichAddon == "GhostRecon" then
      GhostReconDB.Settings = GhostReconDB.Settings or {}
      GhostReconDB.Settings.BarUnit = GhostReconDB.Settings.BarUnit or "target"

      if not masterSpellFrame then
        masterSpellFrame = CreateSpellBar()
        GhostRecon.abilityBar = masterSpellFrame
        GhostRecon:RefreshBar()
      end
    end
  end

  if event == "PLAYER_REGEN_ENABLED" then
    -- went out of combat
    if masterSpellFrame:IsVisible() then
      UIFrameFadeIn(masterSpellFrame, 1, masterSpellFrame:GetAlpha(), GhostReconDB.Settings.OutOfCombatAlpha or 1)
    end

    masterSpellFrame.preferredAlpha = GhostReconDB.Settings.OutOfCombatAlpha
    masterSpellFrame:StopCooldowns()
    mobsInCombat = {}
    inCombat = false
  elseif event == "PLAYER_REGEN_DISABLED" then
    -- went into combat
    if masterSpellFrame:IsVisible() then
      UIFrameFadeIn(masterSpellFrame, 1, masterSpellFrame:GetAlpha(), GhostReconDB.Settings.InCombatAlpha or 1)
    end

    masterSpellFrame.preferredAlpha = GhostReconDB.Settings.InCombatAlpha
    inCombat = true
  end
end

local function OnUpdate(frame, elapsed)
  if inCombat then
    local curTime = GetTime()

    if nextRefreshTime == nil or curTime >= nextRefreshTime then
      local curGuid = UnitExists(GhostReconDB.Settings.BarUnit) and UnitGUID(GhostReconDB.Settings.BarUnit)

      if masterSpellFrame.mobGuid ~= curGuid then
        BarUnitChanged()
        nextRefreshTime = curTime + 0.5
      end
    end
  end
end

local frm = CreateFrame("Frame")
frm:RegisterEvent("UNIT_TARGET")
frm:RegisterEvent("PLAYER_TARGET_CHANGED")
frm:RegisterEvent("PLAYER_FOCUS_CHANGED")
frm:RegisterEvent("PLAYER_REGEN_ENABLED")
frm:RegisterEvent("PLAYER_REGEN_DISABLED")
frm:RegisterEvent("ADDON_LOADED")
frm:SetScript("OnEvent", OnEvent)
frm:SetScript("OnUpdate", OnUpdate)

function GhostRecon:RefreshBar()
  masterSpellFrame:SetPoint(
    GhostReconDB.Settings.Anchor or "CENTER",
    UIParent,
    GhostReconDB.Settings.RelativeAnchor or "CENTER",
    GhostReconDB.Settings.X or 0,
    GhostReconDB.Settings.Y or 0
  )
  masterSpellFrame:LayoutSpells()
end
