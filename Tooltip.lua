local ADDON_NAME, namespace = ...
local L = namespace.L

-- enums
GhostRecon.CC_UNKNOWN = 0
GhostRecon.CC_NO = 1
GhostRecon.CC_YES = 2
GhostRecon.CC_SOMETIMES = 3

GhostRecon.CONST_HEAL_SELF = 1
GhostRecon.CONST_HEAL_OTHERS = 2

local CCTYPE_SHEEP = "sheep"  --羊
local CCTYPE_SLEEP = "sleep"  --睡眠
local CCTYPE_SAP = "sap"      --闷棍
local CCTYPE_BLIND = "blind"  --致盲
local CCTYPE_KIDNEYSHOT = "kidney"  --肾击
local CCTYPE_GOUGE = "gouge"  --凿击
local CCTYPE_BANISH = "banish" --放逐
local CCTYPE_ENSLAVE = "enslave" --奴役
local CCTYPE_FEAR = "fear"  --恐惧
local CCTYPE_DEATHCOIL = "dc" --死缠
local CCTYPE_TRAP = "trap" --陷阱
local CCTYPE_HEX = "hex" --妖术
local CCTYPE_SHACKLE = "shackle"  --束缚
local CCTYPE_MINDCONTROL = "MC" --恐惧
local CCTYPE_TURNEVIL = "turnevil"  --超度
local CCTYPE_CYCLONE = "cyclone"  --旋风
local CCTYPE_ROOTS = "roots" --根击
local CCTYPE_SCAREBEAST = "scare"  --恐吓野兽
local CCTYPE_DEATHGRIP = "grip"  --死握
local CCTYPE_SLOW = "slow"  --减速
local CCTYPE_INFWOUNDS = "infwounds"
local CCTYPE_TONGUES = "tongues"  --语言诅咒
local CCTYPE_EXHAUSTION = "exhaust"  --疲劳
local CCTYPE_GROWL = "growl"  --低吼
local CCTYPE_TAUNT = "taunt"  --嘲讽
local CCTYPE_RD = "rd"  -- 清算
local CCTYPE_MAIM = "maim"  --德 重伤
local CCTYPE_BASH = "bash"  --德 蛮力猛击
local CCTYPE_DARKCMD = "darkcmd" --黑暗命令
local CCTYPE_REPENTANCE = "repent" --忏悔
local CCTYPE_PSYCHIC_SCREAM = "scream" --牧 尖啸
local CCTYPE_PSYCHIC_HORROR = "horror" --牧 惊骇
local CCTYPE_HOJ = "hoj"  --制裁
local CCTYPE_HOLYWRATH = "holywrath" --神圣愤怒
local CCTYPE_IMMOBILITY = "immobility" --定身
local CCTYPE_COMA = "coma" --昏迷
local CCTYPE_PARALYSIS = "paralysis" --瘫痪
local CCTYPE_INTERRUPT = "interrupt" --断法禁法
local CCTYPE_REPEL = "repel" --击飞击退激怒群拉

local function GetSpellInfo(spellID)
	if not spellID then
		return nil
	end

	local spellInfo = C_Spell.GetSpellInfo(spellID)
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
	end
end

local enumNames = {
	[GhostRecon.CC_UNKNOWN] = "Unknown",
	[GhostRecon.CC_NO] = "No",
	[GhostRecon.CC_YES] = "Yes",
	[GhostRecon.CC_SOMETIMES] = "Sometimes"
}

