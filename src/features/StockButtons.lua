LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.StockButtons = {}

local BUTTON_COUNT = 12
-- The vehicle, temporary shapeshift and override bars sit on pages 16 to 18.
local PAGE_COUNT = 18

-- Blizzard's buttons stay on their bars for Edit Mode's layout, but out of sight and out of reach.
local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

-- Each button sits in the slot Blizzard lays out for the stock button, so Edit Mode's rows, icons, size,
-- padding and visibility, and the row direction setting, all move it. Showing empty slots follows the stock
-- button's grid, which tracks Always Show Buttons, dragging, the spellbook and Quick Keybind.
local function CreateButton(number, bar, header, index)
    local stock = _G[bar.buttons .. index]
    local button = LuckyActionbars.ActionButtons:Create(index, "LuckyActionbars" .. bar.buttons .. index, header,
        bar.command .. index, function() return stock:GetShowGrid() end,
        LuckyActionbars.Strings.settings.bars.stock.label:format(number))
    for page = 1, PAGE_COUNT do
        button:SetState(page, "action", (page - 1) * BUTTON_COUNT + index)
    end
    button:SetParent(stock.container)
    button:SetAllPoints(stock.container)
    stock:SetParent(hiddenParent)
    return button
end

-- Returns the secure header that pages the bar's buttons, with them listed as header.buttons.
function LuckyActionbars.StockButtons:Create(number, bar)
    local frame = _G[bar.frame]
    -- On UIParent, not the bar: Blizzard sizes a bar to fit its children, and the header has no size.
    local header = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    header.buttons = {}
    for index = 1, BUTTON_COUNT do
        header.buttons[index] = CreateButton(number, bar, header, index)
    end
    hooksecurefunc(frame, "UpdateShownButtons", function()
        for _, button in ipairs(header.buttons) do
            LuckyActionbars.ActionButtons:UpdateEmpty(button)
        end
    end)
    return header
end
