LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ButtonDriver = {}

-- Blizzard drives every action button from shared lists. A button an addon creates is tainted, and once
-- Blizzard's loop over a list reaches it, every button after it runs tainted too: Midnight then refuses
-- their secret cooldowns, on the stock bars as well as ours. So our buttons are kept off those lists
-- and driven from here, on the same events.

-- Events ActionBarButtonEventsFrame passes to every button.
local BUTTON_EVENTS = {
    "PLAYER_ENTERING_WORLD", "ACTIONBAR_SLOT_CHANGED", "UPDATE_BINDINGS", "GAME_PAD_ACTIVE_CHANGED",
    "UPDATE_SHAPESHIFT_FORM", "ACTIONBAR_UPDATE_COOLDOWN", "PET_BAR_UPDATE", "PLAYER_MOUNT_DISPLAY_CHANGED",
}
local PET_BUTTON_EVENTS = { "UNIT_FLAGS", "UNIT_AURA" }

-- Events ActionBarActionEventsFrame passes only to buttons holding an action.
local ACTION_EVENTS = {
    "SPELL_UPDATE_CHARGES", "UPDATE_INVENTORY_ALERTS", "TRADE_SKILL_SHOW", "TRADE_SKILL_CLOSE",
    "ARCHAEOLOGY_CLOSED", "PLAYER_ENTER_COMBAT", "PLAYER_LEAVE_COMBAT", "START_AUTOREPEAT_SPELL",
    "STOP_AUTOREPEAT_SPELL", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "COMPANION_UPDATE",
    "UNIT_INVENTORY_CHANGED", "UNIT_SPELLCAST_SENT", "LEARNED_SPELL_IN_SKILL_LINE", "PET_STABLE_UPDATE",
    "PET_STABLE_SHOW", "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE",
    "UPDATE_SUMMONPETS_ACTION", "SPELL_UPDATE_ICON",
}
local PLAYER_ACTION_EVENTS = {
    "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_RETICLE_TARGET", "UNIT_SPELLCAST_RETICLE_CLEAR", "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP", "LOSS_OF_CONTROL_ADDED", "LOSS_OF_CONTROL_UPDATE",
}

-- Tainted code may not hand secret numbers to SetCooldown, but may hand over the duration object.
local COOLDOWN_DURATIONS = {
    cooldown = C_ActionBar.GetActionCooldownDuration,
    chargeCooldown = C_ActionBar.GetActionChargeDuration,
    lossOfControlCooldown = C_ActionBar.GetActionLossOfControlCooldownDuration,
}

local buttons = {}
-- Button to the action it checks range and usability for, held only while the button is visible.
local watching = {}
local updating = {}
local isButtonEvent = {}
local driver = CreateFrame("Frame")

local function OnUpdate(_, elapsed)
    for button in pairs(updating) do
        button:OnUpdate(elapsed)
    end
end

local function CheckNeedsUpdate(button)
    local needsUpdate = (button.stateDirty or button.flashDirty or button:IsFlashing()) and button:IsVisible()
    updating[button] = needsUpdate or nil
    driver:SetScript("OnUpdate", next(updating) and OnUpdate or nil)
end

local function WatchAction(button, action)
    watching[button] = action
    C_ActionBar.EnableActionRangeCheck(action, true)
end

local function UnwatchAction(button, action)
    watching[button] = nil
    C_ActionBar.EnableActionRangeCheck(action, false)
end

-- Update re-sets these attributes every time, which addon code may not do in combat, so there they wait for it to end.
local ATTRIBUTE_UPDATES = { "UpdatePressAndHoldAction", "UpdatePingAttributes" }

local function DeferInCombat(button, method)
    local original = button[method]
    button[method] = function(self)
        if InCombatLockdown() then
            driver:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            original(self)
        end
    end
end

local function ApplyDeferredAttributes()
    driver:UnregisterEvent("PLAYER_REGEN_ENABLED")
    for button in pairs(buttons) do
        for _, method in ipairs(ATTRIBUTE_UPDATES) do
            button[method](button)
        end
    end
end

