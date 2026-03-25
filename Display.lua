-- Display.lua
-- Main display frame, minimap broker, and UI panel anchoring

local _, CT = ...
CT.Display = {}
local Display = CT.Display

local mainFrame     = nil
local rowFrames     = {}
local userDismissed = false

-- ============================================================
-- Attach-to modes
-- BAGS      = show beside bag, only when a bag is open
-- SCREEN    = always visible, free float
-- CHARACTER = anchor to right of CharacterFrame, show only when open
-- ============================================================
local ATTACH_TARGETS = {
    BAGS      = { label = "Bags" },
    SCREEN    = { label = "Always Visible" },
    CHARACTER = { label = "Character Sheet" },
}
CT.ATTACH_TARGETS = ATTACH_TARGETS

local PANEL_FRAMES = {
    CHARACTER = "CharacterFrame",
}

-- ============================================================
-- Bag frame detection
-- Supports: ElvUI bag, Blizzard combined bag, legacy separate bags
-- ============================================================
local function GetOpenBagFrame()
    local elvBag = _G["ElvUI_ContainerFrame"]
    if elvBag and elvBag:IsShown() then return elvBag end
    local combined = _G["ContainerFrameCombinedBags"]
    if combined and combined:IsShown() then return combined end
    local best = nil
    for i = 1, NUM_CONTAINER_FRAMES or 13 do
        local f = _G["ContainerFrame" .. i]
        if f and f:IsShown() then
            local x = select(4, f:GetPoint()) or 0
            if not best or x < (select(4, best:GetPoint()) or 0) then
                best = f
            end
        end
    end
    return best
end

local function AnyBagOpen()
    if _G["ElvUI_ContainerFrame"] and _G["ElvUI_ContainerFrame"]:IsShown() then return true end
    if _G["ContainerFrameCombinedBags"] and _G["ContainerFrameCombinedBags"]:IsShown() then return true end
    for i = 1, NUM_CONTAINER_FRAMES or 13 do
        local f = _G["ContainerFrame" .. i]
        if f and f:IsShown() then return true end
    end
    return false
end

local function IsPanelOpen(attachTo)
    local frameName = PANEL_FRAMES[attachTo]
    if not frameName then return false end
    local f = _G[frameName]
    return f and f:IsShown()
end

-- ============================================================
-- Build the main frame (called once on enable)
-- ============================================================
function Display:BuildFrame(db)
    if mainFrame then return end

    local disp = db.profile.display

    mainFrame = CreateFrame("Frame", "LarlenCurrencyTrackerFrame", UIParent, "BackdropTemplate")
    mainFrame:SetClampedToScreen(true)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetFrameStrata("HIGH")

    mainFrame:SetScript("OnDragStart", function(f)
        if not db.profile.display.locked then f:StartMoving() end
    end)
    mainFrame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint()
        db.profile.display.point    = point
        db.profile.display.relPoint = relPoint
        db.profile.display.x        = x
        db.profile.display.y        = y
        f:SetParent(UIParent)
        f:ClearAllPoints()
        f:SetPoint(point, UIParent, relPoint, x, y)
    end)

    mainFrame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile     = true, tileSize = 32, edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, -4)
    title:SetText("Larlen Currency Tracker")
    title:SetTextColor(1, 0.82, 0)
    mainFrame.titleText = title

    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 4, 4)
    closeBtn:SetScript("OnClick", function()
        userDismissed = true
        Display:Hide()
    end)
    mainFrame.closeBtn = closeBtn

    local optBtn = CreateFrame("Button", nil, mainFrame)
    optBtn:SetSize(16, 16)
    optBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -2, 0)
    local optTex = optBtn:CreateTexture(nil, "ARTWORK")
    optTex:SetAllPoints()
    optTex:SetTexture("Interface\\GossipFrame\\DailyActiveQuestIcon")
    optBtn:SetScript("OnClick", function()
        LibStub("AceConfigDialog-3.0"):Open("LarlenCurrencyTracker")
    end)
    optBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText("Open Larlen Currency Tracker Options", 1, 1, 1)
        GameTooltip:Show()
    end)
    optBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    mainFrame.optBtn = optBtn

    mainFrame:SetScale(disp.scale)
    mainFrame:SetAlpha(disp.alpha)
    mainFrame:Hide()
    Display:SyncButtons(db)
    Display:SyncLock(db)
