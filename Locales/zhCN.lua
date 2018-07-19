------------------------------
----- Translation for enEN
local L = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Core", "zhCN")
if not L then return end

-- Core stuff
L["CMD_OPTS_FRAME"]		= "打开选项窗口"
L["CMD_OPTS_MODULES"]	= "打开模块选项窗口"
L["CMD_OPTS_CUSTOM"]	= "打开自定义模块选项窗口"
L["CMD_OPTS_TOGGLE"]	= "ArcHUD显示切换"
L["CMD_OPTS_DEBUG"]		= "设置调试级别"
L["CMD_OPTS_DEBUG_SET"]	= "设置调试级别为“%s”"
L["CMD_RESET"]			= "对于这个角色的设置重置为默认值"
L["CMD_RESET_HELP"]		= "此选项将允许您做两件事，首先您可以重置您的设置为默认值。之后输入'CONFIRM'来确认，使这个插件知道您读过此信息"
L["CMD_RESET_CONFIRM"]	= "此选项将会重置所有选项到默认值， 就像此插件重新安装。"
L["TEXT_RESET"]			= "请输入 CONFIRM 这个命令，以确认您确实想要重置您的设置"
L["TEXT_RESET_CONFIRM"]	= "所有设置重置为默认值"
L["TEXT_ENABLED"]       = "ArcHUD现在已启用。"
L["TEXT_DISABLED"]      = "ArcHUD现在已禁用。"

L["FONT"]				= "ARHei.TTF" --FRIZQT__.TTF

L["Version"]		= true
L["Authors"]		= true

--	Options
L["TEXT"] = {
	TITLE		= "ArcHUD3选项",
	GENERAL		= "常规设置",
	
	PROFILES	= "配置文件",
	PROFILES_SELECT= "选择配置文件",
	PROFILES_CREATE= "创建新的配置文件",
	PROFILES_DELETE= "删除配置文件",
	PROFILES_CANNOTDELETE= "无法删除默认配置文件。",
	PROFILES_DEFAULT= "默认配置文件",
	PROFILES_EXISTS= "配置文件已存在。",
	
	DISPLAY		= "显示选项",
	PLAYERFRAME	= "玩家框架",
	TARGETFRAME	= "目标框架",
	PLAYERMODEL	= "玩家3D模型",
	MOBMODEL	= "怪物3D模型",
	SHOWGUILD	= "显示玩家公会",
	SHOWCLASS	= "显示目标职业",
	SHOWBUFFS 	= "显示增(减)益效果",
	SHOWONLYBUFFSCASTBYPLAYER = "只显示你的增(减)益效果",
	SHOWBUFFTT 	= "显示增(减)益效果提示",
	HIDEBUFFTTIC = "战斗中隐藏增(减)益效果提示",
	BUFFICONSIZE= "增(减)益效果图标大小",
	SHOWPVP		= "显示玩家的PvP状态标记",
	SHOWTEXTMAX	= "显示生命/能量最大值",
	TOT			= "启用目标的目标",
	TOTOT		= "启用目标的目标的目标",

	NAMEPLATES	= "姓名板选项",
	NPHINT		= "在这里配置姓名板的鼠标行为。它们的显示可以在“显示选项”进行更改。",
	NPPLAYEROPT = "玩家",
	NPPLAYER	= "玩家",
	NPPET		= "宠物",
	HOVERMSG	= "姓名板悬停消息",
	HOVERDELAY	= "姓名板悬停延时",
	NPTARGETOPT = "目标",
	NPTARGET	= "目标",
	NPTOT		= "目标的目标",
	NPTOTOT		= "目标的目标的目标",
	NPCOMBAT	= "启用战斗中的姓名板",
	
	COMBOPOINTS = "连击点选项",
	COMBOPOINTSSETTINGS1 = "Combo points settings have been moved to the combo points arc settings. These are now available for many secondary power arcs such as Holy Power, Soul Shards etc. (see respective power arc settings).",
	COMBOPOINTSSETTINGS2 = "These combo points settings used to control whether a huge number is displayed in the center of ArcHUD representing the respective player power.",
	-- deprecated: SHOWCOMBO	= "显示连击点文本",
	-- deprecated: COMBODECAY	= "衰变延迟",
	-- deprecated: HOLYPOWERCOMBO = "显示神圣能量作为连击点",
	-- deprecated: SOULSHARDCOMBO = "显示灵魂碎片作为连击点",
	-- deprecated: CHICOMBO 	= "显示真气作为连击点",
	-- deprecated: RUNECOMBO 	= "Show Runes as combo points",
	-- deprecated: SOULFRAGMENTCOMBO = "Show Soul Fragments as combo points",
	-- deprecated: CPCOLOR		= "连击点颜色",
	-- deprecated: CPCOLORDECAY = "连击点衰变的颜色",
	RESETCOLORS	= "重置颜色",

	FADE		= "渐变选项",
	FADE_FULL	= "当全满时",
	FADE_OOC	= "脱离战斗",
	FADE_IC		= "进入战斗",
	RINGVIS		= "渐变行为",
	RINGVIS_1	= "全满淡出：当全满时淡出",
	RINGVIS_2	= "脱战淡出：当脱离战斗时淡出",
	RINGVIS_3	= "两种淡出：当全满时并且脱离战斗时淡出(默认)",
	
	POSITIONING	= "位置 / 缩放",
	WIDTH		= "HUD 宽度",
	YLOC		= "垂直对齐",
	XLOC		= "水平对齐",
	SCALE		= "缩放",
	SCALETARGETFRAME = "目标框架缩放",
	ATTACHTOP	= "附着目标框架到顶部",
	MFUNLOCK	= "解锁移动框架",
	MFRESET		= "重置位置",
	
	MISC		= "其它选项",
	BLIZZPLAYER = "默认暴雪玩家框架可见",
	BLIZZTARGET = "默认暴雪目标框架可见",
	BLIZZFOCUS  = "默认暴雪焦点框架可见",
	BLIZZSPELLACT_CENTER = "居中暴雪的施法效果提示在ArcHUD上",
	BLIZZSPELLACT_SCALE = "法术效果提示缩放",
	BLIZZSPELLACT_OPAC = "法术效果提示透明度",

	RINGS		= "弧形选项",
	RING		= "弧形",
}

