LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.MouseoverFade = {}

local POLL_SECONDS = 0.1
local BAR_FRAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
    "LuckyActionbarsBar9", "LuckyActionbarsBar10", "LuckyActionbarsBar11", "LuckyActionbarsBar12",
}

local db
local poller = CreateFrame("Frame")
local elapsedSinceCheck = 0

-- A drag in progress or an open Edit Mode needs every bar visible to drop onto or arrange.
local function ShowEverything()
    return GetCursorInfo() ~= nil or EditModeManagerFrame:IsShown()
end

local function UpdateAlphas()
    local showAll = ShowEverything()
    for number, name in ipairs(BAR_FRAMES) do
        local bar = _G[name]
        if bar and db.fade[number] then
            bar:SetAlpha((showAll or bar:IsMouseOver()) and 1 or 0)
        end
    end
end

local function OnUpdate(_, elapsed)
    elapsedSinceCheck = elapsedSinceCheck + elapsed
    if elapsedSinceCheck >= POLL_SECONDS then
        elapsedSinceCheck = 0
        UpdateAlphas()
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
    poller:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
    UpdateAlphas()
end

function LuckyActionbars.MouseoverFade:Init(database)
    db = database
    poller:SetScript("OnUpdate", HasFadedBar() and OnUpdate or nil)
    UpdateAlphas()
end
