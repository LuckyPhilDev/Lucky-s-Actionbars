LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.EditModePanel = {}

local LibEditMode = LibStub("LibEditMode")

local STOCK_BAR_SYSTEMS = {
    Enum.EditModeActionBarSystemIndices.MainBar,
    Enum.EditModeActionBarSystemIndices.Bar2,
    Enum.EditModeActionBarSystemIndices.Bar3,
    Enum.EditModeActionBarSystemIndices.RightBar1,
    Enum.EditModeActionBarSystemIndices.RightBar2,
    Enum.EditModeActionBarSystemIndices.ExtraBar1,
    Enum.EditModeActionBarSystemIndices.ExtraBar2,
    Enum.EditModeActionBarSystemIndices.ExtraBar3,
}

local function FadeSetting(key, desc)
    local S = LuckyActionbars.Strings.bars.fade
    return {
        kind = LibEditMode.SettingType.Checkbox,
        name = LuckyActionbars.Utils.Mark(S.label),
        desc = desc or S.desc,
        default = false,
        get = function() return LuckyActionbars.MouseoverFade:IsFaded(key) end,
        set = function(_, faded) LuckyActionbars.MouseoverFade:SetFaded(key, faded) end,
    }
end

local function RowsGrowSetting(number)
    local S = LuckyActionbars.Strings.bars.rowsGrow
    return {
        kind = LibEditMode.SettingType.Dropdown,
        name = LuckyActionbars.Utils.Mark(S.label),
        desc = S.desc,
        default = "up",
        values = { { text = S.up, value = "up" }, { text = S.down, value = "down" } },
        hidden = function() return not LuckyActionbars.RowDirection:IsHorizontal(number) end,
        get = function() return LuckyActionbars.RowDirection:Get(number) end,
        set = function(_, direction) LuckyActionbars.RowDirection:Set(number, direction) end,
    }
end

local function StockBarSettings(number)
    return { FadeSetting(number), RowsGrowSetting(number) }
end

local function ToggleFlyout(flyout, dialog)
    return function() flyout:Toggle(dialog) end
end

local function IsExtraBar(selection)
    return LuckyActionbars.ExtraBars:Frames()[selection.parent.number] == selection.parent
end

local function IsStockBar(systemFrame)
    return systemFrame.system == Enum.EditModeSystem.ActionBar and tContains(STOCK_BAR_SYSTEMS, systemFrame.systemIndex)
end

-- The library's buttons show a tooltip from `button.setting`, so ours use the same shape.
local function ShowButtonTooltip(button)
    SettingsTooltip:SetOwner(button, "ANCHOR_NONE")
    SettingsTooltip:SetPoint("BOTTOMRIGHT", button, "TOPLEFT")
    SettingsTooltip:SetText(button.setting.name, 1, 1, 1)
    SettingsTooltip:AddLine(button.setting.desc)
    SettingsTooltip:Show()
end

local function HideButtonTooltip()
    SettingsTooltip:Hide()
end

-- The library can only add buttons above Blizzard's, so these are our own, slotted into
-- Blizzard's list between Reset To Default Position (3) and Quick Keybind Mode (4).
local function AddStockFlyoutButton(dialog, flyout, text, desc, layoutIndex)
    local button = CreateFrame("Button", nil, dialog.Buttons, "EditModeSystemSettingsDialogExtraButtonTemplate")
    button.layoutIndex = layoutIndex
    button.setting = { name = text, desc = desc }
    button:SetScript("OnEnter", ShowButtonTooltip)
    button:SetScript("OnLeave", HideButtonTooltip)
    button:SetText(LuckyActionbars.Utils.Mark(text))
    button:SetOnClickHandler(ToggleFlyout(flyout, dialog))
    hooksecurefunc(dialog, "UpdateExtraButtons", function()
        button:SetShown(dialog.attachedToSystem and IsStockBar(dialog.attachedToSystem))
    end)
end

-- The library lists a frame's own buttons before its Reset Position button; put ours after it.
-- Its pooled buttons never get a `setting` from the library, so ours is set or cleared on
-- each update to keep the tooltip off other addons' buttons that reuse the frame.
local function AddExtraFlyoutButtons(dialog)
    local S = LuckyActionbars.Strings.bars
    local text = LuckyActionbars.Utils.Mark(S.flyoutButton)
    local setting = { name = S.flyoutButton, desc = S.flyoutDesc }
    for _, bar in pairs(LuckyActionbars.ExtraBars:Frames()) do
        LibEditMode:AddFrameSettingsButtons(bar, {
            { text = text, click = ToggleFlyout(LuckyActionbars.BarFlyout, dialog) },
        })
    end
    hooksecurefunc(dialog, "UpdateButtons", function()
        for _, button in ipairs({ dialog.Buttons:GetChildren() }) do
            button.setting = button.GetText and button:GetText() == text and setting or nil
        end
        if IsExtraBar(dialog.selection) then
            dialog.Buttons.ResetPositionButton.layoutIndex = 0
        end
    end)
