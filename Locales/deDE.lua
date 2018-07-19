------------------------------
----- Translation for deDE
----- based upon ArcHUD2 translations from Gamefaq and cy.raptor
------------------------------
local L = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Core", "deDE")
if not L then return end

-- Core stuff
L["CMD_OPTS_FRAME"]		= "Optionsfenster öffnen"
L["CMD_OPTS_MODULES"]	= "Moduloptionsfenster öffnen"
L["CMD_OPTS_CUSTOM"]	= "Optionsfenster für benutzerdefinierte Ringe öffnen"
L["CMD_OPTS_TOGGLE"]	= "Zeige/verstecke ArcHUD"
L["CMD_OPTS_DEBUG"]		= "Setze Debug-Level"
L["CMD_OPTS_DEBUG_SET"]	= "Setze Debug-Level auf '%s'"
L["CMD_RESET"]			= "Einstellungen auf Grundeinstellung zurücksetzen"
L["CMD_RESET_HELP"]		= "Diese Option wird dir erlauben, deine Einstellungen auf die Grundeinstellung zurückzusetzen. Um dies zu tun tippe 'CONFIRM' hinter der Option ein."
L["CMD_RESET_CONFIRM"]	= "Diese Option wird alle Einstellunegn auf die Grundeinstellung zurücksetzen."
L["TEXT_RESET"]			= "Bitte Tippe CONFIRM hinter diesem Befehl ein, um zu bestätigen, dass du wirklich die Einstellungen zurücksetzen willst."
L["TEXT_RESET_CONFIRM"]	= "Alle Einstellungen wurden auf die Grundeinstellung zurückgesetzt."
L["TEXT_ENABLED"]       = "ArcHUD wurde aktiviert."
L["TEXT_DISABLED"]      = "ArcHUD wurde deaktiviert."

L["FONT"]				= "FRIZQT__.TTF"

L["Version"]		= "Version"
L["Authors"]		= "Autoren"

