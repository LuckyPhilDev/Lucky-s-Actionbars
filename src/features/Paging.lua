LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Paging = {}

-- Combinations come first: a state driver takes the first match, and [mod:ctrl] also matches Ctrl+Shift.
local TRIGGERS = {
    { key = "ALT-CTRL", condition = "mod:alt,mod:ctrl", keyPrefix = "ALT-CTRL-", more = true },
    { key = "ALT-SHIFT", condition = "mod:alt,mod:shift", keyPrefix = "ALT-SHIFT-", more = true },
    { key = "CTRL-SHIFT", condition = "mod:ctrl,mod:shift", keyPrefix = "CTRL-SHIFT-", more = true },
    { key = "CTRL", condition = "mod:ctrl", keyPrefix = "CTRL-" },
    { key = "ALT", condition = "mod:alt", keyPrefix = "ALT-" },
    { key = "SHIFT", condition = "mod:shift", keyPrefix = "SHIFT-" },
    -- A form's bonus bar N is the page 6 + N it puts on Action Bar 1, as in CLASS_FORM_PAGES.
    { key = "cat", condition = "bonusbar:1", form = true },
    { key = "stealth", condition = "bonusbar:1", form = true },
    { key = "bear", condition = "bonusbar:3", form = true },
    { key = "moonkin", condition = "bonusbar:4", form = true },
    { key = "HELP", condition = "help", more = true },
}
local SETTINGS_ORDER = { "CTRL", "ALT", "SHIFT", "CTRL-SHIFT", "ALT-CTRL", "ALT-SHIFT",
    "cat", "bear", "moonkin", "stealth", "HELP" }
-- Bar 1 has no home page: Blizzard picks it from forms and vehicles, which ON_PAGE mirrors.
local BARS = {
    { frame = "MainActionBar", buttons = "ActionButton", command = "ACTIONBUTTON" },
    { frame = "MultiBarBottomLeft", buttons = "MultiBarBottomLeftButton", command = "MULTIACTIONBAR1BUTTON", homePage = 6 },
    { frame = "MultiBarBottomRight", buttons = "MultiBarBottomRightButton", command = "MULTIACTIONBAR2BUTTON", homePage = 5 },
    { frame = "MultiBarRight", buttons = "MultiBarRightButton", command = "MULTIACTIONBAR3BUTTON", homePage = 3 },
    { frame = "MultiBarLeft", buttons = "MultiBarLeftButton", command = "MULTIACTIONBAR4BUTTON", homePage = 4 },
    { frame = "MultiBar5", buttons = "MultiBar5Button", command = "MULTIACTIONBAR5BUTTON", homePage = 13 },
    { frame = "MultiBar6", buttons = "MultiBar6Button", command = "MULTIACTIONBAR6BUTTON", homePage = 14 },
    { frame = "MultiBar7", buttons = "MultiBar7Button", command = "MULTIACTIONBAR7BUTTON", homePage = 15 },
}
local PAGEABLE = { 1, 2, 3, 4, 5, 7, 8, 9, 10, 13, 14, 15 }
local BUTTON_COUNT = 12
local MODIFIER_PREFIXES = { "ALT-", "CTRL-", "SHIFT-", "META-" }

local db
local allowedPages, isAllowed = {}, {}
local pagers = {}
local eventFrame = CreateFrame("Frame")
local appliedSignature