L["TOOLTIP"] = {
	PROFILES_SELECT = "为这个角色选择配置文件。",
	PROFILES_CREATE = "创建基于当前配置的新的配置文件并激活。",
	PROFILES_DELETE = "删除当前配置文件，并激活设置默认配置文件。",

	PLAYERFRAME	= "切换显示玩家和宠物的姓名板。\n注：鼠标行为可以在姓名板选项进行配置。",
	TARGETFRAME = "切换显示整体目标框架。\n注：鼠标行为可以在姓名板选项进行配置。",
	PLAYERMODEL = "切换显示玩家的3D目标模型",
	MOBMODEL	= "切换显示怪物的3D目标模型",
	SHOWGUILD	= "在玩家名旁边显示玩家公会信息",
	SHOWCLASS	= "显示目标职业或生物类别",
	SHOWBUFFS	= "切换显示增益效果和减益效果",
	SHOWONLYBUFFSCASTBYPLAYER = "只显示你施放的增(减)益效果。必须启用“显示增益效果和减益效果”。",
	SHOWBUFFTT 	= "切换显示增益效果或减益效果提示",
	HIDEBUFFTTIC = "切换显示战斗中增益效果或减益效果提示",
	BUFFICONSIZE= "设置增(减)益效果图标大小(像素单位)",
	SHOWPVP		= "切换显示玩家姓名板上的PVP状态标志",
	SHOWTEXTMAX	= "切换显示生命/能量最大值文本",
	TOT			= "启用显示目标的目标",
	TOTOT		= "启用显示目标的目标的目标",

	NPPLAYER	= "切换可点击玩家的姓名板。\n"..
		"注：此选项仅在玩家框架可见时生效(见显示选项)。\n\n"..
		"由于界面限制玩家姓名板的状态无法在战斗中更改。"..
		"因此，无法在战斗中通过悬停激活，或如果进入战斗时处于激活状态，它将保持激活状态。",
	NPPET		= "切换可点击宠物的姓名板。\n"..
		"注：此选项仅在玩家框架可见时生效(见显示选项)。\n\n"..
		"由于界面限制宠物姓名板的状态无法在战斗中更改。"..
		"因此，无法在战斗中通过悬停激活，或如果进入战斗时处于激活状态，它将保持激活状态。",
	NPTARGET	= "切换可点击目标的姓名板。\n注：此选项仅在目标框架可见时生效(见显示选项)。",
	NPTOT		= "切换可点击目标的目标的姓名板。\n注：此选项仅在目标框架可见时生效(见显示选项)。",
	NPTOTOT		= "切换可点击目标的目标的目标的姓名板。\n注：此选项仅在目标框架可见时生效(见显示选项)。",
	HOVERMSG	= "切换显示当鼠标激活启用一条聊天消息",
	HOVERDELAY	= "悬停在玩家/宠物姓名板上所需要激活的秒数",
	
	SHOWCOMBO	= "切换显示在HUD中心的连击点",
	COMBODECAY	= "设置之前目标的连击点消失的延迟(设置为0以禁用此功能)",
	HOLYPOWERCOMBO = "切换显示神圣能量点作为连击点(连击点必须启用)",
	SOULSHARDCOMBO = "切换显示灵魂碎片作为连击点(连击点必须启用)",
	CHICOMBO 	= "切换显示真气作为连击点(连击点必须启用)",
	RUNECOMBO 	= "Toggle display of Deathnight's Runes as combo points (combo points must be turned on)",
	SOULFRAGMENTCOMBO = "Toggle display of Demon Hunter's Soul Fragments as combo points (combo points must be turned on)",
	CPCOLOR		= "设置连击点文本的颜色",
	CPCOLORDECAY = "设置连击点衰变的颜色",
	RESETCOLORS	= "重置颜色为默认值",

	FADE_FULL	= "当脱离战斗并且弧形为100%时淡出的透明度",
	FADE_OOC	= "当脱离战斗并且弧形不满100%时淡出的透明度",
	FADE_IC		= "当进入战斗时淡出的透明度 (仅在行为设置为两种淡出或脱战淡出时使用)",
	RINGVIS		= "设置当弧形淡出：\n" ..
				  "全满淡出：无论是否战斗状态，当弧形全满时淡出\n" ..
				  "脱战淡出：无论弧形是否充满，当脱离战斗时总是淡出\n" ..
				  "两种淡出：当脱离战斗并且弧形全满时淡出(默认)",
	RINGVIS_1	= "无论是否战斗状态，当弧形全满时淡出",
	RINGVIS_2	= "无论弧形是否充满，当脱离战斗时总是淡出",
	RINGVIS_3	= "当脱离战斗并且弧形全满时淡出(默认)",

	WIDTH		= "设置从中心分开多大弧形",
	YLOC		= "ArcHUD沿Y轴的位置。正值向上，负值向下",
	XLOC		= "ArcHUD沿X轴的位置。正值向右，负值向左",
	SCALE		= "设置缩放比例",
	SCALETARGETFRAME = "设置目标框架的缩放比例。这个缩放是基于上面的整体缩放比例。",
	ATTACHTOP	= "附着目标框架到弧形的顶部而不是底部",
	MFUNLOCK	= "允许您自由移动目标框架",
	MFRESET		= "重置可动框架的位置",
	
	BLIZZPLAYER = "切换可见对于暴雪玩家框架",
	BLIZZTARGET = "切换可见对于暴雪目标框架",
	BLIZZFOCUS  = "切换可见对于暴雪焦点框架",
	BLIZZSPELLACT_CENTER = "切换暴雪的施法效果提示是在ArcHUD的中心还是在屏幕上",
	BLIZZSPELLACT_SCALE = "设置暴雪的法术效果提示的缩放比例",
	BLIZZSPELLACT_OPAC = "设置暴雪的法术效果提示的透明度。",
	
}


