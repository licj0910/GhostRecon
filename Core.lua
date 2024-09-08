local ADDON_NAME, namespace = ...
local L = namespace.L

-- master table/object
GhostRecon = { }

-- master database
GhostReconDB = {
	["Instances"] = {
	},

	["Settings"] = {
		["Active"] = true,
		["TooltipEnabled"] = true,
		["AbilitiesBarEnabled"] = true,
		["BarUnit"] = "target",

		["TooltipSpellsEnabled"] = true,
		["TooltipIconsEnabled"] = true,

		["Scale"] = 1.25,
		["Columns"] = 12,
		["RelativeAnchor"] = "TOP",
		["Anchor"] = "TOP",
		["Y"] = -40,
		["X"] = 0,

		["OutOfCombatAlpha"] = 1,
		["InCombatAlpha"] = 1,
		["GuildSync"] = false,
		["InstancesOnly"] = false,
		["ShowMessages"] = true,
	}
}

local raidIconTexts = {
	"{star}",
	"{circle}",
	"{diamond}",
	"{triangle}",
	"{moon}",
	"{square}",
	"{cross}",
	"{skull}",
}

local function GetSpellInfo(spellID)
	if not spellID then
		return nil;
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID);
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
	end
end

GhostRecon.IgnoredAbilities = {
	[1604] = true,    --眩晕
	[181089] = true,  --Encounter Event，转场景
	[384289] = true,  --Taxi 搭乘
}

local versionSent
local requestedList

-- LDB support
local ldb = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)

if ldb then
	local dataObj = ldb:NewDataObject("GhostRecon", {
		type = "launcher",
		icon = "Interface\\AddOns\\GhostRecon\\Recon.tga",
		label = "Ghost: Recon",
		OnClick = function(frame, button)
			if button == "RightButton" then
				Settings.OpenToCategory(GhostRecon.optionsFrame)
			else
				if IsAltKeyDown() or IsShiftKeyDown() then
					GhostRecon:ReportCurrentAbilities()
				else
					Settings.OpenToCategory(GhostRecon.browser)
				end
			end
		end,
	})

	function dataObj:OnTooltipShow()
		GameTooltip:AddLine("Ghost: Recon")
		GameTooltip:AddLine(L["Left-click to search."])
		GameTooltip:AddLine(L["Right-click to configure."])
		GameTooltip:AddLine(L["Alt- or Shift-click to report current target's abilities."])
	end

end

-- functions
function GhostRecon:InInstance()
	local rc
	local isIn, instType = IsInInstance()

	if isIn then
		if instType == "party" or instType == "raid" then
			rc = true
		end
	end

	return rc
end

function GhostRecon:GetUnitIDForGUID(guid)
	local rc = nil
	local units = { "target", "focus", "mouseover" }

	for _, v in pairs(units) do
		if UnitExists(v) then
			if UnitGUID(v) == guid then
				rc = v
				break
			end
		end
	end

	if not rc then
		local prefix = nil
		local limit = nil
		if GetNumGroupMembers() > 5 then
			prefix = "raid"
			limit = 40
		elseif GetNumGroupMembers() <= 5 then
			prefix = "party"
			limit = 5
		elseif GetNumGroupMembers() == 0 then
			prefix = nil
			limit = nil

		end

		if prefix then
			for i = 1, limit do
				local curUnitId = prefix..i

				if UnitExists(curUnitId) and UnitGUID(curUnitId) == guid then
					rc = curUnitId
					break

				else
					curUnitId = curUnitId.."target"

					if UnitExists(curUnitId) and UnitGUID(curUnitId) == guid then
						rc = curUnitId
						break
					end
				end
			end
		end
	end

	return rc
end