--	Options
L["TEXT"] = {
	TITLE		= "ArcHUD3 Optionen",
	GENERAL		= "Allgemeine Einstellungen",
	
	PROFILES	= "Profile",
	PROFILES_SELECT= "Profilauswahl",
	PROFILES_CREATE= "Erstelle neues Profil",
	PROFILES_DELETE= "Lösche Profil",
	PROFILES_CANNOTDELETE= "Das Hauptprofil kann nicht gelöscht werden.",
	PROFILES_DEFAULT= "Hauptprofil",
	PROFILES_EXISTS= "Ein Profil mit diesem Namen existiert bereits.",
	
	DISPLAY		= "Anzeige",
	PLAYERFRAME	= "Spielernamen-Rahmen",
	TARGETFRAME	= "Zieleinheiten-Rahmen",
	PLAYERMODEL	= "3D Modell für Spieler",
	MOBMODEL	= "3D Modell für NSCs",
	SHOWGUILD	= "Zeige Gildennamen des Spielers",
	SHOWCLASS	= "Zeige Klasse des Ziels",
	SHOWBUFFS 	= "Zeige (De-)Buffs",
	SHOWONLYBUFFSCASTBYPLAYER = "Zeige nur eigene (De-)Buffs",
	SHOWBUFFTT 	= "Zeige (De-)Buff-Tooltips",
	HIDEBUFFTTIC= "Verstecke (De-)Buff-Tooltips im Kampf",
	BUFFICONSIZE= "(De-)Buff-Größe",
	SHOWPVP		= "Zeige Spieler-PvP-Status",
	SHOWTEXTMAX	= "Zeige Maximalgesundheit/-energie",
	TOT			= "Aktiviere Ziel des Ziels",
	TOTOT		= "Aktiviere Ziel des Ziel-des-Ziels",

	NAMEPLATES	= "Namensplaketten",
	NPHINT		= "Hier kann das Mausverhalten der Namensplaketten konfiguriert werden. Die Sichtbarkeit kann unter 'Anzeige-Optionen' eingestellt werden.",
	NPPLAYEROPT = "Spieler",
	NPPLAYER	= "Spieler",
	NPPET		= "Begleiter",
	HOVERMSG	= "MouseOver-Nachricht anzeigen",
	HOVERDELAY	= "MouseOver-Verzögerung",
	NPTARGETOPT = "Ziele",
	NPTARGET	= "Ziel",
	NPTOT		= "Ziel des Ziels",
	NPTOTOT		= "Ziel des Ziel-des-Ziels",
	NPCOMBAT	= "Aktiviere Namensplaketten im Kampf",
	
	COMBOPOINTS = "Kombopunkte",
	COMBOPOINTSSETTINGS1 = "Combo points settings have been moved to the combo points arc settings. These are now available for many secondary power arcs such as Holy Power, Soul Shards etc. (see respective power arc settings).",
	COMBOPOINTSSETTINGS2 = "These combo points settings used to control whether a huge number is displayed in the center of ArcHUD representing the respective player power.",
	-- deprecated: SHOWCOMBO	= "Zeige Kombopunkte-Text",
	-- deprecated: COMBODECAY	= "Verfall-Verzögerung",
	-- deprecated: HOLYPOWERCOMBO = "Zeige Heilige Kraft als Kombopunkte",
	-- deprecated: SOULSHARDCOMBO = "Zeige Seelensplitter als Kombopunkte",
	-- deprecated: CHICOMBO 	= "Zeige Chi als Kombopunkte",
	-- deprecated: RUNECOMBO 	= "Zeige Runen als Kombopunkte",
	-- deprecated: SOULFRAGMENTCOMBO = "Zeige Seelenfragmente als Kombopunkte",
	-- deprecated: CPCOLOR		= "Farbe der Kombopunkte",
	-- deprecated: CPCOLORDECAY = "Farbe verfallender Kombopunkte",
	RESETCOLORS	= "Farben zurücksetzen",

	FADE		= "Fading",
	FADE_FULL	= "Wenn voll",
	FADE_OOC	= "Außerhalb des Kampfes",
	FADE_IC		= "Im Kampf",
	RINGVIS		= "Fading-Verhalten",
	RINGVIS_1	= "Fade Full: Wenn voll",
	RINGVIS_2	= "Fade OOC: Außerhalb des Kampfes",
	RINGVIS_3	= "Fade Both: Wenn voll oder außerhalb des Kampfes (Standard)",
	
	POSITIONING	= "Positionierung / Größe",
	WIDTH		= "Breite des HUD",
	YLOC		= "Vertikale Ausrichtung",
	XLOC		= "Horizontale Ausrichtung",
	SCALE		= "Skalierung",
	SCALETARGETFRAME = "Skalierung der Zielrahmen",
	ATTACHTOP	= "Zieleinheitenfenster oben befestigen",
	MFUNLOCK	= "Bewegbare Rahmen entsperren",
	MFRESET		= "Positionen zurücksetzen",
	
	MISC		= "Verschiedenes",
	BLIZZPLAYER = "Blizzard Spielereinheitenfenster sichtbar",
	BLIZZTARGET = "Blizzard Zieleinheitenfenster sichtbar",
	BLIZZFOCUS  = "Blizzard Fokuszieleinheitenfenster sichtbar",
	BLIZZSPELLACT_CENTER = "Zentriere Zauberspruchaktivierungsanzeige",
	BLIZZSPELLACT_SCALE = "Skalierung der Zauberspruchaktivierungsanzeige",
	BLIZZSPELLACT_OPAC = "Deckkraft der Zauberspruchaktivierungsanzeige",

	RINGS		= "Ringoptionen",
	RING		= "Ring",
}

