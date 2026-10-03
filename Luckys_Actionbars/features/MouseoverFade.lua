LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.MouseoverFade = {}

local FADE_IN_SECONDS = 0.15
local FADE_OUT_SECONDS = 0.4
local BAR_FRAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
    "LuckyActionbarsBar9", "LuckyActionbarsBar10", "LuckyActionbarsBar11", "LuckyActionbarsBar12",
}

local db
local animator = CreateFrame("Frame")

-- A drag in progress or an open Edit Mode needs every bar visible to drop onto or arrange.
local function ShowEverything()
    return GetCursorInfo() ~= nil or EditModeManagerFrame:IsShown()
end

local function StepTowards(bar, target, elapsed)
    local alpha = bar:GetAlpha()
    if alpha < target then
        bar:SetAlpha(math.min(target, alpha + elapsed / FADE_IN_SECONDS))
    elseif alpha > target then
        bar:SetAlpha(math.max(target, alpha - elapsed / FADE_OUT_SECONDS))
    end
end

local function OnUpdate(_, elapsed)
    local showAll = ShowEverything()
    for number, name in ipairs(BAR_FRAMES) do
        local bar = _G[name]
        if bar and db.fade[number] then
            StepTowards(bar, (showAll or bar:IsMouseOver()) and 1 or 0, elapsed)
        end
    end
end

local function HasFadedBar()
    for number in ipairs(BAR_FRAMES) do
        if db.fade[number] then
            return true
        end
    end
    return false
end

function LuckyActionbars.MouseoverFade:IsFaded(number)
    return db.fade[number] == true
end

function LuckyActionbars.MouseoverFade:SetFaded(number, faded)
    db.fade[number] = faded or nil
    local bar = _G[BAR_FRAMES[number]]
    if bar and not faded then
        bar:SetAlpha(1)
    end
    animator:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
end

function LuckyActionbars.MouseoverFade:Init(database)
    db = database
    animator:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
end
