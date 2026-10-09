LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.RangeIndicator = {}

-- A red tint of roughly the strength of Blizzard's out-of-mana blue (0.5, 0.5, 1), so the icon stays readable.
local OUT_OF_RANGE_COLOR = { 1, 0.4, 0.4 }
LuckyActionbars.RangeIndicator.OUT_OF_RANGE_COLOR = OUT_OF_RANGE_COLOR

local db
-- Kept here rather than as a field on Blizzard's buttons, so nothing of ours is written onto them.
local outOfRange = {}

local function Recolor(button)
    if db.rangeIndicator and outOfRange[button] then
        button.icon:SetVertexColor(unpack(OUT_OF_RANGE_COLOR))
    end
end

-- Pet buttons share Blizzard's range function but have no UpdateUsable to take the red back off.
local function OnRangeUpdate(button, checksRange, inRange)
    if not button.UpdateUsable or issecretvalue(checksRange) or issecretvalue(inRange) then
        return
    end
    local wasOutOfRange = outOfRange[button]
    outOfRange[button] = (checksRange and not inRange) or nil
    if outOfRange[button] then
        Recolor(button)
    elseif wasOutOfRange then
        button:UpdateUsable()
    end
end

function LuckyActionbars.RangeIndicator:SetEnabled(enabled)
    db.rangeIndicator = enabled
    for button in pairs(outOfRange) do
        button:UpdateUsable()
    end
    LuckyActionbars.ExtraBars:ApplyButtonConfig()
end

-- UpdateUsable resets the icon colour, so each stock button is hooked to paint the red back on afterwards.
-- The extra bars tint through their library config instead.
function LuckyActionbars.RangeIndicator:Init(database)
    db = database
    for _, button in ipairs(ActionBarButtonEventsFrame.frames) do
        hooksecurefunc(button, "UpdateUsable", Recolor)
    end
    hooksecurefunc("ActionButton_UpdateRangeIndicator", OnRangeUpdate)
end
