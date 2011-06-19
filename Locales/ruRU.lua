------------------------------
----- Translation for ruRU by StingerSoft
local L = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Core", "ruRU")
if not L then return end

-- Core stuff
L["CMD_OPTS_FRAME"]		= "Открывает окно настроек"
L["CMD_OPTS_MODULES"]	= "Открывает окно настроек модуля"
L["CMD_OPTS_CUSTOM"]	= "Открывает окно настроек пользовательского модуля"
L["CMD_OPTS_DEBUG"]		= "Уровень отладки"
L["CMD_OPTS_DEBUG_SET"]	= "Настройка уровня отладки: '%s'"
L["CMD_RESET"]			= "Сброс настроек для данного персонажа на стандартные"
L["CMD_RESET_HELP"]		= "Данная опция позволит вам сбросить все настройки на стандартные.  Чтобы это зделать введите 'CONFIRM'"
L["CMD_RESET_CONFIRM"]	= "Данная опция сбросит все настройки на стандартные на те что были установлены при установке аддона"
L["TEXT_RESET"]			= "Пожалуйста введите CONFIRM после команды, для потверждения того что вы согласны сбросить все настройки"
L["TEXT_RESET_CONFIRM"]	= "Все настройки будут сброшены на стандартные"

L["FONT"]				= "FRIZQT__.TTF"

L["Version"]		= "Версия: "
L["Authors"]		= "Автор: "

--	Options
L["TEXT"] = {
	TITLE		= "Настройки ArcHUD3",
	GENERAL		= "Основные настройки",

	DISPLAY		= "Настройки отображения",
	PLAYERFRAME	= "Фрейм игрока",
	TARGETFRAME	= "Фрейм цели",
	PLAYERMODEL	= "3D модель для игроков",
	MOBMODEL	= "3D модель для мобов",
	SHOWGUILD	= "Показ гильдию игрока",
	SHOWCLASS	= "Показ класс цели",
	SHOWBUFFS 	= "Показ (де)баффы",
	SHOWONLYBUFFSCASTBYPLAYER = "Show only your (de)buffs",
	SHOWBUFFTT 	= "Показ подсказки (де)баффов",
	HIDEBUFFTTIC = "Скрыть подсказки (де)баффов в бою",
	SHOWPVP		= "Показ статус PVP игрока",
	TOT	        = "Включить цель цели",
	TOTOT		= "Включить цель цели цели",

    NAMEPLATES	= "Настройки индикаторов",
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
	SHOWCOMBO	= "Показ текст приёмов в серии",
	COMBODECAY	= "Задержка затухания",
	HOLYPOWERCOMBO = "Энергия Света как приемы в серии",
	SOULSHARDCOMBO = "Осколки душ как приемы в серии",
	CPCOLOR		= "Цвет приёмов в серии",
	CPCOLORDECAY = "Цвет уменьшения приёмов в серии",
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
	ATTACHTOP	= "Прикрепить фрейм цели к верху",
	MFUNLOCK	= "Разблокировать перемещение фреймов",
	MFRESET		= "Сброс расположения",
	
	MISC		= "Разные настройки",
	BLIZZPLAYER = "Blizzard фрейм игрока",
	BLIZZTARGET = "Blizzard фрейм цели",
	BLIZZFOCUS  = "Blizzard фрейм фокуса",

	RINGS		= "Опции дуги",
	RING		= "Дуга",
}

L["TOOLTIP"] = {
	PLAYERFRAME	= "Вкл/Выкл отображение индикатора игрока и питомца",
	TARGETFRAME = "Вкл/Выкл отображение фрейма цели",
	PLAYERMODEL = "Вкл/Выкл отображение 3D модели игроков",
	MOBMODEL	= "Вкл/Выкл отображение 3D модели мобов",
	SHOWGUILD	= "Отображать информацию о гильдии игрока рядом с его именем",
	SHOWCLASS	= "Отображать класс цели или тип создания",
	SHOWBUFFS	= "Вкл/Выкл отображение баффов/дебаффов",
	SHOWONLYBUFFSCASTBYPLAYER = "Show (de)buffs only if cast by you. 'Показ (де)баффы' must be enabled.",
	SHOWBUFFTT 	= "Вкл/Выкл отображение подсказок баффов/дебаффов",
	HIDEBUFFTTIC = "Вкл/Выкл отображение подсказок баффов/дебаффов в бою",
	SHOWPVP		= "Вкл/Выкл отображение стутуса, метки PVP на индикаторе игрока",
	TOT	        = "Включить отображение цели цели",
	TOTOT		= "Включить отображение цели цели цели",

	NPPLAYER	= "Вкл/Выкл кликабельность имен игроков"..
		"The player nameplate's state cannot be changed in combat due to UI restrictions. "..
		"Thus, it cannot be activated in combat by hovering over them, or it will remain activated if active upon entering combat.",
	NPPET		= "Вкл/Выкл кликабельность имен питомцев"..
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
	ATTACHTOP	= "Прикрепить фрейм цели к верху дуги вместо низа",
	MFUNLOCK	= "Позволяет перемещать фреймы",
	MFRESET		= "Сброс расположения перемещаемых фреймов",
	
	BLIZZPLAYER = "Вкл/Выкл отображение Blizzardского фрейма игрока",
	BLIZZTARGET = "Вкл/Выкл отображение Blizzardского фрейма цели",
	BLIZZFOCUS  = "Вкл/Выкл отображение Blizzardского фрейма фокуса",

}


