------------------------------
----- Translation for ruRU by StingerSoft
----- with additions from evilstar
local L = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Core", "ruRU")
if not L then return end

-- Core stuff
L["CMD_OPTS_FRAME"]		= "Открывает окно настроек"
L["CMD_OPTS_MODULES"]	= "Открывает окно настроек модуля"
L["CMD_OPTS_CUSTOM"]	= "Открывает окно настроек пользовательского модуля"
L["CMD_OPTS_TOGGLE"]	= "Toggle visibility of ArcHUD"
L["CMD_OPTS_DEBUG"]		= "Уровень отладки"
L["CMD_OPTS_DEBUG_SET"]	= "Настройка уровня отладки: '%s'"
L["CMD_RESET"]			= "Сброс настроек для данного персонажа на стандартные"
L["CMD_RESET_HELP"]		= "Данная опция позволит вам сбросить все настройки на стандартные.  Чтобы это зделать введите 'CONFIRM'"
L["CMD_RESET_CONFIRM"]	= "Данная опция сбросит все настройки на стандартные на те что были установлены при установке аддона"
L["TEXT_RESET"]			= "Пожалуйста введите CONFIRM после команды, для потверждения того что вы согласны сбросить все настройки"
L["TEXT_RESET_CONFIRM"]	= "Все настройки будут сброшены на стандартные"
L["TEXT_ENABLED"]       = "ArcHUD is now enabled."
L["TEXT_DISABLED"]      = "ArcHUD is now disabled."

L["FONT"]				= "FRIZQT___CYR.TTF"

L["Version"]		= "Версия: "
L["Authors"]		= "Автор: "

--	Options
L["TEXT"] = {
	TITLE		= "Настройки ArcHUD3",
	GENERAL		= "Основные настройки",

	PROFILES	= "Profiles",
	PROFILES_SELECT= "Select profile",
	PROFILES_CREATE= "Create new profile",
	PROFILES_DELETE= "Delete profile",
	PROFILES_CANNOTDELETE= "Cannot delete default profile.",
	PROFILES_DEFAULT= "Default profile",
	PROFILES_EXISTS= "Profile already exists.",
	
	DISPLAY		= "Настройки отображения",
	PLAYERFRAME	= "Фрейм игрока",
	TARGETFRAME	= "Фрейм цели",
	PLAYERMODEL	= "3D модель для игроков",
	MOBMODEL	= "3D модель для мобов",
	SHOWGUILD	= "Показ гильдию игрока",
	SHOWCLASS	= "Показ класс цели",
	SHOWBUFFS 	= "Показ (де)баффы",
	SHOWONLYBUFFSCASTBYPLAYER = "Показывать только свои (де)баффы",
	SHOWBUFFTT 	= "Показ подсказки (де)баффов",
	HIDEBUFFTTIC = "Скрыть подсказки (де)баффов в бою",
	BUFFICONSIZE= "Размер иконок (де)баффов",
	SHOWPVP		= "Показ статус PVP игрока",
	SHOWTEXTMAX	= "Show health/power maximum text",
	TOT	        = "Включить цель цели",
	TOTOT		= "Включить цель цели цели",

    NAMEPLATES	= "Настройки индикаторов",
	NPHINT		= "Mouse behavior of nameplates is configured here. Their visibility can be changed under 'Display Options'.",
	NPPLAYEROPT = "Игрок",
	NPPLAYER	= "Игрок",
	NPPET		= "Питомец",
	HOVERMSG	= "Зависание сообщения индикатора",
	HOVERDELAY	= "Задержка зависания индикатора",
	NPTARGETOPT = "Цели",
	NPTARGET	= "Цель",
	NPTOT		= "Цель цели",
	NPTOTOT		= "Цель цели цели",
	NPCOMBAT	= "Включить индикаторы в бою",
	
	COMBOPOINTS = "Настройки приёмов в серии",
	COMBOPOINTSSETTINGS1 = "Combo points settings have been moved to the combo points arc settings. These are now available for many secondary power arcs such as Holy Power, Soul Shards etc. (see respective power arc settings).",
	COMBOPOINTSSETTINGS2 = "These combo points settings used to control whether a huge number is displayed in the center of ArcHUD representing the respective player power.",
	-- deprecated: SHOWCOMBO	= "Показ текст приёмов в серии",
	-- deprecated: COMBODECAY	= "Задержка затухания",
	-- deprecated: HOLYPOWERCOMBO = "Энергия Света как приемы в серии",
	-- deprecated: SOULSHARDCOMBO = "Осколки душ как приемы в серии",
	-- deprecated: CHICOMBO 	= "Show Chi as combo points",
	-- deprecated: RUNECOMBO 	= "Show Runes as combo points",
	-- deprecated: SOULFRAGMENTCOMBO = "Show Soul Fragments as combo points",
	-- deprecated: CPCOLOR		= "Цвет приёмов в серии",
	-- deprecated: CPCOLORDECAY = "Цвет уменьшения приёмов в серии",
	RESETCOLORS	= "Сброс окраски",

	FADE		= "Настройки затухания",
	FADE_FULL	= "Когда целый",
	FADE_OOC	= "Вне боя",
	FADE_IC		= "В бою",
	RINGVIS		= "Действие затухания",
	RINGVIS_1	= "FadeFull: Блекнуть когда целый",
	RINGVIS_2	= "FadeOOC: Блекнуть когда покидаете бой",
	RINGVIS_3	= "FadeBoth: Блекнуть когда целый или покидаете бой",	
	
	POSITIONING	= "Позиционирование",
	WIDTH		= "Ширина HUDa",
	YLOC		= "Выравнивание по вертикали",
	XLOC		= "Выравнивание по горизонтали",
	SCALE		= "Масштаб",
	SCALETARGETFRAME = "Scale of Target Frame(s)",
	ATTACHTOP	= "Прикрепить фрейм цели к верху",
	MFUNLOCK	= "Разблокировать перемещение фреймов",
	MFRESET		= "Сброс расположения",
	
	MISC		= "Разные настройки",
	BLIZZPLAYER = "Blizzard фрейм игрока",
	BLIZZTARGET = "Blizzard фрейм цели",
	BLIZZFOCUS  = "Blizzard фрейм фокуса",
	BLIZZSPELLACT_CENTER = "Center Blizzard's spell activation overlays on ArcHUD",
	BLIZZSPELLACT_SCALE = "Scale of spell activation overlays",
	BLIZZSPELLACT_OPAC = "Opacity of spell activation overlays",

	RINGS		= "Опции дуги",
	RING		= "Дуга",
}