GhostRecon.ccCreatures = {
	[CCTYPE_SHEEP] = { ["Beast"] = true, ["Humanoid"] = true, ["Critter"] = true },
	[CCTYPE_SLEEP] = { ["Beast"] = true, ["Dragonkin"] = true },
	[CCTYPE_SAP] = { ["Beast"] = true, ["Dragonkin"] = true, ["Humanoid"] = true, ["Demon"] = true },
	[CCTYPE_BANISH] = { ["Elemental"] = true, ["Demon"] = true, ["Aberration"] = true },
	[CCTYPE_ENSLAVE] = { ["Demon"] = true },
	[CCTYPE_HEX] = { ["Beast"] = true, ["Humanoid"] = true },
	[CCTYPE_SHACKLE] = { ["Undead"] = true },
	[CCTYPE_MINDCONTROL] = { ["Humanoid"] = true },
	[CCTYPE_TURNEVIL] = { ["Demon"] = true, ["Undead"] = true, ["Aberration"] = true  },
	[CCTYPE_SCAREBEAST] = { ["Beast"] = true },
	[CCTYPE_REPENTANCE] = { ["Demon"] = true, ["Dragonkin"] = true, ["Giant"] = true, ["Humanoid"] = true, ["Undead"] = true },
	[CCTYPE_HOLYWRATH] = { ["Demon"] = true, ["Undead"] = true, ["Dragonkin"] = true, ["Elemental"] = true }
}

local ccClasses = {
	["DEATHKNIGHT"] = { [CCTYPE_DEATHGRIP] = true, [CCTYPE_DARKCMD] = true, [CCTYPE_SLOW] = true,  [CCTYPE_SHACKLE] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_COMA] = true, [CCTYPE_REPEL] = true },
	["DEMONHUNTER"] = {[CCTYPE_TAUNT] = true, [CCTYPE_SLOW] = true, [CCTYPE_FEAR] = true, [CCTYPE_COMA] = true, [CCTYPE_PARALYSIS] = true, [CCTYPE_INTERRUPT] = true },
	["DRUID"] = { [CCTYPE_SLEEP] = true, [CCTYPE_CYCLONE] = true, [CCTYPE_ROOTS] = true, [CCTYPE_INFWOUNDS] = true, [CCTYPE_GROWL] = true, [CCTYPE_MAIM] = true, [CCTYPE_BASH] = true, [CCTYPE_SLOW] = true,[CCTYPE_IMMOBILITY] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_PARALYSIS] = true },
	["HUNTER"] = { [CCTYPE_TRAP] = true, [CCTYPE_SCAREBEAST] = true, [CCTYPE_ROOTS] = true, [CCTYPE_SLEEP] = true, [CCTYPE_TAUNT] = true, [CCTYPE_SLOW] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_REPEL] = true },
	["MAGE"] = { [CCTYPE_SHEEP] = true, [CCTYPE_SLOW] = true, [CCTYPE_IMMOBILITY] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_REPEL] = true, [CCTYPE_PARALYSIS] = true },
	["MONK"] = {[CCTYPE_TAUNT] = true, [CCTYPE_SLOW] = true, [CCTYPE_IMMOBILITY] = true, [CCTYPE_PARALYSIS] = true, [CCTYPE_COMA] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_REPEL] = true },
	["PALADIN"] = { [CCTYPE_TURNEVIL] = true, [CCTYPE_REPENTANCE] = true, [CCTYPE_RD] = true, [CCTYPE_HOLYWRATH] = true, [CCTYPE_HOJ] = true, [CCTYPE_TAUNT] = true, [CCTYPE_INTERRUPT] = true },
	["PRIEST"] = { [CCTYPE_SHACKLE] = true, [CCTYPE_MINDCONTROL] = true, [CCTYPE_PSYCHIC_SCREAM] = true, [CCTYPE_PSYCHIC_HORROR] = true, [CCTYPE_PARALYSIS] = true },
	["ROGUE"] = { [CCTYPE_SAP] = true, [CCTYPE_GOUGE] = true, [CCTYPE_BLIND] = true, [CCTYPE_KIDNEYSHOT] = true, [CCTYPE_SLOW] = true, [CCTYPE_INTERRUPT] = true },
	["SHAMAN"] = { [CCTYPE_HEX] = true, [CCTYPE_BANISH] = true, [CCTYPE_SLOW] = true, [CCTYPE_COMA] = true, [CCTYPE_INTERRUPT] = true },
	["WARLOCK"] = { [CCTYPE_BANISH] = true, [CCTYPE_ENSLAVE] = true, [CCTYPE_FEAR] = true, [CCTYPE_TONGUES] = true, [CCTYPE_EXHAUSTION] = true, [CCTYPE_DEATHCOIL] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_COMA] = true },
	["WARRIOR"] = { [CCTYPE_TAUNT] = true, [CCTYPE_FEAR] = true, [CCTYPE_SLOW] = true, [CCTYPE_IMMOBILITY] = true, [CCTYPE_COMA] = true, [CCTYPE_INTERRUPT] = true },
	["EVOKER"] = { [CCTYPE_SLOW] = true, [CCTYPE_COMA] = true, [CCTYPE_INTERRUPT] = true, [CCTYPE_REPEL] = true }
}

