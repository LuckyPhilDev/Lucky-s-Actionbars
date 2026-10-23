LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ActionButtons = {}

local LAB = LibStub("LibActionButton-1.0")
local LBG = LibStub("LibButtonGlow-1.0")
local Masque = LibStub("Masque", true)

local db
local buttons = {}
local isOwnButton, spellAlerts = {}, {}
-- Per button: the binding command it shows and Quick Keybind sets, and whether its bar shows empty slots.
local keyBoundTargets, showEmptyTests = {}, {}
local configPending = false
local events = CreateFrame("Frame")

-- Stock bars mark range on the hotkey; with the range indicator on, the icon is tinted instead.
local function ButtonConfig(button)
    return {
        -- Empty slots are faded by UpdateEmpty, which also follows the spellbook and Quick Keybind.
        showGrid = true,
        actionButtonUI = true,
        spellCastVFX = true,
        outOfRangeColoring = db.rangeIndicator and "button" or "hotkey",
        colors = { range = LuckyActionbars.RangeIndicator.OUT_OF_RANGE_COLOR, mana = { 0.5, 0.5, 1 } },
        keyBoundTarget = keyBoundTargets[button] or false,
    }
end

-- The library's buttons lack Blizzard's Quick Keybind template, so it is wired on the way Blizzard's bars wire it.
local function AddQuickKeybind(button)
    Mixin(button, QuickKeybindButtonTemplateMixin)
    local highlight = button:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.4)
    highlight:Hide()
    button.QuickKeybindHighlightTexture = highlight
    button:HookScript("OnEnter", button.QuickKeybindButtonOnEnter)
    button:HookScript("OnLeave", button.QuickKeybindButtonOnLeave)
    button:HookScript("OnShow", button.QuickKeybindButtonOnShow)
    button:HookScript("OnHide", button.QuickKeybindButtonOnHide)
    button:HookScript("OnClick", button.QuickKeybindButtonOnClick)
    button:QuickKeybindButtonOnShow()
end

-- Blizzard only lights up the buttons it knows by name when Quick Keybind mode toggles.
local function SetQuickKeybindHighlights(_, shown)
    for _, button in ipairs(buttons) do
        button:DoModeChange(shown)
    end
end

-- Our own copy of Blizzard's proc animation, not ActionButtonSpellAlertManager, whose shared alert list an
-- addon would taint.
local function ShowSpellAlert(button)
    local alert = spellAlerts[button]
    if not alert then
        alert = CreateFrame("Frame", nil, button, "ActionButtonSpellAlertTemplate")
        local width, height = button:GetSize()
        alert:SetSize(width * 1.4, height * 1.4)
        alert:SetPoint("CENTER")
        alert:SetFrameLevel(button:GetFrameLevel() + 5)
        spellAlerts[button] = alert
    end
    if not alert:IsShown() then
        alert:Show()
        alert.ProcStartAnim:Play()
    end
end

local function HideSpellAlert(button)
    local alert = spellAlerts[button]
    if alert then
        alert:Hide()
        alert.ProcStartAnim:Stop()
    end
end

-- LibActionButton only glows through LibButtonGlow, whose ants predate Blizzard's current proc art, so on our
-- buttons its overlay goes straight back to its pool, as its own fade-out would leave it.
-- ponytail: leans on LibButtonGlow internals (__LBGoverlay, unusedOverlays); recheck when updating the library.
local function ReplaceButtonGlow(button)
    if not isOwnButton[button] then return end
    local overlay = button.__LBGoverlay
    if overlay then
        overlay:Hide()
        tinsert(LBG.unusedOverlays, overlay)
        button.__LBGoverlay = nil
    end
    ShowSpellAlert(button)
end

-- Blizzard's Single-Button Assistant frame, which LibActionButton puts on our buttons, refreshes the slot with
-- C_ActionBar.ForceUpdateAction, which is forbidden to addons. The button reads the next spell without it.
local function RefreshAssistedAction(frame, elapsed)
    frame.updateTimeLeft = frame.updateTimeLeft - elapsed
    if frame.updateTimeLeft <= 0 then
        frame:GetParent():OnActionBarSlotChanged()
        frame.updateTimeLeft = AssistedCombatManager:GetUpdateRate()
    end