function GhostRecon:WhereAmI()
	local name = GetRealZoneText()
	local isIn, instType = IsInInstance()

	if isIn then
		local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
		--https://warcraft.wiki.gg/wiki/DifficultyID 数据表中无10、13、21、22、26、27、28、31
		if difficultyID==2 then name = "Heroic "..name		--英雄5人本
		elseif difficultyID==3 then name = name.."(10)"		--10 Player普通10人团本
		elseif difficultyID==4 then name = name.."(25)"		--25 Player普通25人团本
		elseif difficultyID==5 then name = name.."(10H)"	--10 Player (Heroic)英雄10人团本
		elseif difficultyID==6 then name = name.."(25H)"	--25 Player (Heroic)英雄25人团本
		elseif difficultyID==7 then name = name.."(LFRlegacy)"	--随机团本Legacy LFRs prior to SoO
		elseif difficultyID==8 then name = name.."(Challenge)"	--Mythic Keystone史诗钥石
		elseif difficultyID==9 then name = name.."(40)"		--40 Player 40人团本
		elseif difficultyID==11 then name = name.."(HSC)"	--Heroic Scenario英雄场景战役
		elseif difficultyID==12 then name = name.."(SC)"	--Normal Scenario普通场景战役
		elseif difficultyID==14 then name = name.."(Raid)"	--Normal Raid普通团本
		elseif difficultyID==15 then name = name.."(HRaid)"	--Heroic Raid英雄团本
		elseif difficultyID==16 then name = name.."(MRaid)"	--Mythic Raid史诗团本
		elseif difficultyID==17 then name = name.."(LFR)"	--Looking For Raid随机团本
		elseif difficultyID==23 then name = name.."(M5P)"	--Mythic party史诗5人本
		elseif difficultyID==24 then name = name.."(TW)"	--Timewalking party时光5人本
		elseif difficultyID==33 then name = name.."(TW)"	--Timewalking raid时光团本
		end
	end
	return name
end

function GhostRecon:UnitAffectedByImmunityDebuff(unitId)
	local rc = false

	for i = 1, 40 do
		local name = C_UnitAuras.GetAuraDataByIndex(unitId, i, "HARMFUL")

		if name == "Banish" or name == "Cyclone" then
			rc = true
			break
		end
	end

	return rc
end

local function GuidIsNPC(guid)
	local rc

	if guid ~= nil then
		local ch = string.sub(guid, 5, 5)

		if ch == "3" then
			rc = true
		end
	end

	return rc
end

