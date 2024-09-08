-- Thanks to phanx for her excellent (as usual) tutorial on addons localization.
-- https://phanx.net/addons/tutorials/localize

local _, namespace = ...

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

namespace.L = L

local LOCALE = GetLocale()

if LOCALE == "enUS" then
	-- The EU English game client also uses the US English locale code.
	--Config.lua
	L["Bar Scale: "]					= "Bar Scale: "
	L["Columns: "]						= "Columns: "
	L["Out of Combat Alpha: %d%%"]		= "Out of Combat Alpha: %d%%"
	L["In-Combat Alpha: %d%%"]			= "In-Combat Alpha: %d%%"

	L["Tooltip enabled"]				= "Tooltip enabled"
	L["Add spells to tooltip"]			= "Add spells to tooltip"
	L["Show icons in tooltip"]			= "Show icons in tooltip"
	L["Show abilities bar"]				= "Show abilities bar"
	L["Unit for bar"]					= "Unit for bar"

	L["Synchronize with guild members"]	= "Synchronize with guild members"
	L["Display information messages"]	= "Display information messages"
	L["Record instances/raids only"]	= "Record instances/raids only"
	L["Locked"]							= "Locked"

	--Comms.lua
	L["Received control information: %s works on %s (%s).  Sent by %s."] = "Received control information: %s works on %s (%s).  Sent by %s."
	L["Received control information: %s fails on %s (%s).  Sent by %s."] = "Received control information: %s fails on %s (%s).  Sent by %s."
	L["Received spell/ability information: %s has a spell/ability called %s (%s).  Sent by %s."] = "Received spell/ability information: %s has a spell/ability called %s (%s).  Sent by %s."
	L["Received spell information: %s is removable.  Sent by %s."] = "Received spell information: %s is removable.  Sent by %s."
	L["Received heal information: %s is a self-healing spell.  Sent by %s."] = "Received heal information: %s is a self-healing spell.  Sent by %s."
	L["Received heal information: %s is a general healing spell.  Sent by %s."] = "Received heal information: %s is a general healing spell.  Sent by %s."
	L["%s has version %s of Ghost: Recon - time for you to update!"] = "%s has version %s of Ghost: Recon - time for you to update!"
	L["Switching communications on - other guild members are using Ghost: Recon."] = "Switching communications on - other guild members are using Ghost: Recon."

	--Core.lua
	L["Left-click to search."] = "Left-click to search."
	L["Right-click to configure."] = "Right-click to configure."
	L["Alt- or Shift-click to report current target's abilities."] = "Alt- or Shift-click to report current target's abilities."
	L["Saw heal: %s healed themselves with %s."] = "Saw heal: %s healed themselves with %s."
	L["Saw heal: %s healed another mob with %s."] = "Saw heal: %s healed another mob with %s."
	L["Saw dispel: %s is removable."] = "Saw dispel: %s is removable."
	L["Saw control: %s is affected by %s."] = "Saw control: %s is affected by %s."
	L["Saw spell/ability: %s has a spell/ability called %s."] = "Saw spell/ability: %s has a spell/ability called %s."
	L["Saw control: %s is not affected by %s."] = "Saw control: %s is not affected by %s."
	L["Ghost: Recon users in guild currently on-line..."] = "Ghost: Recon users in guild currently on-line..."
	L["Ghost: Recon - Spells and Abilities of '%s'..."] = "Ghost: Recon - Spells and Abilities of '%s'..."	
	L["Recording is switched on."] = "Recording is switched on."
	L["Recording is switched off."] = "Recording is switched off."

	--Search.lua
	L["Abilities"]						= "Abilities"	
	L["Ghost: Recon - Mob Search"]		= "Ghost: Recon - Mob Search"	
	L["Zone"]							= "Zone"		
	L["Mob"]							= "Mob"	
	L["Notes"]							= "Notes"	
	L["Clear Mob"]						= "Clear Mob"
	L["Whisper"]						= "Whisper"
	L["Report"]							= "Report"
	L["Do you really want to remove information about this mob from the database?"] = "Do you really want to remove information about this mob from the database?"
	L["Report the spells and abilities to who?"] = "Report the spells and abilities to who?"

	--Tooltip.lua
	L["Affected by: "]					= "Affected by: "
	L["Sometimes works: "]				= "Sometimes works: "
	L["Immune: "]						= "Immune: "
	L["Instant"]						= "Instant"
	L["%0.1f sec"]						= "%0.1f sec"
	L[" (%d yds)"]						= " (%d yds)"
	L[" (%d-%d yds)"]					= " (%d-%d yds)"	
	L["Tauntable"]						= "Tauntable"
	L["Not tauntable"]					= "Not tauntable"
	L["Stunnable"]						= "Stunnable"	
	L["Not stunnable"]					= "Not stunnable"
return end

if LOCALE == "deDE" then
	-- German translations go here

