LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.RowDirection = {}

local STOCK_BAR_FRAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
}

local db

-- Blizzard always stacks horizontal rows upwards from BOTTOMLEFT, so rows grow downwards by
-- mirroring each button across the bar's top edge. Vertical bars anchor TOPLEFT and are left alone.
local function Apply(number)
    local bar = _G[STOCK_BAR_FRAMES[number]]
    if not bar.isHorizontal or InCombatLockdown() then
        return
    end
    local down = db.rowsDown[number]
    local from, to = down and "BOTTOMLEFT" or "TOPLEFT", down and "TOPLEFT" or "BOTTOMLEFT"
    for _, container in ipairs(bar.shownButtonContainers) do
        local point, relativeTo, _, x, y = container:GetPoint(1)
        if point == from then
            container:ClearAllPoints()
            container:SetPoint(to, relativeTo, to, x, -y)
        end
    end
end

function LuckyActionbars.RowDirection:IsHorizontal(number)
    return _G[STOCK_BAR_FRAMES[number]].isHorizontal
end

function LuckyActionbars.RowDirection:Get(number)
    return db.rowsDown[number] and "down" or "up"
end

function LuckyActionbars.RowDirection:Set(number, direction)
    db.rowsDown[number] = direction == "down" or nil
    Apply(number)
end

-- Hooked on the layout itself, so a change to rows, icons or padding keeps the direction.
function LuckyActionbars.RowDirection:Init(database)
    db = database
    for number, name in ipairs(STOCK_BAR_FRAMES) do
        hooksecurefunc(_G[name], "UpdateGridLayout", function() Apply(number) end)
        Apply(number)
    end
end