end

local function TakeOverAssistedRefresh(frame)
    if isOwnButton[frame:GetParent()] then
        frame:SetScript("OnUpdate", RefreshAssistedAction)
    end
end

local function UpdateAllEmpty()
    for _, button in ipairs(buttons) do
        LuckyActionbars.ActionButtons:UpdateEmpty(button)
    end
end

-- Lock Action Bars leaves only a Shift-drag able to take an action off a button, as on Blizzard's bars.
local function Configure(button)
    button:UpdateConfig(ButtonConfig(button))
    button:SetAttribute("buttonlock", GetCVarBool("lockActionBars"))
end

-- Updating a config re-sets secure attributes, so in combat it waits for the fight to end.
local function ApplyConfig()
    if InCombatLockdown() then
        configPending = true
        events:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    configPending = false
    for _, button in ipairs(buttons) do
        Configure(button)
    end
    -- The config shows every slot again.
    UpdateAllEmpty()
end

local libGetHotkey

-- The library shows the raw key ("ALT-D") unless KeyBound is loaded; stock bars abbreviate it ("a-D").
local function GetAbbreviatedHotkey(button)
    local key = libGetHotkey(button)
    return (key and not KeyBound) and GetBindingText(key, true) or key
end

-- LibActionButton rather than Blizzard's ActionBarButtonTemplate, whose OnLoad registers slot 1 for range
-- checks before a slot can be given, which hard-crashes the Classic beta client, and whose updates error on
-- secret cooldowns when an addon pages them in combat.
-- keyBoundTarget is the binding command the button answers to, or nil for its own click binding.
function LuckyActionbars.ActionButtons:Create(index, name, header, keyBoundTarget, showEmpty, masqueGroupName)
    local button = LAB:CreateButton(index, name, header)
    buttons[#buttons + 1] = button
    isOwnButton[button] = true
    keyBoundTargets[button] = keyBoundTarget
    showEmptyTests[button] = showEmpty
    libGetHotkey = libGetHotkey or button.GetHotkey
    button.GetHotkey = GetAbbreviatedHotkey
    Configure(button)
    -- The library binds and shows hotkeys for this command, and Quick Keybind and Import read it.
    button.commandName = button:GetBindingAction()
    AddQuickKeybind(button)
    if Masque then
        button:AddToMasque(Masque:Group("Lucky's Actionbars", masqueGroupName))
    end
    return button
end

-- Alpha rather than Hide, so it can change in combat; the slot keeps its place as Blizzard's spacers do.
function LuckyActionbars.ActionButtons:UpdateEmpty(button)
    button:SetAlpha((showEmptyTests[button]() or button:HasAction()) and 1 or 0)
end

function LuckyActionbars.ActionButtons:ForEach(fn)
    for _, button in ipairs(buttons) do
        fn(button)
    end
end

function LuckyActionbars.ActionButtons:ApplyConfig()
    ApplyConfig()
end

function LuckyActionbars.ActionButtons:Init(database)
    db = database
    hooksecurefunc(LBG, "ShowOverlayGlow", ReplaceButtonGlow)
    hooksecurefunc(LBG, "HideOverlayGlow", HideSpellAlert)
    if ActionBarButtonAssistedCombatRotationFrameMixin then
        hooksecurefunc(ActionBarButtonAssistedCombatRotationFrameMixin, "OnLoad", TakeOverAssistedRefresh)
    end
    EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeEnabled", SetQuickKeybindHighlights, buttons, true)
    EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", SetQuickKeybindHighlights, buttons, false)
    -- Fires after a button takes a new action, which is how a page change in combat reaches the alpha.
    LAB.RegisterCallback(self, "OnButtonUpdate", function(_, button)
        if showEmptyTests[button] then
            self:UpdateEmpty(button)
        end
    end)
    events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    events:RegisterEvent("CVAR_UPDATE")
    events:SetScript("OnEvent", function(_, event, cvar)
        if event == "CVAR_UPDATE" then
            if cvar == "lockActionBars" then
                ApplyConfig()
            end
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            events:UnregisterEvent(event)
            if configPending then
                ApplyConfig()
            end
            return
        end
        UpdateAllEmpty()
    end)
end
