LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.MouseoverFade = {}

-- Action bars are keyed by their number, other Edit Mode bars by name.
local BAR_FRAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
    "LuckyActionbarsBar9", "LuckyActionbarsBar10", "LuckyActionbarsBar11", "LuckyActionbarsBar12",
    menu = "MicroMenuContainer",
    bags = "BagsBar",
}

local IDLE_CHECK_INTERVAL = 0.05

local db
local animator = CreateFrame("Frame")
local settled = false
local idleElapsed = 0

-- A drag in progress or an open Edit Mode needs every bar visible to drop onto or arrange.
local function ShowEverything()
    return GetCursorInfo() ~= nil or EditModeManagerFrame:IsShown()
end

local function StepTowards(bar, target, elapsed)
    local alpha = bar:GetAlpha()
    if alpha < target then
        alpha = math.min(target, alpha + elapsed * 1000 / db.fadeInMs)
    elseif alpha > target then
        alpha = math.max(target, alpha - elapsed * 1000 / db.fadeOutMs)
    else
        return true
    end
    bar:SetAlpha(alpha)
    return alpha == target
end

local function OnUpdate(_, elapsed)
    if settled then
        idleElapsed = idleElapsed + elapsed
        if idleElapsed < IDLE_CHECK_INTERVAL then
            return
        end
        idleElapsed = 0
    end
    settled = true
    local showAll = ShowEverything()
    for key in pairs(db.fade) do
        local bar = _G[BAR_FRAMES[key]]
        if bar and not StepTowards(bar, (showAll or bar:IsMouseOver()) and 1 or 0, elapsed) then
            settled = false
        end
    end
end

local function HasFadedBar()
    return next(db.fade) ~= nil
end

function LuckyActionbars.MouseoverFade:IsFaded(key)
    return db.fade[key] == true
end

function LuckyActionbars.MouseoverFade:SetFaded(key, faded)
    db.fade[key] = faded or nil
    local bar = _G[BAR_FRAMES[key]]
    if bar and not faded then
        bar:SetAlpha(1)
    end
    settled = false
    animator:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
end

function LuckyActionbars.MouseoverFade:Init(database)
    db = database
    animator:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
end