end

-- ============================================================
-- SyncButtons
-- ============================================================
function Display:SyncButtons(db)
    if not mainFrame then return end
    local disp = db.profile.display
    local rev  = disp.reverseDirection

    -- X button only shown in SCREEN mode; bags/character auto-hide the frame
    local showClose = disp.showCloseButton and (disp.attachTo == "SCREEN")

    local closeBtn = mainFrame.closeBtn
    local optBtn   = mainFrame.optBtn

    if closeBtn then
        closeBtn:ClearAllPoints()
        if rev then
            closeBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", -2, 2)
        else
            closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 2, 2)
        end
        if showClose then closeBtn:Show() else closeBtn:Hide() end
    end

    if optBtn then
        optBtn:ClearAllPoints()
        if showClose then
            if rev then
                optBtn:SetPoint("TOPLEFT", closeBtn, "TOPRIGHT", 2, 0)
            else
                optBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -2, 0)
            end
        else
            if rev then
                optBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 4, -4)
            else
                optBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)
            end
        end
        if disp.showOptionsButton then optBtn:Show() else optBtn:Hide() end
    end
end

-- ============================================================
-- SyncLock: enable/disable frame dragging
-- ============================================================
function Display:SyncLock(db)
    if not mainFrame then return end
    if db.profile.display.locked then
        mainFrame:SetMovable(false)
        mainFrame:EnableMouse(false)
    else
        mainFrame:SetMovable(true)
        mainFrame:EnableMouse(true)
    end
end

-- ============================================================
-- Apply position / anchoring
-- ============================================================
function Display:ApplyPosition(db)
    if not mainFrame then return end
    local disp = db.profile.display

    mainFrame:SetParent(UIParent)
    mainFrame:ClearAllPoints()

    local isCharDefault   = (disp.point == "TOPLEFT"  and disp.relPoint == "TOPRIGHT" and disp.x == 4  and disp.y == 0)
    local isBagDefault    = (disp.point == "TOPRIGHT" and disp.relPoint == "TOPLEFT"  and disp.x == -4 and disp.y == 0)
    local isScreenDefault = (disp.point == "CENTER"   and disp.relPoint == "CENTER"   and disp.x == 0  and disp.y == 0)
    local userMoved = not (isCharDefault or isBagDefault or isScreenDefault)

    if disp.attachTo == "SCREEN" or userMoved then
        mainFrame:SetPoint(disp.point, UIParent, disp.relPoint, disp.x, disp.y)

    elseif disp.attachTo == "BAGS" then
        local bagFrame = GetOpenBagFrame()
        if bagFrame then
            mainFrame:SetPoint("TOPRIGHT", bagFrame, "TOPLEFT", -4, 0)
        else
            mainFrame:SetPoint(disp.point, UIParent, disp.relPoint, disp.x, disp.y)
        end

    elseif disp.attachTo == "CHARACTER" then
        local f = _G["CharacterFrame"]
        if f then
            mainFrame:SetPoint("TOPLEFT", f, "TOPRIGHT", 4, 0)
        else
            mainFrame:SetPoint(disp.point, UIParent, disp.relPoint, disp.x, disp.y)
        end
    end
end

function Display:OnBankOpened()
    Display:UpdateVisibility(CT.addon.db)
end

function Display:OnBankClosed(db)
    if mainFrame then mainFrame:Hide() end
    C_Timer.After(0.15, function()
        Display:UpdateVisibility(db)
    end)
end

