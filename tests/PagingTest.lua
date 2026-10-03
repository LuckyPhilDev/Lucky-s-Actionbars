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
function InCombatLockdown() return inCombat end
function UnitClass() return "Druid", "DRUID" end
function GetBindingKey(command) return table.unpack(boundKeys[command] or {}) end
function GetBindingAction(key) return key == "CTRL-2" and "SOMETHING_ELSE" or "" end
function ClearOverrideBindings() bindings = {} end
function SetOverrideBinding(_, _, key, command) bindings[key] = command end

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
local bar1, bar2 = frames[2], frames[3]

check(drivers[bar1] == "[vehicleui][overridebar][possessbar][petbattle] 0; [mod:ctrl] 2; 0",
    "a paged bar hands back to Blizzard in vehicles, then pages on its trigger")
check(drivers[bar2] == nil, "a bar with no pages set gets no state driver")

check(bindings["CTRL-1"] == "ACTIONBUTTON1", "a paged bar's keys are mirrored onto the held modifier")
check(bindings["CTRL-SHIFT-F"] == nil, "a key that already has a modifier is not mirrored")
check(bindings["CTRL-2"] == nil, "a modified key the player bound themselves is left alone")

Paging:SetPage(1, "CTRL-SHIFT", 3)
check(drivers[bar1] == "[vehicleui][overridebar][possessbar][petbattle] 0; [mod:ctrl,mod:shift] 3; [mod:ctrl] 2; 0",
    "combinations come before single modifiers so Ctrl+Shift is not taken as Ctrl")

check(Paging:GetPage(1, "ALT") == 0, "an unset trigger reads as page 0")
Paging:SetPage(1, "ALT", 7)
check(not drivers[bar1]:find("mod:alt"), "a page the class's forms own is never driven")

Paging:SetPage(2, "SHIFT", 4)
check(drivers[bar2] ~= nil, "a second bar pages independently")
Paging:SetPage(2, "SHIFT", 0)
check(drivers[bar2] == nil and bar2.attributes["state-page"] == "0" and db.paging[2].SHIFT == nil,
    "clearing a bar's last page returns it to its home page and forgets the setting")

inCombat = true
Paging:SetPage(2, "SHIFT", 4)
check(drivers[bar2] == nil and eventFrame.events.PLAYER_REGEN_ENABLED, "changes in combat wait for combat to end")
inCombat = false
eventFrame.OnEvent(eventFrame, "PLAYER_REGEN_ENABLED")
check(drivers[bar2] ~= nil and not eventFrame.events.PLAYER_REGEN_ENABLED, "the waiting change applies once combat ends")

print(string.format("PagingTest: %d/%d assertions passed", passed, tests))