return end

if LOCALE == "frFR" then
	-- French translations go here

return end

if LOCALE == "esES" or LOCALE == "esMX" then
	-- Spanish translations go here

return end

if LOCALE == "ptBR" then
	-- Brazilian Portuguese translations go here
	-- Note that the EU Portuguese WoW client also uses the Brazilian Portuguese locale code.

return end

if LOCALE == "ruRU" then
	-- Russian translations go here

return end

if LOCALE == "koKR" then
	-- Korean translations go here

return end

if LOCALE == "zhCN" then
	-- Simplified Chinese translations go here
	--Config.lua
	L["Bar Scale: "]					= "技能条缩放: "
	L["Columns: "]						= "每行图标: "
	L["Out of Combat Alpha: %d%%"]		= "脱战透明: %d%%"
	L["In-Combat Alpha: %d%%"]			= "战斗中透明: %d%%"

	L["Tooltip enabled"]				= "启用鼠标提示"
	L["Add spells to tooltip"]			= "添加技能到提示"
	L["Show icons in tooltip"]			= "显示提示图标"
	L["Show abilities bar"]				= "显示技能条"
	L["Unit for bar"]					= "技能条对象"

	L["Synchronize with guild members"]	= "公会同步"
	L["Display information messages"]	= "聊天栏显示信息"
	L["Record instances/raids only"]	= "仅记录副本/团本"
	L["Locked"]							= "锁定"

	--Comms.lua
	L["Received control information: %s works on %s (%s).  Sent by %s."] = "收到控制信息: %s 起作用 %s (%s).  来自 %s."
	L["Received control information: %s fails on %s (%s).  Sent by %s."] = "收到控制信息: %s 无用 %s (%s).  来自 %s."
	L["Received spell/ability information: %s has a spell/ability called %s (%s).  Sent by %s."] = "收到法术/技能信息: %s 有法术/技能叫 %s (%s).  来自 %s."
	L["Received spell information: %s is removable.  Sent by %s."] = "收到法术信息: %s 可移除.  来自 %s."
	L["Received heal information: %s is a self-healing spell.  Sent by %s."] = "收到治疗信息: %s 是自疗法术.  来自 %s."
	L["Received heal information: %s is a general healing spell.  Sent by %s."] = "收到治疗信息: %s 是常规治疗法术.  来自 %s."
	L["%s has version %s of Ghost: Recon - time for you to update!"] = "%s 有版本 %s 的 Ghost: Recon - 你可以更新!"
	L["Switching communications on - other guild members are using Ghost: Recon."] = "打开交流开关 - 其他公会人员在用 Ghost: Recon."

	--Core.lua
	L["Left-click to search."] = "左键点击搜索。"
	L["Right-click to configure."] = "右键点击设置。"
	L["Alt- or Shift-click to report current target's abilities."] = "Alt或Shift点击报告当前目标技能。"
	L["Saw heal: %s healed themselves with %s."] = "发现治疗: %s 治疗他们自己，使用 %s."
	L["Saw heal: %s healed another mob with %s."] = "发现治疗: %s 治疗其他怪物，使用 %s."
	L["Saw dispel: %s is removable."] = "发现驱散: %s 可移除."
	L["Saw control: %s is affected by %s."] = "发现控制: %s 可被影响 %s."
	L["Saw spell/ability: %s has a spell/ability called %s."] = "发现法术/技能: %s 有法术/技能叫 %s."
	L["Saw control: %s is not affected by %s."] = "发现控制: %s 不可被影响 %s."
	L["Ghost: Recon users in guild currently on-line..."] = "Ghost: Recon 当前在线公会成员..."
	L["Ghost: Recon - Spells and Abilities of '%s'..."] = "Ghost: Recon - '%s'的法术和技能..."	
	L["Recording is switched on."] = "打开记录"
	L["Recording is switched off."] = "关闭记录"

	--Search.lua
	L["Abilities"]						= "技能"	
	L["Ghost: Recon - Mob Search"]		= "Ghost: Recon - 怪物搜索"	
	L["Zone"]							= "区域"		
	L["Mob"]							= "怪物"	
	L["Notes"]							= "注释"	
	L["Clear Mob"]						= "清除怪物"
	L["Whisper"]						= "密语"
	L["Report"]							= "报告"
	L["Do you really want to remove information about this mob from the database?"] = "你确实要从库删除这个怪物的信息吗？"
	L["Report the spells and abilities to who?"] = "把法术和技能报告给谁？"

	--Tooltip.lua
	L["Affected by: "]					= "受影响: "
	L["Sometimes works: "]				= "有时有效: "
	L["Immune: "]						= "免疫: "
	L["Instant"]						= "瞬发"
	L["%0.1f sec"]						= "%0.1f 秒"
	L[" (%d yds)"]						= " (%d 码)"
	L[" (%d-%d yds)"]					= " (%d-%d 码)"
	L["Tauntable"]						= "可嘲讽"
	L["Not tauntable"]					= "不可嘲讽"
	L["Stunnable"]						= "可晕"	
	L["Not stunnable"]					= "不可晕"