-- ============================================================
-- UpdateVisibility
-- ============================================================
function Display:UpdateVisibility(db)
    if not mainFrame then return end
    local disp = db.profile.display

    if UnitAffectingCombat and UnitAffectingCombat("player") and not disp.showInCombat then
        mainFrame:Hide()
        return
    end

    local shouldShow = false
    if disp.attachTo == "BAGS" then
        shouldShow = AnyBagOpen()
    elseif disp.attachTo == "CHARACTER" then
        local f = _G["CharacterFrame"]
        shouldShow = f ~= nil and f:IsShown()
    else
        shouldShow = not userDismissed
    end

    if disp.attachTo ~= "SCREEN" then
        if not shouldShow then userDismissed = false end
    end

    local isShown = mainFrame:IsShown()
    if shouldShow and not isShown then
        Display:ApplyPosition(db)
        mainFrame:Show()
        Display:Refresh(db)
    elseif not shouldShow and isShown then
        mainFrame:Hide()
    end
end

-- ============================================================
-- Refresh: rebuild all visible rows
-- ============================================================
function Display:Refresh(db)
    if not mainFrame then return end
    if not mainFrame:IsShown() then return end

    local disp = db.profile.display
    local rows = CT:GetRows(db)

    for _, rf in ipairs(rowFrames) do rf:Hide() end

    local iconSize   = disp.iconSize   or 18
    local fontSize   = disp.fontSize   or 14
    local rowSpacing = disp.rowSpacing or 2
    local padLeft    = 10
    local padTop     = 20
    local padBottom  = 8
    local padRight   = 10
    local maxWidth   = 180
    local rev        = disp.reverseDirection

    if mainFrame.titleText then
        mainFrame.titleText:ClearAllPoints()
        if rev then
            mainFrame.titleText:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -8, -4)
            mainFrame.titleText:SetJustifyH("RIGHT")
        else
            mainFrame.titleText:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, -4)
            mainFrame.titleText:SetJustifyH("LEFT")
        end
    end

    for i, row in ipairs(rows) do
        local rf = rowFrames[i]
        if not rf then
            rf = CreateFrame("Frame", nil, mainFrame)
            rf.icon  = rf:CreateTexture(nil, "ARTWORK")
            rf.count = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rf.name  = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rowFrames[i] = rf
        end

        rf:SetParent(mainFrame)
        rf:SetHeight(iconSize)
        rf:ClearAllPoints()
        rf:SetPoint("TOPLEFT", mainFrame, "TOPLEFT",
            padLeft, -(padTop + (i - 1) * (iconSize + rowSpacing)))

        if disp.showIcon then
            rf.icon:SetTexture(row.icon)
            rf.icon:SetSize(iconSize, iconSize)
            rf.icon:ClearAllPoints()
            if rev then
                rf.icon:SetPoint("RIGHT", rf, "RIGHT", 0, 0)
            else
                rf.icon:SetPoint("LEFT", rf, "LEFT", 0, 0)
            end
            rf.icon:Show()
        else
            rf.icon:Hide()
        end

        local iconOffset  = disp.showIcon and (iconSize + 4) or 0
        local rawCount    = CT:FormatCount(row.count, row.max, db)
        local shortMode   = disp.nameShorten or 0
        local displayName = CT:ShortenName(row.name, shortMode)
        local countStr    = (disp.colorize and row.color) and WrapTextInColorCode(rawCount, row.color) or rawCount
        local nameStr     = (disp.colorize and row.color) and WrapTextInColorCode(displayName, row.color) or displayName

        local fontPath
        local LSM     = LibStub and LibStub("LibSharedMedia-3.0", true)
        local fontKey = disp.font or "Friz Quadrata TT"
        if LSM then fontPath = LSM:Fetch("font", fontKey) end
        if not fontPath then
            local builtinFonts = {
                ["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
                ["Arial Narrow"]     = "Fonts\\ARIALN.TTF",
                ["Skurri"]           = "Fonts\\skurri.ttf",
                ["Morpheus"]         = "Fonts\\MORPHEUS.ttf",
                ["Adventure Normal"] = "Fonts\\MORPHEUS.ttf",
                ["Expressway"]       = "Fonts\\ARIALN.TTF",
                ["PT Sans Narrow"]   = "Fonts\\ARIALN.TTF",
            }
            fontPath = builtinFonts[fontKey] or "Fonts\\FRIZQT__.TTF"
        end

        local outlineMap = {
            ["none"]       = "",
            ["outline"]    = "OUTLINE",
            ["thick"]      = "THICKOUTLINE",
            ["monochrome"] = "OUTLINE, MONOCHROME",
        }
        local outlineFlag = outlineMap[disp.fontOutline or "outline"] or "OUTLINE"

        rf.count:SetFont(fontPath, fontSize, outlineFlag)
        rf.name:SetFont(fontPath, fontSize, outlineFlag)
        rf.count:ClearAllPoints()
        rf.name:ClearAllPoints()

        local layout = disp.textLayout
        if not rev then
            if layout == 1 then
                rf.count:SetText(countStr .. " " .. displayName)
                rf.name:SetText("")
                rf.count:SetPoint("LEFT", rf, "LEFT", iconOffset, 0)
            elseif layout == 2 then
                rf.count:SetText(displayName .. " " .. countStr)
                rf.name:SetText("")
                rf.count:SetPoint("LEFT", rf, "LEFT", iconOffset, 0)
            elseif layout == 3 then
                rf.count:SetText(countStr)
                rf.name:SetText("")
                rf.count:SetPoint("LEFT", rf, "LEFT", iconOffset, 0)
            elseif layout == 4 then
                rf.count:SetText(countStr)
                rf.name:SetText(nameStr)
                rf.count:SetPoint("LEFT", rf, "LEFT", iconOffset, 0)
                rf.name:SetPoint("LEFT", rf.count, "RIGHT", 6, 0)
            elseif layout == 5 then
                rf.name:SetText(nameStr)
                rf.count:SetText(countStr)
                rf.name:SetPoint("LEFT", rf, "LEFT", iconOffset, 0)
                rf.count:SetPoint("LEFT", rf.name, "RIGHT", 6, 0)
            end
        else
            if layout == 1 then
                rf.count:SetText(displayName .. " " .. countStr)
                rf.name:SetText("")
                rf.count:SetPoint("RIGHT", rf, "RIGHT", -iconOffset, 0)
            elseif layout == 2 then
                rf.count:SetText(countStr .. " " .. displayName)
                rf.name:SetText("")
                rf.count:SetPoint("RIGHT", rf, "RIGHT", -iconOffset, 0)
            elseif layout == 3 then
                rf.count:SetText(countStr)
                rf.name:SetText("")
                rf.count:SetPoint("RIGHT", rf, "RIGHT", -iconOffset, 0)
            elseif layout == 4 then
                rf.count:SetText(countStr)
                rf.name:SetText(nameStr)
                rf.count:SetPoint("RIGHT", rf, "RIGHT", -iconOffset, 0)
                rf.name:SetPoint("RIGHT", rf.count, "LEFT", -6, 0)
            elseif layout == 5 then
                rf.name:SetText(nameStr)
                rf.count:SetText(countStr)
                rf.name:SetPoint("RIGHT", rf, "RIGHT", -iconOffset, 0)
                rf.count:SetPoint("RIGHT", rf.name, "LEFT", -6, 0)
            end
        end

        rf:EnableMouse(true)
        local capturedRow = row
        rf:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if capturedRow.type == "anima" or capturedRow.type == "stygia" then
                GameTooltip:SetText(capturedRow.name, 1, 1, 1)
                GameTooltip:AddLine("Total: " .. capturedRow.count, 1, 0.82, 0)
            else
                GameTooltip:SetCurrencyByID(capturedRow.id)
            end
            GameTooltip:Show()
        end)
        rf:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local rowW = iconOffset + rf.count:GetStringWidth() + 6 + rf.name:GetStringWidth() + padLeft + padRight
        if rowW > maxWidth then maxWidth = rowW end
        rf:SetWidth(maxWidth)
        rf:Show()
    end

    local totalHeight = padTop + #rows * (iconSize + rowSpacing) + padBottom
    mainFrame:SetSize(maxWidth + padLeft + padRight, totalHeight)

    if disp.background then
        mainFrame:SetBackdropColor(0, 0, 0, disp.bgAlpha or 0.7)
        mainFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, disp.bgAlpha or 0.7)
    else
        mainFrame:SetBackdropColor(0, 0, 0, 0)
        mainFrame:SetBackdropBorderColor(0, 0, 0, 0)
    end

    Display:SyncButtons(db)
    Display:SyncLock(db)