L["TOOLTIP"] = {
	PROFILES_SELECT = "Select a profile for this character.",
	PROFILES_CREATE = "Create a new profile based on the current profile and activate it.",
	PROFILES_DELETE = "Delete current profile and set default profile as active one.",

	PLAYERFRAME	= "Вкл/Выкл отображение индикатора игрока и питомца",
	TARGETFRAME = "Вкл/Выкл отображение фрейма цели",
	PLAYERMODEL = "Вкл/Выкл отображение 3D модели игроков",
	MOBMODEL	= "Вкл/Выкл отображение 3D модели мобов",
	SHOWGUILD	= "Отображать информацию о гильдии игрока рядом с его именем",
	SHOWCLASS	= "Отображать класс цели или тип создания",
	SHOWBUFFS	= "Вкл/Выкл отображение баффов/дебаффов",
	SHOWONLYBUFFSCASTBYPLAYER = "Показывать (де)баффы наложенные вами. 'Показ (де)баффов' должен быть включен.",
	SHOWBUFFTT 	= "Вкл/Выкл отображение подсказок баффов/дебаффов",
	HIDEBUFFTTIC = "Вкл/Выкл отображение подсказок баффов/дебаффов в бою",
	BUFFICONSIZE= "Размер иконки (де)баффов в пикселях",
	SHOWPVP		= "Вкл/Выкл отображение стутуса, метки PVP на индикаторе игрока",
	SHOWTEXTMAX	= "Toggle display of health/power maximum text",
	TOT	        = "Включить отображение цели цели",
	TOTOT		= "Включить отображение цели цели цели",

	NPPLAYER	= "Вкл/Выкл кликабельность имен игроков"..
		"NOTE: This option only takes effect if the Player Frame is visible (see Display Options).\n\n"..
		"The player nameplate's state cannot be changed in combat due to UI restrictions. "..
		"Thus, it cannot be activated in combat by hovering over them, or it will remain activated if active upon entering combat.",
	NPPET		= "Вкл/Выкл кликабельность имен питомцев"..
		"NOTE: This option only takes effect if the Player Frame is visible (see Display Options).\n\n"..
		"The pet nameplate's state cannot be changed in combat due to UI restrictions. "..
		"Thus, it cannot be activated in combat by hovering over them, or it will remain activated if active upon entering combat.",
	NPTARGET	= "Вкл/Выкл кликабельность имен целей",
	NPTOT		= "Вкл/Выкл кликабельность имен целей целей",
	NPTOTOT		= "Вкл/Выкл кликабельность имен целей целей цели",
	NPCOMBAT	= "Вкл/Выкл кликабельность имен при началебоя",
	HOVERMSG	= "Вкл/Выкл отображение имен при активном вводе в чате",
	HOVERDELAY	= "Значение в секундах, необходимое для зависания вверху имени до активации",
	
	SHOWCOMBO	= "Вкл/Выкл отображение приемов в серии в центре HUDа",
	COMBODECAY	= "Установите задержку в секундах перед тем как приёмы серии на предыдущей цели изчезнут (для отклучения этой функции установите значение на 0)",
	HOLYPOWERCOMBO = "Вкл/Выкл отображение очков Энергии Света как приёмов в серии (Приёмы в серии должны быть включены)",
	SOULSHARDCOMBO = "Вкл/Выкл отображение Осколков душ как приёмов в серии (Приёмы в серии должны быть включены)",
	CHICOMBO 	= "Toggle display of Chi as combo points (combo points must be turned on)",
	RUNECOMBO 	= "Toggle display of Deathnight's Runes as combo points (combo points must be turned on)",
	SOULFRAGMENTCOMBO = "Toggle display of Demon Hunter's Soul Fragments as combo points (combo points must be turned on)",
	CPCOLOR		= "Установка цвета текста приёмов в серии",
	CPCOLORDECAY = "Установка цвета уменьшения приёмов в серии",
	RESETCOLORS	= "Сброс окраски на цвета по умолчанию",

	FADE_FULL	= "Прозрачность затухания когда в не боя и дуга на 100%",
	FADE_OOC	= "Прозрачность затухания когда в не боя и дуга НЕ на 100%",
	FADE_IC		= "Прозрачность затухания когда в бою (используется только если действие установленно на FadeBoth или FadeOOC)",
	RINGVIS		= "Устанавливает когда дуги будут затухать:\n" ..
				  "Fade Full: затухание дуг когда они полны, внезависимости от состояния боя\n" ..
				  "Fade OOC: всегда затухают при выходе из боя, внезависимости от состояния дуги\n" ..
				  "Fade both: затухание дуг когда они полны и при выходе из боя (по умолчанию)",
	RINGVIS_1	= "Затухать когда дуги целые, не обращающий внимания на статус боя",
	RINGVIS_2	= "Всегда затухать когда вне боя, не обращающий внимания на статус дуг",
	RINGVIS_3	= "Затухать когда вне боя или дуги целые (по умолчанию)",

	WIDTH		= "Устанавливает, на сколько дуги должны быть отделены от центра",
	YLOC		= "Позиция ArcHUDа вдоль Y-оси. Положительная величина двигает вверх, отрицательная величина вних",
	XLOC		= "Позиция ArcHUDа вдоль X-оси. Положительная величина двигает вправо, отрицательная величина влево",
	SCALE		= "Устанавливает множитель масштаба",
	SCALETARGETFRAME = "Set scaling factor of Target Frame(s). This factor is relative to the overall scaling factor above.",
	ATTACHTOP	= "Прикрепить фрейм цели к верху дуги вместо низа",
	MFUNLOCK	= "Позволяет перемещать фреймы",
	MFRESET		= "Сброс расположения перемещаемых фреймов",
	
	BLIZZPLAYER = "Вкл/Выкл отображение Blizzardского фрейма игрока",
	BLIZZTARGET = "Вкл/Выкл отображение Blizzardского фрейма цели",
	BLIZZFOCUS  = "Вкл/Выкл отображение Blizzardского фрейма фокуса",
	BLIZZSPELLACT_CENTER = "Toggles whether Blizzard's spell activation overlays are centered on ArcHUD or on the screen",
	BLIZZSPELLACT_SCALE = "Sets the scaling factor of Blizzard's spell activation overlays",
	BLIZZSPELLACT_OPAC = "Sets opacity of Blizzard's spell activation overlays.",

}


