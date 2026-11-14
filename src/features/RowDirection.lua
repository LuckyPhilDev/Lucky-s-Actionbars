LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.RowDirection = {}

local STOCK_BAR_FRAMES = {
    "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight",
    "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
}

local db

-- How far into the spare room of a shorter row its first button starts.
LuckyActionbars.RowDirection.ALIGN_SHIFT = { left = 0, center = 0.5, right = 1 }
local ALIGN_SHIFT = LuckyActionbars.RowDirection.ALIGN_SHIFT

-- Blizzard fills every row to the same length. A first row length gives the rest of the icons
-- their own even rows beneath it, so 10 icons over 2 rows with a first row of 6 is 6 then 4.
function LuckyActionbars.RowDirection.RowLengths(count, rows, first)
    local lengths = {}
    if first and rows > 1 and first < count then
        lengths[1] = first
        count, rows = count - first, rows - 1
    end
    local stride = math.ceil(count / rows)
    while count > 0 do
        local length = math.min(stride, count)
        lengths[#lengths + 1] = length
        count = count - length
    end
    return lengths
end

-- Blizzard always stacks horizontal rows upwards from BOTTOMLEFT, left aligned, in equal rows. This
-- places every button again, so rows can grow downwards, differ in length and align left, centre
-- or right, then refits the bar to the result. Vertical bars are left alone.
local function Apply(number)
    local bar = _G[STOCK_BAR_FRAMES[number]]
    if not bar.isHorizontal or InCombatLockdown() then
        return
    end
    local containers = bar.shownButtonContainers
    if #containers == 0 then
        return
    end
    local down = db.rowsDown[number]
    local anchor = down and "TOPLEFT" or "BOTTOMLEFT"
    local lengths = LuckyActionbars.RowDirection.RowLengths(#containers, bar.numRows, db.rowSplit[number])
    local padding = math.max(bar.minButtonPadding, bar.buttonPadding)
    local stepX, stepY = containers[1]:GetWidth() + padding, containers[1]:GetHeight() + padding
    local shift, widest = ALIGN_SHIFT[db.rowAlign[number] or "left"], math.max(unpack(lengths))
    local index = 1
    for row, length in ipairs(lengths) do
        local offset = shift * (widest - length) * stepX
        for column = 0, length - 1 do
            local y = (row - 1) * stepY
            containers[index]:ClearAllPoints()
            containers[index]:SetPoint(anchor, bar, anchor, offset + column * stepX, down and -y or y)
            index = index + 1
        end
    end
    bar:Layout()
end

function LuckyActionbars.RowDirection:IsShapeOffered(number)
    return db.rowShape and self:IsHorizontal(number)
end

function LuckyActionbars.RowDirection:GetSplit(number)
    return db.rowSplit[number] or 0
end

function LuckyActionbars.RowDirection:SetSplit(number, first)
    db.rowSplit[number] = first > 0 and first or nil
    Apply(number)
end

function LuckyActionbars.RowDirection:GetAlign(number)
    return db.rowAlign[number] or "left"
end

function LuckyActionbars.RowDirection:SetAlign(number, align)
    db.rowAlign[number] = align ~= "left" and align or nil
    Apply(number)
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