-- Modules
local LM = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Module", "zhCN")

LM["FONT"]			= "ARHei.TTF" --FRIZQT__.TTF

LM["Version"]	= "版本"
LM["Authors"]	= "作者"

LM["Health"]		= "玩家生命"
LM["Power"]			= "玩家能量"
LM["PetHealth"]		= "宠物生命"
LM["PetPower"]		= "宠物能量"
LM["TargetCasting"]	= "目标施法"
LM["TargetHealth"]	= "目标生命"
LM["TargetPower"]	= "目标能量"
LM["FocusCasting"]	= "专注施法"
LM["FocusHealth"]	= "焦点生命"
LM["FocusPower"]	= "焦点能量"
LM["Casting"]		= "玩家施法"
LM["MirrorTimer"]	= "镜象计时"
LM["ComboPoints"]	= "Rogue: 连击点"
LM["ComboPointsDruid"] = "Druid: 连击点"
LM["HolyPower"]		= "圣骑士：神圣能量"
LM["SoulShards"]	= "术士：灵魂碎片,燃烧余烬,恶魔之怒"
-- deprecated: LM["Eclipse"]		= "德鲁伊：日蚀"
LM["Chi"]			= "武僧：真气"
LM["Stagger"]		= "武僧：醉拳"
LM["Runes"]			= "死亡骑士：符文"
LM["ManaShadowPriest"]	= "牧师：Mana (Shadow Priest)"
LM["ManaBalanceDruid"]	= "德鲁伊：Mana (Balance Druid)"
LM["ManaElementalShaman"]	= "Shaman: Mana (Elemental/Enhancement Shaman)"
LM["ArcaneCharges"]	= "Mage: Arcane Charges"

