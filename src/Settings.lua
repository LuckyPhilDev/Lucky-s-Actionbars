LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Settings = {}

local panel

local function BarToggle(group, strings, number, module, ...)
    group:Toggle({
        label = strings.label:format(number),
        desc = strings.desc:format(...),
        checked = function() return module:IsShown(number) end,
        onToggle = function(checked) module:SetShown(number, checked) end,
    })
end

local function ExtraBarToggle(group, S, number)
    local extraBars = LuckyActionbars.ExtraBars
    local page = extraBars:Page(number)
    local form = extraBars:FormOnPage(number)
    local note = form and S.bars.formNote:format(page, LuckyActionbars.Strings.forms[form])
        or LuckyActionbars.Strings.bars.pageUsers[page]
    group:Toggle({
        label = S.bars.extra.label:format(number),
        desc = S.bars.extra.desc:format(page) .. " " .. note,
        disabled = form ~= nil,
        checked = function() return extraBars:IsShown(number) end,
        onToggle = function(checked) extraBars:SetShown(number, checked) end,
    })
end

local function BuildBarRows(group, S)
    group:Section(S.sections.stockBars)
    group:Toggle({ S.bars[1], checked = true, disabled = true })
    for number = 2, 8 do
        BarToggle(group, S.bars.stock, number, LuckyActionbars.StockBars, number)
    end
    group:Section(S.sections.extraBars)
    for number = 9, 12 do
        ExtraBarToggle(group, S, number)
    end
end

local function BuildFadeRows(group, S, db)
    group:Section(S.sections.fade)
    for _, setting in ipairs({ "fadeInMs", "fadeOutMs" }) do
        group:Slider({
            S[setting],
            key = setting,
            min = 0,
            max = 2000,
            step = 50,
            suffix = S.milliseconds,
            value = function() return db[setting] end,
            onChanged = function(ms) db[setting] = ms end,
        })
    end
end

function LuckyActionbars.Settings:Init(db)
    local S = LuckyActionbars.Strings.settings
    panel = LuckySettings:NewRichPanel(LuckyActionbars.Strings.addon.title, {
        addonFolder = "Luckys_Actionbars",
    }, function(builder)
        builder:Group(S.groups.bars, function(group)
            BuildBarRows(group, S)
            BuildFadeRows(group, S, db)
        end)
        builder:Group(S.groups.buttons, function(group)
            group:Toggle({
                S.rangeIndicator,
                checked = function() return db.rangeIndicator end,
                onToggle = function(checked) LuckyActionbars.RangeIndicator:SetEnabled(checked) end,
            })
            for _, setting in ipairs({ "hideKeybinds", "hideMacroNames" }) do
                group:Toggle({
                    S.buttonText[setting],
                    checked = function() return LuckyActionbars.ButtonText:IsHidden(setting) end,
                    onToggle = function(checked) LuckyActionbars.ButtonText:SetHidden(setting, checked) end,
                })
            end
            local modes = {}
            for _, mode in ipairs(LuckyActionbars.Tooltips.MODES) do
                modes[#modes + 1] = { key = mode, label = S.tooltips.modes[mode] }
            end
            group:Select({
                S.tooltips,
                newLine = true,
                options = modes,
                value = function() return LuckyActionbars.Tooltips:GetMode() end,
                onSelect = function(mode) LuckyActionbars.Tooltips:SetMode(mode) end,
            })
        end)
    end)
end

function LuckyActionbars.Settings:Open()
    panel:Open()
end
