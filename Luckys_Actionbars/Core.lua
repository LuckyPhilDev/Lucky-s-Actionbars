LuckyActionbars = LuckyActionbars or {}

local function LoadDatabase()
    LuckyActionbarsDB = LuckyActionbarsDB or {}
    local db = LuckyActionbarsDB
    for key, value in pairs(LuckyActionbars.DB_DEFAULTS) do
        if type(value) ~= "table" and db[key] == nil then
            db[key] = value
        end
    end
    if not db.paging then
        -- Before paging moved into Edit Mode it only covered Action Bar 1, stored as db.pages.
        db.paging = db.pages and { [1] = db.pages } or CopyTable(LuckyActionbars.DB_DEFAULTS.paging)
        db.pages = nil
    end
    for number = 1, LuckyActionbars.Paging.BAR_COUNT do
        db.paging[number] = db.paging[number] or {}
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
    LuckyActionbars.RangeIndicator:Init(db)
    LuckyActionbars.ButtonText:Init(db)
    LuckyActionbars.Tooltips:Init(db)
    LuckyActionbars.EditModePanel:Init()
    LuckyActionbars.EditModePaging:Init()
    LuckyActionbars.Settings:Init(db)
end)

SLASH_LUCKYACTIONBARS1 = "/luckybars"
SlashCmdList.LUCKYACTIONBARS = function()
    LuckyActionbars.Settings:Open()
end
