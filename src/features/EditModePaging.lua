LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.EditModePaging = {}

local LibEditMode = LibStub("LibEditMode")

local expanded = false

local function PageValues(number)
    local S = LuckyActionbars.Strings.settings
    local values = { { text = S.off, value = 0 } }
    for _, page in ipairs(LuckyActionbars.Paging:AllowedPages()) do
        if page ~= LuckyActionbars.Paging:HomePage(number) then
            values[#values + 1] = { text = S.pageLabels[page], value = page }
        end
    end
    return values
end

local function IsCollapsed()
    return not expanded
end

-- Paging is account-wide, so the layout name the library passes is ignored.
local function PagingSettings(number)
    local S = LuckyActionbars.Strings.settings
    local settings = {
        {
            kind = LibEditMode.SettingType.Expander,
            name = S.paging.expander,
            default = false,
            get = function() return expanded end,
            set = function(_, value) expanded = value end,
        },
    }
    local values = PageValues(number)
    for _, trigger in ipairs(LuckyActionbars.Paging.TRIGGERS) do
        settings[#settings + 1] = {
            kind = LibEditMode.SettingType.Dropdown,
            name = S.modifiers[trigger].label,
            desc = S.modifiers[trigger].desc,
            default = 0,
            values = values,
            hidden = IsCollapsed,
            get = function() return LuckyActionbars.Paging:GetPage(number, trigger) end,
            set = function(_, page) LuckyActionbars.Paging:SetPage(number, trigger, page) end,
        }
    end
    return settings
end

-- Subsystem index N is Action Bar N for the eight stock bars.
function LuckyActionbars.EditModePaging:Init()
    for number = 1, LuckyActionbars.Paging.BAR_COUNT do
        LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, PagingSettings(number), number)
    end
end