-- Modules
local LM = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Module", "ruRU")

LM["FONT"]			= "FRIZQT___CYR.TTF"

LM["Version"]	= "Версия: "
LM["Authors"]	= "Авторы: "

LM["Health"]		= "Здоровье игрока"
LM["Power"]			= "Энергия игрока"
LM["PetHealth"]		= "Здоровье питомца"
LM["PetPower"]		= "Энергия питомца"
LM["TargetCasting"]	= "Применение цели"
LM["TargetHealth"]	= "Здоровье цели"
LM["TargetPower"]	= "Энергия цели"
LM["FocusCasting"]	= "Focus Casting"
LM["FocusHealth"]	= "Здоровье фокуса"
LM["FocusPower"]	= "Энергия фокуса"
LM["Casting"]		= "Применение"
LM["MirrorTimer"]	= "Таймер зеркала"
LM["ComboPoints"]	= "Rogue: Пиемы в серии"
LM["ComboPointsDruid"] = "Druid: Пиемы в серии"
LM["HolyPower"]		= "Paladin: Энергия Света"
LM["SoulShards"]	= "Warlock: Осколки душ"
-- deprecated: LM["Eclipse"]		= "Druid: Eclipse"
LM["Chi"]			= "Monk: Chi"
LM["Stagger"]		= "Monk: Stagger"
LM["Runes"]			= "Death Knight: Runes"
LM["ManaShadowPriest"]	= "Priest: Mana (Shadow Priest)"
LM["ManaBalanceDruid"]	= "Druid: Mana (Balance Druid)"
LM["ManaElementalShaman"]	= "Shaman: Mana (Elemental/Enhancement Shaman)"
LM["ArcaneCharges"]	= "Mage: Arcane Charges"