-- State 0 returns the bar to its home page, or for bar 1 to the page ActionBarController_UpdateAll would pick.
-- Touching an attribute on each button makes it re-resolve its slot, even in combat.
local ON_PAGE = ([[
    local page = tonumber(newstate)
    if page == 0 then
        page = self:GetAttribute("homepage")
    end
    if not page then
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

local triggersByKey = {}
for _, trigger in ipairs(TRIGGERS) do
    triggersByKey[trigger.key] = trigger
end

-- Pages behind More paging options stay saved while it is off, they just stop applying.
-- Form triggers are only for your own class's forms, and not on Action Bar 1, which Blizzard
-- already pages for them.
local function IsOffered(number, trigger)
    if trigger.more then
        return db.morePaging
    end
    if trigger.form then
        return number ~= 1 and tInvert(LuckyActionbars.PlayerFormPages())[trigger.key] ~= nil
    end
    return true
end

local function ActiveTriggers(number)
    local active = {}
    for _, trigger in ipairs(TRIGGERS) do
        local page = db.paging[number][trigger.key]
        if isAllowed[page] and IsOffered(number, trigger) then
            active[#active + 1] = { trigger = trigger, page = page }
        end
    end
    return active
end

local function BuildConditions(active)
    local parts = { "[vehicleui][overridebar][possessbar][petbattle] 0" }
    for _, entry in ipairs(active) do
        parts[#parts + 1] = ("[%s] %d"):format(entry.trigger.condition, entry.page)
    end
    parts[#parts + 1] = "0"
    return table.concat(parts, "; ")
end

-- Holding a modifier turns "1" into "CTRL-1", so mirror each paged bar's keys onto their modified twins.
local function AddModifierBindings(wanted, signature, bar, active)
    for _, entry in ipairs(active) do
        local keyPrefix = entry.trigger.keyPrefix
        if keyPrefix then
            for i = 1, BUTTON_COUNT do
                local command = bar.command .. i
                for _, key in ipairs({ GetBindingKey(command) }) do
                    local modifiedKey = keyPrefix .. key
                    if not HasModifier(key) and GetBindingAction(modifiedKey) == "" then
                        wanted[#wanted + 1] = { modifiedKey, command }
                        signature[#signature + 1] = modifiedKey .. command
                    end
                end
            end
        end
    end
end

local function ApplyBindings(wanted, signature)
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

local function CreatePager(bar)
    local pager = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    pager:SetFrameRef("bar", _G[bar.frame])
    for i = 1, BUTTON_COUNT do
        pager:SetFrameRef("button" .. i, _G[bar.buttons .. i])
    end
    if bar.homePage then
        pager:SetAttribute("homepage", bar.homePage)
    end
    pager:SetAttribute("_onstate-page", ON_PAGE)
    return pager
end

local function CollectAllowedPages()
    local taken = LuckyActionbars.PlayerFormPages()
    for _, page in ipairs(PAGEABLE) do
        if not taken[page] then
            allowedPages[#allowedPages + 1] = page
            isAllowed[page] = true
        end
    end
end

LuckyActionbars.Paging.TRIGGERS = SETTINGS_ORDER
LuckyActionbars.Paging.BAR_COUNT = #BARS

function LuckyActionbars.Paging:AllowedPages()
    return allowedPages
end

function LuckyActionbars.Paging:BindingCommand(number, index)
    return BARS[number].command .. index
end

function LuckyActionbars.Paging:HomePage(number)
    return BARS[number].homePage
end

function LuckyActionbars.Paging:IsTriggerOffered(number, triggerKey)
    return IsOffered(number, triggersByKey[triggerKey])
end

function LuckyActionbars.Paging:SetMorePaging(enabled)
    db.morePaging = enabled
    self:Apply()
end

function LuckyActionbars.Paging:GetPage(number, triggerKey)
    return db.paging[number][triggerKey] or 0
end

function LuckyActionbars.Paging:SetPage(number, triggerKey, page)
    db.paging[number][triggerKey] = page ~= 0 and page or nil
    self:Apply()
end

function LuckyActionbars.Paging:Apply()
    if InCombatLockdown() then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local wanted, signature = {}, {}
    for number, bar in ipairs(BARS) do
        local active = ActiveTriggers(number)
        local pager = pagers[number]
        if #active > 0 then
            RegisterStateDriver(pager, "page", BuildConditions(active))
            pager.driven = true
        elseif pager.driven then
            -- Bars that never paged are left alone; one that stops paging is handed back to its home page.
            UnregisterStateDriver(pager, "page")
            pager:SetAttribute("state-page", "0")
            pager.driven = nil
        end
        AddModifierBindings(wanted, signature, bar, active)
    end
    ApplyBindings(wanted, signature)
end

function LuckyActionbars.Paging:Init(database)
    db = database
    CollectAllowedPages()
    for number, bar in ipairs(BARS) do
        pagers[number] = CreatePager(bar)
    end
    self:Apply()
    eventFrame:RegisterEvent("UPDATE_BINDINGS")
    eventFrame:SetScript("OnEvent", function(frame, event)
        if event == "PLAYER_REGEN_ENABLED" then
            frame:UnregisterEvent(event)
        end
        LuckyActionbars.Paging:Apply()
    end)
end
