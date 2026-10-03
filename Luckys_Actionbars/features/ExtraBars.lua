LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ExtraBars = {}

local LibEditMode = LibStub("LibEditMode")

local BAR_PAGES = { [9] = 7, [10] = 8, [11] = 9, [12] = 10 }
local BUTTON_COUNT = 12
local BUTTON_SIZE = 45
local BUTTON_SPACING = 2

local db
local bars = {}

local function DefaultPosition(number)
    return { point = "CENTER", x = 0, y = -(BUTTON_SIZE + 10) * (number - 9) }
end

local function ApplyPosition(bar, layoutName)
    local position = bar.positions[layoutName] or DefaultPosition(bar.number)
    bar:ClearAllPoints()
    bar:SetPoint(position.point, UIParent, position.point, position.x, position.y)
end

local function OnPositionChanged(bar, layoutName, point, x, y)
    bar.positions[layoutName] = { point = point, x = x, y = y }
end

-- Buttons get a fixed "action" and ID 0, as Dominos does, so the stock paging and bar 1 keybinds never touch them.
local function CreateButton(bar, index)
    local button = CreateFrame("CheckButton", bar:GetName() .. "Button" .. index, bar, "ActionBarButtonTemplate")
    button:SetID(0)
    button:SetAttribute("action", (BAR_PAGES[bar.number] - 1) * BUTTON_COUNT + index)
    button:SetPoint("LEFT", (index - 1) * (BUTTON_SIZE + BUTTON_SPACING), 0)
end

local function CreateBar(number)
    local bar = CreateFrame("Frame", "LuckyActionbarsBar" .. number, UIParent)
    bar.number = number
    bar.positions = db.bars[number].positions
    bar:SetSize(BUTTON_COUNT * (BUTTON_SIZE + BUTTON_SPACING) - BUTTON_SPACING, BUTTON_SIZE)
    bar:SetClampedToScreen(true)
    bar:SetDontSavePosition(true)
    for index = 1, BUTTON_COUNT do
        CreateButton(bar, index)
    end
    ApplyPosition(bar)
    bar:SetShown(db.bars[number].shown)
    LibEditMode:AddFrame(bar, OnPositionChanged, DefaultPosition(number), LuckyActionbars.Strings.bars.names[number])
    return bar
end

local function OnLayoutChanged(layoutName)
    for _, bar in pairs(bars) do
        ApplyPosition(bar, layoutName)
    end
end

local function OnLayoutRenamed(oldName, newName)
    for _, bar in pairs(bars) do
        bar.positions[newName] = bar.positions[oldName]
        bar.positions[oldName] = nil
    end
end

function LuckyActionbars.ExtraBars:Frames()
    return bars
end

function LuckyActionbars.ExtraBars:IsShown(number)
    return db.bars[number].shown
end

function LuckyActionbars.ExtraBars:SetShown(number, shown)
    if InCombatLockdown() then
        print(LuckyActionbars.Strings.bars.combatBlocked)
        return
    end
    db.bars[number].shown = shown
    bars[number]:SetShown(shown)
end

function LuckyActionbars.ExtraBars:Init(database)
    db = database
    for number in pairs(BAR_PAGES) do
        bars[number] = CreateBar(number)
    end
    LibEditMode:RegisterCallback("layout", OnLayoutChanged)
    LibEditMode:RegisterCallback("rename", OnLayoutRenamed)
end