end
-- ============================================================
function Display:Show()
    if mainFrame then
        userDismissed = false
        Display:ApplyPosition(CT.addon.db)
        mainFrame:Show()
        Display:Refresh(CT.addon.db)
    end
end

function Display:Hide()
    if mainFrame then mainFrame:Hide() end
end

function Display:Toggle()
    if mainFrame then
        if mainFrame:IsShown() then
            userDismissed = true
            mainFrame:Hide()
        else
            userDismissed = false
            Display:Show()
        end
    end
end

-- ============================================================
-- DataBroker + Minimap Icon
-- ============================================================
local _ldb_data = {
    type  = "launcher",
    label = "Larlen Currency Tracker",
    icon  = 463446,
    OnClick = function(self, btn)
        if btn == "LeftButton" then
            LibStub("AceConfigDialog-3.0"):Open("LarlenCurrencyTracker")
        elseif btn == "RightButton" then
            if IsShiftKeyDown() then
                LarlenCurrencyTrackerCharDB.hide = true
                if Display.ldbi and Display.ldbi:IsRegistered("LarlenCurrencyTracker") then
                    Display.ldbi:Hide("LarlenCurrencyTracker")
                end
                print("|cffffa500Larlen Currency Tracker|r: Minimap icon hidden. Type |cff00ff00/lct minimap|r to show it again.")
            else
                Display:Toggle()
            end
        end
    end,
    OnTooltipShow = function(tt)
        tt:AddLine("Larlen Currency Tracker", 1, 0.82, 0)
        tt:AddLine(" ")
        tt:AddLine("|cff00ccff Left-Click|r to open options.", 1, 1, 1)
        tt:AddLine("|cff00ccff Right-Click|r to toggle currency display.", 1, 1, 1)
        tt:AddLine("|cff00ccff Shift+Right-Click|r to hide this button.", 1, 1, 1)
        tt:AddLine("|cff00ccff Drag|r to reposition.", 1, 1, 1)
    end,
}

