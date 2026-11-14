LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ExtraBars = {}

local LibEditMode = LibStub("LibEditMode")

local BAR_PAGES = { [9] = 7, [10] = 8, [11] = 9, [12] = 10 }
local BUTTON_COUNT = 12
local BUTTON_SIZE = 45

local LAYOUT_DEFAULTS = {
    orientation = "horizontal", rowsGrow = "up", rowSplit = 0, rowAlign = "left", rows = 1, icons = 12, size = 100, padding = 2,
    visibility = "always", alwaysShowButtons = true,
}

local VISIBILITY_DRIVERS = {
    always = "show",
    inCombat = "[combat] show; hide",
    outOfCombat = "[combat] hide; show",
    hidden = "hide",
}

local db
local bars = {}
local activeLayoutName
local editModeActive = false
-- Bit flags of why empty slots are on show (a drag, the spellbook, Quick Keybind), as Blizzard's bars track them.
local gridReasons = 0
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

local function LayoutValue(bar, key, layoutName)
    local layout = bar.layouts[layoutName or activeLayoutName]
    if layout and layout[key] ~= nil then
        return layout[key]
    end
    return LAYOUT_DEFAULTS[key]
end

local function UpdateEmptyButtons(bar)
    for _, button in ipairs(bar.buttons) do
        LuckyActionbars.ActionButtons:UpdateEmpty(button)
    end
end

local function CreateButton(bar, index)
    local button = LuckyActionbars.ActionButtons:Create(index, bar:GetName() .. "Button" .. index, bar, nil,
        function() return LayoutValue(bar, "alwaysShowButtons") or gridReasons > 0 end,
        LuckyActionbars.Strings.bars.names[bar.number])
    button:SetState(0, "action", (BAR_PAGES[bar.number] - 1) * BUTTON_COUNT + index)
    _G["BINDING_NAME_" .. button.commandName] = LuckyActionbars.Strings.bars.buttonName:format(
        LuckyActionbars.Strings.bars.names[bar.number], index)
    bar.buttons[index] = button
end

local function VisibilityDriver(bar)
    if editModeActive or gridReasons > 0 then
        return "show"
    end
    return VISIBILITY_DRIVERS[LayoutValue(bar, "visibility")]
end

-- A state driver, so In Combat and Out of Combat can switch the bar mid-fight.
local function ApplyVisibility(bar)
    if LuckyActionbars.ExtraBars:IsShown(bar.number) then
        RegisterStateDriver(bar, "visibility", VisibilityDriver(bar))
    else
        UnregisterStateDriver(bar, "visibility")
        bar:Hide()
    end
end

-- Mirrors Blizzard's grid: horizontal bars fill rows left to right and stack them upwards
-- (or downwards, by choice), vertical bars fill columns top to bottom and stack them rightwards.
local function ApplyLayout(bar)
    local icons, lines = LayoutValue(bar, "icons"), LayoutValue(bar, "rows")
    local scale, padding = LayoutValue(bar, "size") / 100, LayoutValue(bar, "padding")
    local horizontal = LayoutValue(bar, "orientation") == "horizontal"
    local rowsUp = horizontal and LayoutValue(bar, "rowsGrow") == "up"
    local first = horizontal and LayoutValue(bar, "rowSplit") or 0
    local lengths = LuckyActionbars.RowDirection.RowLengths(icons, lines, first > 0 and first or nil)
    local widest = math.max(unpack(lengths))
    local shift = horizontal and LuckyActionbars.RowDirection.ALIGN_SHIFT[LayoutValue(bar, "rowAlign")] or 0
    local step = BUTTON_SIZE * scale + padding
    local anchor = rowsUp and "BOTTOMLEFT" or "TOPLEFT"
    local index = 1
    for across, length in ipairs(lengths) do
        for position = 0, length - 1 do
            local along = position + shift * (widest - length)
            local x, y = along, rowsUp and across - 1 or 1 - across
            if not horizontal then
                x, y = across - 1, -along
            end
            local button = bar.buttons[index]
            button:SetScale(scale)
            button:ClearAllPoints()
            -- Offsets are in the button's own scaled units.
            button:SetPoint(anchor, bar, anchor, x * step / scale, y * step / scale)
            button:SetShown(true)
            index = index + 1
        end
    end
    for hidden = index, #bar.buttons do
        bar.buttons[hidden]:Hide()
    end
    local long, short = widest * step - padding, #lengths * step - padding
    if horizontal then
        bar:SetSize(long, short)
    else
        bar:SetSize(short, long)
    end
    UpdateEmptyButtons(bar)
    ApplyVisibility(bar)
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

local function SetGridShown(shown, reason)
    if shown then
        gridReasons = bit.bor(gridReasons, reason)
    else
        gridReasons = bit.band(gridReasons, bit.bnot(reason))
    end
    for _, bar in pairs(bars) do
        UpdateEmptyButtons(bar)
    end
    ApplyAllLayouts()
end

local function SetEditModeActive(active)
    editModeActive = active
    ApplyAllLayouts()
end

local EVENT_HANDLERS = {
    PLAYER_REGEN_ENABLED = function(frame, event)
        frame:UnregisterEvent(event)
        ApplyAllLayouts()
    end,
    ACTIONBAR_SHOWGRID = function() SetGridShown(true, ACTION_BUTTON_SHOW_GRID_REASON_EVENT) end,
    ACTIONBAR_HIDEGRID = function() SetGridShown(false, ACTION_BUTTON_SHOW_GRID_REASON_EVENT) end,
}

local function FormatPercent(value)
    return value .. "%"
end