LM["TEXT"] = {
	TITLE		= "Настройки модуля",

	ENABLED		= "Включен",
	OUTLINE		= "Контур дуги",
	SHOWTEXT	= "Показ текста",
	SHOWTEXTMAX	= "Show maximum",
	SHOWPERC	= "Показ проценты",
	FLASH		= "Вспышка при макс приемов в серии",
	FLASH_HP	= "Flash when 3 Holy Power are gained",
	SHOWSPELL	= "Показ применение заклинания",
	SHOWTIME	= "Показ таймера заклинаний",
	INDINTERRUPT= "Подсвечивать прерываемые заклинания",
	INDLATENCY  = "Индикатор задержки",
	INDSPELLQ   = "Indicate spell queue time limit",
	HIDEBLIZZ	= "Скрыть стандартные фреймы Blizzard",
	ENABLEMENU	= "Включить меню по [правому-клику]",
	DEFICIT		= "Нехватка",
	INCOMINGHEALS= "Indicate incoming heals",
	SHOWABSORBS = "Show absorbs",
	ATTACH		= "Прикрепления",
	SIDE		= "Сторона",
	LEVEL		= "Уровень",
	
	SEPARATORS  = "Show separators",
	SWAPHEALTHPOWERTEXT = "Swap health and power text display",
	
	COLOR		= "Цвет дуги",
	COLORRESET	= "Сброс цвета",
	COLORFADE	= "Цвет затухания",
	COLORCUST	= "Пользовательский цвет",
	COLORSET	= "Цвет дуги",
	COLORSETFADE= "Цвет дуги",
	COLORFRIEND = "Цвет дружественного дуги",
	COLORFOE	= "Цвет вражеского дуги",
	COLORMANA 	= "Цвет маны",
	COLORRAGE	= "Цвет ярости",
	COLORFOCUS 	= "Цвет фокуса",
	COLORENERGY	= "Цвет энергии",
	COLORRUNIC	= "Цвет руническо энергии",

	-- deprecated: COLORLUNAR	= "Lunar power color",
	-- deprecated: COLORSOLAR	= "Solar power color",
	
	STAGGER_MAX = "Maximum value (in max. health %)",
	COLORSTAGGERL = "Color for Light Stagger",
	COLORSTAGGERM = "Color for Moderate Stagger",
	COLORSTAGGERH = "Color for Heavy Stagger",

	SORTRUNES   = "Sort Runes",
	
	INNERANCHOR = "Attach ring to inner ('pet') anchor",
	
	CUSTOM		= "Свои баффы",
	CUSTNEW		= "Новая своя дуга",
	CUSTRING	= "Настройки дуги",
	
	CUSTDEBUFF	= "Дебафф",
	CUSTUNIT	= "Объект",
	CUSTNAME	= "Название (Де)Баффа",
	CUSTCASTBYPLAYER = "Показать только ваши (де)баффы",
	CUSTSTACKS	= "Исп. устройство",
	CUSTTEXTSTACKS = "Вид устройства",
	CUSTMAX		= "Сумма",
	CUSTMAXVALIDATE= "Maximum value must be >= 1.",
	CUSTDEL		= "Удалить",
}

