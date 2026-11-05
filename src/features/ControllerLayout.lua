LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ControllerLayout = {}

local ControllerLayout = LuckyActionbars.ControllerLayout

-- Offsets in pixels from Blizzard's own layout: spacing is positive apart, height positive up.
ControllerLayout.SETTINGS = { "sideSpacing", "sideHeight", "topHeight", "bottomHeight", "shoulderSpacing", "shoulderHeight" }

local db, pageUnit
local baselines = {}
local afterCombat = CreateFrame("Frame")

local function Offset(key)
    return db.controller[key] or 0
end

local function Shift(region, dx, dy)
    local base = baselines[region]
    region:ClearAllPoints()
    region:SetPoint(base.point, base.relativeTo, base.relativePoint, base.x + dx, base.y + dy)
end

-- The bars are secure action buttons, so their anchors only move out of combat.
local function Apply()
    if InCombatLockdown() then
        afterCombat:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    Shift(pageUnit.BottomCenteredAnchor, 0, Offset("bottomHeight"))
    Shift(pageUnit.LeftShoulderBackground, -Offset("shoulderSpacing"), Offset("shoulderHeight"))
    Shift(pageUnit.RightShoulderBackground, Offset("shoulderSpacing"), Offset("shoulderHeight"))
    -- Compact mode stacks the other three on the bottom anchor, so they follow it.
    if not pageUnit:ShouldUseCompactLayout() then
        Shift(pageUnit.TopCenteredAnchor, 0, Offset("topHeight"))
        Shift(pageUnit.LeftCenteredAnchor, -Offset("sideSpacing"), Offset("sideHeight"))
        Shift(pageUnit.RightCenteredAnchor, Offset("sideSpacing"), Offset("sideHeight"))
    end
end

afterCombat:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    Apply()
end)

local function SaveBaseline(region)
    local point, relativeTo, relativePoint, x, y = region:GetPoint(1)
    baselines[region] = { point = point, relativeTo = relativeTo, relativePoint = relativePoint, x = x, y = y }
end

function ControllerLayout:IsAvailable()
    return pageUnit ~= nil
end

function ControllerLayout:Get(key)
    return Offset(key)
end

function ControllerLayout:Set(key, value)
    db.controller[key] = value
    Apply()
end

-- Blizzard re-anchors the top and side bars from its own saved points whenever Compact is
-- toggled, so those baselines come from that table and our offsets go back on after each refresh.
function ControllerLayout:Init(database)
    if not GamepadMainActionBarFrame then
        return
    end
    db = database
    pageUnit = GamepadMainActionBarFrame.PageUnit
    for anchor, points in pairs(pageUnit.anchorPoints) do
        baselines[anchor] = points[1]
    end
    SaveBaseline(pageUnit.BottomCenteredAnchor)
    SaveBaseline(pageUnit.LeftShoulderBackground)
    SaveBaseline(pageUnit.RightShoulderBackground)
    hooksecurefunc(pageUnit, "RefreshCompactLayout", Apply)
    Apply()
end
