LuckyActionbars = LuckyActionbars or {}

-- Pages a class's or race's own forms already put on Action Bar 1, keyed to the form's name in Strings.forms.
LuckyActionbars.CLASS_FORM_PAGES = {
    DRUID = { [7] = "cat", [8] = "druidSpare", [9] = "bear", [10] = "moonkin" },
    ROGUE = { [7] = "stealth" },
}
-- Soar is a Dracthyr racial, so every Dracthyr has it whatever their class.
LuckyActionbars.RACE_FORM_PAGES = {
    Dracthyr = { [7] = "soar" },
}

function LuckyActionbars.PlayerFormPages()
    local _, class = UnitClass("player")
    local _, race = UnitRace("player")
    local pages = {}
    for _, source in ipairs({ LuckyActionbars.CLASS_FORM_PAGES[class] or {}, LuckyActionbars.RACE_FORM_PAGES[race] or {} }) do
        for page, form in pairs(source) do
            pages[page] = pages[page] or form
        end
    end
    return pages
end
