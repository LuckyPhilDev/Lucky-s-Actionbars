LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.SkyridingBar = {}

-- Page 11 is the bar Blizzard swaps in while skyriding.
local FIRST_SLOT, LAST_SLOT = 121, 132

local db, charDb
-- Slots the player dragged a spell on or off. Only these are recorded, so the bar loading in at login
-- and spells Blizzard places itself never change the shared layout.
local touched = {}
local events = CreateFrame("Frame")
local devLog

-- Builds the message only in dev mode, since slot changes fire often.
local function Log(message, ...)
    if db.devMode then
        devLog(message:format(...))
    end
end

local function SpellName(id)
    return id and C_Spell.GetSpellName(id) or "empty"
end

local function IsActive()
    return db.shareSkyriding and charDb.skyridingIncluded
end

local function SkyridingSpellIn(slot)
    local kind, id = GetActionInfo(slot)
    return kind == "spell" and LuckyActionbars.SKYRIDING_SPELLS[id] and id or nil
end

-- A slot holding a spell this character can't learn keeps it, so one character can't erase another's.
local function RecordSlot(slot)
    if not IsActive() or not db.skyridingBar then
        return
    end
    local wanted, current = db.skyridingBar[slot], SkyridingSpellIn(slot)
    if current or (wanted and IsPlayerSpell(wanted)) then
        if wanted ~= current then
            Log("Skyriding: saved slot %d as %s, was %s", slot, SpellName(current), SpellName(wanted))
        end
        db.skyridingBar[slot] = current
    end
end

-- A slot wanting a spell this character can't learn already matches, since applying can't change it.
local function NeedsChange(wanted, current)
    return wanted ~= current and (current ~= nil or IsPlayerSpell(wanted))
end

local function LayoutMatches()
    for slot = FIRST_SLOT, LAST_SLOT do
        if NeedsChange(db.skyridingBar[slot], SkyridingSpellIn(slot)) then
            return false
        end
    end
    return true
end

-- The shared layout wins over this character's skyriding spells, and over its own spell in a slot the layout claims.
local function Apply()
    if not IsActive() or not db.skyridingBar or LayoutMatches() then
        return
    end
    -- SPELLS_CHANGED fires repeatedly in combat, so only the first wait is logged.
    if InCombatLockdown() then
        if not events:IsEventRegistered("PLAYER_REGEN_ENABLED") then
            Log("Skyriding: in combat, applying the layout afterwards")
            events:RegisterEvent("PLAYER_REGEN_ENABLED")
        end
        return
    end
    ClearCursor()
    for slot = FIRST_SLOT, LAST_SLOT do
        local wanted, current = db.skyridingBar[slot], SkyridingSpellIn(slot)
        if NeedsChange(wanted, current) then
            Log("Skyriding: applying slot %d, %s replaces %s", slot, SpellName(wanted), SpellName(current))
            if wanted and IsPlayerSpell(wanted) then
                C_Spell.PickupSpell(wanted)
                PlaceAction(slot)
            elseif current then
                PickupAction(slot)
            end
            ClearCursor()
        end
    end
end

-- Recorded here as well as on ACTIONBAR_SLOT_CHANGED, in case that event fires before this hook runs.
local function OnDrag(slot)
    if slot >= FIRST_SLOT and slot <= LAST_SLOT then
        touched[slot] = true
        RecordSlot(slot)
    end
end

-- Clicking a held spell into a slot places it through UseAction, which the drag hooks never see.
-- That is the second half of every swap, so without this the displaced spell is lost from the layout.
local function OnPreClick(button)
    local slot = button.action
    if GetCursorInfo() and slot and slot >= FIRST_SLOT and slot <= LAST_SLOT then
        touched[slot] = true
    end
end

function LuckyActionbars.SkyridingBar:IsSharing()
    return db.shareSkyriding
end

-- Turning sharing on starts the layout from this character's bar, never from whichever character logs in first.
function LuckyActionbars.SkyridingBar:SetSharing(sharing)
    db.shareSkyriding = sharing
    if sharing then
        db.skyridingBar = {}
        for slot = FIRST_SLOT, LAST_SLOT do
            db.skyridingBar[slot] = SkyridingSpellIn(slot)
        end
    end
    Apply()
end

function LuckyActionbars.SkyridingBar:IsIncluded()
    return charDb.skyridingIncluded
end

function LuckyActionbars.SkyridingBar:SetIncluded(included)
    charDb.skyridingIncluded = included
    Apply()
end

function LuckyActionbars.SkyridingBar:Init(database, characterDatabase)
    db, charDb = database, characterDatabase
    devLog = LuckyLog:New(LuckyActionbars.Strings.addon.prefix, function() return db.devMode end)
    hooksecurefunc("PickupAction", OnDrag)
    hooksecurefunc("PlaceAction", OnDrag)
    -- The main bar is the one that pages to the skyriding bar.
    for index = 1, 12 do
        _G["ActionButton" .. index]:HookScript("PreClick", OnPreClick)
    end
    -- Not PLAYER_ENTERING_WORLD: the skyriding spells are not known yet then, so none could be placed.
    events:RegisterEvent("SPELLS_CHANGED")
    -- Blizzard places skyriding spells itself on a new character, sometimes after the layout went on.
    events:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
    events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    events:SetScript("OnEvent", function(_, event, slot)
        if event == "ACTIONBAR_SLOT_CHANGED" then
            if touched[slot] then
                touched[slot] = nil
                RecordSlot(slot)
            end
            return
        end
        if event == "PLAYER_REGEN_ENABLED" then
            events:UnregisterEvent(event)
        end
        Apply()
    end)
end