GhostRecon.ccList = {
	[CCTYPE_SHEEP] = { [118] = true, [61305] = true, [28272] = true, [61721] = true, [61780] = true, [28271] = true, [161354] = true, [126819] = true, [277787] = true, [383121] = true},  --法师羊
	[CCTYPE_SLOW] = { [31589] = true, [116095] = true, [391102] = true, [116] = true, [44614] = true, [84714] = true, [190356] = true, [195645] = true, [390231] = true, [187698] = true, [5116] = true, [109248] = true, [393344] = true, [277953] = true, [120] = true, [196840] = true, [2484] = true, [320635] = true, [202138] = true, [370897] = true, [121253] = true, [45524] = true, [389679] = true, [273952] = true, [102793] = true, [345208] = true, [1715] = true, [6343] = true, [12323] = true },  --减速
	[CCTYPE_SLEEP] = { [2637] = true, [19386] = true },  --睡眠
	[CCTYPE_CYCLONE] = { [33786] = true },  --旋风
	[CCTYPE_ROOTS] = { [339] = true, [50245] = true },
	[CCTYPE_SAP] = { [6770] = true },  --闷棍
	[CCTYPE_KIDNEYSHOT] = { [408] = true, [1833] = true},  --肾击、偷袭
	[CCTYPE_BLIND] = { [2094] = true },  --致盲
	[CCTYPE_GOUGE] = { [1776] = true },  --凿击
	[CCTYPE_BANISH] = { [710] = true }, --放逐
	[CCTYPE_ENSLAVE] = { [1098] = true },  --征服恶魔 奴役
	[CCTYPE_FEAR] = { [5782] = true, [5484] = true, [5246] = true, [207684] = true }, --恐惧
	[CCTYPE_DEATHCOIL] = { [6789] = true },  --死亡缠绕
	[CCTYPE_TRAP] = { [3355] = true, [187650] = true, [162488] = true, [213691] = true, [19577] = true }, --陷阱驱散胁迫，高爆放击飞
	[CCTYPE_HEX] = { [51514] = true, [269352] = true },   --妖术
	[CCTYPE_SHACKLE] = { [9484] = true,[111673] = true },  --牧 束缚亡灵，死骑控制亡灵
	[CCTYPE_MINDCONTROL] = { [605] = true, [205364] = true },  --牧 精神控制、统御意志
	[CCTYPE_TURNEVIL] = { [10326] = true },  --QS超度邪恶
	[CCTYPE_DEATHGRIP] = { [49575] = true, [49576] = true },  --死骑 死亡之握
	[CCTYPE_DARKCMD] = { [56222] = true },  --死骑  黑暗命令
	[CCTYPE_SCAREBEAST] = { [1513] = true }, --恐惧野兽
	[CCTYPE_INFWOUNDS] = { [48484] = true },  --德鲁伊 感染伤口
	[CCTYPE_TONGUES] = { [1714] = true },  --语言诅咒
	[CCTYPE_EXHAUSTION] = { [334275] = true, [702] = true },  --疲劳、虚弱诅咒
	[CCTYPE_GROWL] = { [6795] = true },  --德 低吼
	[CCTYPE_TAUNT] = { [355] = true, [115546] = true, [115315] = true, [1161] = true, [386071] = true, [185245] = true },  --嘲讽、嚎震八方、召唤玄牛雕像、挑战怒吼、瓦解怒吼、折磨
	[CCTYPE_RD] = { [62124] = true },  --圣骑士 清算之手
	[CCTYPE_MAIM] = { [22570] = true }, --德 割碎
	[CCTYPE_BASH] = { [5211] = true },  --德 蛮力猛击
	[CCTYPE_REPENTANCE] = { [20066] = true }, --QS忏悔
	[CCTYPE_PSYCHIC_HORROR] = { [64044] = true }, --牧 惊骇
	[CCTYPE_PSYCHIC_SCREAM] = { [8122] = true }, --牧 尖啸
	[CCTYPE_HOLYWRATH] = { [2812] = true },  --QS 谴责
	[CCTYPE_HOJ] = { [853] = true, [115750] = true },  --QS 制裁、盲光
	[CCTYPE_IMMOBILITY] = { [122] = true, [157997] = true, [386763] = true, [339] = true, [102359] = true, [100] = true, [358385] = true, [324312] = true },  --定身
	[CCTYPE_COMA] = { [119381] = true, [30283] = true, [192058] = true, [207167] = true, [221562] = true, [107570] = true, [46968] = true, [179057] = true, [360806] = true },  --昏迷
	[CCTYPE_PARALYSIS] = { [115078] = true, [88625] = true, [99] = true, [217832] = true, [113724] = true },  --瘫痪
	[CCTYPE_INTERRUPT] = { [116705] = true, [2139] = true, [31661] = true, [147362] = true, [392060] = true, [96231] = true, [31935] = true, [1766] = true, [119910] = true, [57944] = true, [47528] = true, [106839] = true, [132469] = true, [6552] = true, [183752] = true, [202137] = true, [351338] = true } , --断法禁法  C_Spell.GetSpellInfo(57944) Increased Damage 3
	[CCTYPE_REPEL] = { [328670] = true, [236776] = true, [368970] = true, [357214] = true, [108199] = true, [383269] = true, [157981] = true },  --击飞击退激怒群拉
}