local function SpellcastSpellID(event, ...)
    if event == "UNIT_SPELLCAST_SENT" then
        return (select(4, ...))
    end
    return (select(3, ...))
end

local function OnEvent(_, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        ApplyDeferredAttributes()
    elseif event == "ACTION_RANGE_CHECK_UPDATE" then
        local action = ...
        for button, watched in pairs(watching) do
            if watched == action then
                button:OnEvent(event, ...)
            end
        end
    elseif event == "ACTION_USABLE_CHANGED" then
        for _, change in ipairs((...)) do
            for button, watched in pairs(watching) do
                if watched == change.slot then
                    button:UpdateUsable(change.slot, change.usable, change.noMana)
                end
            end
        end
    elseif isButtonEvent[event] then
        for button in pairs(buttons) do
            button:OnEvent(event, ...)
        end
    elseif event:find("^UNIT_SPELLCAST_") then
        local spellID = SpellcastSpellID(event, ...)
        for button in pairs(buttons) do
            if button.eventsRegistered and button:MatchesActiveButtonSpellID(spellID) then
                button:OnEvent(event, ...)
            end
        end
    else
        for button in pairs(buttons) do
            if button.eventsRegistered then
                button:OnEvent(event, ...)
            end
        end
    end
end

-- OnLoad has already put the button on Blizzard's lists, so it comes off them before taking an action.
local function TakeOffBlizzardLists(button)
    local frames = ActionBarButtonEventsFrame.frames
    for index = #frames, 1, -1 do
        if frames[index] == button then
            table.remove(frames, index)
        end
    end
    ActionBarActionEventsFrame:UnregisterFrame(button)
    ActionBarButtonUpdateFrame:UnregisterFrame(button)
    if button.action then
        button:UnregisterActionBarButtonCheckFrames(button.action)
    end
end

-- Call straight after creating a button from ActionBarButtonTemplate, before giving it an action.
function LuckyActionbars.ButtonDriver:Adopt(button)
    TakeOffBlizzardLists(button)
    buttons[button] = true
    button.CheckNeedsUpdate = CheckNeedsUpdate
    button.RegisterActionBarButtonCheckFrames = WatchAction
    button.UnregisterActionBarButtonCheckFrames = UnwatchAction
    for _, method in ipairs(ATTRIBUTE_UPDATES) do
        DeferInCombat(button, method)
    end
    for key, duration in pairs(COOLDOWN_DURATIONS) do
        button[key].SetCooldown = function(cooldown)
            cooldown:SetCooldownFromDurationObject(duration(button.action))
        end
    end
end

-- Blizzard's buttons and ours together, for features that apply to every action button.
function LuckyActionbars.ButtonDriver:ForEachButton(fn)
    for _, button in pairs(ActionBarButtonEventsFrame.frames) do
        fn(button)
    end
    for button in pairs(buttons) do
        fn(button)
    end
end

for _, event in ipairs(BUTTON_EVENTS) do
    isButtonEvent[event] = true
    driver:RegisterEvent(event)
end
for _, event in ipairs(PET_BUTTON_EVENTS) do
    isButtonEvent[event] = true
    driver:RegisterUnitEvent(event, "pet")
end
for _, event in ipairs(ACTION_EVENTS) do
    driver:RegisterEvent(event)
end
for _, event in ipairs(PLAYER_ACTION_EVENTS) do
    driver:RegisterUnitEvent(event, "player")
end
driver:RegisterEvent("ACTION_RANGE_CHECK_UPDATE")
driver:RegisterEvent("ACTION_USABLE_CHANGED")
driver:SetScript("OnEvent", OnEvent)

-- Update registers a button with an action here again; it is taken straight back off.
hooksecurefunc(ActionBarActionEventsFrame, "RegisterFrame", function(eventsFrame, button)
    if buttons[button] then
        eventsFrame:UnregisterFrame(button)
    end
end)

CVarCallbackRegistry:RegisterCallback("countdownForCooldowns", function()
    for button in pairs(buttons) do
        ActionButton_UpdateCooldownNumberHidden(button)
    end
end, driver)
