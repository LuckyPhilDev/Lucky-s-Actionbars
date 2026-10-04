LuckyActionbars = LuckyActionbars or {}
LuckyActionbars.SidePanel = {}

-- Only one side panel is open at a time, so opening one closes the other.
local openPanel

local panelMixin = {}

-- Opens on whichever side of the dialog has room, top edges aligned.
function panelMixin:AnchorBeside(dialog)
    self:ClearAllPoints()
    if dialog:GetRight() + self:GetWidth() > UIParent:GetRight() then
        self:SetPoint("TOPRIGHT", dialog, "TOPLEFT")
    else
        self:SetPoint("TOPLEFT", dialog, "TOPRIGHT")
    end
end

function panelMixin:Follow(dialog, target)
    self.attachedDialog = dialog
    self.refresh(target)
    self.List:Layout()
    self:Layout()
    self:AnchorBeside(dialog)
end

function panelMixin:Toggle(dialog, target)
    if self:IsShown() and self.attachedDialog == dialog then
        self:Hide()
        return
    end
    if openPanel and openPanel ~= self then
        openPanel:Hide()
    end
    openPanel = self
    self:Follow(dialog, target)
    self:Show()
end

-- The panel stays open while you move between targets that `keepsOpen` accepts, following
-- whichever dialog shows them, and closes once something else is selected or nothing is.
-- `attach` names the dialog method that points it at a new target.
function panelMixin:Watch(dialog, attach, keepsOpen)
    dialog:HookScript("OnHide", function()
        if self.attachedDialog == dialog then
            -- Moving between two dialogs can hide this one before the other opens.
            RunNextFrame(function()
                if not self.attachedDialog:IsShown() then
                    self:Hide()
                end
            end)
        end
    end)
    hooksecurefunc(dialog, attach, function(_, target)
        if not self:IsShown() then
            return
        end
        if keepsOpen(target) then
            self:Follow(dialog, target)
        else
            self:Hide()
        end
    end)
end

-- `refresh(target)` updates the rows in panel.List for whatever the dialog is showing.
function LuckyActionbars.SidePanel:Create(refresh)
    local panel = Mixin(CreateFrame("Frame", nil, UIParent, "ResizeLayoutFrame"), panelMixin)
    panel.refresh = refresh
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(400)
    panel:EnableMouse(true)
    panel:Hide()
    panel.widthPadding = 40
    panel.heightPadding = 40

    local border = CreateFrame("Frame", nil, panel, "DialogBorderTranslucentTemplate")
    border.ignoreInLayout = true

    panel.Title = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    panel.Title:SetPoint("TOP", 0, -15)

    panel.List = CreateFrame("Frame", nil, panel, "VerticalLayoutFrame")
    panel.List:SetPoint("TOP", panel.Title, "BOTTOM", 0, -12)
    panel.List.spacing = 2
    return panel
end

local function ShowRowTooltip(row)
    SettingsTooltip:SetOwner(row, "ANCHOR_NONE")
    SettingsTooltip:SetPoint("BOTTOMRIGHT", row, "TOPLEFT")
    SettingsTooltip:SetText(row.Label:GetText(), 1, 1, 1)
    SettingsTooltip:AddLine(row.desc, nil, nil, nil, true)
    SettingsTooltip:Show()
end

local function HideRowTooltip()
    SettingsTooltip:Hide()
end

-- `control` covers most of the row, so it passes hover through for the row's tooltip.
function LuckyActionbars.SidePanel.AddTooltip(row, desc, control)
    row.desc = desc
    control:SetPropagateMouseMotion(true)
    row:SetScript("OnEnter", ShowRowTooltip)
    row:SetScript("OnLeave", HideRowTooltip)
end
