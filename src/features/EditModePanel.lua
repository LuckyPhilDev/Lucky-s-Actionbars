LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.EditModePanel = {}

local LibEditMode = LibStub("LibEditMode")

local EXTRA_BAR_NUMBERS = { 9, 10, 11, 12 }
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

local function FadeSetting(number)
    return {
        kind = LibEditMode.SettingType.Checkbox,
        name = LuckyActionbars.Strings.bars.fade.label,
        desc = LuckyActionbars.Strings.bars.fade.desc,
        default = false,
        get = function() return LuckyActionbars.MouseoverFade:IsFaded(number) end,
        set = function(_, faded) LuckyActionbars.MouseoverFade:SetFaded(number, faded) end,
    }
end

-- Bar settings are account-wide, so the layout name the library passes is ignored.
local function BarSettings(number)
    local settings = {
        FadeSetting(number),
        { kind = LibEditMode.SettingType.Divider, name = LuckyActionbars.Strings.bars.extraBarsDivider },
    }
    for _, extraNumber in ipairs(EXTRA_BAR_NUMBERS) do
        settings[#settings + 1] = {
            kind = LibEditMode.SettingType.Checkbox,
            name = LuckyActionbars.Strings.bars.names[extraNumber],
            desc = LuckyActionbars.Strings.bars.pageUsers[LuckyActionbars.ExtraBars:Page(extraNumber)],
            default = false,
            hidden = function() return not LuckyActionbars.ExtraBars:IsAvailable(extraNumber) end,
            get = function() return LuckyActionbars.ExtraBars:IsShown(extraNumber) end,
            set = function(_, shown) LuckyActionbars.ExtraBars:SetShown(extraNumber, shown) end,
        }
    end
    return settings
end

-- STOCK_BAR_SYSTEMS is in bar order, so each index is that bar's number.
function LuckyActionbars.EditModePanel:Init()
    for number, subSystem in ipairs(STOCK_BAR_SYSTEMS) do
        LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, BarSettings(number), subSystem)
    end
    for number, bar in pairs(LuckyActionbars.ExtraBars:Frames()) do
        LuckyActionbars.ExtraBars:AddEditModeSettings(bar, BarSettings(number))
    end
end
