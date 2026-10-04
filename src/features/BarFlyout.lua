LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.BarFlyout = {}

local LABEL_WIDTH = 150

local panel
local rows = {}

local rowMixin = {}

function rowMixin:OnCheckButtonClick()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    self.module:SetShown(self.number, self.Button:GetChecked())
    -- SetShown refuses in combat, so read back what actually happened.
    self.Button:SetChecked(self.module:IsShown(self.number))
end

local function CreateRow(module, number, label, desc)
    local row = Mixin(CreateFrame("Frame", nil, panel.List, "EditModeSettingCheckboxTemplate"), rowMixin)
    row.module, row.number = module, number
    row.layoutIndex = number
    row.Label:SetText(label)
    row.Label:SetWidth(LABEL_WIDTH)
    if desc then
        LuckyActionbars.SidePanel.AddTooltip(row, desc, row.Button)
    end
    rows[#rows + 1] = row
end

-- Only the extra bars get a tooltip, naming the forms that normally use their page.
local function CreateRows()
    local S = LuckyActionbars.Strings
    for number = 2, LuckyActionbars.Paging.BAR_COUNT do
        CreateRow(LuckyActionbars.StockBars, number, S.settings.bars.stock.label:format(number))
    end
    for number in pairs(LuckyActionbars.ExtraBars:Frames()) do
        CreateRow(LuckyActionbars.ExtraBars, number, S.bars.names[number],
            S.bars.pageUsers[LuckyActionbars.ExtraBars:Page(number)])
    end
end

-- Extra bars whose page a form already uses can't be shown, so they're left off the list.
local function Refresh()
    for _, row in ipairs(rows) do
        local usable = row.module ~= LuckyActionbars.ExtraBars or row.module:IsAvailable(row.number)
        row:SetShown(usable)
        row.Button:SetChecked(usable and row.module:IsShown(row.number))
    end
end

function LuckyActionbars.BarFlyout:Toggle(dialog)
    panel:Toggle(dialog)
end

-- `dialogs` maps each dialog to the method that points it at something and a test for
-- whether that is an action bar.
function LuckyActionbars.BarFlyout:Init(dialogs)
    panel = LuckyActionbars.SidePanel:Create(Refresh)
    panel.Title:SetText(LuckyActionbars.Utils.Mark(LuckyActionbars.Strings.bars.flyoutTitle))
    CreateRows()
    for dialog, rule in pairs(dialogs) do
        panel:Watch(dialog, rule.attach, rule.isActionBar)
    end
end