return end

if LOCALE == "zhTW" then
	-- Traditional Chinese translations go here
	--Config.lua
	L["Bar Scale: "]					= "技能條縮放: "
	L["Columns: "]						= "每行圖標: "
	L["Out of Combat Alpha: %d%%"]		= "脫戰透明: %d%%"
	L["In-Combat Alpha: %d%%"]			= "戰鬥中透明: %d%%"

	L["Tooltip enabled"]				= "啓用鼠標提示"
	L["Add spells to tooltip"]			= "添加技能到提示"
	L["Show icons in tooltip"]			= "顯示提示圖標"
	L["Show abilities bar"]				= "顯示技能條"
	L["Unit for bar"]					= "技能條對象"

	L["Synchronize with guild members"]	= "公會同步"
	L["Display information messages"]	= "聊天欄顯示信息"
	L["Record instances/raids only"]	= "僅記錄副本/團本"
	L["Locked"]							= "鎖定"

	--Comms.lua
	L["Received control information: %s works on %s (%s).  Sent by %s."] = "收到控制信息: %s 起作用 %s (%s).  來自 %s."
	L["Received control information: %s fails on %s (%s).  Sent by %s."] = "收到控制信息: %s 無用 %s (%s).  來自 %s."
	L["Received spell/ability information: %s has a spell/ability called %s (%s).  Sent by %s."] = "收到法術/技能信息: %s 有法術/技能叫 %s (%s).  來自 %s."
	L["Received spell information: %s is removable.  Sent by %s."] = "收到法術信息: %s 可移除.  來自 %s."
	L["Received heal information: %s is a self-healing spell.  Sent by %s."] = "收到治療信息: %s 是自療法術.  來自 %s."
	L["Received heal information: %s is a general healing spell.  Sent by %s."] = "收到治療信息: %s 是常規治療法術.  來自 %s."
	L["%s has version %s of Ghost: Recon - time for you to update!"] = "%s 有版本 %s 的 Ghost: Recon - 你可以更新!"
	L["Switching communications on - other guild members are using Ghost: Recon."] = "打開交流開關 - 其他公會人員在用 Ghost: Recon."

	--Core.lua
	L["Left-click to search."] = "左鍵點擊搜索。"
	L["Right-click to configure."] = "右鍵點擊設置。"
	L["Alt- or Shift-click to report current target's abilities."] = "Alt或Shift點擊報告當前目標技能。"
	L["Saw heal: %s healed themselves with %s."] = "發現治療: %s 治療他們自己，使用 %s."
	L["Saw heal: %s healed another mob with %s."] = "發現治療: %s 治療其他怪物，使用 %s."
	L["Saw dispel: %s is removable."] = "發現驅散: %s 可移除。"
	L["Saw control: %s is affected by %s."] = "發現控制: %s 可被影響 %s."
	L["Saw spell/ability: %s has a spell/ability called %s."] = "發現法術/技能: %s 有法術/技能叫 %s。"
	L["Saw control: %s is not affected by %s."] = "發現控制: %s 不可被影響 %s."
	L["Ghost: Recon users in guild currently on-line..."] = "Ghost: Recon 當前在線公會成員..."
	L["Ghost: Recon - Spells and Abilities of '%s'..."] = "Ghost: Recon - '%s'的法術和技能..."	
	L["Recording is switched on."] = "打開記錄"
	L["Recording is switched off."] = "關閉記錄"

	--Search.lua
	L["Abilities"]						= "技能"	
	L["Ghost: Recon - Mob Search"]		= "Ghost: Recon - 怪物搜索"	
	L["Zone"]							= "區域"		
	L["Mob"]							= "怪物"	
	L["Notes"]							= "註釋"	
	L["Clear Mob"]						= "清除怪物"
	L["Whisper"]						= "密語"
	L["Report"]							= "報告"
	L["Do you really want to remove information about this mob from the database?"] = "你確實要從庫刪除這個怪物的信息嗎？"
	L["Report the spells and abilities to who?"] = "把法術和技能報告給誰？"

	--Tooltip.lua
	L["Affected by: "]					= "受影響: "
	L["Sometimes works: "]				= "有時有效: "
	L["Immune: "]						= "免疫: "
	L["Instant"]						= "瞬發"
	L["%0.1f sec"]						= "%0.1f 秒"
	L[" (%d yds)"]						= " (%d 碼)"
	L[" (%d-%d yds)"]					= " (%d-%d 碼)"
	L["Tauntable"]						= "可嘲諷"
	L["Not tauntable"]					= "不可嘲諷"
	L["Stunnable"]						= "可暈"	
	L["Not stunnable"]					= "不可暈"
return end