LM["TOOLTIP"] = {
	ENABLED		= "Вкл/Выкл дугу",
	OUTLINE		= "Вкл/Выкл контур дуги",
	SHOWTEXT	= "Вкл/Выкл отображение текста (здоровье, мана, и т.д.)",
	SHOWTEXTMAX	= "Toggle text display of maximum value",
	SHOWPERC	= "Вкл/Выкл отображение процентов",
	SHOWTEXTHUGE = "Toggle huge text display in the center of ArcHUD (formerly known as 'combo points')",
	SHOWSPELL	= "Вкл/Выкл отображение нечало применения текущего заклинание",
	SHOWTIME	= "Вкл/Выкл отображение таймера заклинания",
	INDINTERRUPT= "Подсвечивать заклинания которые можно сбить. Дуга будет желтого цвета если каст можно сбить. Дуга каста должна быть включена.",
	INDLATENCY  = "Отображать текущую задержку мира. Добавляет к времени применения время задержки если включено.",
	INDSPELLQ   = "Добавляет к времени каста задержку (при лагах). Это должно помочь при задержках вовремя индексировать для последующего удара. Добавить к задержке если включено.",
	FLASH		= "Вкл/Выкл отображение вспышки когда достигнуто макс приемов в серии",
	FLASH_HP	= "Toggle flashing when 3 Holy Power are gained",
	HIDEBLIZZ	= "Вкл/Выкл отображение стандартных фреймов Blizzardа",
	ENABLEMENU	= "Вкл/Выкл отображение меню по [правому-клику]",
	DEFICIT		= "Вкл/Выкл нехватку здоровья (Макс здоровья - текущее здоровья)",
	INCOMINGHEALS= "Toggle indication of incoming heals",
	SHOWABSORBS = "Toggle display of active absorbs",
	SIDE		= "Установка к какой стороне прикрепить",
	LEVEL		= "Установка на коком уровне прикреплять, отображать по отношению якоря (<-1: по направлению к центру, 0: at anchor, >1: в сторону от центра)",
	
	SEPARATORS  = "Toggle separators (only for maximum ring values between 2 and 20)",
	SWAPHEALTHPOWERTEXT = "Swaps health and power text display so that power text is displayed left and health text displayed right",

	COLOR		= "Настройки окраски дуг:\n"..
					"Color fading: Установка затухания цвета дуги (для здоровья, зеленый -> красный)\n"..
					"Custom color: Установка цвета дуги на пользовательские цвета",
	COLORRESET	= "Сброс цвета на стандартный цвет дуги",
	COLORFADE	= "Цвет дуги затухания (для здоровья зеленый или красный)",
	COLORCUST	= "Установка пользовательского цвета дуги",
	COLORSET	= "Установка пользовательского цвета дуги",
	COLORSETFADE= "Установка цвета пользовательскоq дуги (режим цвета должен быть установлен на \"custom\")",
	COLORFRIEND	= "Установка пользовательского цвета дружелюбной дуги",
	COLORFOE	= "Установка пользовательского цвета вражеской дуги",
	COLORMANA	= "Установка пользовательского цвета дуги маны",
	COLORRAGE	= "Установка пользовательского цвета дуги ярости",
	COLORFOCUS	= "Установка пользовательского цвета дуги фокуса",
	COLORENERGY	= "Установка пользовательского цвета дуги энергии",
	COLORRUNIC	= "Установка пользовательского цвета дуги рунической энергии",
	COLORABSORBS = "Set custom ring color for active absorbs",
	
	STAGGER_MAX = "Maximum ring value in percentage of maximum health",
	COLORSTAGGERL = "Change ring color for Light Stagger",
	COLORSTAGGERM = "Change ring color for Moderate Stagger",
	COLORSTAGGERH = "Change ring color for Heavy Stagger",

	SORTRUNES   = "Sort the Runes according to their status",
	
	INNERANCHOR = "If selected, attach ring to inner ('pet') anchor. If not, use normal (outer) anchors.",
	
	CUSTNEW		= "Создать новую пользовательскую дугу для специфических баффов или дебаффов",
	CUSTDEBUFF	= "Поиск дебаффов вместо баффов",
	CUSTUNIT	= "Объект наблюдения (де)баффов",
	CUSTNAME	= "Название (де)баффа. Multiple (de)buffs can be named by separating them with semicolon (;). Priorities are given according to their order here.",
	CUSTCASTBYPLAYER = "Показать только если (де)бафф произнесен вами",
	CUSTSTACKS	= "Use stack applications instead of remaining time for the arc",
	CUSTTEXTSTACKS = "Display stack applications as text instead of remaining time",
	CUSTMAX		= "Максимальный размер суммы (де)бафа. If duration is displayed, a value of '1' means that the initial (de)buff duration is used instead of the value given here.",
	CUSTDEL		= "Удалить эту пользовательскую дугу",
}

LM["SIDE"] = {
	LEFT		= "Якорь слево",
	RIGHT		= "Якорь справо",
}
