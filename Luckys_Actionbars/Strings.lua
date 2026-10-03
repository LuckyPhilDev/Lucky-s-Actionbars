LuckyActionbars = LuckyActionbars or {}

LuckyActionbars.Strings = {
    addon = {
        title = "Lucky's Actionbars",
    },
    bars = {
        combatBlocked = "Lucky's Actionbars: action bars can't be shown or hidden in combat.",
        names = {
            [9] = "Action Bar 9",
            [10] = "Action Bar 10",
            [11] = "Action Bar 11",
            [12] = "Action Bar 12",
        },
    },
    settings = {
        groups = { paging = "Paging", bars = "Bars", buttons = "Buttons" },
        sections = { modifiers = "Hold to page", stockBars = "Stock bars", extraBars = "Extra bars" },
        rangeIndicator = {
            label = "Red icon when out of range",
            desc = "Action buttons turn their whole icon red while the target is out of range, instead of only the keybind text.",
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
            extra = {
                label = "Action Bar %d",
                desc = "Shows page %d as a bar of its own. Move it in Edit Mode like any other bar.",
            },
        },
        off = "Off",
        modifiers = {
            CTRL = {
                label = "Ctrl",
                desc = "While Ctrl is held, Action Bar 1 shows the chosen page and your Action Bar 1 keys press its buttons.",
            },
            ALT = {
                label = "Alt",
                desc = "While Alt is held, Action Bar 1 shows the chosen page and your Action Bar 1 keys press its buttons.",
            },
            SHIFT = {
                label = "Shift",
                desc = "While Shift is held, Action Bar 1 shows the chosen page. Shift-1 to Shift-6 switch action bar pages by default, so unbind them in Key Bindings for those keys to press the paged buttons.",
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