L["TOOLTIP"] = {
	PROFILES_SELECT = "Wählt ein Profil für diesen Charakter.",
	PROFILES_CREATE = "Erstellt ein neues Profil basierend auf dem aktuellen und aktiviert es.",
	PROFILES_DELETE = "Löscht das aktuelle Profil und aktiviert das Hauptprofil.",

	PLAYERFRAME	= "Schaltet Anzeige der Spieler/Begleiter-Namen ein/aus.\nHINWEIS: Mausverhalten kann unter 'Namensplaketten' eingestellt werden.",
	TARGETFRAME = "Schaltet Anzeige der Zieleinheiten-Rahmen ein/aus.\nHINWEIS: Mausverhalten kann unter 'Namensplaketten' eingestellt werden.",
	PLAYERMODEL = "Schaltet Anzeige von 3D-Spielermodellen ein/aus",
	MOBMODEL	= "Schaltet Anzeige von 3D-NSC-Modellen ein/aus",
	SHOWGUILD	= "Schaltet Anzeige von Spieler-Gildenzugehörigkeit ein/aus",
	SHOWCLASS	= "Schaltet Anzeige von Zielklasse oder Kreaturentyp ein/aus",
	SHOWBUFFS	= "Schaltet Anzeige von Buffs/Debuffs ein/aus",
	SHOWONLYBUFFSCASTBYPLAYER = "Zeige nur (De-)Buffs, die von Euch gecastet wurden. 'Zeige (De-)Buffs' muss aktiviert sein.",
	SHOWBUFFTT 	= "Schaltet Anzeige von Buff/Debuff-Tooltips ein/aus",
	HIDEBUFFTTIC = "Schaltet Anzeige von Buff/Debuff-Tooltips im Kampf ein/aus",
	BUFFICONSIZE= "Setzt die Größe des (De-)Buff-Piktogramms in Pixel",
	SHOWPVP		= "Schaltet Anzeige des PvP-Status am Spieler-Namensschild ein/aus",
	SHOWTEXTMAX	= "Schaltet Anzeige der Maximalgesundheit/-energie ein/aus",
	TOT			= "Schaltet Anzeige des Ziel des Ziels ein/aus",
	TOTOT		= "Schaltet Anzeige des Ziel des Ziel-des-Ziels ein/aus",

	NPPLAYER	= "(De-)Aktiviert Interaktion mit Spieler-Namensschild.\n"..
		"HINWEIS: Diese Option hat nur einen Effekt, wenn der Spielernamen-Rahmen angezeigt wird (siehe Anzeige-Optionen).\n\n"..
		"Der Interaktionsstatus kann im Kampf nicht geändert werden und verbleibt im Zustand wie er zu Kampfesbeginn war.",
	NPPET		= "(De-)Aktiviert Interaktion mit Begleiter-Namensschild.\n"..
		"HINWEIS: Diese Option hat nur einen Effekt, wenn der Spielernamen-Rahmen angezeigt wird (siehe Anzeige-Optionen).\n\n"..
		"Der Interaktionsstatus kann im Kampf nicht geändert werden und verbleibt im Zustand wie er zu Kampfesbeginn war.",
	NPTARGET	= "(De-)Aktiviert Interaktion mit Ziel-Namensschild.\n"..
		"HINWEIS: Diese Option hat nur einen Effekt, wenn der Zieleinheiten-Rahmen angezeigt wird (siehe Anzeige-Optionen).",
	NPTOT		= "(De-)Aktiviert Interaktion mit Ziel-des-Ziels-Namensschild.\n"..
		"HINWEIS: Diese Option hat nur einen Effekt, wenn der Zieleinheiten-Rahmen angezeigt wird (siehe Anzeige-Optionen).",
	NPTOTOT		= "(De-)Aktiviert Interaktion mit Ziel-des-Ziel-des-Ziels-Namensschild.\n"..
		"HINWEIS: Diese Option hat nur einen Effekt, wenn der Zieleinheiten-Rahmen angezeigt wird (siehe Anzeige-Optionen).",
	NPCOMBAT	= "Toggle always enabling clickable nameplates when entering combat", -- TODO: obsolete
	HOVERMSG	= "Schaltet Anzeige einer Chat-Nachricht ein/aus wenn Mauseingabe aktiviert wird",
	HOVERDELAY	= "Anzahl der Sekunden, die die Maus über den Spieler/Begleiter-Namensschildern schweben muss, um diese zu aktivieren",
	
	SHOWCOMBO	= "Schaltet Anzeige von Kombopunkten in der Mitte des HUD ein/aus",
	COMBODECAY	= "Setzt die Anzahl von Sekunden, die vergehen müssen, bis die unverbrauchten Kombopunkte des letzten Ziels verfallen. Ein Wert von 0 deaktiviert dieses Feature.",
	HOLYPOWERCOMBO = "Schaltet Anzeige von Heiliger Kraft (Paladin) als Kombopunkte ein/aus (die Anzeige von Kombopunkten muss aktiviert sein)",
	SOULSHARDCOMBO = "Schaltet Anzeige von Seelensplittern (Hexenmeister) als Kombopunkte ein/aus (die Anzeige von Kombopunkten muss aktiviert sein)",
	CHICOMBO	= "Schaltet Anzeige von Chi (Mönch) als Kombopunkte ein/aus (die Anzeige von Kombopunkten muss aktiviert sein)",
	RUNECOMBO 	= "Schaltet Anzeige von Runen (Todesritter) als Kombopunkte ein/aus (die Anzeige von Kombopunkten muss aktiviert sein)",
	SOULFRAGMENTCOMBO = "Schaltet Anzeige von Seelenfragmenten (Dämonenjäger) als Kombopunkte ein/aus (die Anzeige von Kombopunkten muss aktiviert sein)",
	CPCOLOR		= "Setzt die Textfarbe für Kombopunkte",
	CPCOLORDECAY = "Setzt die Farbe von verfallenden Kombopunkten des letzten Ziels",
	RESETCOLORS	= "Setzt die Farben auf ihre Standardeinstellungen zurück",

	FADE_FULL	= "Alpha-Wert (Transparenz) wenn Ring voll ist und nicht im Kampf",
	FADE_OOC	= "Alpha-Wert (Transparenz) wenn Ring nicht voll ist und nicht im Kampf",
	FADE_IC		= "Alpha-Wert (Transparenz) wenn im Kampf (wird nur verwendet, wenn Fading-Verhalten 'Fade Both' oder 'Fade OOC' ist)",
	RINGVIS		= "Setzt das Fading-Verhalten:\n" ..
				  "Fade Full: Immer ganz verblassen, wenn Ring voll ist\n" ..
				  "Fade OOC: Immer ganz verblassen, wenn nicht im Kampf\n" ..
				  "Fade Both: Verblassen, wenn außerhalb des Kampfes oder Ring voll ist (Standard)",
	RINGVIS_1	= "Immer ganz verblassen, wenn Ring voll ist",
	RINGVIS_2	= "Immer ganz verblassen, wenn nicht im Kampf",
	RINGVIS_3	= "Verblassen, wenn außerhalb des Kampfes oder Ring voll ist (Standard)",

	WIDTH		= "Setzt den Abstand der Ringe zur Mitte des HUDs",
	YLOC		= "Vertikale Position: Positive Werte schieben das HUD nach oben, negative nach unten",
	XLOC		= "Horizontale Position: Positive Werte schieben das HUD nach rechts, negative nach links",
	SCALE		= "Setzt den Skalierungsfaktor",
	SCALETARGETFRAME = "Setzt den Skalierungsfaktor der Zielrahmen relativ zum Gesamtskalierungsfaktor oben.",
	ATTACHTOP	= "Heftet den Zielrahmen überhalb der Ringe an, anstatt unterhalb",
	MFUNLOCK	= "Erlaubt es, die Zieleinheitenfenster frei zu verschieben",
	MFRESET		= "Setzt die Positionen der Zieleinheitenfenster zurück",
	
	BLIZZPLAYER = "Schaltet die Sichtbarkeit des Blizzard-Spieler-Einheitenfensters ein/aus",
	BLIZZTARGET = "Schaltet die Sichtbarkeit des Blizzard-Ziel-Einheitenfensters ein/aus",
	BLIZZFOCUS  = "Schaltet die Sichtbarkeit des Blizzard-Fokusziel-Einheitenfensters ein/aus",
	BLIZZSPELLACT_CENTER = "Zentriert Blizzards Zauberspruchaktivierungssymbole über ArcHUD",
	BLIZZSPELLACT_SCALE = "Setzt den Skalierungsfaktor von Blizzards Zauberspruchaktivierungssymbole.",
	BLIZZSPELLACT_OPAC = "Setzt die Deckkraft von Blizzards Zauberspruchaktivierungssymbole.",
	
}


