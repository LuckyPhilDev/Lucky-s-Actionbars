-- luacheck: globals CreateFrame hooksecurefunc InCombatLockdown C_ActionBar CVarCallbackRegistry ActionBarButtonEventsFrame ActionBarActionEventsFrame ActionBarButtonUpdateFrame
local script = arg[0]:gsub("\\", "/")
local root = script:match("^(.*)/tests/[^/]+$") .. "/"

local tests, passed = 0, 0
local function check(condition, message)
    tests = tests + 1
    if not condition then error("FAIL: " .. message, 2) end
    passed = passed + 1
end

local driver
function CreateFrame()
    driver = { events = {} }
    function driver:RegisterEvent(event) self.events[event] = true end
    function driver:RegisterUnitEvent(event) self.events[event] = true end
    function driver:UnregisterEvent(event) self.events[event] = nil end
    function driver:SetScript(kind, fn) self[kind] = fn end
    return driver
end

function hooksecurefunc(target, name, hook)
    local original = target[name]
    target[name] = function(...)
        original(...)
        hook(...)
    end
end

local rangeChecks = {}
C_ActionBar = {
    GetActionCooldownDuration = function(action) return "cooldown " .. action end,
    GetActionChargeDuration = function(action) return "charge " .. action end,
    GetActionLossOfControlCooldownDuration = function(action) return "loc " .. action end,
    EnableActionRangeCheck = function(action, enabled) rangeChecks[action] = enabled end,
}
local inCombat = false
function InCombatLockdown() return inCombat end
CVarCallbackRegistry = { RegisterCallback = function() end }

local function List()
    local list = { frames = {} }
    function list:RegisterFrame(frame) self.frames[frame] = frame end
    function list:UnregisterFrame(frame) self.frames[frame] = nil end
    return list
end
ActionBarButtonEventsFrame = { frames = {} }
ActionBarActionEventsFrame = List()
ActionBarButtonUpdateFrame = List()

local function Cooldown()
    local cooldown = {}
    function cooldown:SetCooldownFromDurationObject(duration) self.duration = duration end
    return cooldown
end

