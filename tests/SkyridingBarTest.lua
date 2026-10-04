-- luacheck: globals hooksecurefunc CreateFrame GetActionInfo ClearCursor PickupAction PlaceAction IsPlayerSpell InCombatLockdown C_Spell
-- luacheck: globals GetCursorInfo

local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

local tests, passed = 0, 0
local function check(condition, message)
    tests = tests + 1
    if not condition then error("FAIL: " .. message, 2) end
    passed = passed + 1
end

local SURGE, ASCENT, WHIRL, HALT, FIREBALL = 372608, 372610, 361584, 403092, 133

local bars, cursor, known, inCombat = {}, nil, {}, false
local events, frame = {}, nil
function CreateFrame()
    frame = {
        RegisterEvent = function(_, event) events[event] = true end,
        UnregisterEvent = function(_, event) events[event] = nil end,
        SetScript = function(self, _, fn) self.OnEvent = fn end,
    }
    return frame
end
function GetActionInfo(slot) local a = bars[slot]; if a then return "spell", a end end
function ClearCursor() cursor = nil end
function PickupAction(slot) cursor, bars[slot] = bars[slot], nil end
function PlaceAction(slot) cursor, bars[slot] = bars[slot], cursor end
function IsPlayerSpell(id) return known[id] end
function InCombatLockdown() return inCombat end
local hooks = {}
function hooksecurefunc(name, fn) hooks[name] = fn end
C_Spell = { PickupSpell = function(id) if known[id] then cursor = id end end }
function GetCursorInfo() if cursor then return "spell", cursor end end
local buttons = {}
for index = 1, 12 do
    buttons[index] = { action = 120 + index, HookScript = function(self, _, fn) self.PreClick = fn end }
    _G["ActionButton" .. index] = buttons[index]
end

dofile(root .. "src/Constants.lua")

-- Each login reloads the file, as the game does, so every character gets a fresh events frame.
local function Login(db, charDb, actions, knows)
    bars, known, events = actions, knows, {}
    dofile(root .. "src/features/SkyridingBar.lua")
    LuckyActionbars.SkyridingBar:Init(db, charDb)
end
local function Fire(event, slot) if events[event] then frame.OnEvent(frame, event, slot) end end
-- The player dragging a spell on or off: the drag hook runs, then the slot changes on the server.
local function Place(slot, spell)
    hooks.PlaceAction(slot)
    bars[slot] = spell
    Fire("ACTIONBAR_SLOT_CHANGED", slot)
end
-- The player dragging a spell off a slot, leaving it on the cursor.
local function Pickup(slot)
    PickupAction(slot)
    hooks.PickupAction(slot)
    Fire("ACTIONBAR_SLOT_CHANGED", slot)
end
-- The player releasing the drag over another slot, picking up whatever was there.
local function Drop(slot)
    PlaceAction(slot)
    hooks.PlaceAction(slot)
    Fire("ACTIONBAR_SLOT_CHANGED", slot)
end
-- The player dropping the cursor's spell on a slot by clicking it, which goes through UseAction, not PlaceAction.
local function ClickPlace(slot)
    local button = buttons[slot - 120]
    button.PreClick(button)
    PlaceAction(slot)
    Fire("ACTIONBAR_SLOT_CHANGED", slot)
end
-- Blizzard placing a spell itself, with no drag.
local function Push(slot, spell)
    bars[slot] = spell
    Fire("ACTIONBAR_SLOT_CHANGED", slot)
    Fire("SPELL_PUSHED_TO_ACTIONBAR", spell)
end

local all = { [SURGE] = true, [ASCENT] = true, [WHIRL] = true, [HALT] = true, [FIREBALL] = true }
local db = { shareSkyriding = false }

Login(db, { skyridingIncluded = true }, { [121] = SURGE, [123] = FIREBALL }, all)
Push(122, ASCENT)
Fire("SPELLS_CHANGED")
Place(127, WHIRL)
check(db.skyridingBar == nil and bars[121] == SURGE, "nothing is shared until sharing is turned on")
LuckyActionbars.SkyridingBar:SetSharing(true)
check(db.skyridingBar[121] == SURGE and db.skyridingBar[122] == ASCENT and db.skyridingBar[127] == WHIRL,
    "turning it on shares this character's skyriding spells")
check(db.skyridingBar[123] == nil, "its own spells are not shared")
Place(125, HALT)
check(db.skyridingBar[125] == HALT, "a skyriding spell placed afterwards is shared straight away")

Login(db, { skyridingIncluded = true }, { [121] = ASCENT, [124] = FIREBALL, [126] = WHIRL }, all)
Fire("SPELLS_CHANGED")
check(bars[121] == SURGE and bars[122] == ASCENT and bars[125] == HALT, "another character gets the shared layout")
check(bars[124] == FIREBALL, "and keeps its own spells")
check(bars[126] == nil, "a skyriding spell outside the shared layout is removed")
check(cursor == nil, "the cursor is left empty")
Push(126, WHIRL)
check(db.skyridingBar[126] == nil and bars[126] == nil, "a spell Blizzard places is not shared, and is put back")
Place(125, nil)
check(db.skyridingBar[125] == nil, "removing a shared spell removes it for everyone")
Pickup(121)
Drop(122)
ClickPlace(121)
check(db.skyridingBar[121] == ASCENT and db.skyridingBar[122] == SURGE, "swapping two spells shares both halves")
Pickup(121)
Drop(122)
ClickPlace(121)
Place(124, nil)
Place(124, FIREBALL)
check(db.skyridingBar[124] == nil, "moving its own spells shares nothing")

Login(db, { skyridingIncluded = false }, { [121] = HALT }, all)
Fire("SPELLS_CHANGED")
Place(122, HALT)
check(bars[121] == HALT and db.skyridingBar[121] == SURGE and db.skyridingBar[122] == ASCENT,
    "an excluded character neither gets nor changes the layout")
LuckyActionbars.SkyridingBar:SetIncluded(true)
check(bars[121] == SURGE and bars[122] == ASCENT, "including it applies the layout straight away")

Login(db, { skyridingIncluded = true }, {}, { [ASCENT] = true })
Fire("SPELLS_CHANGED")
check(bars[121] == nil and bars[122] == ASCENT, "a spell the character does not know is skipped")
Place(123, FIREBALL)
check(db.skyridingBar[121] == SURGE, "and stays shared for the characters that do")

db.shareSkyriding = false
Login(db, { skyridingIncluded = true }, { [121] = HALT }, all)
Fire("SPELLS_CHANGED")
Place(122, HALT)
check(bars[121] == HALT and db.skyridingBar[121] == SURGE, "turning sharing off stops it for every character")
LuckyActionbars.SkyridingBar:SetSharing(true)
check(db.skyridingBar[121] == HALT and db.skyridingBar[122] == HALT and db.skyridingBar[126] == nil,
    "turning it back on starts over from this character's bar")

inCombat = true
Login(db, { skyridingIncluded = true }, {}, all)
Fire("SPELLS_CHANGED")
check(bars[121] == nil and events.PLAYER_REGEN_ENABLED, "a login in combat waits for combat to end")
inCombat = false
Fire("PLAYER_REGEN_ENABLED")
check(bars[121] == HALT, "then applies the layout")


print(string.format("SkyridingBarTest: %d/%d assertions passed", passed, tests))