local function OnEvent(this, event, timeStamp, combatEvent, hideCaster, sourceGuid, sourceName, sourceFlags, sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, missType, ...)

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
	  local timeStamp, combatEvent, hideCaster, sourceGuid, sourceName, sourceFlags, sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, missType = CombatLogGetCurrentEventInfo()
		if not GhostRecon.IgnoredAbilities[spellId] then
			local where = GhostRecon:WhereAmI()
			local inInst = GhostRecon:InInstance()
			if where ~= nil and where ~= "" and spellId ~= nil then
				local link = C_Spell.GetSpellLink(spellId)
				if not link then
					link = "Unknown spells for id=" .. spellId
				end

				GhostReconDB.Instances[where] = GhostReconDB.Instances[where] or { }

				if inInst then
					GhostReconDB.Instances[where].isInstance = inInst
				else
					GhostReconDB.Instances[where].isInstance = nil
				end

				if combatEvent == "SPELL_INTERRUPT" then
					if GhostReconDB.Settings.Active then
						if GhostRecon.abilityBar.mobGuid == destGuid then
							GhostRecon.abilityBar:StopSpell(destGuid, sourceName, missType)
						end
					end
				end

		if combatEvent == "SPELL_CAST_START" or combatEvent == "SPELL_CAST_SUCCESS" then
		  if GhostReconDB.Settings.Active then
			  if GhostRecon.abilityBar.mobGuid == sourceGuid then
				  local _, _, _,castTime = GetSpellInfo(spellId)
				  if not castTime then
					  castTime = 0
				  end
				  GhostRecon.abilityBar:SawSpell(sourceGuid, sourceName, spellId, GetTime(), castTime / 1000)
			  end
		  end
		end

				if combatEvent == "SPELL_HEAL" then
					if GhostReconDB.Settings.Active and (inInst or not GhostReconDB.Settings.InstancesOnly) then
						if GuidIsNPC(sourceGuid) and GuidIsNPC(destGuid) then
							GhostReconDB.SpellInfo = GhostReconDB.SpellInfo or { }
							GhostReconDB.SpellInfo[spellId] = GhostReconDB.SpellInfo[spellId] or { }

							if GhostReconDB.SpellInfo[spellId].healType == nil then
								if sourceGuid == destGuid then
									GhostReconDB.SpellInfo[spellId].healType = GhostRecon.CONST_HEAL_SELF
									GhostRecon:TellUser(string.format(L["Saw heal: %s healed themselves with %s."], sourceName, link), 0.3, 1, 0.3)
								else
									GhostReconDB.SpellInfo[spellId].healType = GhostRecon.CONST_HEAL_OTHERS
									GhostRecon:TellUser(string.format(L["Saw heal: %s healed another mob with %s."], sourceName, link), 0.3, 1, 0.3)
								end

								GhostRecon:SendHealInfoNotification(spellId, spellName, where, GhostRecon.CONST_HEAL_SELF)

							elseif GhostReconDB.SpellInfo[spellId].healType == GhostRecon.CONST_HEAL_SELF then
								if sourceGuid ~= destGuid then
									GhostReconDB.SpellInfo[spellId].healType = GhostRecon.CONST_HEAL_OTHERS
									GhostRecon:TellUser(string.format(L["Saw heal: %s healed another mob with %s."], sourceName, link), 0.3, 1, 0.3)
								end

								GhostRecon:SendHealInfoNotification(spellId, spellName, where, GhostRecon.CONST_HEAL_OTHERS)
							end
						end
					end
				end

				if combatEvent == "SPELL_DISPEL" then
					if GhostReconDB.Settings.Active and (inInst or not GhostReconDB.Settings.InstancesOnly) then
						local dispelledSpellId = missType

						if UnitIsFriend(destName, "player") then
							local extraLink = C_Spell.GetSpellLink(dispelledSpellId)
							local extraName = GetSpellInfo(dispelledSpellId)

							if extraLink then
								GhostReconDB.SpellInfo = GhostReconDB.SpellInfo or { }
								GhostReconDB.SpellInfo[dispelledSpellId] = GhostReconDB.SpellInfo[dispelledSpellId] or { }

								if not GhostReconDB.SpellInfo[dispelledSpellId].removable then
									GhostRecon:TellUser(string.format(L["Saw dispel: %s is removable."], extraLink), 0.3, 1, 0.3)
								end

								GhostReconDB.SpellInfo[dispelledSpellId].removable = true
								GhostRecon:SendSpellInfoNotification(dispelledSpellId, extraName, where, true)
							end
						end
					end
				end

				if combatEvent == "SPELL_AURA_APPLIED" then
					if GuidIsNPC(destGuid) then
						if GhostReconDB.Settings.Active and (inInst or not GhostReconDB.Settings.InstancesOnly) then
							if GhostRecon:AddControl(where, destGuid, destName, spellId, true) then
								GhostRecon:TellUser(string.format(L["Saw control: %s is affected by %s."], destName, link), 0.3, 1, 0.3)
							end
						end

						GhostRecon:SendNotification("CONTROL", destGuid, destName, spellId, spellName, where, true, inInst)
					end
				end

				if combatEvent == "SPELL_AURA_APPLIED" or combatEvent == "SPELL_CAST_START" or combatEvent == "SPELL_CAST_SUCCESS" then
					local unitId = GhostRecon:GetUnitIDForGUID(sourceGuid)

					if unitId and UnitExists(unitId) and not UnitIsFriend("player", unitId) and not UnitPlayerControlled(unitId) then
						if GhostReconDB.Settings.Active and (inInst or not GhostReconDB.Settings.InstancesOnly) then
							if GhostRecon:AddAbility(where, sourceGuid, sourceName, spellId) then
								if UnitExists("target") and UnitGUID("target") == sourceGuid then
									GhostRecon:RefreshSpells("target")
								end

								GhostRecon:TellUser(string.format(L["Saw spell/ability: %s has a spell/ability called %s."], sourceName, link), 0.3, 1, 0.3)
							end
						end

						GhostRecon:SendNotification("ABILITY", sourceGuid, sourceName, spellId, spellName, where, true, inInst)
					end

				elseif combatEvent == "SPELL_MISSED" and missType == "IMMUNE" then
					if destName then
						local unitId = GhostRecon:GetUnitIDForGUID(destGuid)

						if unitId and UnitExists(unitId) and not UnitIsFriend("player", unitId) and not UnitPlayerControlled(unitId) then
							if not GhostRecon:UnitAffectedByImmunityDebuff(unitId) then
								if GhostReconDB.Settings.Active and (inInst or not GhostReconDB.Settings.InstancesOnly) then
									if GhostRecon:AddControl(where, destGuid, destName, spellId, false) then
										GhostRecon:TellUser(string.format(L["Saw control: %s is not affected by %s."], destName, link), 1, 0.3, 0.3)
									end
								end

								GhostRecon:SendNotification("CONTROL", destGuid, destName, spellId, spellName, where, false, inInst)
							end
						end
					end
				end
			end
		end
	end

	if event == "UPDATE_MOUSEOVER_UNIT" then
		if not UnitIsFriend("player", "mouseover") and not UnitIsPlayer("mouseover") and not UnitPlayerControlled("mouseover") then
			GhostRecon:DecorateTooltip(UnitGUID("mouseover"), UnitName("mouseover"), GhostReconDB.Settings.TooltipSpellsEnabled)
		end
	end

	if event == "ADDON_LOADED" then
		local whichAddon = timeStamp

		if whichAddon == "GhostRecon" then
			GhostReconDB.Settings = GhostReconDB.Settings or { }

			-- remove cooldown data because it's useless
			if GhostReconDB.Settings.SpellBlacklist ~= nil then
				for curZone, info in pairs(GhostReconDB.Instances) do
					for curMob, data in pairs(info) do
						if curMob ~= "isInstance" then
							data.cooldowns = nil
						end
					end
				end

				GhostReconDB.Settings.SpellBlacklist = nil
			end

			if GhostReconDB.Settings.Active == nil then
				GhostReconDB.Settings.Active = true
			end

			if GhostReconDB.Settings.GuildSync == nil then
				GhostReconDB.Settings.GuildSync = true
			end

			if GhostReconDB.Settings.TooltipSpellsEnabled == nil then
				GhostReconDB.Settings.TooltipSpellsEnabled = true
			end

			if GhostReconDB.Settings.TooltipIconsEnabled == nil then
				GhostReconDB.Settings.TooltipIconsEnabled = true
			end

			-- check for Prat/Chatter and install our
			-- /gr slash command if it's not installed
			local chatEnabled = select(4, C_AddOns.GetAddOnInfo("Prat-3.0")) or select(4, C_AddOns.GetAddOnInfo("Chatter"))

			if not chatEnabled then
				SLASH_GHOSTRECON4 = "/recon"
				SLASH_GHOSTRECON5 = "/gr"
			end

			if not versionSent then
				GhostRecon:SendVersion()
				versionSent = true
			end
		end
	end

	if event == "GUILD_ROSTER_UPDATE" then
		if requestedList then
			local i

			-- prune out pople no longer on-line
			local online = { }

			for i = 1, GetNumGuildMembers() do
				local cur = GetGuildRosterInfo(i)

				if cur then
					online[cur] = true
				end
			end

			-- display the list
			local verString
			local c = 0

			GhostRecon:TellUser(L["Ghost: Recon users in guild currently on-line..."], true)

			for i, verString in pairs(GhostRecon.knownUsers) do
				if online[i] then
					if verString == true then
						verString = "* unknown *"
					end

					GhostRecon:TellUser("    "..i.." - "..verString, true)
					c = c + 1
				end
			end

			if c == 0 then
				GhostRecon:TellUser("*** No-one ***", true)
			end

			requestedList = false
		end
	end
