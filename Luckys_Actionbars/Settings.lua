LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Settings = {}

local panel

local function PageOptions(S)
    local options = { { key = 0, label = S.off } }
    for _, page in ipairs(LuckyActionbars.Paging:AllowedPages()) do
        options[#options + 1] = { key = page, label = S.pageLabels[page] }
    end
    return options
end

local function BarToggle(group, strings, number, module, ...)
    group:Toggle({
        label = strings.label:format(number),
        desc = strings.desc:format(...),
        checked = function() return module:IsShown(number) end,
        onToggle = function(checked) module:SetShown(number, checked) end,
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
        BarToggle(group, S.bars.extra, number, LuckyActionbars.ExtraBars, number - 2)
    end
end

function LuckyActionbars.Settings:Init(db)
    local S = LuckyActionbars.Strings.settings
    panel = LuckySettings:NewRichPanel(LuckyActionbars.Strings.addon.title, {
        addonFolder = "Luckys_Actionbars",
    }, function(builder)
        local options = PageOptions(S)
        builder:Group(S.groups.paging, function(group)
            group:Section(S.sections.modifiers)
            for _, modifier in ipairs(LuckyActionbars.Paging.MODIFIERS) do
                group:Select({
                    S.modifiers[modifier],
                    options = options,
                    placeholder = S.off,
                    value = function() return db.pages[modifier] end,
                    onSelect = function(page)
                        db.pages[modifier] = page
                        LuckyActionbars.Paging:Apply()
                    end,
                })
            end
        end)
        builder:Group(S.groups.bars, function(group)
            BuildBarRows(group, S)
        end)
        builder:Group(S.groups.buttons, function(group)
            for _, setting in ipairs({ "hideKeybinds", "hideMacroNames" }) do
                group:Toggle({
                    S.buttonText[setting],
                    checked = function() return LuckyActionbars.ButtonText:IsHidden(setting) end,
                    onToggle = function(checked) LuckyActionbars.ButtonText:SetHidden(setting, checked) end,
                })
            end
        end)
    end)
end

function LuckyActionbars.Settings:Open()
    panel:Open()
end
