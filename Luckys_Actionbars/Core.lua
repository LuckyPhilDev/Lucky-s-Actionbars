LuckyActionbars = LuckyActionbars or {}

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    LuckyActionbars.Paging:Init()
end)
