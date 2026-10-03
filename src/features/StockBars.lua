LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.StockBars = {}

-- Going through the stock proxy settings keeps Options > Action Bars in sync with ours.
local function SettingName(number)
    return "PROXY_SHOW_ACTIONBAR_" .. number
end

function LuckyActionbars.StockBars:IsShown(number)
    return Settings.GetValue(SettingName(number))
end

function LuckyActionbars.StockBars:SetShown(number, shown)
    if InCombatLockdown() then
        print(LuckyActionbars.Strings.bars.combatBlocked)
        return
    end
    Settings.SetValue(SettingName(number), shown)
end