-- Modules
local LM = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Module", "ruRU")

LM["FONT"]			= "FRIZQT__.TTF"

LM["Version"]	= "Версия: "
LM["Authors"]	= "Авторы: "

LM["Health"]		= "Здоровье игрока"
LM["Power"]			= "Энергия игрока"
LM["PetHealth"]		= "Здоровье питомца"
LM["PetPower"]		= "Энергия питомца"
LM["TargetCasting"]	= "Применение цели"
LM["TargetHealth"]	= "Здоровье цели"
LM["TargetPower"]	= "Энергия цели"
LM["FocusHealth"]	= "Здоровье фокуса"
LM["FocusPower"]	= "Энергия фокуса"
LM["Casting"]		= "Применение"
LM["DruidMana"]		= "Мана друида"
LM["MirrorTimer"]	= "Таймер зеркала"
LM["ComboPoints"]	= "Пиемы в серии"
LM["EnergyTick"]	= "Такт энергии"
LM["HolyPower"]		= "Энергия Света"
LM["SoulShards"]	= "Осколки душ"
LM["CustomBuff"]	= "Свои баффы" -- TODO: to be removed

LM["TEXT"] = {
	TITLE		= "Настройки модуля",

	ENABLED		= "Включен",
	OUTLINE		= "Контур дуги",
	SHOWTEXT	= "Показ текста",
	SHOWPERC	= "Показ проценты",
	FLASH		= "Вспышка при макс приемов в серии",
	SHOWSPELL	= "Показ применение заклинания",
	SHOWTIME	= "Показ таймера заклинаний",
	INDINTERRUPT= "Подсвечивать прерываемые заклинания",
	INDLATENCY  = "Индикатор задержки",
	INDSPELLQ   = "Indicate spell queue time limit",
	HIDEBLIZZ	= "Скрыть стандартные фреймы Blizzard",
	ENABLEMENU	= "Включить меню по [правому-клику]",
	DEFICIT		= "Нехватка",
	SHOWINCOMBAT= "Показ в бою",
	SHOWINSTEALTH="Показ при скрытности",
	ATTACH		= "Прикрепления",
	SIDE		= "Сторона",
	LEVEL		= "Уровень",
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
	ATTACHRING	= "Отсоединить дугу",

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
	CUSTDEL		= "Удалить",
}

LM["TOOLTIP"] = {
	ENABLED		= "Вкл/Выкл дугу",
	OUTLINE		= "Вкл/Выкл контур дуги",
	SHOWTEXT	= "Вкл/Выкл отображение текста (здоровье, мана, и т.д.)",
	SHOWPERC	= "Вкл/Выкл отображение процентов",
	SHOWSPELL	= "Вкл/Выкл отображение нечало применения текущего заклинание",
	SHOWTIME	= "Вкл/Выкл отображение таймера заклинания",
	INDINTERRUPT= "Toggle highlighting of interruptable spells. The casting arc will have a yellow outline for interruptable spells. Arc outline needs to be activated.",
	INDLATENCY  = "Toggle indication of current world latency. Adds with spell queue time limit if selected.",
	INDSPELLQ   = "Toggle indication of spell queue time limit (lag tolerance). It should be safe to start casting the next spell once the current cast passes the indicator. Adds with latency if selected.",
	FLASH		= "Вкл/Выкл отображение вспышки когда достигнуто макс приемов в серии",
	HIDEBLIZZ	= "Вкл/Выкл отображение стандартных фреймов Blizzardа",
	ENABLEMENU	= "Вкл/Выкл отображение меню по [правому-клику]",
	DEFICIT		= "Вкл/Выкл нехватку здоровья (Макс здоровья - текущее здоровья)",
	SHOWINCOMBAT= "Вкл/Выкл отображение тиков в бою",
	SHOWINSTEALTH="Вкл/Выкл отображение тиков во время Незаметности",
	SIDE		= "Установка к какой стороне прикрепить",
	LEVEL		= "Установка на коком уровне прикреплять, отображать по отношению якоря (<-1: по направлению к центру, 0: at anchor, >1: в сторону от центра)",
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
	ATTACHRING	= "Вкл/Выкл прикрепление дуги к обычному якорю фрейма (будет вести себя как обычная дуга при активности)",
	
	CUSTNEW		= "Создать новую пользовательскую дугу для специфических баффов или дебаффов",
	CUSTDEBUFF	= "Поиск дебаффов вместо баффов",
	CUSTUNIT	= "Объект наблюдения (де)баффов",
	CUSTNAME	= "Название (де)баффа",
	CUSTCASTBYPLAYER = "Показать только если (де)бафф произнесен вами",
	CUSTSTACKS	= "Use appliances instead of remaining time for the arc",
	CUSTTEXTSTACKS = "Display appliances as text instead of remaining time",
	CUSTMAX		= "Максимальный размер суммы (де)бафа",
	CUSTDEL		= "Удалить эту пользовательскую дугу",
}

LM["SIDE"] = {
	LEFT		= "Якорь слево",
	RIGHT		= "Якорь справо",
}

LM["You gain Prowl."] = "Вы применили: Крадущийся зверь."
LM["Prowl fades from you."] = "Эффект: Крадущийся зверь, закончился."
LM["You gain Stealth."] = "Вы применили: Незаметность."
LM["Stealth fades from you."] = "Эффект: Незаметность, закончился."

