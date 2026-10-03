LuckyActionbars = LuckyActionbars or {}

-- Pages a class's own forms already put on Action Bar 1, keyed to the form's name in Strings.forms.
LuckyActionbars.CLASS_FORM_PAGES = {
    DRUID = { [7] = "cat", [8] = "druidSpare", [9] = "bear", [10] = "moonkin" },
    ROGUE = { [7] = "stealth" },
    EVOKER = { [7] = "soar" },
}

function LuckyActionbars.PlayerFormPages()
    local _, class = UnitClass("player")
    return LuckyActionbars.CLASS_FORM_PAGES[class] or {}
end