local taunts = {  --嘲讽
	[CCTYPE_TAUNT] = true,
	[CCTYPE_GROWL] = true,
	[CCTYPE_DARKCMD] = true,
	[CCTYPE_DEATHGRIP] = true,
	[CCTYPE_RD] = true
}

local stuns = {  --昏迷,眩晕
	[CCTYPE_KIDNEYSHOT] = true,
	[CCTYPE_GOUGE] = true,
	[CCTYPE_MAIM] = true,
	[CCTYPE_BASH] = true,
	[CCTYPE_HOJ] = true,
	[CCTYPE_TRAP] = true,
	[CCTYPE_COMA] = true,
	[CCTYPE_PARALYSIS] = true
}

local realNames = {
}


local function LocalizeCCTypeNames()

	for i, _ in pairs(GhostRecon.ccList) do

		for j, _ in pairs(GhostRecon.ccList[i]) do
			local name = GetSpellInfo(j)

			realNames[i] = name
			break
		end
	end
end

local function GetClassForCCType(ccType)
	local rc = ""

	for i, v in pairs(ccClasses) do
		if v[ccType] then
			rc = i
			break
		end
	end

	return rc
end

local function DecToHex(num)
	local b, k, rc, i, d = 16, "0123456789ABCDEF", "", 0, nil

	while num > 0 do
		i = i + 1
		num, d = math.floor(num / b), num % b + 1
		rc = string.sub(k, d, d)..rc
	end

	return rc
end

local function FractionToHex(num)
	local rc = DecToHex(num * 255)

	if string.len(rc) == 1 then
		rc = "0"..rc
	elseif string.len(rc) == 0 then
		rc = "00"
	end

	return rc
end

local function ColorToHex(col)
	return "FF"..FractionToHex(col.r)..FractionToHex(col.g)..FractionToHex(col.b)
end

function GhostRecon:ColoredText(text, color)
		return "|c"..ColorToHex(color)..text.."|r"