LM["TEXT"] = {
	TITLE		= "弧形选项",

	ENABLED		= "启用",
	OUTLINE		= "弧形轮廓",
	SHOWTEXT	= "显示文本",
	SHOWTEXTMAX	= "显示最大",
	SHOWPERC	= "显示百分比",
	SHOWTEXTHUGE = "Show huge text",
	FLASH		= "弧形充满时闪耀",
	FLASH_HP	= "神圣能量3点时闪耀",
	SHOWSPELL	= "显示正在施放法术",
	SHOWTIME	= "显示法术计时",
	INDINTERRUPT= "高亮可中断法术",
	INDLATENCY  = "世界延迟指标",
	INDSPELLQ   = "施法延迟指标",
	HIDEBLIZZ	= "隐藏默认暴雪框架",
	ENABLEMENU	= "启用右键单击菜单",
	DEFICIT		= "损伤",
	INCOMINGHEALS= "受到治愈指标",
	SHOWABSORBS = "显示吸收",
	ATTACH		= "附着",
	SIDE		= "侧向",
	LEVEL		= "水平",
	
	SEPARATORS  = "显示分隔符",
	SWAPHEALTHPOWERTEXT = "互换生命和能量文本显示",
	
	COLOR		= "颜色模式",
	COLORRESET	= "重置颜色",
	COLORFADE	= "衰变颜色",
	COLORCUST	= "自定颜色",
	COLORSET	= "弧形颜色",
	COLORSETFADE= "弧形颜色",
	COLORFRIEND = "友好弧形颜色",
	COLORFOE	= "敌对弧形颜色",
	COLORMANA 	= "法力弧形颜色",
	COLORRAGE	= "怒气弧形颜色",
	COLORFOCUS 	= "集中弧形颜色",
	COLORENERGY	= "能量弧形颜色",
	COLORRUNIC	= "符文能量弧形颜色",
	COLORABSORBS = "主动吸收颜色",
	
	-- deprecated: COLORLUNAR	= "月蚀能量颜色",
	-- deprecated: COLORSOLAR	= "日蚀能量颜色",
	
	STAGGER_MAX = "最大值(于最大生命的百分比)",
	COLORSTAGGERL = "轻度醉拳颜色",
	COLORSTAGGERM = "中度醉拳颜色",
	COLORSTAGGERH = "重度醉拳颜色",

	SORTRUNES   = "Sort Runes",
	
	INNERANCHOR = "附着弧形到内部(“宠物”)锚点",
	
	CUSTOM		= "自定增益效果弧形",
	CUSTNEW		= "新的自定弧形",
	CUSTRING	= "弧形选项",
	
	CUSTDEBUFF	= "减益效果",
	CUSTUNIT	= "单位",
	CUSTNAME	= "增(减)益效果名称",
	CUSTCASTBYPLAYER = "只显示你的增(减)益效果",
	CUSTSTACKS	= "使用堆叠数量",
	CUSTTEXTSTACKS = "显示堆叠数量",
	CUSTMAX		= "最大值",
	CUSTMAXVALIDATE= "最大值必须>= 1。",
	CUSTDEL		= "删除",
}