-- Modules
local LM = LibStub("AceLocale-3.0"):NewLocale("ArcHUD_Module", "deDE")

LM["FONT"]			= "FRIZQT__.TTF"

LM["Version"]	= true
LM["Authors"]	= "Autoren"

LM["Health"]		= "Spieler Gesundheit"
LM["Power"]			= "Spieler Ressource"
LM["PetHealth"]		= "Begleiter Gesundheit"
LM["PetPower"]		= "Begleiter Ressource"
LM["TargetCasting"]	= "Ziel Zauberwirken"
LM["TargetHealth"]	= "Ziel Gesundheit"
LM["TargetPower"]	= "Ziel Ressource"
LM["FocusCasting"]	= "Fokusziel Zauberwirken"
LM["FocusHealth"]	= "Fokusziel Gesundheit"
LM["FocusPower"]	= "Fokusziel Ressource"
LM["Casting"]		= "Spieler Zauberwirken"
LM["MirrorTimer"]	= "Spiegel Timer"
LM["ComboPoints"]	= "Schurke: Kombopunkte"
LM["ComboPointsDruid"]	= "Druide: Kombopunkte"
LM["HolyPower"]		= "Paladin: Heilige Kraft"
LM["SoulShards"]	= "Hexenmeister: Seelensplitter etc."
-- deprecated: LM["Eclipse"]		= "Druide: Finsternis"
LM["Chi"]			= "Mönch: Chi"
LM["Stagger"]		= "Mönch: Staffelung"
LM["Runes"]			= "Todesritter: Runen"
LM["ManaShadowPriest"]	= "Priester: Mana (Schattenpriester)"
LM["ManaBalanceDruid"]	= "Druide: Mana (Gleichgewichtsdruide)"
LM["ManaElementalShaman"]	= "Schamane: Mana (Elementar-/Verstärkerschamane)"
LM["ArcaneCharges"]	= "Magier: Arkane Ladungen"

