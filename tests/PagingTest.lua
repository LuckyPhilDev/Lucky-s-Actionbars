local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

local tests, passed = 0, 0
local function check(condition, message)
    tests = tests + 1
    if not condition then error("FAIL: " .. message, 2) end
    passed = passed + 1
end

local frames = {}
function CreateFrame()
    local frame = { attributes = {}, events = {} }
    function frame:SetFrameRef() end
    function frame:SetAttribute(name, value) self.attributes[name] = value end
    function frame:RegisterEvent(event) self.events[event] = true end
    function frame:UnregisterEvent(event) self.events[event] = nil end
    function frame:SetScript(kind, fn) self[kind] = fn end
    frames[#frames + 1] = frame
    return frame
end

local drivers, bindings, boundKeys = {}, {}, {}
local inCombat = false
function RegisterStateDriver(frame, _, conditions) drivers[frame] = conditions end
function UnregisterStateDriver(frame) drivers[frame] = nil end
function tInvert(t)
    local inverted = {}
    for k, v in pairs(t) do inverted[v] = k end
    return inverted
end
function InCombatLockdown() return inCombat end
function UnitClass() return "Druid", "DRUID" end
function GetBindingKey(command) return table.unpack(boundKeys[command] or {}) end
function GetBindingAction(key) return key == "CTRL-2" and "SOMETHING_ELSE" or "" end
function ClearOverrideBindings() bindings = {} end
function SetOverrideBindingClick(_, _, key, buttonName) bindings[key] = buttonName end

local headers = {}
LuckyActionbars = { StockButtons = {} }
function LuckyActionbars.StockButtons:Create(number, bar)
    local header = CreateFrame()
    header.buttons = {}
    for i = 1, 12 do
        header.buttons[i] = { GetName = function() return bar.buttons .. i end }
    end
    headers[number] = header
    return header
end

dofile(root .. "src/Constants.lua")
dofile(root .. "src/features/Paging.lua")

local Paging = LuckyActionbars.Paging
local eventFrame = frames[1]
local db = { paging = {} }
for number = 1, Paging.BAR_COUNT do db.paging[number] = {} end
db.paging[1].CTRL = 2
boundKeys.ACTIONBUTTON1 = { "1", "SHIFT-F" }
boundKeys.ACTIONBUTTON2 = { "2" }

Paging:Init(db)
local bar1, bar2 = headers[1], headers[2]
local BAR1_OVERRIDES = "[overridebar] override; [vehicleui] vehicle; [possessbar] possess; [shapeshift] shapeshift; [petbattle] 0"
local BAR1_PAGES = "[bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; "
    .. "[bonusbar:1] bonus1; [bonusbar:2] bonus2; [bonusbar:3] bonus3; [bonusbar:4] bonus4; [bonusbar:5] bonus5; 1"

check(drivers[bar1] == BAR1_OVERRIDES .. "; [mod:ctrl] 2; " .. BAR1_PAGES,
    "Action Bar 1 follows Blizzard's vehicle, page and form changes, and pages on its trigger in between")
check(drivers[bar2] == "[vehicleui][overridebar][possessbar][petbattle] 0; 0", "a bar with no pages set stays on its home page")

check(bindings["1"] == "ActionButton1" and bindings["SHIFT-F"] == "ActionButton1",
    "every key bound to a stock button clicks the button that replaces it")
check(bindings["CTRL-1"] == "ActionButton1", "a paged bar's keys are mirrored onto the held modifier")
check(bindings["CTRL-SHIFT-F"] == nil, "a key that already has a modifier is not mirrored")
check(bindings["CTRL-2"] == nil, "a modified key the player bound themselves is left alone")

Paging:SetPage(1, "CTRL-SHIFT", 3)
check(not drivers[bar1]:find("mod:shift"), "combination pages need More paging options")
Paging:SetMorePaging(true)
check(drivers[bar1] == BAR1_OVERRIDES .. "; [mod:ctrl,mod:shift] 3; [mod:ctrl] 2; " .. BAR1_PAGES,
    "combinations come before single modifiers so Ctrl+Shift is not taken as Ctrl")

check(Paging:GetPage(1, "ALT") == 0, "an unset trigger reads as page 0")
Paging:SetPage(1, "ALT", 7)
check(not drivers[bar1]:find("mod:alt"), "a page the class's forms own is never driven")

Paging:SetPage(2, "SHIFT", 4)
check(drivers[bar2]:find("%[mod:shift%] 4"), "a second bar pages independently")
Paging:SetPage(2, "SHIFT", 0)
check(drivers[bar2] == "[vehicleui][overridebar][possessbar][petbattle] 0; 0" and db.paging[2].SHIFT == nil,
    "clearing a bar's last page returns it to its home page and forgets the setting")

Paging:SetPage(3, "cat", 8)
check(drivers[headers[3]]:find("%[bonusbar:1%] 8"), "a druid can page another bar in Cat Form")
Paging:SetPage(3, "stealth", 9)
check(not drivers[headers[3]]:find("9"), "another class's form never pages")
Paging:SetPage(1, "cat", 8)
check(not drivers[bar1]:find("%[bonusbar:1%] 8"), "Action Bar 1 keeps Blizzard's own form pages")

inCombat = true
Paging:SetPage(2, "SHIFT", 4)
check(not drivers[bar2]:find("mod:shift") and eventFrame.events.PLAYER_REGEN_ENABLED, "changes in combat wait for combat to end")
inCombat = false
eventFrame.OnEvent(eventFrame, "PLAYER_REGEN_ENABLED")
check(drivers[bar2]:find("mod:shift") and not eventFrame.events.PLAYER_REGEN_ENABLED, "the waiting change applies once combat ends")

print(string.format("PagingTest: %d/%d assertions passed", passed, tests))
