LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.EditModePanel = {}

local LibEditMode = LibStub("LibEditMode")

local BAR_NUMBERS = { 9, 10, 11, 12 }
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

-- Bar visibility is account-wide, so the layout name the library passes is ignored.
local function BarSettings()
    local settings = {}
    for _, number in ipairs(BAR_NUMBERS) do
        settings[#settings + 1] = {
            kind = LibEditMode.SettingType.Checkbox,
            name = LuckyActionbars.Strings.bars.names[number],
            default = false,
            get = function() return LuckyActionbars.ExtraBars:IsShown(number) end,
            set = function(_, shown) LuckyActionbars.ExtraBars:SetShown(number, shown) end,
        }
    end
    return settings
end

function LuckyActionbars.EditModePanel:Init()
    for _, subSystem in ipairs(STOCK_BAR_SYSTEMS) do
        LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, BarSettings(), subSystem)
    end
    for _, bar in pairs(LuckyActionbars.ExtraBars:Frames()) do
        LibEditMode:AddFrameSettings(bar, BarSettings())
    end
end
