local _, CT = ...
CT.Display = {}
local Display = CT.Display

local mainFrame     = nil
local rowFrames     = {}
local userDismissed = false
local PRIMARY_ORDER = { "Mid", "Delve", "PvP", "Misc" }
local LEGACY_ORDER = { "TWW", "DF", "SL", "BFA", "Leg", "WoD", "MoP", "Cata", "WotLK", "BC" }
local BUILTIN_FONTS = {
    ["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
    ["Arial Narrow"]     = "Fonts\\ARIALN.TTF",
    ["Skurri"]           = "Fonts\\skurri.ttf",
    ["Morpheus"]         = "Fonts\\MORPHEUS.ttf",
    ["Adventure Normal"] = "Fonts\\MORPHEUS.ttf",
    ["Expressway"]       = "Fonts\\ARIALN.TTF",
    ["PT Sans Narrow"]   = "Fonts\\ARIALN.TTF",
}
local OUTLINE_MAP = {
    ["none"]       = "",
    ["outline"]    = "OUTLINE",
    ["thick"]      = "THICKOUTLINE",
    ["monochrome"] = "OUTLINE, MONOCHROME",
}

local function RowOnEnter(self)
    if self.isHeader then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to expand or collapse", 1, 1, 1)
        GameTooltip:Show()
        return
    end
    local row = self.rowData
    if not row then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if row.type == "anima" or row.type == "stygia" then
        GameTooltip:SetText(row.name, 1, 1, 1)
        GameTooltip:AddLine("Total: " .. row.count, 1, 0.82, 0)
    else
        GameTooltip:SetCurrencyByID(row.id)
    end
    GameTooltip:Show()
end

local function RowOnLeave()
    GameTooltip:Hide()
end

local function RowOnMouseUp(self, btn)
    if btn ~= "LeftButton" then return end
    if not self.isHeader then return end
    if not self.stateTable or not self.stateKey or not self.db then return end
    self.stateTable[self.stateKey] = not self.stateTable[self.stateKey]
    Display:Refresh(self.db)
end

local ATTACH_TARGETS = {
    BAGS      = { label = "Bags" },
    SCREEN    = { label = "Always Visible" },
    CHARACTER = { label = "Character Sheet" },
}
CT.ATTACH_TARGETS = ATTACH_TARGETS

local PANEL_FRAMES = {
    CHARACTER = "CharacterFrame",
}

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

function Display:SyncButtons(db)
    if not mainFrame then return end
    local disp = db.profile.display
    local rev  = disp.reverseDirection

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

function Display:Refresh(db)
    if not mainFrame then return end
    if not mainFrame:IsShown() then return end

    local disp = db.profile.display
    local rows = CT:GetRows(db)
    db.profile.categoryState = db.profile.categoryState or {}
    local state = db.profile.categoryState

    local function EnsureState(stateKey, defaultOpen)
        if state[stateKey] == nil then
            state[stateKey] = defaultOpen
        end
    end

    local visibleRows = {}
    local showCategories = disp.showCategories == true
    if showCategories then
        local byExp = {}
        for _, row in ipairs(rows) do
            local expKey = row.expKey or "Misc"
            byExp[expKey] = byExp[expKey] or {}
            byExp[expKey][#byExp[expKey] + 1] = row
        end

        local function AddHeader(stateKey, label, indent, defaultOpen)
            EnsureState(stateKey, defaultOpen)
            visibleRows[#visibleRows + 1] = {
                type = "header",
                stateKey = stateKey,
                label = label,
                indent = indent or 0,
            }
            return state[stateKey]
        end
        local function AddCurrencies(list)
            for _, r in ipairs(list) do
                visibleRows[#visibleRows + 1] = r
            end
        end

        for _, expKey in ipairs(PRIMARY_ORDER) do
            local list = byExp[expKey]
            if list and #list > 0 then
                local expData = LarlenCurrencyTrackerExpansions[expKey]
                local isOpen = AddHeader("cat_" .. expKey, expData and expData.label or expKey, 0, true)
                if isOpen then
                    AddCurrencies(list)
                end
            end
        end

        local hasLegacy = false
        for _, expKey in ipairs(LEGACY_ORDER) do
            local list = byExp[expKey]
            if list and #list > 0 then
                hasLegacy = true
                break
            end
        end
        if hasLegacy then
            local legacyOpen = AddHeader("cat_Legacy", "Legacy", 0, false)
            if legacyOpen then
                for _, expKey in ipairs(LEGACY_ORDER) do
                    local list = byExp[expKey]
                    if list and #list > 0 then
                        local expData = LarlenCurrencyTrackerExpansions[expKey]
                        local childOpen = AddHeader("cat_legacy_" .. expKey, expData and expData.label or expKey, 1, false)
                        if childOpen then
                            AddCurrencies(list)
                        end
                    end
                end
            end
        end
    else
        for _, row in ipairs(rows) do
            visibleRows[#visibleRows + 1] = row
        end
    end

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
    local shownRows  = 0

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

    for i, row in ipairs(visibleRows) do
        local rf = rowFrames[i]
        if not rf then
            rf = CreateFrame("Frame", nil, mainFrame)
            rf.icon  = rf:CreateTexture(nil, "ARTWORK")
            rf.count = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rf.name  = rf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rf:SetScript("OnEnter", RowOnEnter)
            rf:SetScript("OnLeave", RowOnLeave)
            rf:SetScript("OnMouseUp", RowOnMouseUp)
            rowFrames[i] = rf
        end

        rf:SetParent(mainFrame)
        rf:SetHeight(iconSize)
        rf:ClearAllPoints()
        rf:SetPoint("TOPLEFT", mainFrame, "TOPLEFT",
            padLeft, -(padTop + (i - 1) * (iconSize + rowSpacing)))
        rf.rowData = row
        rf.db = db

        local iconOffset = 0
        local rowW = 0

        local fontPath
        local LSM     = LibStub and LibStub("LibSharedMedia-3.0", true)
        local fontKey = disp.font or "Friz Quadrata TT"
        if LSM then fontPath = LSM:Fetch("font", fontKey) end
        if not fontPath then
            fontPath = BUILTIN_FONTS[fontKey] or "Fonts\\FRIZQT__.TTF"
        end

        local outlineFlag = OUTLINE_MAP[disp.fontOutline or "outline"] or "OUTLINE"

        rf.count:SetFont(fontPath, fontSize, outlineFlag)
        rf.name:SetFont(fontPath, fontSize, outlineFlag)
        rf.count:ClearAllPoints()
        rf.name:ClearAllPoints()

        if row.type == "header" then
            rf.isHeader = true
            rf.stateTable = state
            rf.stateKey = row.stateKey
            rf.icon:Hide()
            local indentOffset = (row.indent or 0) * 14
            local marker = state[row.stateKey] and "[-]" or "[+]"
            local headerText = marker .. " " .. row.label
            rf.count:SetText("|cffffd200" .. headerText .. "|r")
            rf.name:SetText("")
            if not rev then
                rf.count:SetPoint("LEFT", rf, "LEFT", indentOffset, 0)
            else
                rf.count:SetPoint("RIGHT", rf, "RIGHT", -indentOffset, 0)
            end
            rowW = indentOffset + rf.count:GetStringWidth() + padLeft + padRight
        else
            rf.isHeader = false
            rf.stateTable = nil
            rf.stateKey = nil
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

            iconOffset  = disp.showIcon and (iconSize + 4) or 0
            local rawCount    = CT:FormatCount(row.count, row.max, db)
            local shortMode   = disp.nameShorten or 0
            local displayName = CT:ShortenName(row.name, shortMode)
            local countStr    = (disp.colorize and row.color) and WrapTextInColorCode(rawCount, row.color) or rawCount
            local nameStr     = (disp.colorize and row.color) and WrapTextInColorCode(displayName, row.color) or displayName

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
            rowW = iconOffset + rf.count:GetStringWidth() + 6 + rf.name:GetStringWidth() + padLeft + padRight
        end

        rf:EnableMouse(true)
        if rowW > maxWidth then maxWidth = rowW end
        shownRows = i
        rf:Show()
    end

    for i = 1, shownRows do
        rowFrames[i]:SetWidth(maxWidth)
    end

    local totalHeight = padTop + #visibleRows * (iconSize + rowSpacing) + padBottom
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
