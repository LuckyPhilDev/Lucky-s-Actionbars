LuckyActionbars = LuckyActionbars or {}

-- Pages a class's own forms put on Action Bar 1, measured in game, keyed to the form's name in Strings.forms.
-- Soar and Flight Form use the skyriding page 11, which is never offered, and no form uses page 8.
LuckyActionbars.CLASS_FORM_PAGES = {
    DRUID = { [7] = "cat", [9] = "bear", [10] = "moonkin" },
    ROGUE = { [7] = "stealth" },
}

function LuckyActionbars.PlayerFormPages()
    local _, class = UnitClass("player")
    return LuckyActionbars.CLASS_FORM_PAGES[class] or {}
end
