更新GhostRecon-怪物技能记录插件，在oyg123、KeiraMetz等大佬基础上修改，增加翻译并实现简繁英自适应、增减技能、更新API、重排缩进。目前11.0可用
如有问题，请大家反馈错误代码

1.插件介绍
记录怪物所有技能，并在屏幕上显示怪物技能栏，并添加鼠标提示。还可以搜索技能，仅限已保存怪物。




2.插件设置方法
(1)ESC-选项-插件-Ghost：Recon
(2)/gr、 /recon、 /ghost 等命令，插件--Ghost：Recon
(3)修改配置文件 \World of Warcraft\_retail_\WTF\Account\账户名\SavedVariables\GhostRecon.lua
GhostReconDB = {
["Settings"] = {
["Active"] = true,
["TooltipEnabled"] = true,
["RelativeAnchor"] = "TOP",
["OutOfCombatAlpha"] = 1,
["Anchor"] = "TOP",
["AbilitiesBarEnabled"] = true,
["TooltipSpellsEnabled"] = true,
["GuildSync"] = false,
["InstancesOnly"] = false,
["Y"] = -40,
["X"] = 0,
["Columns"] = 12,
["BarUnit"] = "target",
["TooltipIconsEnabled"] = true,
["Scale"] = 1.25,
["ShowMessages"] = true,
["InCombatAlpha"] = 1,
},



3.插件下载
GhostRecon-20240819-简繁英、缩进排版.zip
https://img.nga.178.com/attachments/mon_202408/20/5kQ2u-jursK14.zip?filename=GhostRecon%2d20240819%2d%E7%AE%80%E7%B9%81%E8%8B%B1%E3%80%81%E7%BC%A9%E8%BF%9B%E6%8E%92%E7%89%88%2ezip

4.当前遗留问题
目前命令无法直接打开到具体设置界面，也不能自动展开。
Settings API changes
The Settings API has been updated to resolve a few usability issues with respect to the creation and management of settings.

The Settings.RegisterAddOnSetting function has had its signature changed significantly and now requires two additional parameters (variableKey and variableTbl) in the middle of the parameter list. These are used to directly read and write settings from a supplied table, which is typically expected to be the addon's saved variables.
The Settings.RegisterProxySetting function has been adjusted and can now be called from insecure code. Proxy settings can be used to execute author-supplied callbacks when reading and writing settings as an alternative to RegisterAddOnSetting.
The Settings.OpenToCategory function has been improved and now supports directly opening to a subcategory, as well as automatically expanding any categories that it opens.

https://bbs.nga.cn/read.php?&tid=34246233

5.出处、发布修改历史
https://www.wowinterface.com/downloads/info11869-GhostRecon.html
https://www.wowinterface.com/downloads/info18957-GhostReconContinued.html
https://www.wowinterface.com/downloads/info24744-GhostReconBFA.html
https://bbs.nga.cn/read.php?tid=10057098&forder_by=postdatedesc&page=4
https://bbs.nga.cn/read.php?tid=34053506&fav=:F05349FF5
https://bbs.nga.cn/read.php?tid=34246233