LM["TEXT"] = {
	TITLE		= "Ringoptionen",

	ENABLED		= "Aktiviert",
	OUTLINE		= "Ringumrandung",
	SHOWTEXT	= "Zeige Text",
	SHOWTEXTMAX	= "Zeige Maximalwert",
	SHOWPERC	= "Zeige Prozente",
	SHOWTEXTHUGE = "Zeige großen Text",
	FLASH		= "Pulsieren wenn Ring voll",
	FLASH_HP	= "Pulsiere wenn 3 Heilige Kraft aktiv sind",
	SHOWSPELL	= "Zeige gewirkten Zauber",
	SHOWTIME	= "Zeige Zauberzeit",
	INDINTERRUPT= "Unterbrechbare Zauber hervorheben",
	INDLATENCY  = "Netzwerklatenz andeuten",
	INDSPELLQ   = "Zauber-Queuing-Zeitfenster andeuten",
	HIDEBLIZZ	= "Verstecke Standard-Blizzard-Rahmen",
	ENABLEMENU	= "Aktiviere Rechts-Klick-Menü",
	DEFICIT		= "Defizit",
	INCOMINGHEALS= "Zeige eintreffende Heilungen",
	SHOWABSORBS = "Zeige Absorptionen",
	ATTACH		= "Anheften",
	SIDE		= "Seite",
	LEVEL		= "Ebene",
	
	SEPARATORS  = "Zeige Trennlinien",
	SWAPHEALTHPOWERTEXT = "Vertausche Gesundheits- und Energie-Text",
	
	COLOR		= "Farbmodus",
	COLORRESET	= "Farben zurücksetzen",
	COLORFADE	= "Farb-Fading",
	COLORCUST	= "Benutzerdef. Farbe",
	COLORSET	= "Ringfarbe",
	COLORSETFADE= "Ringfarbe",
	COLORFRIEND = "Freund-Farbe",
	COLORFOE	= "Gegner-Farbe",
	COLORMANA 	= "Mana-Farbe",
	COLORRAGE	= "Wut-Farbe",
	COLORFOCUS 	= "Fokus-Farbe",
	COLORENERGY	= "Energie-Farbe",
	COLORRUNIC	= "Runenmacht-Farbe",
	COLORABSORBS = "Farbe für Absorptionen",
	
	-- deprecated: COLORLUNAR	= "Farbe Lunarenergie",
	-- deprecated: COLORSOLAR	= "Farbe Solarenergie",
	
	STAGGER_MAX = "Maximum value (in max. health %)",
	COLORSTAGGERL = "Color for Light Stagger",
	COLORSTAGGERM = "Color for Moderate Stagger",
	COLORSTAGGERH = "Color for Heavy Stagger",

	SORTRUNES   = "Runen sortieren",
	
	INNERANCHOR = "Am inneren ('Begleiter') Anker befestigen",
	
	CUSTOM		= "Benutzerdef. Buff-Ring",
	CUSTNEW		= "Neuer benutzerdef. Ring",
	CUSTRING	= "Ringoptionen",
	
	CUSTDEBUFF	= "Debuff",
	CUSTUNIT	= "Einheit",
	CUSTNAME	= "(De)Buff Name",
	CUSTCASTBYPLAYER = "Zeige nur eigene (De)Buffs",
	CUSTSTACKS	= "Benutze Stapelgröße",
	CUSTTEXTSTACKS = "Zeige Stapelgröße als Text",
	CUSTMAX		= "Maximale Größe",
	CUSTMAXVALIDATE= "Die maximale Größe muss >= 1 sein.",
	CUSTDEL		= "Löschen",
}

