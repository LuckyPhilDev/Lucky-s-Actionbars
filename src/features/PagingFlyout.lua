LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.PagingFlyout = {}

local LABEL_WIDTH = 110
local DROPDOWN_WIDTH = 200
local ROW_HEIGHT = 32

local panel
local rows = {}
local barNumber

-- Pages in the order of the bars that show them, so the menu reads Action Bar 1 to 12.
local PAGE_ORDER = { 1, 2, 5, 3, 4, 13, 14, 15, 7, 8, 9, 10 }

local function PageValues(number)
    local S = LuckyActionbars.Strings.settings
    local values = { { text = S.off, value = 0 } }
    local allowed = tInvert(LuckyActionbars.Paging:AllowedPages())
    for _, page in ipairs(PAGE_ORDER) do
        if allowed[page] and page ~= LuckyActionbars.Paging:HomePage(number) then
            values[#values + 1] = { text = S.pageLabels[page], value = page }
        end
    end
    return values
end

-- The menu is rebuilt on every open, so it always lists the pages for the bar shown now.
local function SetupMenu(row)
    row.Dropdown:SetupMenu(function(_, root)
        for _, entry in ipairs(PageValues(barNumber)) do
            root:CreateRadio(entry.text,
                function() return LuckyActionbars.Paging:GetPage(barNumber, row.trigger) == entry.value end,
                function() LuckyActionbars.Paging:SetPage(barNumber, row.trigger, entry.value) end)
        end
    end)
end

local function CreateRow(index, trigger)
    local S = LuckyActionbars.Strings.settings.triggers[trigger]
    local row = CreateFrame("Frame", nil, panel.List)
    row:SetSize(LABEL_WIDTH + DROPDOWN_WIDTH + 5, ROW_HEIGHT)
    row.layoutIndex = index
    row.trigger = trigger

    row.Label = row:CreateFontString(nil, nil, "GameFontHighlightMedium")
    row.Label:SetPoint("LEFT")
    row.Label:SetWidth(LABEL_WIDTH)
    row.Label:SetJustifyH("LEFT")
    row.Label:SetText(S.label)

    row.Dropdown = CreateFrame("DropdownButton", nil, row, "WowStyle1DropdownTemplate")
    row.Dropdown:SetPoint("LEFT", row.Label, "RIGHT", 5, 0)
    row.Dropdown:SetSize(DROPDOWN_WIDTH, 30)
    SetupMenu(row)

    LuckyActionbars.SidePanel.AddTooltip(row, S.desc, row.Dropdown)
    rows[#rows + 1] = row
end

-- Subsystem index N is Action Bar N for the eight stock bars.
local function Refresh(systemFrame)
    barNumber = systemFrame.systemIndex
    panel.Title:SetText(LuckyActionbars.Utils.Mark(LuckyActionbars.Strings.bars.pagingTitle:format(barNumber)))
    for _, row in ipairs(rows) do
        row:SetShown(LuckyActionbars.Paging:IsTriggerOffered(barNumber, row.trigger))
        row.Dropdown:GenerateMenu()
    end
end

function LuckyActionbars.PagingFlyout:Toggle(dialog)
    panel:Toggle(dialog, dialog.attachedToSystem)
end

-- Paging is account-wide, so it ignores the Edit Mode layout.
function LuckyActionbars.PagingFlyout:Init(dialog, isStockBar)
    panel = LuckyActionbars.SidePanel:Create(Refresh)
    for index, trigger in ipairs(LuckyActionbars.Paging.TRIGGERS) do
        CreateRow(index, trigger)
    end
    panel:Watch(dialog, "AttachToSystemFrame", isStockBar)
end
