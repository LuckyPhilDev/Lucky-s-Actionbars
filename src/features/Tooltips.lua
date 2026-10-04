LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Tooltips = {}

LuckyActionbars.Tooltips.MODES = { "always", "outOfCombat", "modifier", "never" }

local db
local hookedButtons = {}
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

-- SetTooltip leaves the tooltip owned by the button but empty on an empty slot, so the slot line shows there too.
local function OnSetTooltip(button)
    if db.devMode then
        GameTooltip:AddLine(LuckyActionbars.Strings.addon.actionSlot:format(button.action), 0.5, 0.8, 1)
        GameTooltip:Show()
    elseif not IsAllowed() then
        GameTooltip:Hide()
    end
end

local function HoveredButton()
    for _, frame in ipairs(GetMouseFoci()) do
        if hookedButtons[frame] then
            return frame
        end
    end
end

-- Pressing the modifier while already pointing at a button shows its tooltip there and then.
local function OnModifierChanged()
    local button = HoveredButton()
    if button then
        button:SetTooltip()
    end
end

function LuckyActionbars.Tooltips:GetMode()
    return db.tooltipMode
end

function LuckyActionbars.Tooltips:SetMode(mode)
    db.tooltipMode = mode
end

-- Hooked on SetTooltip, which Blizzard also re-runs every tooltip refresh, so a hidden tooltip stays hidden.
function LuckyActionbars.Tooltips:Init(database)
    db = database
    for _, button in pairs(ActionBarButtonEventsFrame.frames) do
        hooksecurefunc(button, "SetTooltip", OnSetTooltip)
        hookedButtons[button] = true
    end
    modifierWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
    modifierWatcher:SetScript("OnEvent", OnModifierChanged)
end