LM["TOOLTIP"] = {
	ENABLED		= "Schaltet den Ring ein/aus",
	OUTLINE		= "Schaltet die Ringumrandung ein/aus",
	SHOWTEXT	= "Schaltet die Textanzeige ein/aus",
	SHOWTEXTMAX	= "Schaltet die Textanzeige des Maximalwert ein/aus",
	SHOWPERC	= "Schaltet die Prozentanzeige ein/aus",
	SHOWTEXTHUGE = "Schaltet die große Textanzeige in der Mitte von ArcHUD ein/aus",
	SHOWSPELL	= "Schaltet Anzeige des gewirkten Zaubers ein/aus",
	SHOWTIME	= "Schaltet Anzeige der Zauberzeit ein/aus",
	INDINTERRUPT= "Schaltet Hervorhebung von unterbrechbaren Zaubern ein/aus. Der Ring bekommt eine gelbe Umrandung bei unterbrechbaren Zaubern. Die Ringumrandung muss dazu aktiviert sein.",
	INDLATENCY  = "Schaltet Andeutung der aktuellen Netzwerklatenz (Welt) ein/aus. Addiert sich mit dem Zauber-Queuing-Zeitfenster, wenn aktiviert.",
	INDSPELLQ   = "Schaltet Andeutung des Zauber-Queuing-Zeitfensters (Latenztoleranz) ein/aus. Es sollte möglich sein, den nächsten Zauber zu aktivieren, sobald der Marker passiert wurde. Addiert sich mit der Netzwerklatenz, wenn aktiviert.",
	FLASH		= "Schaltet Pulsieren bei vollem Ring ein/aus",
	FLASH_HP	= "Toggle flashing when 3 Holy Power are gained",
	HIDEBLIZZ	= "Schaltet Anzeige des Standard-Blizzard-Rahmens ein/aus",
	ENABLEMENU	= "Schaltet Rechts-Klick-Menü ein/aus",
	DEFICIT		= "Schaltet Anzeige des Gesundheitsdefizits (Maximum - aktueller Wert) ein/aus",
	INCOMINGHEALS= "Schaltet die Anzeige eintreffender Heilungen ein/aus",
	SHOWABSORBS = "Schaltet die Anzeige von Absorptionen ein/aus",
	SIDE		= "Legt die Seite fest, auf welcher der Ring angeheftet werden soll",
	LEVEL		= "Setzt die Ebene, auf der der Ring angeheftet werden soll (<-1: zur Mitte, 0: am Anker, >1: zum Rand)",
	
	SEPARATORS  = "Schaltet Trennlinien ein/aus (nur für Maximalwerte zwischen 2 und 20)",
	SWAPHEALTHPOWERTEXT = "Vertauscht die Gesundheits- und Energietextanzeige, sodass die Energie links und die Gesundheit rechts angezeigt werden",
	
	COLOR		= "Setzt den Farbenmodus:\n"..
					"Farb-Fading: Farbverlauf anhängig vom Füllstand (z.B. von grün nach rot für Gesundheit)\n"..
					"Benutzerdef. Farbe: Setzt die Farbe zu einer benutzerdefinierten Farbe",
	COLORRESET	= "Setzt die Farben auf die Standardfarben zurück",
	COLORFADE	= "Farbverlauf abhängig vom Füllstand (z.B. von grün nach rot für Gesundheit)",
	COLORCUST	= "Benutzerdefinierte Farbe",
	COLORSET	= "Setzt eine benutzerdefinierte Farbe",
	COLORSETFADE= "Setzt eine benutzerdefinierte Farbe (Farbmodus muss auf 'benutzerdefiniert' stehen)",
	COLORFRIEND	= "Setzt eine benutzerdefinierte Farbe für freundliche Einheiten",
	COLORFOE	= "Setzt eine benutzerdefinierte Farbe für feindliche Einheiten",
	COLORMANA	= "Setzt eine benutzerdefinierte Farbe für Mana",
	COLORRAGE	= "Setzt eine benutzerdefinierte Farbe für Wut",
	COLORFOCUS	= "Setzt eine benutzerdefinierte Farbe für Fokus",
	COLORENERGY	= "Setzt eine benutzerdefinierte Farbe für Energie",
	COLORRUNIC	= "Setzt eine benutzerdefinierte Farbe für Runenmacht",
	COLORABSORBS = "Setzt eine benutzerdefinierte Farbe für Absorptionen",
	
	STAGGER_MAX = "Maximumwert des Rings in Prozent der maximalen Trefferpunkte des Spieler-Characters",
	COLORSTAGGERL = "Setzt eine benutzerdefinierte Farbe des Rings bei leichter Staffelung",
	COLORSTAGGERM = "Setzt eine benutzerdefinierte Farbe des Rings bei moderater Staffelung",
	COLORSTAGGERH = "Setzt eine benutzerdefinierte Farbe des Rings bei schwerer Staffelung",

	SORTRUNES   = "Runen nach ihrem Status sortieren",
	
	INNERANCHOR = "Wenn ausgewählt, befestige und skaliere den Ring am inneren ('Begleiter') Anker. Ansonsten befestige den Ring in seiner normalen Größe am äußeren Anker (Standard).",
	
	CUSTNEW		= "Erstellt einen neuen benutzerdefinierten Ring für einen bestimmten Buff oder Debuff",
	CUSTDEBUFF	= "Überwachter Buff ist ein Debuff",
	CUSTUNIT	= "Einheit, auf dem dieser (De)Buff angewendet wird",
	CUSTNAME	= "Name des (De)Buff. Mehrere (De)Buffs können durch Semikolon (;) getrennt angegeben werden. Priorisierung erfolgt in der hier gegebenen Reihenfolge.",
	CUSTCASTBYPLAYER = "Nur anzeigen, wenn (De)Buff vom Spieler gewirkt wird",
	CUSTSTACKS	= "Benutze Stapelgröße für den Ring anstelle der verbleibenden Zeit",
	CUSTTEXTSTACKS = "Zeige Stapelgröße als Text an anstelle der verbleibenden Zeit",
	CUSTMAX		= "Maximale Stapelgröße bzw. Dauer des (De)Buff. Wenn die (De)Buff-Dauer angezeigt wird, bedeutet ein Wert von '1', dass die initiale (De)Buff-Dauer als Maximalwert verwendet wird.",
	CUSTDEL		= "Löscht diesen benutzerdefinierten Ring unwiderruflich",
}

LM["SIDE"] = {
	LEFT		= "Linker Anker",
	RIGHT		= "Rechter Anker",
}