local function LayoutSetting(bar, key, setting)
    setting.default = LAYOUT_DEFAULTS[key]
    setting.get = function(layoutName) return LayoutValue(bar, key, layoutName) end
    setting.set = function(layoutName, value)
        bar.layouts[layoutName] = bar.layouts[layoutName] or {}
        bar.layouts[layoutName][key] = value
        ApplyLayout(bar)
    end
    return setting
end

local function LayoutSlider(bar, key, minValue, maxValue, valueStep, formatter)
    return LayoutSetting(bar, key, {
        kind = LibEditMode.SettingType.Slider,
        name = LuckyActionbars.Strings.bars.layout[key],
        minValue = minValue,
        maxValue = maxValue,
        valueStep = valueStep,
        formatter = formatter,
    })
end

local function LayoutDropdown(bar, key, options)
    local S = LuckyActionbars.Strings.bars[key]
    local values = {}
    for _, option in ipairs(options) do
        values[#values + 1] = { text = S[option], value = option }
    end
    return LayoutSetting(bar, key, { kind = LibEditMode.SettingType.Dropdown, name = S.label, values = values })
end

local function IsVertical(layoutName, bar)
    return LayoutValue(bar, "orientation", layoutName) == "vertical"
end

-- Blizzard renames "# of Rows" to "# of Columns" on vertical bars. The library's labels are
-- fixed, so two sliders share the value and each hides in the other orientation.
local function LineSliders(bar)
    local rows = LayoutSlider(bar, "rows", 1, 12, 1)
    rows.hidden = function(layoutName) return IsVertical(layoutName, bar) end
    local columns = LayoutSlider(bar, "rows", 1, 12, 1)
    columns.name = LuckyActionbars.Strings.bars.layout.columns
    columns.hidden = function(layoutName) return not IsVertical(layoutName, bar) end
    return rows, columns
end

local function LayoutSettings(bar)
    local rows, columns = LineSliders(bar)
    return {
        LayoutDropdown(bar, "orientation", { "horizontal", "vertical" }),
        rows,
        columns,
        LayoutSlider(bar, "icons", 6, 12, 1),
        LayoutSlider(bar, "size", 50, 200, 10, FormatPercent),
        LayoutSlider(bar, "padding", 2, 10, 1),
        LayoutDropdown(bar, "visibility", { "always", "inCombat", "outOfCombat", "hidden" }),
        LayoutSetting(bar, "alwaysShowButtons", {
            kind = LibEditMode.SettingType.Checkbox,
            name = LuckyActionbars.Strings.bars.alwaysShowButtons,
        }),
    }
end

local function CreateBar(number)
    -- The library drives its buttons' secure snippets through their parent, so the bar is a secure handler.
    local bar = CreateFrame("Frame", "LuckyActionbarsBar" .. number, UIParent, "SecureHandlerStateTemplate")
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
    LibEditMode:AddFrame(bar, OnPositionChanged, DefaultPosition(number),
        LuckyActionbars.Utils.Mark(LuckyActionbars.Strings.bars.names[number]))
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

-- Built here for the layout it reads, but added by EditModePanel so it sits under Hidden until hovered.
function LuckyActionbars.ExtraBars:RowsGrowSetting(bar)
    local setting = LayoutDropdown(bar, "rowsGrow", { "up", "down" })
    setting.name = LuckyActionbars.Utils.Mark(setting.name)
    setting.desc = LuckyActionbars.Strings.bars.rowsGrow.desc
    setting.hidden = function(layoutName) return IsVertical(layoutName, bar) end
    return setting
end

function LuckyActionbars.ExtraBars:RowSplitSetting(bar)
    local S = LuckyActionbars.Strings.bars.rowSplit
    local setting = LayoutSlider(bar, "rowSplit", 0, 12, 1, function(value) return value == 0 and S.even or value end)
    setting.name = LuckyActionbars.Utils.Mark(S.label)
    setting.desc = S.desc
    setting.hidden = function(layoutName) return IsVertical(layoutName, bar) or not db.rowShape end
    return setting
end

function LuckyActionbars.ExtraBars:RowAlignSetting(bar)
    local S = LuckyActionbars.Strings.bars.rowAlign
    local setting = LayoutDropdown(bar, "rowAlign", { "left", "center", "right" })
    setting.name = LuckyActionbars.Utils.Mark(S.label)
    setting.desc = S.desc
    setting.hidden = function(layoutName) return IsVertical(layoutName, bar) or not db.rowShape end
    return setting
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
    ApplyVisibility(bars[number])
end

function LuckyActionbars.ExtraBars:Init(database)
    db = database
    for number in pairs(BAR_PAGES) do
        bars[number] = CreateBar(number)
    end
    hooksecurefunc(LibEditMode.internal.dialog, "Update", StyleSliders)
    LibEditMode:RegisterCallback("layout", OnLayoutChanged)
    LibEditMode:RegisterCallback("rename", OnLayoutRenamed)
    LibEditMode:RegisterCallback("enter", function() SetEditModeActive(true) end)
    LibEditMode:RegisterCallback("exit", function() SetEditModeActive(false) end)
    -- The spellbook and Quick Keybind show empty slots through these rather than an event.
    hooksecurefunc("MultiActionBar_ShowAllGrids", function(reason) SetGridShown(true, reason) end)
    hooksecurefunc("MultiActionBar_HideAllGrids", function(reason) SetGridShown(false, reason) end)
    layoutFrame:SetScript("OnEvent", function(frame, event) EVENT_HANDLERS[event](frame, event) end)
    layoutFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
    layoutFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
end
