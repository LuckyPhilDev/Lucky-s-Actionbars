LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Snapping = {}

local THRESHOLD = 10
local STOCK_BAR_NAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
}

local function Edges(frame)
    local scale = frame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local left, bottom, width, height = frame:GetRect()
    if not left then
        return nil
    end
    left, bottom = left * scale, bottom * scale
    return left, left + width * scale, bottom, bottom + height * scale
end

-- Returns the smallest move that lines one of our edges up with one of theirs, or 0.
local function ClosestOffset(best, mineLow, mineHigh, theirsLow, theirsHigh)
    for _, mine in ipairs({ mineLow, mineHigh }) do
        for _, theirs in ipairs({ theirsLow, theirsHigh }) do
            local offset = theirs - mine
            if math.abs(offset) <= THRESHOLD and (best == 0 or math.abs(offset) < math.abs(best)) then
                best = offset
            end
        end
    end
    return best
end

local function Candidates(bar, extraBars)
    local frames = { UIParent }
    for _, name in ipairs(STOCK_BAR_NAMES) do
        local frame = _G[name]
        if frame and frame:IsShown() then
            frames[#frames + 1] = frame
        end
    end
    for _, other in pairs(extraBars) do
        if other ~= bar and other:IsShown() then
            frames[#frames + 1] = other
        end
    end
    return frames
end

function LuckyActionbars.Snapping:Offset(bar, extraBars)
    if not EditModeManagerFrame:IsSnapEnabled() then
        return 0, 0
    end
    local left, right, bottom, top = Edges(bar)
    local dx, dy = 0, 0
    for _, frame in ipairs(Candidates(bar, extraBars)) do
        local otherLeft, otherRight, otherBottom, otherTop = Edges(frame)
        if otherLeft then
            dx = ClosestOffset(dx, left, right, otherLeft, otherRight)
            dy = ClosestOffset(dy, bottom, top, otherBottom, otherTop)
        end
    end
    return dx, dy
end
