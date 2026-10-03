LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ExtraBars = {}

local LibEditMode = LibStub("LibEditMode")

local BAR_PAGES = { [9] = 7, [10] = 8, [11] = 9, [12] = 10 }
local BUTTON_COUNT = 12
local BUTTON_SIZE = 45

local LAYOUT_DEFAULTS = { rows = 1, icons = 12, size = 100, padding = 2 }

local db
local bars = {}
local activeLayoutName
local layoutFrame = CreateFrame("Frame")

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

-- Hooked on drag stop rather than the position callback, which also fires for arrow-key nudges.
local function SnapAfterDrag(bar)
    local dx, dy = LuckyActionbars.Snapping:Offset(bar, bars)
    if dx == 0 and dy == 0 then
        return
    end
    local point, _, _, x, y = bar:GetPoint()
    bar:ClearAllPoints()
    bar:SetPoint(point, UIParent, point, x + dx, y + dy)
    OnPositionChanged(bar, LibEditMode:GetActiveLayoutName(), point, x + dx, y + dy)
end

-- Buttons get a fixed "action" and ID 0, as Dominos does, so the stock paging and bar 1 keybinds never touch them.
local function CreateButton(bar, index)
    local button = CreateFrame("CheckButton", bar:GetName() .. "Button" .. index, bar, "ActionBarButtonTemplate")
    button:SetID(0)
    button:SetAttribute("action", (BAR_PAGES[bar.number] - 1) * BUTTON_COUNT + index)
    bar.buttons[index] = button
end

local function LayoutValue(bar, key)
    local layout = bar.layouts[activeLayoutName]
    return layout and layout[key] or LAYOUT_DEFAULTS[key]
end

local function ApplyLayout(bar)
    local icons, rows = LayoutValue(bar, "icons"), LayoutValue(bar, "rows")
    local scale, padding = LayoutValue(bar, "size") / 100, LayoutValue(bar, "padding")
    local columns = math.ceil(icons / rows)
    local step = BUTTON_SIZE * scale + padding
    for index, button in ipairs(bar.buttons) do
        local column, row = (index - 1) % columns, math.floor((index - 1) / columns)
        button:SetScale(scale)
        button:ClearAllPoints()
        -- Offsets are in the button's own scaled units.
        button:SetPoint("TOPLEFT", bar, "TOPLEFT", column * step / scale, -row * step / scale)
        button:SetShown(index <= icons)
    end
    bar:SetSize(columns * step - padding, math.ceil(icons / columns) * step - padding)
end

local function ApplyAllLayouts()
    if InCombatLockdown() then
        layoutFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    for _, bar in pairs(bars) do
        ApplyLayout(bar)
    end
end

local function FormatPercent(value)
    return value .. "%"
end

local function LayoutSlider(bar, key, minValue, maxValue, valueStep, formatter)
    return {
        kind = LibEditMode.SettingType.Slider,
        name = LuckyActionbars.Strings.bars.layout[key],
        default = LAYOUT_DEFAULTS[key],
        minValue = minValue,
        maxValue = maxValue,
        valueStep = valueStep,
        formatter = formatter,
        get = function(layoutName)
            local layout = bar.layouts[layoutName]
            return layout and layout[key] or LAYOUT_DEFAULTS[key]
        end,
        set = function(layoutName, value)
            bar.layouts[layoutName] = bar.layouts[layoutName] or {}
            bar.layouts[layoutName][key] = value
            ApplyLayout(bar)
        end,
    }
end

local function LayoutSettings(bar)
    return {
        LayoutSlider(bar, "rows", 1, 12, 1),
        LayoutSlider(bar, "icons", 6, 12, 1),
        LayoutSlider(bar, "size", 50, 200, 10, FormatPercent),
        LayoutSlider(bar, "padding", 2, 10, 1),
    }
end

local function CreateBar(number)
    local bar = CreateFrame("Frame", "LuckyActionbarsBar" .. number, UIParent)
    bar.number = number
    bar.buttons = {}
    bar.positions = db.bars[number].positions
    bar.layouts = db.bars[number].layouts
    bar:SetClampedToScreen(true)
    bar:SetDontSavePosition(true)
    for index = 1, BUTTON_COUNT do
        CreateButton(bar, index)
    end
    ApplyLayout(bar)
    ApplyPosition(bar)
    bar:SetShown(LuckyActionbars.ExtraBars:IsShown(number))
    LibEditMode:AddFrame(bar, OnPositionChanged, DefaultPosition(number), LuckyActionbars.Strings.bars.names[number])
    LibEditMode.frameSelections[bar]:HookScript("OnDragStop", function() SnapAfterDrag(bar) end)
    bar.editModeSettings = {}
    LuckyActionbars.ExtraBars:AddEditModeSettings(bar, LayoutSettings(bar))
    return bar
end

-- The library frames each slider value in an input box; stock bars show bare text. The widgets
-- are pooled with every other addon using the library, so the box comes back for their frames.
local function StyleSliders(dialog, selection)
    local ours = bars[selection.parent.number] == selection.parent
    for _, widget in ipairs(dialog.Settings.widgets) do
        local editBox = widget.EditBox
        if editBox then
            editBox.Left:SetShown(not ours)
            editBox.Middle:SetShown(not ours)
            editBox.Right:SetShown(not ours)
        end
    end
end

local function OnLayoutChanged(layoutName)
    activeLayoutName = layoutName
    ApplyAllLayouts()
    for _, bar in pairs(bars) do
        ApplyPosition(bar, layoutName)
    end
end

local function OnLayoutRenamed(oldName, newName)
    for _, bar in pairs(bars) do
        bar.positions[newName] = bar.positions[oldName]
        bar.positions[oldName] = nil
        bar.layouts[newName] = bar.layouts[oldName]
        bar.layouts[oldName] = nil
    end
end

function LuckyActionbars.ExtraBars:Frames()
    return bars
end

-- The library keeps one settings list per frame, so every module adds to this shared one.
function LuckyActionbars.ExtraBars:AddEditModeSettings(bar, settings)
    for _, setting in ipairs(settings) do
        bar.editModeSettings[#bar.editModeSettings + 1] = setting
    end
    LibEditMode:AddFrameSettings(bar, bar.editModeSettings)
end

function LuckyActionbars.ExtraBars:Page(number)
    return BAR_PAGES[number]
end

-- A bar whose page your class's forms already use would only duplicate Action Bar 1 in that form.
function LuckyActionbars.ExtraBars:FormOnPage(number)
    return LuckyActionbars.PlayerFormPages()[BAR_PAGES[number]]
end

function LuckyActionbars.ExtraBars:IsAvailable(number)
    return not self:FormOnPage(number)
end

function LuckyActionbars.ExtraBars:IsShown(number)
    return db.bars[number].shown and self:IsAvailable(number)
end

function LuckyActionbars.ExtraBars:SetShown(number, shown)
    if not self:IsAvailable(number) then
        return
    end
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
    hooksecurefunc(LibEditMode.internal.dialog, "Update", StyleSliders)
    LibEditMode:RegisterCallback("layout", OnLayoutChanged)
    LibEditMode:RegisterCallback("rename", OnLayoutRenamed)
    layoutFrame:SetScript("OnEvent", function(frame, event)
        frame:UnregisterEvent(event)
        ApplyAllLayouts()
    end)
end
