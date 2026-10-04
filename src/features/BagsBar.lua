LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.BagsBar = {}

local db
-- Blizzard re-shows bag slots whenever the bar expands, so hidden ones live under a hidden parent instead.
local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local function ExtraButtons()
    local buttons = { BagBarExpandToggle }
    for _, button in MainMenuBarBagManager:EnumerateBagButtons() do
        if button ~= MainMenuBarBackpackButton then
            table.insert(buttons, button)
        end
    end
    return buttons
end

local function Apply()
    local parent = db.backpackOnly and hiddenParent or BagsBar
    for _, button in ipairs(ExtraButtons()) do
        button:SetParent(parent)
    end
    BagsBar:Layout()
end

function LuckyActionbars.BagsBar:IsBackpackOnly()
    return db.backpackOnly
end

function LuckyActionbars.BagsBar:SetBackpackOnly(backpackOnly)
    db.backpackOnly = backpackOnly
    Apply()
end

-- Blizzard's layout sizes the bar for every slot. Shrinking it to the backpack keeps the Edit Mode
-- box and the hover area on the button. SetWidth and SetHeight don't re-enter this hook.
function LuckyActionbars.BagsBar:Init(database)
    db = database
    hooksecurefunc(BagsBar, "SetSize", function(bar)
        if db.backpackOnly then
            bar:SetWidth(MainMenuBarBackpackButton:GetWidth())
            bar:SetHeight(MainMenuBarBackpackButton:GetHeight())
        end
    end)
    if db.backpackOnly then
        Apply()
    end
end
