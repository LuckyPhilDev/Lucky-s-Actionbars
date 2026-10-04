LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Utils = {}

-- Inline texture escape: font-height square of the 64px icon, tinted LuckyUI's goldIcon.
local MARKER = "|T%s:0:0:0:0:64:64:0:64:0:64:255:210:100|t %s"

-- Prefixes text this addon adds to Blizzard's UI with the suite's icon, so players can tell it apart.
-- Strings are built once at login, so changing db.markAdditions needs a reload.
function LuckyActionbars.Utils.Mark(text)
    if not LuckyActionbarsDB.markAdditions then
        return text
    end
    return MARKER:format(LuckyIcon("layers"), text)
end
