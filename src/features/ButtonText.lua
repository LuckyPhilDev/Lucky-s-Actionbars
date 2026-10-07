LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.ButtonText = {}

-- Setting key to the button region it hides. Alpha rather than Hide, since Blizzard shows and hides these itself.
local REGIONS = { hideKeybinds = "HotKey", hideMacroNames = "Name" }

local db

-- Not every frame registered with the events frame has both regions, so skip the missing ones.
local function Apply()
    LuckyActionbars.ButtonDriver:ForEachButton(function(button)
        for setting, region in pairs(REGIONS) do
            local text = button[region]
            if text then
                text:SetAlpha(db[setting] and 0 or 1)
            end
        end
    end)
end

function LuckyActionbars.ButtonText:IsHidden(setting)
    return db[setting]
end

function LuckyActionbars.ButtonText:SetHidden(setting, hidden)
    db[setting] = hidden
    Apply()
end

function LuckyActionbars.ButtonText:Init(database)
    db = database
    Apply()
end
