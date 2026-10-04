LuckyActionbars = LuckyActionbars or {}

LuckyActionbars.Strings = {
    addon = {
        title = "Lucky's Actionbars",
        prefix = "|cffffd100Lucky's Actionbars:|r",
        minimapHints = { "Left-click: Open Edit Mode", "Right-click: Open settings", "Middle-click: Toggle dev mode",
            "Drag: Move button" },
        devModeOn = "Lucky's Actionbars: Dev mode enabled.",
        devModeOff = "Lucky's Actionbars: Dev mode disabled.",
        actionSlot = "Action slot: %d",
    },
    forms = {
        cat = "Cat Form",
        bear = "Bear Form",
        moonkin = "Moonkin Form",
        stealth = "Stealth",
    },
    bars = {
        fade = {
            label = "Hidden until hovered",
            desc = "This bar stays invisible until you point at it\nor drag something to place. Its keybinds\nstill work while it is invisible.",
            descNoKeybinds = "This bar stays invisible until you point at it\nor drag something to place.",
        },
        -- Edit Mode tooltips don't wrap, so these carry their own line breaks.
        flyoutButton = "Show/Hide Action Bars",
        flyoutDesc = "Turn Action Bars 2 to 12 on and off\nfrom a list beside this window.",
        flyoutTitle = "Action Bars",
        pagingButton = "Paging",
        pagingDesc = "Make this bar show another bar's buttons\nwhile you hold a modifier key or change form.",
        pagingTitle = "Action Bar %d Paging",
        -- Blizzard's own strings, so these read exactly like the stock bars' settings in every locale.
        orientation = {
            label = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION,
            horizontal = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL,
            vertical = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL,
        },
        visibility = {
            label = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING,
            always = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS,
            inCombat = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            outOfCombat = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT,
            hidden = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_HIDDEN,
        },
        alwaysShowButtons = HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS,
        rowsGrow = {
            label = "Rows Grow",
            desc = "Which way extra rows stack on a bar with\nmore than one row. Down puts the first\nbutton in the top left corner.",
            up = "Up",
            down = "Down",
        },
        layout = {
            rows = "# of Rows",
            columns = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
            icons = "# of Icons",
            size = "Icon Size",
            padding = "Icon Padding",
        },
        pageUsers = {
            [7] = "Druids use this page for Cat Form and rogues for Stealth.",
            [8] = "No class or form uses this page, so it is free for everyone.",
            [9] = "Druids use this page for Bear Form.",
            [10] = "Druids use this page for Moonkin Form.",
        },
        combatBlocked = "Lucky's Actionbars: action bars can't be shown or hidden in combat.",
        names = {
            [9] = "Action Bar 9",
            [10] = "Action Bar 10",
            [11] = "Action Bar 11",
            [12] = "Action Bar 12",
        },
        buttonName = "%s Button %d",
    },
    bags = {
        backpackOnly = {
            label = "Backpack only",
            desc = "Hide the other bag slots and the arrow\nthat shows them, leaving just the backpack.",
        },
    },
    menu = {
        hiddenButtons = {
            label = "Hidden buttons",
            none = NONE,
            unhideAll = "Unhide all",
            desc = "Pick which buttons to remove from the menu.\nThe rest close up to fill the gap.",
        },
        -- Blizzard's own names for the buttons, so they read the same as their tooltips in every locale.
        buttons = {
            CharacterMicroButton = CHARACTER_BUTTON,
            ProfessionMicroButton = PROFESSIONS_BUTTON,
            PlayerSpellsMicroButton = PLAYERSPELLS_BUTTON,
            AchievementMicroButton = ACHIEVEMENT_BUTTON,
            QuestLogMicroButton = QUESTLOG_BUTTON,
            HousingMicroButton = HOUSING_MICRO_BUTTON,
            GuildMicroButton = GUILD_AND_COMMUNITIES,
            LFDMicroButton = DUNGEONS_BUTTON,
            EJMicroButton = ADVENTURE_JOURNAL,
            CollectionsMicroButton = COLLECTIONS,
            MainMenuMicroButton = MAINMENU_BUTTON,
            StoreMicroButton = BLIZZARD_STORE,
        },
    },
    settings = {
        groups = { whatsNew = "What's New", bars = "Bars", buttons = "Buttons" },
        sections = { paging = "Paging", fade = "Hidden until hovered", bars = "Bars", skyriding = "Skyriding" },
        shareSkyriding = {
            label = "Share Skyriding Bar layout",
            desc = "Keeps Surge Forward, Skyward Ascent and the other skyriding abilities in the same slots on the skyriding bar of every included character. Turning this on shares the layout on the character you are playing, and your other included characters pick it up at their next login. Anything else you put on that bar stays with each character.",
        },
        includeSkyriding = {
            label = "Include this character",
            desc = "This character uses the shared skyriding layout, and rearranging its skyriding abilities updates it for the others. Set per character.",
        },
        fadeInMs = {
            label = "Time to appear",
            desc = "How long a hidden bar takes to appear when you point at it. Set to 0 to show it instantly.",
        },
        fadeOutMs = {
            label = "Time to hide",
            desc = "How long a hidden bar takes to disappear once you stop pointing at it. Set to 0 to hide it instantly.",
        },
        milliseconds = " ms",
        morePaging = {
            label = "More paging options",
            desc = "Adds Ctrl+Shift, Ctrl+Alt, Alt+Shift and Friendly target to each bar's Paging panel in Edit Mode.",
        },
        rangeIndicator = {
            label = "Red icon when out of range",
            desc = "Action buttons turn their whole icon red while the target is out of range, instead of only the keybind text.",
        },
        buttonText = {
            hideKeybinds = {
                label = "Hide keybind text",
                desc = "Removes the keybind shown in the corner of every action button.",
            },
            hideMacroNames = {
                label = "Hide macro names",
                desc = "Removes the macro name shown along the bottom of every action button.",
            },
        },
        tooltips = {
            label = "Button tooltips",
            desc = "When action buttons show their tooltip as you point at them.",
            modes = {
                always = "Always",
                outOfCombat = "Out of combat only",
                modifier = "While holding Shift, Ctrl or Alt",
                never = "Never",
            },
        },
        bars = {
            stock = { label = "Action Bar %d" },
            shown = {
                label = "Shown bars",
                desc = "Pick which of Action Bars 2 to 12 to show. Action Bar 1 is always shown, so use its Bar Visible setting in Edit Mode to hide it. Action Bars 9 to 12 show spare pages, and you move them in Edit Mode like any other bar.",
            },
            formNote = "Action Bar %d is left out because your %s already uses its page.",
            all = "All",
            none = "None",
        },
        off = "Off",
        triggers = {
            CTRL = {
                label = "Ctrl",
                desc = "While Ctrl is held, this bar shows the chosen page and its keys press the paged buttons.",
            },
            ALT = {
                label = "Alt",
                desc = "While Alt is held, this bar shows the chosen page and its keys press the paged buttons.",
            },
            SHIFT = {
                label = "Shift",
                desc = "While Shift is held, this bar shows the chosen page. Shift-1 to Shift-6 switch action bar pages by default, so unbind them in Key Bindings for those keys to press the paged buttons.",
            },
            ["CTRL-SHIFT"] = {
                label = "Ctrl+Shift",
                desc = "While Ctrl and Shift are both held, this bar shows the chosen page. This wins over the Ctrl and Shift pages.",
            },
            ["ALT-CTRL"] = {
                label = "Ctrl+Alt",
                desc = "While Ctrl and Alt are both held, this bar shows the chosen page. This wins over the Ctrl and Alt pages.",
            },
            ["ALT-SHIFT"] = {
                label = "Alt+Shift",
                desc = "While Alt and Shift are both held, this bar shows the chosen page. This wins over the Alt and Shift pages.",
            },
            cat = {
                label = "Cat Form",
                desc = "While you are in Cat Form, this bar shows the chosen page. A held modifier with a page of its own wins over this.",
            },
            bear = {
                label = "Bear Form",
                desc = "While you are in Bear Form, this bar shows the chosen page. A held modifier with a page of its own wins over this.",
            },
            moonkin = {
                label = "Moonkin Form",
                desc = "While you are in Moonkin Form, this bar shows the chosen page. A held modifier with a page of its own wins over this.",
            },
            stealth = {
                label = "Stealth",
                desc = "While you are stealthed, this bar shows the chosen page. A held modifier with a page of its own wins over this.",
            },
            HELP = {
                label = "Friendly target",
                desc = "While your target is friendly, this bar shows the chosen page. Any held modifier with a page of its own wins over this.",
            },
        },
        -- Named for the bar that shows each page. Pages 7 to 10 are Action Bars 9 to 12.
        pageLabels = {
            [1] = "Action Bar 1",
            [2] = "Action Bar 1, page 2",
            [3] = "Action Bar 4",
            [4] = "Action Bar 5",
            [5] = "Action Bar 3",
            [7] = "Action Bar 9",
            [8] = "Action Bar 10",
            [9] = "Action Bar 11",
            [10] = "Action Bar 12",
            [13] = "Action Bar 6",
            [14] = "Action Bar 7",
            [15] = "Action Bar 8",
        },
    },
}
