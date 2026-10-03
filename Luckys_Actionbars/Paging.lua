LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Paging = {}

local MODIFIER = "CTRL"
local PAGE = 2 -- the only page no stock bar displays
local BUTTON_COUNT = 12
local MODIFIER_PREFIXES = { "ALT-", "CTRL-", "SHIFT-", "META-" }

local pager = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
local bindingOwner = CreateFrame("Frame")
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

local function CreatePager()
    pager:SetFrameRef("bar", MainActionBar)
    for i = 1, BUTTON_COUNT do
        pager:SetFrameRef("button" .. i, _G["ActionButton" .. i])
    end
    pager:SetAttribute("_onstate-page", ON_PAGE)
    RegisterStateDriver(pager, "page",
        ("[vehicleui][overridebar][possessbar][petbattle] 0; [mod:%s] %d; 0"):format(MODIFIER:lower(), PAGE))
end

-- Holding the modifier turns "1" into "CTRL-1", so mirror each bar 1 key onto its modified twin.
local function ApplyModifierBindings()
    if InCombatLockdown() then
        bindingOwner:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    local wanted, signature = {}, {}
    for i = 1, BUTTON_COUNT do
        local command = "ACTIONBUTTON" .. i
        for _, key in ipairs({ GetBindingKey(command) }) do
            local modifiedKey = MODIFIER .. "-" .. key
            if not HasModifier(key) and GetBindingAction(modifiedKey) == "" then
                wanted[#wanted + 1] = { modifiedKey, command }
                signature[#signature + 1] = modifiedKey .. command
            end
        end
    end

    -- Setting override bindings fires UPDATE_BINDINGS, so stop once nothing changes.
    signature = table.concat(signature, "\0")
    if signature == appliedSignature then
        return
    end
    appliedSignature = signature

    ClearOverrideBindings(bindingOwner)
    for _, binding in ipairs(wanted) do
        SetOverrideBinding(bindingOwner, false, binding[1], binding[2])
    end
end

function LuckyActionbars.Paging:Init()
    CreatePager()
    ApplyModifierBindings()
    bindingOwner:RegisterEvent("UPDATE_BINDINGS")
    bindingOwner:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent(event)
        end
        ApplyModifierBindings()
    end)
end