end

function GhostRecon:ReportCurrentAbilities(who)
	if self.abilityBar.mobGuid then
		if self.abilityBar.spellCount > 0 then
			local i
			local name = self.abilityBar.mobName
			local msg = ""
			local curCount = 0

			if GetRaidTargetIndex(GhostReconDB.Settings.BarUnit) then
				name = name.." ("..raidIconTexts[GetRaidTargetIndex(GhostReconDB.Settings.BarUnit)]..")"
			end

			self:Announce(string.format(L["Ghost: Recon - Spells and Abilities of '%s'..."], name), who)

			for i = 1, self.abilityBar.spellCount do
				curCount = curCount + 1

				if curCount > 5 then
					curCount = 1
					GhostRecon:Announce("- "..msg, who)
					msg = ""
				end

				if curCount > 1 then
					msg = msg..", "
				end

				msg = msg..self.abilityBar.spellFrames[i].hyperlink
			end

			if string.len(msg) > 0 then
				GhostRecon:Announce("- "..msg, who)
			end

			-- notes
			local notes = self:GetNotes(self:WhereAmI(), self.abilityBar.mobGuid, self.abilityBar.mobName)

			if notes ~= nil and string.len(notes) > 0 then
				self:Announce("Notes: "..notes, who)
			end
		end
	end
