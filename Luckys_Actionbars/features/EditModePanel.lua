LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.EditModePanel = {}

local LibEditMode = LibStub("LibEditMode")

local BAR_NUMBERS = { 9, 10, 11, 12 }

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
    LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, BarSettings())
    for _, bar in pairs(LuckyActionbars.ExtraBars:Frames()) do
        LibEditMode:AddFrameSettings(bar, BarSettings())
    end
end