end

local function IsStunnable(mobInfo)
	local rc = nil

	for i, v in pairs(mobInfo) do
		if stuns[i] then
			if v.value == GhostRecon.CC_YES or v.value == GhostRecon.CC_SOMETIMES then
				rc = true
				break

			elseif v.value == GhostRecon.CC_NO then
				rc = false
			end
		end
	end

	return rc
end

local function IsTauntable(mobInfo)
	local rc = nil

	for i, v in pairs(mobInfo) do
		if taunts[i] then
			if v.value == GhostRecon.CC_YES then
				rc = true
				break
			elseif v.value == GhostRecon.CC_NO then
				rc = false
			end
		end
	end

	return rc
end

local function ClassInGroup(class)
	local rc = false

	if select(2, UnitClass("player")) == class then
		rc = true
	else
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

				if UnitExists(curUnitId) then
					if select(2, UnitClass(curUnitId)) == class then
						rc = true
						break
					end
				end
			end
		end
	end

	return rc
end

function GhostRecon:ControlTypeForSpellId(spellId)
	local rc

	for i, v in pairs(self.ccList) do
		if v[spellId] then
			rc = i
			break
		end
	end

	return rc
end

local function ShouldAddTooltipInfo(mobGuid, mobName)
	local rc = true

	if not GhostReconDB.Settings.TooltipEnabled then
		rc = false
	end

	return rc
end

