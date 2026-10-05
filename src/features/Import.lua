LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Import = {}

local BUTTON_COUNT = 12
local BUTTON_SIZE = 45
-- Where a bar with no number of its own here goes, the bars nobody uses by default first.
local SPARE_BAR_ORDER = { 6, 7, 8, 10, 9, 11, 12, 2, 3, 4, 5 }
local MORE_PAGING = { ["CTRL-SHIFT"] = true, ["ALT-CTRL"] = true, ["ALT-SHIFT"] = true, HELP = true }

local db, charDb
local devLog

local function Print(message, ...)
    print(LuckyActionbars.Strings.addon.prefix .. " " .. message:format(...))
end

-- Dev mode keeps the log in this character's saved variables, so a long one can be read after a reload.
local function Keep(line)
    if db.devMode then
        charDb.importLog = charDb.importLog or {}
        charDb.importLog[#charDb.importLog + 1] = date("%H:%M:%S ") .. line
    end
end

local function Log(message, ...)
    if db.devMode then
        local line = message:format(...)
        devLog("Import: " .. line)
        Keep(line)
    end
end

local function Describe(paging)
    local parts = {}
    for key, page in pairs(paging) do
        parts[#parts + 1] = key .. "=" .. page
    end
    return #parts > 0 and table.concat(parts, " ") or "none"
end

local function Clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function Round(value)
    return math.floor(value + 0.5)
end

local function CountDistinct(values, step)
    local seen, count = {}, 0
    for _, value in ipairs(values) do
        local key = Round(value / step)
        if not seen[key] then
            seen[key] = true
            count = count + 1
        end
    end
    return count
end

-- Rects are { left, bottom, width, height } in UIParent units, in button order. Rows and
-- columns are told apart by counting distinct button positions on each axis.
function LuckyActionbars.Import.Measure(rects)
    local first, last = rects[1], rects[#rects]
    local size = first[3]
    local left, bottom, right, top = math.huge, math.huge, -math.huge, -math.huge
    local xs, ys = {}, {}
    for index, rect in ipairs(rects) do
        left, bottom = math.min(left, rect[1]), math.min(bottom, rect[2])
        right, top = math.max(right, rect[1] + rect[3]), math.max(top, rect[2] + rect[4])
        xs[index], ys[index] = rect[1], rect[2]
    end
    local columns, rows = CountDistinct(xs, size / 2), CountDistinct(ys, size / 2)
    local gap = 2
    if columns > 1 then
        gap = (right - left - columns * size) / (columns - 1)
    elseif rows > 1 then
        gap = (top - bottom - rows * size) / (rows - 1)
    end
    local horizontal = columns >= rows
    return {
        x = (left + right) / 2,
        y = (bottom + top) / 2,
        horizontal = horizontal,
        lines = horizontal and rows or columns,
        icons = #rects,
        size = Clamp(Round(size / BUTTON_SIZE * 10) * 10, 50, 200),
        padding = Clamp(Round(gap), 2, 10),
        rowsDown = horizontal and rows > 1 and first[2] > last[2],
    }
end

local function ButtonRects(buttons)
    local rects = {}
    local parentScale = UIParent:GetEffectiveScale()
    for _, button in ipairs(buttons) do
        local left, bottom, width, height = button:GetRect()
        if not left then
            return nil
        end
        local scale = button:GetEffectiveScale() / parentScale
        rects[#rects + 1] = { left * scale, bottom * scale, width * scale, height * scale }
    end
    return #rects > 0 and rects or nil
end

-- Offsets from the screen's centre, which is how both Edit Mode and the extra bars anchor them.
local function MeasureBar(buttons)
    local rects = ButtonRects(buttons)
    if not rects then
        return nil
    end
    local shape = LuckyActionbars.Import.Measure(rects)
    shape.x = shape.x - UIParent:GetWidth() / 2
    shape.y = shape.y - UIParent:GetHeight() / 2
    return shape
end

local function IsPageEmpty(page)
    for index = 1, BUTTON_COUNT do
        if HasAction((page - 1) * BUTTON_COUNT + index) then
            return false
        end
    end
    return true
end

local function DescribeSlot(slot)
    local kind, id = GetActionInfo(slot)
    if not kind then
        return "empty"
    end
    local name = kind == "spell" and C_Spell.GetSpellName(id) or GetActionText(slot)
    return ("%s %s"):format(kind, name or tostring(id))
end

-- Only ever onto an empty slot, so nothing has to come back on the cursor; clearing a cursor
-- that still holds a picked-up action deletes it. Anything that didn't land goes back.
local function MoveAction(from, to)
    PickupAction(from)
    PlaceAction(to)
    if GetCursorInfo() then
        PlaceAction(from)
    end
    return HasAction(to) and not HasAction(from)
end

local function SwapSlots(x, y, spare)
    if HasAction(x) and HasAction(y) then
        return MoveAction(x, spare) and MoveAction(y, x) and MoveAction(spare, y)
    elseif HasAction(x) then
        return MoveAction(x, y)
    elseif HasAction(y) then
        return MoveAction(y, x)
    end
    return true
end

-- Pages 11 and 12 are skipped: the game swaps actions onto them while skyriding or possessing.
local function SpareSlot(a, b)
    for page = 1, 15 do
        if page ~= a and page ~= b and page ~= 11 and page ~= 12 then
            for index = 1, BUTTON_COUNT do
                local slot = (page - 1) * BUTTON_COUNT + index
                if not HasAction(slot) then
                    return slot
                end
            end
        end
    end
end

-- Swapping, never overwriting, so running it again puts everything back. Stops at the first
-- slot that doesn't swap cleanly rather than carry on moving things.
local function SwapPages(a, b)
    ClearCursor()
    local spare = SpareSlot(a, b)
    if not spare then
        Log("no empty slot to swap pages %d and %d through", a, b)
        return false
    end
    for index = 1, BUTTON_COUNT do
        local x, y = (a - 1) * BUTTON_COUNT + index, (b - 1) * BUTTON_COUNT + index
        local wasX, wasY = DescribeSlot(x), DescribeSlot(y)
        local ok = SwapSlots(x, y, spare)
        local nowX, nowY = DescribeSlot(x), DescribeSlot(y)
        ok = ok and nowX == wasY and nowY == wasX
        Log("slot %d <-> %d via %d: [%s | %s] -> [%s | %s]%s", x, y, spare, wasX, wasY, nowX, nowY,
            ok and "" or "  FAILED, spare holds " .. DescribeSlot(spare))
        if not ok then
            return false
        end
    end
    return true
end

-- Dev mode check of what each page holds, to find spells a swap put somewhere unexpected.
function LuckyActionbars.Import:DumpPages(pages)
    for _, page in ipairs(pages) do
        for index = 1, BUTTON_COUNT do
            local slot = (page - 1) * BUTTON_COUNT + index
            local line = ("page %d button %d (slot %d): %s"):format(page, index, slot, DescribeSlot(slot))
            Print(line)
            Keep(line)
        end
    end
end

-- A swap that fails stays on record, so the spells it holds can still be found and put back.
local function UndoSwaps()
    local swaps = charDb.importSwaps or {}
    for index = #swaps, 1, -1 do
        if not SwapPages(swaps[index][1], swaps[index][2]) then
            return false
        end
        swaps[index] = nil
    end
    charDb.importSwaps = nil
    return true
end

local function PageOf(number)
    if number == 1 then
        return 1
    elseif number <= LuckyActionbars.Paging.BAR_COUNT then
        return LuckyActionbars.Paging:HomePage(number)
    end
    return LuckyActionbars.ExtraBars:Page(number)
end

local function IsAvailable(number)
    return number <= LuckyActionbars.Paging.BAR_COUNT or LuckyActionbars.ExtraBars:IsAvailable(number)
end

local function BarsByPage()
    local byPage = {}
    for number = 1, 12 do
        if IsAvailable(number) then
            byPage[PageOf(number)] = number
        end
    end
    return byPage
end

local function SpareBar(taken)
    for _, wantEmpty in ipairs({ true, false }) do
        for _, number in ipairs(SPARE_BAR_ORDER) do
            if not taken[number] and IsAvailable(number) and (IsPageEmpty(PageOf(number)) or not wantEmpty) then
                return number
            end
        end
    end
end

-- Each source bar keeps its own number where it can, so Dominos bar 3 is Action Bar 3. Failing
-- that it goes where its page already shows, and failing that to a spare bar.
local function AssignBars(bars, report)
    local byPage, taken, unplaced = BarsByPage(), {}, {}
    for _, bar in ipairs(bars) do
        local number = bar.number
        if number and number <= 12 and IsAvailable(number) and not taken[number] then
            taken[number] = bar
        else
            unplaced[#unplaced + 1] = bar
        end
    end
    for _, bar in ipairs(unplaced) do
        local number = byPage[bar.page]
        if not number or taken[number] then
            number = SpareBar(taken)
        end
        if number then
            taken[number] = bar
        else
            report(LuckyActionbars.Strings.import.noBar, bar.label)
        end
    end
    return taken
end

-- Every move is a swap, tracked so a later swap never disturbs a page already placed.
-- Returns where each original page's spells ended up.
local function MovePages(taken, report)
    local location, holder, swaps = {}, {}, {}
    for number = 1, 12 do
        local bar, target = taken[number], PageOf(number)
        if bar and bar.page ~= target then
            local from = location[bar.page] or bar.page
            local displaced = holder[target] or target
            local ok = SwapPages(from, target)
            swaps[#swaps + 1] = { from, target }
            charDb.importSwaps = swaps
            if not ok then
                return nil
            end
            location[bar.page], location[displaced] = target, from
            holder[target], holder[from] = bar.page, displaced
            Log("swapped page %d with page %d for %s", from, target, bar.label)
            report(LuckyActionbars.Strings.import.moved, bar.label, number)
        end
    end
    charDb.importSwaps = #swaps > 0 and swaps or nil
    return location
end

LuckyActionbars.Import.MovePages = MovePages

local function Pair(bars, report)
    local taken = AssignBars(bars, report)
    for number = 1, 12 do
        if taken[number] then
            Log("Action Bar %d <- %s (page %d)", number, taken[number].label, taken[number].page)
        end
    end
    return taken, MovePages(taken, report)
end

local function SetSetting(system, setting, value)
    local displayInfo = EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(system.system)[setting]
    value = displayInfo:ConvertValue(value)
    for _, entry in ipairs(system.settings) do
        if entry.setting == setting then
            entry.value = value
            return
        end
    end
    system.settings[#system.settings + 1] = { setting = setting, value = value }
end

local function PlaceStockBar(system, shape)
    local setting = Enum.EditModeActionBarSetting
    system.isInDefaultPosition = false
    system.anchorInfo = {
        point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", offsetX = shape.x, offsetY = shape.y,
    }
    system.anchorInfo2 = nil
    SetSetting(system, setting.Orientation,
        shape.horizontal and Enum.ActionBarOrientation.Horizontal or Enum.ActionBarOrientation.Vertical)
    SetSetting(system, setting.NumRows, Clamp(shape.lines, 1, 4))
    SetSetting(system, setting.NumIcons, Clamp(shape.icons, 6, 12))
    SetSetting(system, setting.IconSize, shape.size)
    SetSetting(system, setting.IconPadding, shape.padding)
    SetSetting(system, setting.VisibleSetting, Enum.ActionBarVisibleSetting.Always)
    -- None of the bar addons draw the gryphons or page arrows, so Action Bar 1 drops them too.
    if system.systemIndex == Enum.EditModeActionBarSystemIndices.MainBar then
        SetSetting(system, setting.HideBarArt, 1)
        SetSetting(system, setting.HideBarScrolling, 1)
    end
end

local function FindLayout(layouts, name)
    for index, layout in ipairs(layouts) do
        if layout.layoutType ~= Enum.EditModeLayoutType.Preset and layout.layoutName == name then
            return index
        end
    end
end

-- Account layouts sit after the presets and before character ones, as Blizzard orders them.
local function NewAccountLayoutIndex(layouts)
    local index = Enum.EditModePresetLayoutsMeta.NumValues + 1
    for position, layout in ipairs(layouts) do
        if layout.layoutType == Enum.EditModeLayoutType.Account then
            index = position + 1
        end
    end
    return index
end

-- Built from the active layout so everything but the action bars stays where the player has it.
-- Indices count the presets, which GetLayouts leaves out, as LibEditModeOverride found.
local function SaveLayout(name, taken)
    local layoutInfo = C_EditMode.GetLayouts()
    local layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    tAppendAll(layouts, layoutInfo.layouts)
    layoutInfo.layouts = layouts

    local layout = CopyTable(EditModeManagerFrame:GetActiveLayoutInfo())
    layout.layoutName, layout.layoutType = name, Enum.EditModeLayoutType.Account
    local stockSystems = LuckyActionbars.EditModePanel.STOCK_BAR_SYSTEMS
    for _, system in ipairs(layout.systems) do
        local number = system.system == Enum.EditModeSystem.ActionBar and tIndexOf(stockSystems, system.systemIndex)
        if number and taken[number] then
            PlaceStockBar(system, taken[number].shape)
        end
    end

    local index = FindLayout(layouts, name)
    Log("layout \"%s\": %s at index %d, active was %d", name, index and "replacing" or "adding",
        index or NewAccountLayoutIndex(layouts), layoutInfo.activeLayout)
    if index then
        layout.layoutType = layouts[index].layoutType
        layouts[index] = layout
        C_EditMode.SaveLayouts(layoutInfo)
        -- Selecting the layout already active fires nothing, so step off it to have it reapplied.
        if index == layoutInfo.activeLayout then
            C_EditMode.SetActiveLayout(1)
        end
        C_EditMode.SetActiveLayout(index)
    else
        index = NewAccountLayoutIndex(layouts)
        table.insert(layouts, index, layout)
        C_EditMode.SaveLayouts(layoutInfo)
        C_EditMode.OnLayoutAdded(index, true, false)
    end
end

-- Written before the layout switches, so the bars find their place under its name when it does.
local function SaveExtraBars(name, taken)
    for number in pairs(LuckyActionbars.ExtraBars:Frames()) do
        local bar = taken[number]
        if bar then
            local shape = bar.shape
            Log("Action Bar %d saved for layout \"%s\"", number, name)
            db.bars[number].positions[name] = { point = "CENTER", x = shape.x, y = shape.y }
            db.bars[number].layouts[name] = {
                orientation = shape.horizontal and "horizontal" or "vertical",
                rowsGrow = shape.rowsDown and "down" or "up",
                rows = Clamp(shape.lines, 1, 12),
                icons = Clamp(shape.icons, 6, 12),
                size = shape.size,
                padding = shape.padding,
            }
        end
    end
end

local function ImportPaging(taken, pageMap, report)
    local S = LuckyActionbars.Strings.import
    local Paging = LuckyActionbars.Paging
    local allowed = tInvert(Paging:AllowedPages())
    local usesMore = false
    for number = 1, 12 do
        local bar = taken[number]
        local pageable = number <= Paging.BAR_COUNT
        if pageable then
            db.paging[number] = {}
        end
        for key, page in pairs(bar and bar.paging or {}) do
            page = pageMap[page] or page
            if pageable and allowed[page] then
                db.paging[number][key] = page
                usesMore = usesMore or MORE_PAGING[key] or false
            else
                report(S.pagingSkipped, bar.label, LuckyActionbars.Strings.settings.triggers[key].label)
            end
        end
        for _, state in ipairs(bar and bar.skipped or {}) do
            report(S.pagingSkipped, bar.label, state)
        end
    end
    for number = 1, Paging.BAR_COUNT do
        Log("Action Bar %d paging: %s", number, Describe(db.paging[number]))
    end
    if usesMore then
        Paging:SetMorePaging(true)
    else
        Paging:Apply()
    end
end

local function ImportBarSettings(data, taken)
    for number = 1, 12 do
        local bar = taken[number]
        if number > 1 then
            local module = number <= LuckyActionbars.Paging.BAR_COUNT and LuckyActionbars.StockBars or LuckyActionbars.ExtraBars
            module:SetShown(number, bar ~= nil)
        end
        LuckyActionbars.MouseoverFade:SetFaded(number, bar and bar.faded or false)
        if bar and number <= LuckyActionbars.Paging.BAR_COUNT then
            LuckyActionbars.RowDirection:Set(number, bar.shape.rowsDown and "down" or "up")
        end
    end
    LuckyActionbars.ButtonText:SetHidden("hideKeybinds", data.hideKeybinds and true or false)
    LuckyActionbars.ButtonText:SetHidden("hideMacroNames", data.hideMacroNames and true or false)
end

local function TargetCommand(number, index)
    if number <= LuckyActionbars.Paging.BAR_COUNT then
        return LuckyActionbars.Paging:BindingCommand(number, index)
    end
    return LuckyActionbars.ExtraBars:Frames()[number].buttons[index].commandName
end

-- Dominos binds its own "CLICK button:HOTKEY" commands; EllesmereUI uses Blizzard's.
local function SourceCommand(button)
    return button:GetAttribute("commandName") or button.commandName or ("CLICK " .. button:GetName() .. ":HOTKEY")
end

-- Every key is read before any is moved, since binding a key takes it off its old command.
-- A button with no keys of its own leaves ours alone, in case its addon binds through ours.
-- The first binding each key had before any import, so Reverse can put it back.
local function RebindKey(key, command)
    local saved = charDb.importBackup.keybinds
    if saved[key] == nil then
        saved[key] = GetBindingAction(key)
    end
    SetBinding(key, command)
end

local function ImportKeybinds(taken, report)
    local moves = {}
    for number = 1, 12 do
        local bar = taken[number]
        for index, button in ipairs(bar and bar.buttons or {}) do
            local from, to = SourceCommand(button), TargetCommand(number, index)
            local keys = { GetBindingKey(from) }
            if from ~= to and #keys > 0 then
                moves[#moves + 1] = { to = to, keys = keys }
            end
        end
    end
    for _, move in ipairs(moves) do
        for _, key in ipairs({ GetBindingKey(move.to) }) do
            RebindKey(key)
        end
    end
    local count = 0
    for _, move in ipairs(moves) do
        for _, key in ipairs(move.keys) do
            RebindKey(key, move.to)
            count = count + 1
            Log("bound %s to %s", key, move.to)
        end
    end
    if count > 0 then
        SaveBindings(GetCurrentBindingSet())
        report(LuckyActionbars.Strings.import.keybinds, count)
    end
end

local function MeasuredBars(bars, report)
    local measured = {}
    for _, bar in ipairs(bars) do
        bar.shape = MeasureBar(bar.buttons)
        local shape = bar.shape or {}
        Log("%s: page %d, %d buttons, faded %s, paging %s, skipped %s", bar.label, bar.page, #bar.buttons,
            tostring(bar.faded), Describe(bar.paging), table.concat(bar.skipped, " "))
        Log("  %s at %.0f,%.0f, %s x%s, %s icons, size %s, padding %s, rows %s", bar.shape and "measured" or "NOT measured",
            shape.x or 0, shape.y or 0, shape.horizontal and "horizontal" or "vertical", tostring(shape.lines),
            tostring(shape.icons), tostring(shape.size), tostring(shape.padding), shape.rowsDown and "down" or "up")
        if bar.shape then
            measured[#measured + 1] = bar
        else
            report(LuckyActionbars.Strings.import.notMeasured, bar.label)
        end
    end
    return measured
end

local function CanImport(name)
    local S = LuckyActionbars.Strings.import
    if InCombatLockdown() then
        return false, S.combat
    elseif not EditModeManagerFrame.accountSettings then
        return false, S.notReady
    elseif not FindLayout(EditModeManagerFrame:GetLayouts(), name)
        and EditModeManagerFrame:AreLayoutsOfTypeMaxed(Enum.EditModeLayoutType.Account) then
        return false, S.layoutsFull
    end
    return true
end

-- Kept from the first import until reversed, so importing again still reverses to before any import.
local function Backup(source)
    if charDb.importBackup then
        return
    end
    local layout = EditModeManagerFrame:GetActiveLayoutInfo()
    local stockShown, extraShown = {}, {}
    for number = 2, LuckyActionbars.Paging.BAR_COUNT do
        stockShown[number] = LuckyActionbars.StockBars:IsShown(number)
    end
    for number in pairs(LuckyActionbars.ExtraBars:Frames()) do
        extraShown[number] = db.bars[number].shown
    end
    charDb.importBackup = {
        addon = source.addon,
        layoutName = layout.layoutName,
        layoutType = layout.layoutType,
        paging = CopyTable(db.paging),
        morePaging = db.morePaging,
        fade = CopyTable(db.fade),
        rowsDown = CopyTable(db.rowsDown),
        hideKeybinds = db.hideKeybinds,
        hideMacroNames = db.hideMacroNames,
        stockShown = stockShown,
        extraShown = extraShown,
        keybinds = {},
    }
end

local function RestoreLayout(name, layoutType)
    local layouts = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    tAppendAll(layouts, C_EditMode.GetLayouts().layouts)
    for index, layout in ipairs(layouts) do
        if layout.layoutName == name and layout.layoutType == layoutType then
            C_EditMode.SetActiveLayout(index)
            return
        end
    end
end

local function RestoreSettings(backup)
    db.paging, db.morePaging = backup.paging, backup.morePaging
    LuckyActionbars.Paging:Apply()
    for number = 1, 12 do
        LuckyActionbars.MouseoverFade:SetFaded(number, backup.fade[number] or false)
        if number <= LuckyActionbars.Paging.BAR_COUNT then
            LuckyActionbars.RowDirection:Set(number, backup.rowsDown[number] and "down" or "up")
        end
    end
    for number, shown in pairs(backup.stockShown) do
        LuckyActionbars.StockBars:SetShown(number, shown)
    end
    for number, shown in pairs(backup.extraShown) do
        LuckyActionbars.ExtraBars:SetShown(number, shown)
    end
    LuckyActionbars.ButtonText:SetHidden("hideKeybinds", backup.hideKeybinds)
    LuckyActionbars.ButtonText:SetHidden("hideMacroNames", backup.hideMacroNames)
end

function LuckyActionbars.Import:Reverse()
    local S = LuckyActionbars.Strings.import
    local backup = charDb.importBackup
    if InCombatLockdown() then
        Print(S.combat)
        return
    elseif not backup then
        Print(S.nothingToReverse)
        return
    end
    if not UndoSwaps() then
        Print(S.moveFailed)
        return
    end
    for key, command in pairs(backup.keybinds) do
        SetBinding(key, command ~= "" and command or nil)
        Log("restored %s to %s", key, command ~= "" and command or "nothing")
    end
    SaveBindings(GetCurrentBindingSet())
    RestoreSettings(backup)
    RestoreLayout(backup.layoutName, backup.layoutType)
    C_AddOns.EnableAddOn(backup.addon)
    charDb.importBackup = nil
    Print(S.reversed, backup.layoutName, backup.addon)
end

function LuckyActionbars.Import:Run(source)
    local S = LuckyActionbars.Strings.import
    local name = S.layoutName:format(source.title)
    local ok, problem = CanImport(name)
    local data
    if ok then
        data, problem = source.Read()
    end
    Log("running for %s into \"%s\"", source.title, name)
    if not data then
        Print(problem)
        return
    end
    Log("%s shows %d bars", source.title, #data.bars)

    local lines = {}
    local function report(message, ...)
        lines[#lines + 1] = message:format(...)
    end
    -- Starting from the original pages, or a second import would move spells already moved.
    Backup(source)
    local taken, pageMap
    if UndoSwaps() then
        taken, pageMap = Pair(MeasuredBars(data.bars, report), report)
    end
    if not pageMap then
        Print(S.moveFailed)
        return
    end
    SaveExtraBars(name, taken)
    SaveLayout(name, taken)
    ImportKeybinds(taken, report)
    ImportPaging(taken, pageMap, report)
    ImportBarSettings(data, taken)
    Log("done")

    Print(S.done, source.title, name)
    for _, line in ipairs(lines) do
        Print(line)
    end
    StaticPopup_Show("LUCKY_ACTIONBARS_IMPORT_DONE", source.title, nil, source)
end

function LuckyActionbars.Import:CanUndo()
    return charDb.importSwaps ~= nil
end

function LuckyActionbars.Import:Undo()
    if InCombatLockdown() then
        Print(LuckyActionbars.Strings.import.combat)
        return
    end
    Print(LuckyActionbars.Strings.import[UndoSwaps() and "undone" or "moveFailed"])
end

function LuckyActionbars.Import:LoadedSources()
    local loaded = {}
    for _, source in ipairs(LuckyActionbars.ImportSources) do
        if C_AddOns.IsAddOnLoaded(source.addon) then
            loaded[#loaded + 1] = source
        end
    end
    return loaded
end

local function DefinePopups()
    local S = LuckyActionbars.Strings.import
    StaticPopupDialogs.LUCKY_ACTIONBARS_IMPORT_OFFER = {
        text = S.offer,
        button1 = S.importNow,
        button2 = S.notNow,
        OnAccept = function(_, source) LuckyActionbars.Import:Run(source) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopupDialogs.LUCKY_ACTIONBARS_IMPORT_DONE = {
        text = S.disablePrompt,
        button1 = S.disableAndReload,
        button2 = S.later,
        OnAccept = function(_, source)
            C_AddOns.DisableAddOn(source.addon)
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
end

-- Offered once per addon, the first time we see it loaded alongside us; every login in dev mode.
function LuckyActionbars.Import:Init(database, characterDatabase)
    db, charDb = database, characterDatabase
    db.importOffered = db.importOffered or {}
    devLog = LuckyLog:New(LuckyActionbars.Strings.addon.prefix, function() return db.devMode end)
    DefinePopups()
    local source = self:LoadedSources()[1]
    Log("loaded source %s, offered before %s, spell swaps on record %s", source and source.title or "none",
        tostring(source and db.importOffered[source.key]), tostring(charDb.importSwaps and #charDb.importSwaps or 0))
    if source and (db.devMode or not db.importOffered[source.key]) then
        db.importOffered[source.key] = true
        StaticPopup_Show("LUCKY_ACTIONBARS_IMPORT_OFFER", source.title, nil, source)
    end
end