LM["TOOLTIP"] = {
	ENABLED		= "切换弧形开或关",
	OUTLINE		= "切换弧形周围轮廓",
	SHOWTEXT	= "切换文本显示(生命，法力，等。)",
	SHOWTEXTMAX	= "切换最大值文本显示",
	SHOWPERC	= "切换显示百分比",
	SHOWTEXTHUGE = "Toggle huge text display in the center of ArcHUD (formerly known as 'combo points')",
	SHOWSPELL	= "切换显示当前正在施放法术名",
	SHOWTIME	= "切换显示法术计时",
	INDINTERRUPT= "切换高亮可中断的法术。施法弧形将有一个黄色的轮廓为可中断的法术。弧形轮廓需要启用。",
	INDLATENCY  = "切换当前指标为世界延迟。如果选择，添加到施法延迟指标。",
	INDSPELLQ   = "切换施法延迟指标(延迟误差)。当前施法经过指标时，其应该可以安全的开始施放下一个法术。 如果选择，添加延迟。",
	FLASH		= "切换弧形充满时闪耀",
	FLASH_HP	= "切换神圣能量3点时闪耀",
	HIDEBLIZZ	= "切换显示默认暴雪框架",
	ENABLEMENU	= "切换右键单击菜单打开和关闭",
	DEFICIT		= "切换生命损伤(最大生命值-当前生命值)",
	INCOMINGHEALS= "切换受到治愈指标",
	SHOWABSORBS = "切换显示主动吸收",
	SIDE		= "设置附着于哪一侧",
	LEVEL		= "设置在哪个水平对于相关附着锚点(<-1：向中心，0：在锚点，>1：离中心)",
	
	SEPARATORS  = "切换分隔符 (仅对2到20之间的最大弧形值)",
	SWAPHEALTHPOWERTEXT = "互换生命和能量文本显示，让能量文本显示在左并且生命文本显示于右",
	
	COLOR		= "设置颜色模式：\n"..
					"衰变颜色：设置弧形颜色为衰变(生命绿色到红色)\n"..
					"自定颜色：设置弧形颜色为一个自定义颜色",
	COLORRESET	= "重置颜色为弧形的默认颜色",
	COLORFADE	= "设置弧形颜色为衰变(生命绿色到红色)",
	COLORCUST	= "设置弧形颜色为一个自定义颜色",
	COLORSET	= "设置自定弧形颜色",
	COLORSETFADE= "设置自定弧形颜色(颜色模式必须设置为“自定颜色”)",
	COLORFRIEND	= "设置自定友好弧形颜色",
	COLORFOE	= "设置自定敌对弧形颜色",
	COLORMANA	= "设置自定法力弧形颜色",
	COLORRAGE	= "设置自定怒气弧形颜色",
	COLORFOCUS	= "设置自定集中弧形颜色",
	COLORENERGY	= "设置自定能量弧形颜色",
	COLORRUNIC	= "设置自定符文能量弧形颜色",
	COLORABSORBS = "设置自定主动吸收弧形颜色",
	
	STAGGER_MAX = "最大生命值的百分比作为最大弧形值",
	COLORSTAGGERL = "更改轻度醉拳弧形颜色",
	COLORSTAGGERM = "更改中度醉拳弧形颜色",
	COLORSTAGGERH = "更改重度醉拳弧形颜色",

	SORTRUNES   = "Sort the Runes according to their status",
	
	INNERANCHOR = "如果选择，附着弧形到内部(“宠物”)锚点。如果没选择，使用通常(外部)锚点。",
	
	CUSTNEW		= "为一个特定的增益效果或减益效果创建一个新的自定弧形",
	CUSTDEBUFF	= "寻找减益效果而不是增益效果",
	CUSTUNIT	= "増(减)益效果被施加的哪个单位",
	CUSTNAME	= "増(减)益效果的名称。多个増(减)益效果可以通过用分号(;)分隔命名。优先级按照这里的顺序给出。",
	CUSTCASTBYPLAYER = "只显示自己施放的増(减)益效果",
	CUSTSTACKS	= "使用堆叠数量，而不是剩余时间作为弧形",
	CUSTTEXTSTACKS = "显示堆叠数量作为文字，而不是剩余时间",
	CUSTMAX		= "增(减)益效果最大堆叠数量或持续时间。如果显示持续时间，数值“1” 意味着使用增(减)益效果的初始持续时间来替代这里给出的值。",
	CUSTDEL		= "删除这个自定弧形",
}

LM["SIDE"] = {
	LEFT		= "左侧锚点",
	RIGHT		= "右侧锚点",
}
