LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Tooltips = {}

LuckyActionbars.Tooltips.MODES = { "always", "outOfCombat", "modifier", "never" }

local db
local actionButtons = {}
local modifierWatcher = CreateFrame("Frame")

local function IsAllowed()
    local mode = db.tooltipMode
    if mode == "outOfCombat" then
        return not InCombatLockdown()
    elseif mode == "modifier" then
        return IsModifierKeyDown()
    end
    return mode ~= "never"
end

-- Hooked on SetAction, which Blizzard's buttons and the extra bars' library both call for every tooltip and
-- refresh, empty slots included, so a hidden tooltip stays hidden and the slot line shows on empty slots too.
local function OnSetAction(tooltip)
    local button = tooltip:GetOwner()
    if not actionButtons[button] then
        return
    end
    if db.devMode then
        GameTooltip:AddLine(LuckyActionbars.Strings.addon.actionSlot:format(button.action), 0.5, 0.8, 1)
        GameTooltip:Show()
    elseif not IsAllowed() then
        GameTooltip:Hide()
    end
end

local function HoveredButton()
    for _, frame in ipairs(GetMouseFoci()) do
        if actionButtons[frame] then
            return frame
        end
    end
end

-- Pressing the modifier while already pointing at a button shows its tooltip there and then.
-- The library's SetTooltip, unlike Blizzard's, does not anchor the tooltip itself.
local function OnModifierChanged()
    local button = HoveredButton()
    if button then
        GameTooltip_SetDefaultAnchor(GameTooltip, button)
        button:SetTooltip()
    end
end

function LuckyActionbars.Tooltips:GetMode()
    return db.tooltipMode
end

function LuckyActionbars.Tooltips:SetMode(mode)
    db.tooltipMode = mode
end

local function Track(button)
    actionButtons[button] = true
end

function LuckyActionbars.Tooltips:Init(database)
    db = database
    for _, button in ipairs(ActionBarButtonEventsFrame.frames) do
        Track(button)
    end
    LuckyActionbars.ExtraBars:ForEachButton(Track)
    hooksecurefunc(GameTooltip, "SetAction", OnSetAction)
    modifierWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
    modifierWatcher:SetScript("OnEvent", OnModifierChanged)
end
