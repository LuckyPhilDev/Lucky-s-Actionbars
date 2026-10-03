LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Paging = {}

local MODIFIERS = { "CTRL", "ALT", "SHIFT" }
local PAGEABLE = { 1, 2, 3, 4, 5, 7, 8, 9, 10, 13, 14, 15 }
-- Pages the class's own forms already put on Action Bar 1 (Cat, Bear, Moonkin, Stealth, Soar).
local CLASS_FORM_PAGES = {
    DRUID = { [7] = true, [8] = true, [9] = true, [10] = true },
    ROGUE = { [7] = true },
    EVOKER = { [7] = true },
}
local BUTTON_COUNT = 12
local MODIFIER_PREFIXES = { "ALT-", "CTRL-", "SHIFT-", "META-" }

local db
local allowedPages, isAllowed = {}, {}
local pager = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
local eventFrame = CreateFrame("Frame")
local appliedSignature

-- State 0 hands the bar back using the same rules as ActionBarController_UpdateAll.
-- Touching an attribute on each button makes it re-resolve its slot, even in combat.
local ON_PAGE = ([[
    local page = tonumber(newstate)
    if page == 0 then
        if HasVehicleActionBar() then
            page = GetVehicleBarIndex()
        elseif HasOverrideActionBar() then
            page = GetOverrideBarIndex()
        elseif HasTempShapeshiftActionBar() then
            page = GetTempShapeshiftBarIndex()
        elseif HasBonusActionBar() and GetActionBarPage() == 1 then
            page = GetBonusBarIndex()
        else
            page = GetActionBarPage()
        end
    end
    self:GetFrameRef("bar"):SetAttribute("actionpage", page)
    for i = 1, %d do
        self:GetFrameRef("button" .. i):SetAttribute("lucky-actionpage", page)
    end
]]):format(BUTTON_COUNT)

local function HasModifier(key)
    for _, prefix in ipairs(MODIFIER_PREFIXES) do
        if key:sub(1, #prefix) == prefix then
            return true
        end
    end
    return false
end

local function ActiveModifiers()
    local active = {}
    for _, modifier in ipairs(MODIFIERS) do
        local page = db.pages[modifier]
        if isAllowed[page] then
            active[#active + 1] = { modifier = modifier, page = page }
        end
    end
    return active
end

local function BuildConditions(active)
    local parts = { "[vehicleui][overridebar][possessbar][petbattle] 0" }
    for _, entry in ipairs(active) do
        parts[#parts + 1] = ("[mod:%s] %d"):format(entry.modifier:lower(), entry.page)
    end
    parts[#parts + 1] = "0"
    return table.concat(parts, "; ")
end

-- Holding a modifier turns "1" into "CTRL-1", so mirror each bar 1 key onto its modified twin.
local function ApplyModifierBindings(active)
    local wanted, signature = {}, {}
    for _, entry in ipairs(active) do
        for i = 1, BUTTON_COUNT do
            local command = "ACTIONBUTTON" .. i
            for _, key in ipairs({ GetBindingKey(command) }) do
                local modifiedKey = entry.modifier .. "-" .. key
                if not HasModifier(key) and GetBindingAction(modifiedKey) == "" then
                    wanted[#wanted + 1] = { modifiedKey, command }
                    signature[#signature + 1] = modifiedKey .. command
                end
            end
        end
    end

    -- Setting override bindings fires UPDATE_BINDINGS, so stop once nothing changes.
    signature = table.concat(signature, "\0")
    if signature == appliedSignature then
        return
    end
    appliedSignature = signature

    ClearOverrideBindings(eventFrame)
    for _, binding in ipairs(wanted) do
        SetOverrideBinding(eventFrame, false, binding[1], binding[2])
    end
end

local function CreatePager()
    pager:SetFrameRef("bar", MainActionBar)
    for i = 1, BUTTON_COUNT do
        pager:SetFrameRef("button" .. i, _G["ActionButton" .. i])
    end
    pager:SetAttribute("_onstate-page", ON_PAGE)
end

local function CollectAllowedPages()
    local _, class = UnitClass("player")
    local taken = CLASS_FORM_PAGES[class] or {}
    for _, page in ipairs(PAGEABLE) do
        if not taken[page] then
            allowedPages[#allowedPages + 1] = page
            isAllowed[page] = true
        end
    end
end

LuckyActionbars.Paging.MODIFIERS = MODIFIERS

function LuckyActionbars.Paging:AllowedPages()
    return allowedPages
end

function LuckyActionbars.Paging:Apply()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local active = ActiveModifiers()
    RegisterStateDriver(pager, "page", BuildConditions(active))
    ApplyModifierBindings(active)
end

function LuckyActionbars.Paging:Init(database)
    db = database
    CollectAllowedPages()
    CreatePager()
    self:Apply()
    eventFrame:RegisterEvent("UPDATE_BINDINGS")
    eventFrame:SetScript("OnEvent", function(frame, event)
        if event == "PLAYER_REGEN_ENABLED" then
            frame:UnregisterEvent(event)
        end
        LuckyActionbars.Paging:Apply()
    end)
end
