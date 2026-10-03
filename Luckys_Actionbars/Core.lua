LuckyActionbars = LuckyActionbars or {}

local function LoadDatabase()
    LuckyActionbarsDB = LuckyActionbarsDB or {}
    local db = LuckyActionbarsDB
    db.pages = db.pages or {}
    for modifier, page in pairs(LuckyActionbars.DB_DEFAULTS.pages) do
        if db.pages[modifier] == nil then
            db.pages[modifier] = page
        end
    end
    db.bars = db.bars or {}
    for _, number in ipairs(LuckyActionbars.DB_DEFAULTS.extraBars) do
        db.bars[number] = db.bars[number] or { shown = false }
        db.bars[number].positions = db.bars[number].positions or {}
    end
    return db
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    local db = LoadDatabase()
    LuckyActionbars.Paging:Init(db)
    LuckyActionbars.ExtraBars:Init(db)
    LuckyActionbars.EditModePanel:Init()
    LuckyActionbars.Settings:Init(db)
end)

SLASH_LUCKYACTIONBARS1 = "/luckybars"
SlashCmdList.LUCKYACTIONBARS = function()
    LuckyActionbars.Settings:Open()
end