function GhostRecon:DecorateTooltip(mobGuid, mobName, showSpells, overrideWhere, overrideParty)
	if ShouldAddTooltipInfo() then
		local where = overrideWhere or GhostRecon:WhereAmI()
		local whereInfo = GhostReconDB.Instances[where] or { }
		local mobInfo = whereInfo[mobName] or { }
		local added = false
		local report = ""
		local affected = L["Affected by: "]
		local sometimes = L["Sometimes works: "]
		local immunes = L["Immune: "]
		local cc = ""
		local red = { ["r"] = 0.9, ["g"] = 0, ["b"] = 0 }
		local green = { ["r"] = 0, ["g"] = 0.9, ["b"] = 0 }
		local tauntString = ""
		local stunString = ""
		local tauntColor
		local stunColor
		local addedSomething = false
		local reshow = GameTooltip:IsVisible()

		-- tauntable?
		local tauntable = IsTauntable(mobInfo)

		if tauntable == true then
			tauntString = L["Tauntable"]
			tauntColor = green
		elseif tauntable == false then
			tauntString = L["Not tauntable"]
			tauntColor = red
		end

		if tauntColor and string.len(tauntString) > 0 then
			tauntString = self:ColoredText(tauntString, tauntColor)
		end

		-- stunnable?    
		local stunnable = IsStunnable(mobInfo)

		if stunnable == true then
			stunString = L["Stunnable"]
			stunColor = green
		elseif stunnable == false then
			stunString = L["Not stunnable"]
			stunColor = red
		end

		if stunColor and string.len(stunString) > 0 then
			stunString = self:ColoredText(stunString, stunColor)
		end

		if string.len(tauntString) > 0 or string.len(stunString) > 0 then
			local effString = ""

			if string.len(tauntString) > 0 then
				effString = tauntString
			end

			if string.len(stunString) > 0 then
				if string.len(effString) == 0 then
					effString = stunString
				else
					effString = effString..", "..stunString
				end
			end

			GameTooltip:AddLine(effString, 0.5, 0.5, 0.5, 1)
			addedSomething = true
		end

		-- find yes
		for i, v in pairs(mobInfo) do
			-- check to see if this is a general CC entry (i.e. not special info about the mob)
			if self.ccList[i] then
				if not stuns[i] and not taunts[i] then
					local owningClass = GetClassForCCType(i)

					if v.value == GhostRecon.CC_YES then
						if ClassInGroup(owningClass) or overrideParty then
							if cc ~= "" then
								cc = cc..", "
							end
							cc = cc..self:ColoredText(realNames[i], RAID_CLASS_COLORS[owningClass])
							added = true
						end
					end
				end
			end
		end

		if added then
			report = affected..cc
			GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
		end

		-- find sometimes
		added = false
		report = ""
		cc = ""

		for i, v in pairs(mobInfo) do
			-- check to see if this is a general CC entry (i.e. not special info about the mob)
			if self.ccList[i] then
				if not stuns[i] and not taunts[i] then
					local owningClass = GetClassForCCType(i)

					if v.value == GhostRecon.CC_SOMETIMES then
						if ClassInGroup(owningClass) or overrideParty then
							if cc ~= "" then
								cc = cc..", "
							end

							cc = cc..self:ColoredText(realNames[i], RAID_CLASS_COLORS[owningClass])
							added = true
						end
					end
				end
			end
		end

		if added then
			report = sometimes..cc
			GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
		end

		-- find no
		added = false
		report = ""
		cc = ""

		for i, v in pairs(mobInfo) do
			-- check to see if this is a general CC entry (i.e. not special info about the mob)
			if self.ccList[i] then
				if not stuns[i] and not taunts[i] then
					local owningClass = GetClassForCCType(i)

					if v.value == GhostRecon.CC_NO then
						if ClassInGroup(owningClass) or overrideParty then
							if cc ~= "" then
								cc = cc..", "
							end

							cc = cc..self:ColoredText(realNames[i], { ["r"] = 1, ["g"] = 0, ["b"] = 0 })
							added = true
						end
					end
				end
			end
		end

		if added then
			report = immunes..cc
			GameTooltip:AddLine(report, 1, 1, 0, 1)
			addedSomething = true
		end

		if showSpells then
			-- spells
			local spellList = ""

			if mobInfo.spells then
				local spells = { }
				local namesSeen = { }

				for i, v in pairs(mobInfo.spells) do
					local info = { }

					info.spellId = i
					info.name = GetSpellInfo(i)

					table.insert(spells, info)
				end

				table.sort(spells, function(a, b)
					if a == nil and b == nil then
						return false
					elseif a.name == nil and b.name == nil then
						return false
					elseif a.name == nil then
						return false
					elseif b.name == nil then
						return true
					elseif a.name < b.name then
						return true
					else
						return false
					end
				end)


				for _, i in pairs(spells) do
					local name, _, texture, castTime, minRange, maxRange, _ = GetSpellInfo(i.spellId)
					local right = ""
					local v = mobInfo.spells[i.spellId]
					local leftR = 0.3
					local leftG = 0.3
					local leftB = 1

					if name then
						if namesSeen[name] == nil then
							namesSeen[name] = true
							addedSomething = true

							if castTime == 0 then
								right = L["Instant"]
							else
								right = string.format(L["%0.1f sec"], castTime / 1000)
							end

							if  maxRange > 0 then
								if minRange == 0 then
									right = right..string.format(L[" (%d yds)"], maxRange)
								else
									right = right..string.format(L[" (%d-%d yds)"], minRange, maxRange)
								end
							end

							if v == 1 then
								right = "|cffff0000"..right.."|r"
							end

							if GhostReconDB.SpellInfo and GhostReconDB.SpellInfo[i.spellId] then
								if GhostReconDB.SpellInfo[i.spellId].removable then
									leftR = 1
									leftG = 0.3
									leftB = 1
								end

								if GhostReconDB.SpellInfo[i.spellId].healType ~= nil then
									leftR = 0.3
									leftG = 1
									leftB = 0.3
								end
							end

							-- texture
							local textureString = ""

							if GhostReconDB.Settings.TooltipIconsEnabled and texture then
								textureString = "|T"..texture..":16|t "
							end

							-- add it to the tooltip
							GameTooltip:AddDoubleLine(textureString..name, right, leftR, leftG, leftB, 1, 1, 1)
							addedSomething = true
						end
					end
				end
			end
		end

		if addedSomething and reshow then
			GameTooltip:Show()
		end
	end
end

LocalizeCCTypeNames()