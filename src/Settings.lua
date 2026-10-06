LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.Settings = {}

local panel

local function BarModule(number)
    return number > LuckyActionbars.Paging.BAR_COUNT and LuckyActionbars.ExtraBars or LuckyActionbars.StockBars
end

-- Extra bars whose page a form already uses can't be shown, so they're left out and named in the description.
local function BuildBarRows(group, S)
    local extraBars = LuckyActionbars.ExtraBars
    local options, notes = {}, { S.bars.shown.desc }
    for number = 2, 12 do
        local form = number > LuckyActionbars.Paging.BAR_COUNT and extraBars:FormOnPage(number)
        if form then
            notes[#notes + 1] = S.bars.formNote:format(number, LuckyActionbars.Strings.forms[form])
        else
            options[#options + 1] = { key = number, label = S.bars.stock.label:format(number) }
        end
    end
    group:Section(S.sections.bars)
    group:MultiSelect({
        label = S.bars.shown.label,
        desc = table.concat(notes, " "),
        options = options,
        isChecked = function(number) return BarModule(number):IsShown(number) end,
        onToggle = function(number, checked) BarModule(number):SetShown(number, checked) end,
        summarize = function(labels)
            if #labels == #options then return S.bars.all end
            local numbers = {}
            for index, label in ipairs(labels) do numbers[index] = label:match("%d+") end
            return #numbers > 0 and table.concat(numbers, ", ") or S.bars.none
        end,
    })
    group:Section(S.sections.skyriding)
    group:Toggle({
        S.shareSkyriding,
        checked = function() return LuckyActionbars.SkyridingBar:IsSharing() end,
        onToggle = function(checked) LuckyActionbars.SkyridingBar:SetSharing(checked) end,
    })
    group:Toggle({
        S.includeSkyriding,
        parent = S.shareSkyriding,
        checked = function() return LuckyActionbars.SkyridingBar:IsIncluded() end,
        onToggle = function(checked) LuckyActionbars.SkyridingBar:SetIncluded(checked) end,
    })
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

-- Only the addons loaded right now can be read, and that can't change without a reload.
local function BuildImportRows(group, S, db)
    local Import = LuckyActionbars.Import
    local sources = Import:LoadedSources()
    if #sources == 0 and not Import:CanUndo() and not db.devMode then
        return
    end
    group:Section(S.sections.import)
    for _, source in ipairs(sources) do
        group:Button({
            label = S.importFrom.label:format(source.title),
            desc = S.importFrom.desc:format(source.title, source.title),
            width = 200,
            onClick = function() Import:Run(source) end,
        })
    end
    if Import:CanUndo() then
        group:Button({ S.undoImport, width = 200, onClick = function() Import:Undo() end })
    end
    -- Read once when the panel is built, so turning dev mode on shows it after a reload.
    if db.devMode then
        group:Button({ S.reverseImport, width = 200, onClick = function() Import:Reverse() end })
    end
end

function LuckyActionbars.Settings:Init(db)
    local S = LuckyActionbars.Strings.settings
    panel = LuckySettings:NewRichPanel(LuckyActionbars.Strings.addon.title, {
        addonFolder = "Luckys_Actionbars",
        devMode = {
            checked = function() return db.devMode end,
            onToggle = function(checked) db.devMode = checked end,
        },
        -- The minimap button seeds db.minimap after this panel is created, so a first run reads as shown.
        minimapButton = {
            checked = function() return not (db.minimap or {}).hide end,
            onToggle = function(checked) LuckyActionbars.minimapButton:SetShown_Persisted(checked) end,
        },
    }, function(builder)
        builder:Group(S.groups.whatsNew)
        builder:Group(S.groups.bars, function(group)
            group:Section(S.sections.paging)
            group:Toggle({
                S.morePaging,
                since = "0.2",
                checked = function() return db.morePaging end,
                onToggle = function(checked) LuckyActionbars.Paging:SetMorePaging(checked) end,
            })
            BuildFadeRows(group, S, db)
            BuildBarRows(group, S)
            BuildImportRows(group, S, db)
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
        -- Finalize lays out What's New, which the promo row must sit below; the automatic call after this is a no-op.
        builder:Finalize()
        LuckyPromo:AddToRichGroup(builder.whatsNewGroup, "Luckys_Actionbars")
    end)
end

function LuckyActionbars.Settings:Open()
    panel:Open()
end