end

local DIALOG_GAP = 12

-- LibEditMode draws stock-system settings in a separate panel under Blizzard's dialog.
-- Rather than edit the library, anchor that panel's settings column inside the dialog,
-- left-aligned with Blizzard's own so the checkboxes line up, slot it between Blizzard's
-- settings and buttons, and let the dialog grow to fit.
local function DockExtension(extension)
    local dialog = EditModeSystemSettingsDialog
    local hasBlizzardSettings = dialog.Settings:IsShown()
    local column, buttons = extension.Settings, extension.Buttons
    dialog.Buttons:ClearAllPoints()
    if extension:IsShown() then
        column:ClearAllPoints()
        if hasBlizzardSettings then
            column:SetPoint("TOPLEFT", dialog.Settings, "BOTTOMLEFT", 0, -dialog.Settings.spacing)
        else
            column:SetPoint("TOP", dialog.Title, "BOTTOM", 0, -DIALOG_GAP)
        end
        local last = column
        if not buttons.ignoreInLayout then
            buttons:ClearAllPoints()
            buttons:SetPoint("TOPLEFT", column, "BOTTOMLEFT", 0, -column.spacing)
            last = buttons
        end
        -- The dialog sizes itself from these, so they must be laid out before it is.
        column:Layout()
        buttons:Layout()
        dialog.Buttons:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -DIALOG_GAP)
    elseif hasBlizzardSettings then
        -- Blizzard's own anchors, from EditModeSystemSettingsDialogMixin:UpdateSettings.
        dialog.Buttons:SetPoint("TOPLEFT", dialog.Settings, "BOTTOMLEFT", 0, -DIALOG_GAP)
    else
        dialog.Buttons:SetPoint("TOP", dialog.Title, "BOTTOM", 0, -DIALOG_GAP)
    end
    dialog:Layout()
end

local function MergeExtensionIntoDialog()
    local extension = LibEditMode.internal.extension
    extension.Border:Hide()
    extension.ignoreInLayout = true
    -- The panel frame no longer wraps its column, so it must not catch clicks meant for the dialog.
    extension:EnableMouse(false)
    extension.Settings.ResetButton:Hide()
    local dock = function() DockExtension(extension) end
    hooksecurefunc(extension, "Layout", dock)
    extension:HookScript("OnHide", dock)
    hooksecurefunc(EditModeSystemSettingsDialog, "UpdateSettings", function()
        if extension:IsShown() then dock() end
    end)
end

-- STOCK_BAR_SYSTEMS is in bar order, so each index is that bar's number.
function LuckyActionbars.EditModePanel:Init()
    local stockDialog, extraDialog = EditModeSystemSettingsDialog, LibEditMode.internal.dialog
    for number, subSystem in ipairs(STOCK_BAR_SYSTEMS) do
        LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, StockBarSettings(number), subSystem)
    end
    local fadeDesc = LuckyActionbars.Strings.bars.fade.descNoKeybinds
    LibEditMode:AddSystemSettings(Enum.EditModeSystem.MicroMenu, { FadeSetting("menu", fadeDesc) })
    LibEditMode:AddSystemSettings(Enum.EditModeSystem.Bags, { FadeSetting("bags", fadeDesc) })
    MergeExtensionIntoDialog()
    for number, bar in pairs(LuckyActionbars.ExtraBars:Frames()) do
        LuckyActionbars.ExtraBars:AddEditModeSettings(bar,
            { FadeSetting(number), LuckyActionbars.ExtraBars:RowsGrowSetting(bar) })
    end
    local S = LuckyActionbars.Strings.bars
    AddStockFlyoutButton(stockDialog, LuckyActionbars.BarFlyout, S.flyoutButton, S.flyoutDesc, 3.5)
    AddStockFlyoutButton(stockDialog, LuckyActionbars.PagingFlyout, S.pagingButton, S.pagingDesc, 3.6)
    AddExtraFlyoutButtons(extraDialog)
    LuckyActionbars.BarFlyout:Init({
        [stockDialog] = {
            attach = "AttachToSystemFrame",
            isActionBar = function(systemFrame) return systemFrame.system == Enum.EditModeSystem.ActionBar end,
        },
        -- Other addons' frames share the library's dialog, so only ours count.
        [extraDialog] = {
            attach = "Update",
            isActionBar = IsExtraBar,
        },
    })
    LuckyActionbars.PagingFlyout:Init(stockDialog, IsStockBar)
end
