LuckyActionbars = LuckyActionbars or {}

-- Each source reads the bars its addon is showing right now, as
-- { label, number, page, buttons, faded, paging = { [Paging trigger] = page }, skipped = { state names } }.
-- Pages are Blizzard's action pages (slot = (page - 1) * 12 + button).

-- Both addons name their paging states the same way; anything not here has no Lucky's trigger.
local PAGING_KEYS = {
    ctrl = "CTRL", alt = "ALT", shift = "SHIFT",
    ctrlShift = "CTRL-SHIFT", ctrlAlt = "ALT-CTRL", altShift = "ALT-SHIFT",
    help = "HELP", cat = "cat", bear = "bear", moonkin = "moonkin", stealth = "stealth",
}
-- Action Bar 1 already pages for forms, skyriding and Shift+number on its own, so these
-- carry over without being copied.
local NATIVE_ON_BAR_ONE = {
    page2 = true, page3 = true, page4 = true, page5 = true, page6 = true, dragonriding = true,
    cat = true, bear = true, moonkin = true, tree = true, prowl = true, stealth = true,
    shadowdance = true, soar = true,
}

local function ConvertPaging(bar, states, isMainBar, toPage)
    bar.paging, bar.skipped = {}, {}
    for state, value in pairs(states) do
        if not (isMainBar and NATIVE_ON_BAR_ONE[state]) and value then
            local key = PAGING_KEYS[state]
            if key then
                bar.paging[key] = toPage(value)
            else
                bar.skipped[#bar.skipped + 1] = state
            end
        end
    end
end

local DOMINOS_BAR_COUNT = 14

-- Dominos shows page N on bar N, wrapping past its last bar, and skips page 12.
local function DominosPage(position)
    local page = (position - 1) % DOMINOS_BAR_COUNT + 1
    return page >= 12 and page + 1 or page
end

local function ReadDominos()
    local Dominos = _G.Dominos
    if Dominos:NumBars() ~= DOMINOS_BAR_COUNT then
        return nil, LuckyActionbars.Strings.import.dominosBarCount
    end
    local bars = {}
    for id = 1, DOMINOS_BAR_COUNT do
        local frame = Dominos.Frame:Get(id)
        if frame and not frame.sets.hidden then
            local bar = {
                label = LuckyActionbars.Strings.import.dominosBar:format(id),
                number = id,
                page = DominosPage(id),
                buttons = {},
                faded = frame:GetFadeMultiplier() < 1,
            }
            for index = 1, frame:NumButtons() do
                bar.buttons[index] = frame.buttons[index]
            end
            ConvertPaging(bar, frame.pages, id == 1, function(offset) return DominosPage(id + offset) end)
            bars[#bars + 1] = bar
        end
    end
    local mainBar = Dominos.Frame:Get(1)
    return {
        bars = bars,
        hideKeybinds = mainBar and not mainBar:ShowingBindingText(),
        hideMacroNames = mainBar and not mainBar:ShowingMacroText(),
    }
end

-- Buttons are EllesmereUI's own, named by slot; older versions reused Blizzard's on Bars 1 to 8.
local ELLESMERE_BARS = {
    { key = "MainBar", page = 1, blizzard = "ActionButton" },
    { key = "Bar2", page = 6, blizzard = "MultiBarBottomLeftButton" },
    { key = "Bar3", page = 5, blizzard = "MultiBarBottomRightButton" },
    { key = "Bar4", page = 3, blizzard = "MultiBarRightButton" },
    { key = "Bar5", page = 4, blizzard = "MultiBarLeftButton" },
    { key = "Bar6", page = 13, blizzard = "MultiBar5Button" },
    { key = "Bar7", page = 14, blizzard = "MultiBar6Button" },
    { key = "Bar8", page = 15, blizzard = "MultiBar7Button" },
    { key = "Bar9", page = 2 },
    { key = "Bar10", page = 10 },
}
local ELLESMERE_MOD_TARGET_STATES = { shift = true, ctrl = true, alt = true, help = true, harm = true }

local function EllesmereButton(info, index)
    return _G["EABButton" .. ((info.page - 1) * 12 + index)] or (info.blizzard and _G[info.blizzard .. index])
end

local function ReadEllesmere()
    local central = _G.EllesmereUIDB.profiles[_G.EllesmereUIDB.activeProfile or "Default"]
    local settings = central.addons.EllesmereUIActionBars.bars
    local bars = {}
    for number, info in ipairs(ELLESMERE_BARS) do
        local s = settings[info.key]
        if s and s.enabled ~= false and not s.alwaysHidden and s.barVisibility ~= "never" then
            local bar = {
                label = LuckyActionbars.Strings.import.ellesmereBar:format(number),
                number = number,
                page = info.page,
                buttons = {},
                faded = s.mouseoverEnabled,
            }
            for index = 1, math.min(s.overrideNumIcons or s.numIcons or 12, 12) do
                bar.buttons[index] = EllesmereButton(info, index)
            end
            local states = {}
            for state, page in pairs(s.paging or {}) do
                if s.modTargetPaging ~= false or not ELLESMERE_MOD_TARGET_STATES[state] then
                    states[state] = page
                end
            end
            ConvertPaging(bar, states, info.key == "MainBar", tonumber)
            bars[#bars + 1] = bar
        end
    end
    local mainBar = settings.MainBar or {}
    return { bars = bars, hideKeybinds = mainBar.hideKeybind, hideMacroNames = mainBar.hideMacroText }
end

-- addon is what gets disabled after importing; EllesmereUI's other modules keep working without it.
LuckyActionbars.ImportSources = {
    { key = "dominos", title = "Dominos", addon = "Dominos", Read = ReadDominos },
    { key = "ellesmere", title = "EllesmereUI", addon = "EllesmereUIActionBars", Read = ReadEllesmere },
}
LuckyActionbars.ImportSources.DominosPage = DominosPage