local _ldb = LibStub("LibDataBroker-1.1"):GetDataObjectByName("LarlenCurrencyTracker")
          or LibStub("LibDataBroker-1.1"):NewDataObject("LarlenCurrencyTracker", _ldb_data)

if _ldb then
    _ldb.OnClick       = _ldb_data.OnClick
    _ldb.OnTooltipShow = _ldb_data.OnTooltipShow
    _ldb.icon          = _ldb_data.icon
end

Display.ldbi = LibStub("LibDBIcon-1.0")
Display.ldb  = _ldb

function Display:RegisterMinimapButton()
    LarlenCurrencyTrackerCharDB = LarlenCurrencyTrackerCharDB or {}
    if LarlenCurrencyTrackerCharDB.hide == nil then
        LarlenCurrencyTrackerCharDB.hide = false
    end
    C_Timer.After(0, function()
        if self.ldbi and not self.ldbi:IsRegistered("LarlenCurrencyTracker") then
            self.ldbi:Register("LarlenCurrencyTracker", self.ldb, LarlenCurrencyTrackerCharDB)
        end
        Display:SyncMinimapVisibility()
    end)
end

function Display:SyncMinimapVisibility()
    if not self.ldbi or not self.ldbi:IsRegistered("LarlenCurrencyTracker") then return end
    if LarlenCurrencyTrackerCharDB and LarlenCurrencyTrackerCharDB.hide then
        self.ldbi:Hide("LarlenCurrencyTracker")
    else
        self.ldbi:Show("LarlenCurrencyTracker")
    end
end

function Display:ToggleMinimap()
    LarlenCurrencyTrackerCharDB = LarlenCurrencyTrackerCharDB or {}
    LarlenCurrencyTrackerCharDB.hide = not LarlenCurrencyTrackerCharDB.hide
    Display:SyncMinimapVisibility()
    return not LarlenCurrencyTrackerCharDB.hide
end