-- A stand-in for what ActionBarButtonTemplate's OnLoad leaves behind.
local function Button(action)
    local button = {
        action = action, received = {},
        cooldown = Cooldown(), chargeCooldown = Cooldown(), lossOfControlCooldown = Cooldown(),
    }
    function button:OnEvent(event) self.received[#self.received + 1] = event end
    function button:UpdateUsable(slot, usable) self.usable = { slot, usable } end
    function button:MatchesActiveButtonSpellID(spellID) return spellID == 100 end
    function button:UnregisterActionBarButtonCheckFrames() self.blizzardUnwatched = true end
    button.attributeUpdates = 0
    function button:UpdatePressAndHoldAction() self.attributeUpdates = self.attributeUpdates + 1 end
    function button:UpdatePingAttributes() self.attributeUpdates = self.attributeUpdates + 1 end
    table.insert(ActionBarButtonEventsFrame.frames, button)
    ActionBarActionEventsFrame:RegisterFrame(button)
    ActionBarButtonUpdateFrame:RegisterFrame(button)
    return button
end

dofile(root .. "src/features/ButtonDriver.lua")
local ButtonDriver = LuckyActionbars.ButtonDriver

local stock = Button(1)
local ours = Button(73)
ButtonDriver:Adopt(ours)

check(#ActionBarButtonEventsFrame.frames == 1 and ActionBarButtonEventsFrame.frames[1] == stock,
    "an adopted button leaves Blizzard's button list and the stock one stays")
check(ActionBarActionEventsFrame.frames[ours] == nil and ActionBarButtonUpdateFrame.frames[ours] == nil,
    "an adopted button leaves Blizzard's action and update lists")
check(ours.blizzardUnwatched, "an adopted button stops Blizzard's range and usable watch on its action")

ActionBarActionEventsFrame:RegisterFrame(ours)
ActionBarActionEventsFrame:RegisterFrame(stock)
check(ActionBarActionEventsFrame.frames[ours] == nil, "re-registering an adopted button is undone")
check(ActionBarActionEventsFrame.frames[stock] == stock, "re-registering a stock button is left alone")

local seen = {}
ButtonDriver:ForEachButton(function(button) seen[button] = true end)
check(seen[stock] and seen[ours], "ForEachButton covers Blizzard's buttons and ours")

ours.cooldown:SetCooldown(1, 2, 1)
ours.chargeCooldown:SetCooldown(1, 2, 1)
ours.lossOfControlCooldown:SetCooldown(1, 2, 1)
check(ours.cooldown.duration == "cooldown 73", "the cooldown swipe is set from the action's duration object")
check(ours.chargeCooldown.duration == "charge 73", "the charge swipe is set from the charge duration")
check(ours.lossOfControlCooldown.duration == "loc 73", "the loss of control swipe is set from its duration")

driver.OnEvent(driver, "ACTIONBAR_UPDATE_COOLDOWN")
check(ours.received[1] == "ACTIONBAR_UPDATE_COOLDOWN", "a button event reaches an adopted button")
check(#stock.received == 0, "the driver never touches stock buttons")

ours.received = {}
driver.OnEvent(driver, "SPELL_UPDATE_CHARGES")
check(#ours.received == 0, "an action event skips a button holding no action")
ours.eventsRegistered = true
driver.OnEvent(driver, "SPELL_UPDATE_CHARGES")
check(ours.received[1] == "SPELL_UPDATE_CHARGES", "an action event reaches a button holding an action")

ours.received = {}
driver.OnEvent(driver, "UNIT_SPELLCAST_START", "player", "guid", 200)
check(#ours.received == 0, "a cast of another spell skips the button")
driver.OnEvent(driver, "UNIT_SPELLCAST_START", "player", "guid", 100)
check(ours.received[1] == "UNIT_SPELLCAST_START", "a cast of the button's spell reaches it")

ours.received = {}
driver.OnEvent(driver, "ACTION_RANGE_CHECK_UPDATE", 73, true, true)
check(#ours.received == 0, "range updates skip a hidden button")
ours:RegisterActionBarButtonCheckFrames(73)
check(rangeChecks[73] == true, "a shown button turns on range checks for its action")
driver.OnEvent(driver, "ACTION_RANGE_CHECK_UPDATE", 12, true, true)
check(#ours.received == 0, "range updates for another action skip the button")
driver.OnEvent(driver, "ACTION_RANGE_CHECK_UPDATE", 73, true, true)
check(ours.received[1] == "ACTION_RANGE_CHECK_UPDATE", "range updates for its action reach the button")
driver.OnEvent(driver, "ACTION_USABLE_CHANGED", { { slot = 73, usable = false } })
check(ours.usable[1] == 73 and ours.usable[2] == false, "usable changes for its action reach the button")
ours:UnregisterActionBarButtonCheckFrames(73)
check(rangeChecks[73] == false, "hiding the button turns its range checks off")

inCombat = true
ours:UpdatePressAndHoldAction()
ours:UpdatePingAttributes()
check(ours.attributeUpdates == 0, "attribute updates wait out combat")
check(driver.events.PLAYER_REGEN_ENABLED, "a deferred attribute update listens for combat ending")
inCombat = false
driver.OnEvent(driver, "PLAYER_REGEN_ENABLED")
check(ours.attributeUpdates == 2, "deferred attribute updates run once combat ends")
check(not driver.events.PLAYER_REGEN_ENABLED, "combat ending is only listened for while updates wait")
ours:UpdatePingAttributes()
check(ours.attributeUpdates == 3, "out of combat, attribute updates run straight away")

print(string.format("ButtonDriverTest: %d/%d assertions passed", passed, tests))
