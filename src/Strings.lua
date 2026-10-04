LuckyActionbars = LuckyActionbars or {}

LuckyActionbars.Strings = {
    addon = {
        title = "Lucky's Actionbars",
        minimapHint = "Click to open settings.",
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
            desc = "This bar stays invisible until you point at it or drag something to place. Its keybinds still work while it is invisible.",
        },
        extraBarsDivider = "Extra bars",
        layout = {
            rows = "# of Rows",
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
    settings = {
        groups = { bars = "Bars", buttons = "Buttons" },
        sections = { stockBars = "Stock bars", extraBars = "Extra bars", fade = "Hidden until hovered" },
        fadeInMs = {
            label = "Time to appear",
            desc = "How long a hidden bar takes to appear when you point at it. Set to 0 to show it instantly.",
        },
        fadeOutMs = {
            label = "Time to hide",
            desc = "How long a hidden bar takes to disappear once you stop pointing at it. Set to 0 to hide it instantly.",
        },
        milliseconds = " ms",
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
            [1] = {
                label = "Action Bar 1",
                desc = "Action Bar 1 is always shown. Use its Bar Visible setting in Edit Mode to hide it.",
            },
            stock = {
                label = "Action Bar %d",
                desc = "Same as the Action Bar %d checkbox in Options, Action Bars.",
            },
            formNote = "Unavailable: page %d is already used by your %s on Action Bar 1.",
            extra = {
                label = "Action Bar %d",
                desc = "Shows page %d as a bar of its own. Move it in Edit Mode like any other bar.",
            },
        },
        off = "Off",
        paging = { expander = "Paging" },
        modifiers = {
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
            HELP = {
                label = "Friendly target",
                desc = "While your target is friendly, this bar shows the chosen page. Any held modifier with a page of its own wins over this.",
            },
        },
        pageLabels = {
            [1] = "Page 1: Action Bar 1",
            [2] = "Page 2: Action Bar 1, second page",
            [3] = "Page 3: Action Bar 4",
            [4] = "Page 4: Action Bar 5",
            [5] = "Page 5: Action Bar 3",
            [7] = "Page 7: spare",
            [8] = "Page 8: spare",
            [9] = "Page 9: spare",
            [10] = "Page 10: spare",
            [13] = "Page 13: Action Bar 6",
            [14] = "Page 14: Action Bar 7",
            [15] = "Page 15: Action Bar 8",
        },
    },
}