end

function GhostRecon:Announce(msg, who)
	local whichChan

	if who then
		whichChan = "WHISPER"
	else
		if GetNumGroupMembers() > 5 then
			whichChan = "RAID"

		elseif GetNumGroupMembers() > 0 then
			whichChan = "PARTY"

		end
	end

	if whichChan then
		SendChatMessage(msg, whichChan, nil, who)
	else
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end

local function Split(line)
	local first
	local second
	local posn = string.find(line," ")

	if posn ~= nil and posn > 0 then
		first = string.sub(line, 1, posn-1)
		second = string.sub(line, posn+1, string.len(line))
	else
		first = line
		second = nil
	end

	return first, second
end

local commandDispatch = {
	["on"] = function()
		GhostReconDB.Settings.Active = true
		GhostRecon:TellUser(L["Recording is switched on."], true)
	end,

	["off"] = function()
		GhostReconDB.Settings.Active = false
		GhostRecon:TellUser(L["Recording is switched off."], true)
	end,

	["report"] = function(who)
		GhostRecon:ReportCurrentAbilities(who)
	end,

	["who"] = function()
		if IsInGuild() then
			requestedList = true
			GhostRecon:RequestVersion()
			C_GuildInfo.GuildRoster()
		end
	end,

	["search"] = function()
		Settings.OpenToCategory(GhostRecon.browser)
	end,
}

local function CommandHandler(commandLine)
	if commandLine == nil or commandLine == "" then
		Settings.OpenToCategory(GhostRecon.optionsFrame)
	else
		local cmd, params = Split(commandLine)
		local func = commandDispatch[cmd]

		if func then
			func(params)
		else
			Settings.OpenToCategory(GhostRecon.optionsFrame)
		end
	end
end

local function CommandHandler2(commandLine)
	Settings.OpenToCategory(GhostRecon.browser)
end

local frm = CreateFrame("Frame")
frm:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frm:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frm:RegisterEvent("GUILD_ROSTER_UPDATE")
frm:RegisterEvent("ADDON_LOADED")
frm:SetScript("OnEvent", OnEvent)
frm:Show()

SlashCmdList["GHOSTRECON"] = CommandHandler
SLASH_GHOSTRECON1 = "/recon"
SLASH_GHOSTRECON2 = "/ghostrecon"
SLASH_GHOSTRECON3 = "/gr"
SLASH_GHOSTRECON6 = "/ghost"


SlashCmdList["GHOSTRECONSEARCH"] = CommandHandler2
SLASH_GHOSTRECONSEARCH1 = "/grs"
SLASH_GHOSTRECONSEARCH2 = "/reconsearch"
SLASH_GHOSTRECONSEARCH3 = "/ghostreconsearch"

SlashCmdList["GHOSTRECONRELOADER"] = function()
	ReloadUI()
end
SLASH_GHOSTRECONRELOADER1 = "/rl"
