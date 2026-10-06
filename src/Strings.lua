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
    import = {
        layoutName = "Imported from %s",
        dominosBar = "Dominos bar %d",
        ellesmereBar = "EllesmereUI Action Bar %d",
        bartenderBar = "Bartender4 %s",
        dominosBarCount = "Dominos is set to a bar count other than 14, so its buttons don't line up with action bar pages. Set it back to 14 bars in Dominos to import.",
        combat = "Importing has to wait until you leave combat.",
        notReady = "Edit Mode is still loading. Try again in a moment.",
        layoutsFull = "You already have the most account-wide Edit Mode layouts allowed. Delete one in Edit Mode to make room for the imported one.",
        done = "Imported your %s bars into the Edit Mode layout \"%s\".",
        moved = "%s is now Action Bar %d, and its spells moved with it.",
        noBar = "%s was left out: every bar here is already taken.",
        notMeasured = "%s was left out: its buttons have no position on screen.",
        pagingSkipped = "%s: paging for %s was left out.",
        keybinds = "Moved %d keybinds onto the matching buttons.",
        nothingToReverse = "There is no import on this character to reverse.",
        moveFailed = "A spell didn't move as expected, so moving stopped there and nothing else was changed. Undo spell moves in /luckybars puts back the ones that did move.",
        undone = "Spells moved by the last import are back where they were.",
        offer = "Lucky's Actionbars can copy your %s bars: where they sit, their size, paging and keybinds, and the spells on them. Import now?",
        importNow = "Import",
        notNow = "Not now",
        disablePrompt = "Import done. Disable %s and reload to see your new bars?",
        disableAndReload = "Disable and reload",
        later = "Later",
        switchBackPrompt = "Another addon switched Edit Mode away from \"%s\" as you logged in. Switch back to your imported bars?",
        switchBack = "Switch back",
        reviewPrompt = "Your %s bars are now Lucky's Actionbars. Keep them, or revert to how everything was before the import?",
        revert = "Revert",
        keep = "Keep",
        switchBackCombat = "Leave combat, then pick \"%s\" in Edit Mode to see your imported bars.",
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
        sections = { paging = "Paging", fade = "Hidden until hovered", bars = "Bars", skyriding = "Skyriding",
            import = "Import" },
        importFrom = {
            label = "Import from %s",
            desc = "Copies your %s bars into a new Edit Mode layout: where they sit, their size, paging, keybinds, hidden until hovered and button text. Each bar keeps its number where it can, and its spells move with it. Run it while %s is still loaded.",
        },
        reverseImport = {
            label = "Revert import",
            desc = "Puts back everything the import changed on this character: spells, keybinds, paging, which bars show, hidden until hovered, button text and the Edit Mode layout. Then turns the addon you imported from back on and reloads. Also /luckybars revert.",
        },
        undoImport = {
            label = "Undo spell moves",
            desc = "Puts back any spells the last import moved to another bar on this character.",
        },
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
