local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

local tests, passed = 0, 0
local function check(condition, message)
    tests = tests + 1
    if not condition then error("FAIL: " .. message, 2) end
    passed = passed + 1
end

local loader
function CreateFrame()
    loader = { RegisterEvent = function() end }
    function loader:SetScript(_, fn) self.OnEvent = fn end
    return loader
end

function CopyTable(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = type(value) == "table" and CopyTable(value) or value
    end
    return copy
end

SlashCmdList = {}
LuckyMinimap = { Create = function() end }
LuckyActionbars = { Paging = { BAR_COUNT = 8 }, Strings = { addon = {} } }
for _, name in ipairs({ "Paging", "ExtraBars", "RangeIndicator", "ButtonText", "Tooltips", "MouseoverFade", "RowDirection", "BagsBar", "MicroMenu", "SkyridingBar",
    "EditModePanel", "Settings" }) do
    LuckyActionbars[name] = LuckyActionbars[name] or {}
    LuckyActionbars[name].Init = function() end
end
dofile(root .. "src/Defaults.lua")

local function Login(saved)
    LuckyActionbarsDB = saved
    dofile(root .. "src/Core.lua")
    loader.OnEvent(loader, "PLAYER_LOGIN")
    return LuckyActionbarsDB
end

local fresh = Login(nil)
check(fresh.paging[1].CTRL == 2 and fresh.rangeIndicator == true, "a new install gets the defaults")
fresh.paging[1].CTRL = 5
check(LuckyActionbars.DB_DEFAULTS.paging[1].CTRL == 2, "the default pages are copied, not shared")
check(fresh.paging[8] and fresh.fade, "every bar has a paging table and fade settings exist")
check(fresh.bars[9].shown == false and fresh.bars[12].positions and fresh.bars[12].layouts,
    "the extra bars start hidden with somewhere to store their layouts")

local legacy = Login({ pages = { ALT = 3 }, rangeIndicator = false })
check(legacy.paging[1].ALT == 3 and legacy.paging[1].CTRL == nil and legacy.pages == nil,
    "pages saved before Edit Mode paging move to Action Bar 1")
check(legacy.rangeIndicator == false, "a saved setting is not reset to its default")

local current = Login({ paging = { [2] = { SHIFT = 4 } }, bars = { [9] = { shown = true } } })
check(current.paging[2].SHIFT == 4 and current.paging[1].CTRL == nil, "current pages are kept as they are")
check(current.bars[9].shown == true and current.bars[9].positions, "a shown extra bar stays shown")

print(string.format("CoreTest: %d/%d assertions passed", passed, tests))
