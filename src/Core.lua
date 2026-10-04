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
    db.fade = db.fade or {}
    db.rowsDown = db.rowsDown or {}
    db.bars = db.bars or {}
    for _, number in ipairs(LuckyActionbars.DB_DEFAULTS.extraBars) do
        db.bars[number] = db.bars[number] or { shown = false }
        db.bars[number].positions = db.bars[number].positions or {}
        db.bars[number].layouts = db.bars[number].layouts or {}
    end
    return db
end

-- PLAYER_LOGIN, not ADDON_LOADED: paging mirrors key bindings, which are not loaded until then.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    local db = LoadDatabase()
    LuckyActionbars.Paging:Init(db)
    LuckyActionbars.ExtraBars:Init(db)
    LuckyActionbars.RangeIndicator:Init(db)
    LuckyActionbars.ButtonText:Init(db)
    LuckyActionbars.Tooltips:Init(db)
    LuckyActionbars.MouseoverFade:Init(db)
    LuckyActionbars.RowDirection:Init(db)
    LuckyActionbars.EditModePanel:Init()
    LuckyActionbars.Settings:Init(db)
    LuckyActionbars.minimapButton = LuckyMinimap:Create({
        name = "LuckyActionbarsMinimapButton",
        tocname = "Luckys_Actionbars",
        icon = "Interface\\Icons\\INV_Misc_Gear_01",
        dbKey = "minimap",
        db = db,
        defaultAngle = 280,
        onClick = function(_, mouseButton)
            if mouseButton == "RightButton" then
                LuckyActionbars.Settings:Open()
            elseif mouseButton == "MiddleButton" then
                db.devMode = not db.devMode
                print(LuckyActionbars.Strings.addon[db.devMode and "devModeOn" or "devModeOff"])
            elseif EditModeManagerFrame:IsShown() then
                HideUIPanel(EditModeManagerFrame)
            elseif EditModeManagerFrame:CanEnterEditMode() then
                ShowUIPanel(EditModeManagerFrame)
            end
        end,
        tooltip = function(tooltip)
            tooltip:AddLine(LuckyActionbars.Strings.addon.title)
            for _, hint in ipairs(LuckyActionbars.Strings.addon.minimapHints) do
                tooltip:AddLine(hint, 0.8, 0.8, 0.8)
            end
        end,
    })
end)

SLASH_LUCKYACTIONBARS1 = "/luckybars"
SlashCmdList.LUCKYACTIONBARS = function()
    LuckyActionbars.Settings:Open()
end
