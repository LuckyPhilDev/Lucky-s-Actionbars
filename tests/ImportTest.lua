local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

local tests, passed = 0, 0
local function check(condition, message)
    tests = tests + 1
    if not condition then error("FAIL: " .. message, 2) end
    passed = passed + 1
end

dofile(root .. "src/features/ImportSources.lua")
dofile(root .. "src/features/Import.lua")

local Measure = LuckyActionbars.Import.Measure
local DominosPage = LuckyActionbars.ImportSources.DominosPage

local function Grid(count, perLine, size, gap, vertical, topFirst)
    local rects = {}
    for index = 1, count do
        local along, across = (index - 1) % perLine, math.floor((index - 1) / perLine)
        if topFirst then across = -across end
        local x, y = along * (size + gap), across * (size + gap)
        if vertical then x, y = -y, -x end
        rects[index] = { 100 + x, 200 + y, size, size }
    end
    return rects
end

local row = Measure(Grid(12, 12, 45, 2))
check(row.horizontal and row.lines == 1 and row.icons == 12, "a single row reads as one horizontal line of 12")
check(row.size == 100 and row.padding == 2, "stock-sized buttons read as 100% with their gap as padding")
check(row.x == 100 + (12 * 45 + 11 * 2) / 2 and row.y == 200 + 45 / 2, "the centre is the middle of all the buttons")

local block = Measure(Grid(12, 6, 36, 4, false, true))
check(block.horizontal and block.lines == 2, "six across and two down is a horizontal bar of two rows")
check(block.size == 80 and block.padding == 4, "36px buttons round to 80%")
check(block.rowsDown, "a first button on the top row means rows grow down")
check(not Measure(Grid(12, 6, 36, 4)).rowsDown, "a first button on the bottom row means rows grow up")

local column = Measure(Grid(8, 8, 45, 3, true))
check(not column.horizontal and column.lines == 1 and column.icons == 8, "one column of eight is a vertical bar")
check(column.padding == 3, "a vertical bar takes its padding from the vertical gap")

check(Measure(Grid(12, 12, 45, 30)).padding == 10, "padding is held to Edit Mode's 10 at most")

check(DominosPage(1) == 1 and DominosPage(11) == 11, "Dominos shows page N on bar N")
check(DominosPage(12) == 13 and DominosPage(14) == 15, "Dominos skips page 12")
check(DominosPage(1 + 10) == 11 and DominosPage(10 + 5) == 1, "a paging offset wraps past the last bar")

local slots, cursor = {}, nil
function HasAction(slot) return slots[slot] ~= nil end
function PickupAction(slot) slots[slot], cursor = cursor, slots[slot] end
local refused = {}
function PlaceAction(slot) if not refused[slot] then slots[slot], cursor = cursor, slots[slot] end end
function GetCursorInfo() return cursor end
function ClearCursor() cursor = nil end
function GetActionInfo(slot) return slots[slot] and "spell", slots[slot] end
function GetActionText() end
C_Spell = { GetSpellName = function(id) return id end }
LuckyLog = { New = function() return function() end end }
StaticPopupDialogs = {}
C_AddOns = { IsAddOnLoaded = function() return false end }
LuckyActionbars.Strings = { addon = {}, import = { moved = "%s %d" } }
local HOME = { [2] = 6, [3] = 5, [4] = 3, [5] = 4, [6] = 13, [7] = 14, [8] = 15 }
LuckyActionbars.Paging = { BAR_COUNT = 8, HomePage = function(_, number) return HOME[number] end }
LuckyActionbars.ExtraBars = { Page = function(_, number) return number - 2 end }
local charDb = {}
LuckyActionbars.Import:Init({ devMode = false }, charDb)

for page = 1, 15 do slots[(page - 1) * 12 + 1] = "page" .. page end
-- Dominos bars 2, 3 and 4 show pages 2, 3 and 4 and should become Action Bars 2, 3 and 4.
local taken = { [2] = { page = 2, label = "b2" }, [3] = { page = 3, label = "b3" }, [4] = { page = 4, label = "b4" } }
local location = LuckyActionbars.Import.MovePages(taken, function() end)
check(slots[(6 - 1) * 12 + 1] == "page2", "Dominos bar 2's spells land on Action Bar 2's page")
check(slots[(5 - 1) * 12 + 1] == "page3", "Dominos bar 3's spells land on Action Bar 3's page")
check(slots[(3 - 1) * 12 + 1] == "page4", "a later swap never disturbs a page already placed")
for page, now in pairs(location) do
    check(slots[(now - 1) * 12 + 1] == "page" .. page, "the page map says where page " .. page .. " went")
end
function InCombatLockdown() return false end
LuckyActionbars.Strings.import.undone = ""
LuckyActionbars.Strings.addon.prefix = ""
LuckyActionbars.Import:Undo()
local restored = true
for page = 1, 15 do restored = restored and slots[(page - 1) * 12 + 1] == "page" .. page end
check(restored, "undoing the swaps in reverse puts every page back")

local function Count()
    local count = 0
    for _ in pairs(slots) do count = count + 1 end
    return count
end
local before = Count()
refused[(5 - 1) * 12 + 1] = true
check(LuckyActionbars.Import.MovePages(taken, function() end) == nil, "a slot that won't take its action stops the moves")
check(Count() == before and cursor == nil, "a refused placement puts the action back rather than dropping it")
refused = {}

print(("ImportTest: %d/%d assertions passed"):format(passed, tests))
