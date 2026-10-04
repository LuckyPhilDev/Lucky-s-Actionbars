LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.MicroMenu = {}

local db
-- Blizzard shows some buttons itself, such as Shop and Help, so hidden ones live under a hidden parent.
-- The menu only lays out its own children, so a moved button leaves no gap.
local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local buttons = {}
-- Blizzard only shows Customer Support when the Shop is unavailable, so it isn't offered.
local NOT_OFFERED = { HelpMicroButton = true }

-- Read from the menu itself rather than a fixed list, so it matches whatever buttons this client has.
local function CollectButtons()
    for _, child in ipairs({ MicroMenu:GetChildren() }) do
        if child.layoutIndex and child:GetName() and not NOT_OFFERED[child:GetName()] then
            table.insert(buttons, child)
        end
    end
    table.sort(buttons, function(a, b) return a.layoutIndex < b.layoutIndex end)
end

-- Blizzard finds the menu's end buttons by reading the center of every button it holds, shown or not.
-- Help stays hidden and unplaced while the Shop is up, so once the buttons after it are hidden it
-- becomes the end button and has no center. Placing unplaced buttons keeps that lookup working.
local function Relayout()
    for _, child in ipairs({ MicroMenu:GetChildren() }) do
        if child.layoutIndex and child:GetNumPoints() == 0 then
            child:SetPoint("CENTER")
        end
    end
    MicroMenuContainer:Layout()
end

function LuckyActionbars.MicroMenu:Choices()
    local labels = LuckyActionbars.Strings.menu.buttons
    local choices = {}
    for _, button in ipairs(buttons) do
        local name = button:GetName()
        table.insert(choices, { text = labels[name] or name, value = name })
    end
    return choices
end

function LuckyActionbars.MicroMenu:IsHidden(name)
    return db.hiddenMicroButtons[name] == true
end

function LuckyActionbars.MicroMenu:HasHidden()
    return next(db.hiddenMicroButtons) ~= nil
end

function LuckyActionbars.MicroMenu:ToggleButton(name)
    local hidden = not db.hiddenMicroButtons[name]
    db.hiddenMicroButtons[name] = hidden or nil
    _G[name]:SetParent(hidden and hiddenParent or MicroMenu)
    Relayout()
end

function LuckyActionbars.MicroMenu:UnhideAll()
    for name in pairs(db.hiddenMicroButtons) do
        _G[name]:SetParent(MicroMenu)
    end
    wipe(db.hiddenMicroButtons)
    Relayout()
end

function LuckyActionbars.MicroMenu:Init(database)
    db = database
    CollectButtons()
    for name in pairs(db.hiddenMicroButtons) do
        if _G[name] then
            _G[name]:SetParent(hiddenParent)
        end
    end
    Relayout()
end
