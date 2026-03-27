local addonName, CT = ...
_G["LarlenCurrencyTracker"] = CT

local addon = LibStub("AceAddon-3.0"):NewAddon("LarlenCurrencyTracker",
    "AceConsole-3.0",
    "AceEvent-3.0"
)
CT.addon = addon

local defaults = {
    profile = {
        display = {
            point        = "TOPRIGHT",
            relPoint     = "TOPLEFT",
            x            = -4,
            y            = 0,
            attachTo     = "BAGS",
            scale        = 1.0,
            alpha        = 1.0,
            showInCombat = true,
            abbreviate   = true,
            showMax      = true,
            colorize     = true,
            textLayout   = 4,
            sortBy       = 1,
            sortCategory = true,
            fontSize     = 14,
            iconSize     = 18,
            rowSpacing   = 2,
            showIcon     = true,
            background   = true,
            bgAlpha      = 0.7,
            showCloseButton   = true,
            showOptionsButton = true,
            reverseDirection  = false,
            showCategories    = false,
            nameShorten       = 0,
            fontOutline       = "outline",
            locked            = false,
        },
        currencies = {},
        categoryState = {},
    },
}

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("LarlenCurrencyTrackerDB", defaults, "Default")
    self:RegisterChatCommand("lct", "SlashHandler")
    self:RegisterChatCommand("larlenct", "SlashHandler")
    CT.Config:Setup(self.db)
    CT.Display:RegisterMinimapButton()
end

function addon:OnEnable()
    self:RegisterEvent("BAG_UPDATE",               "OnDataChanged")
    self:RegisterEvent("BANKFRAME_OPENED",          "OnBankOpened")
    self:RegisterEvent("BANKFRAME_CLOSED",          "OnBankClosed")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE",   "OnDataChanged")
    self:RegisterEvent("PLAYER_ENTERING_WORLD",     "OnEnteringWorld")
    self:RegisterEvent("PLAYER_REGEN_DISABLED",     "OnCombatChanged")
    self:RegisterEvent("PLAYER_REGEN_ENABLED",      "OnCombatChanged")
    self:RegisterEvent("BAG_OPEN",                  "OnVisibilityChanged")
    self:RegisterEvent("BAG_CLOSED",                "OnVisibilityChanged")

    CT.Display:BuildFrame(self.db)
    CT.Display:UpdateVisibility(self.db)
    self:StartVisibilityTicker()
end

function addon:OnDisable()
    CT.Display:Hide()
end

function addon:OnBankOpened()
    CT.Display:OnBankOpened()
    CT.Display:Refresh(self.db)
end

function addon:OnBankClosed()
    CT.Display:OnBankClosed(self.db)
end

function addon:OnEnteringWorld()
    self:DiscoverCurrencies()
    CT.Display:UpdateVisibility(self.db)
end

function addon:OnDataChanged()
    CT.Display:Refresh(self.db)
end

function addon:OnVisibilityChanged()
    CT.Display:UpdateVisibility(self.db)
end

local _tickerRunning = false
function addon:StartVisibilityTicker()
    if _tickerRunning then return end
    _tickerRunning = true
    C_Timer.NewTicker(0.1, function()
        CT.Display:UpdateVisibility(CT.addon.db)
    end)
end

function addon:OnAddonLoaded() end

function addon:OnCombatChanged()
    local inCombat = UnitAffectingCombat("player")
    if inCombat and not self.db.profile.display.showInCombat then
        CT.Display:Hide()
    else
        CT.Display:UpdateVisibility(self.db)
    end
end

local DEFAULT_ON_CURRENCIES = {
    [3376] = true,
    [3377] = true,
    [3385] = true,
    [3316] = true,
    [3379] = true,
    [3256] = true,
    [3400] = true,
    [3260] = true,
    [3264] = true,
    [3392] = true,
    [3319] = true,
    [3265] = true,
    [3258] = true,
    [3266] = true,
    [3257] = true,
    [3263] = true,
    [3262] = true,
    [3261] = true,
    [3259] = true,
    [3373] = true,
    [3352] = true,
    [2032] = true,
    [1166] = true,
}

local WARBAND_CURRENCIES = {
    [2032] = true,
    [3309] = true,
    [3363] = true,
}

function CT:IsCurrencyDiscoveredForDisplay(currencyID, info)
    if not info then return false end
    if info.discovered then return true end
    if WARBAND_CURRENCIES[currencyID] then return true end
    local quantity = tonumber(info.quantity) or 0
    if quantity > 0 then return true end
    local totalEarned = tonumber(info.totalEarned) or 0
    if totalEarned > 0 then return true end
    return false
end

function addon:DiscoverCurrencies()
    local numCurrencies = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, numCurrencies do
        local entry = C_CurrencyInfo.GetCurrencyListInfo(i)
        if entry and not entry.isHeader and entry.currencyID then
            local id  = entry.currencyID
            local key = tostring(id)
            if self.db.profile.currencies[key] == nil then
                self.db.profile.currencies[key] = DEFAULT_ON_CURRENCIES[id] == true
            end
        end
    end
end

function CT:GetRows(db)
    local rows = {}
    local cfg  = db.profile
    local disp = cfg.display

    local numCurrencies = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, numCurrencies do
        local entry = C_CurrencyInfo.GetCurrencyListInfo(i)
        if entry and not entry.isHeader and entry.currencyID then
            local id  = entry.currencyID
            local key = tostring(id)
            if (not LarlenCurrencyTrackerHiddenCurrencyIDs or not LarlenCurrencyTrackerHiddenCurrencyIDs[id]) and cfg.currencies[key] == true then
                local info = C_CurrencyInfo.GetCurrencyInfo(id)
                if CT:IsCurrencyDiscoveredForDisplay(id, info) then
                    local count = info.quantity
                    local max   = info.maxQuantity
                    if id == 1822 then count = count + 1; max = max + 1 end

                    local expKey    = LarlenCurrencyTrackerGetExpansionKey(id, info.name)
                    local expData   = LarlenCurrencyTrackerExpansions[expKey] or LarlenCurrencyTrackerExpansions["Misc"]
                    local catLetter = expData and expData.letter or "L"

                    local row = {
                        id        = id,
                        name      = info.name,
                        icon      = info.iconFileID,
                        count     = count,
                        max       = max,
                        color     = CT:QualityColor(info.quality),
                        type      = "currency",
                        expKey    = expKey,
                        expansion = expData and expData.label or "Miscellaneous",
                        catLetter = catLetter,
                    }
                    row.sortIndex = CT:BuildSortIndex(row, disp, catLetter)
                    rows[#rows + 1] = row
                end
            end
        end
    end

    table.sort(rows, function(a, b)
        if type(a.sortIndex) == type(b.sortIndex) then
            return a.sortIndex < b.sortIndex
        end
        return tostring(a.sortIndex) < tostring(b.sortIndex)
    end)

    return rows
end

function CT:QualityColor(quality)
    if not quality then return "ffffffff" end
    local r, g, b = GetItemQualityColor(quality)
    if r then
        return string.format("ff%02x%02x%02x",
            math.floor(r * 255),
            math.floor(g * 255),
            math.floor(b * 255))
    end
    return "ffffffff"
end

function CT:BuildSortIndex(row, disp, catLetter)
    local sortBy = disp.sortBy
    if sortBy == 2 then return row.count
    elseif sortBy == 3 then return row.id
    else
        if disp.sortCategory then
            return catLetter .. row.name
        end
        return row.name
    end
end

local SKIP_WORDS = { ["of"] = true, ["the"] = true, ["a"] = true, ["an"] = true }

function CT:ShortenName(name, mode)
    if not name or not mode or mode == 0 then return name end
    local words = {}
    for w in name:gmatch("%S+") do words[#words + 1] = w end
    if mode == 1 then
        local parts = {}
        for _, w in ipairs(words) do
            if not SKIP_WORDS[w:lower()] or #parts == 0 then
                parts[#parts + 1] = w:sub(1, 3)
            end
        end
        return table.concat(parts, " ")
    elseif mode == 2 then
        local parts = {}
        for _, w in ipairs(words) do
            if not SKIP_WORDS[w:lower()] then
                parts[#parts + 1] = w:sub(1, 1):upper()
            end
        end
        return table.concat(parts)
    end
    return name
end

function CT:FormatCount(count, max, db)
    local disp = db.profile.display
    local c    = count

    if disp.abbreviate then
        if c >= 1e6 then
            c = string.format("%.2fM", math.floor(c / 10000) / 100)
        elseif c >= 1e3 then
            c = string.format("%.1fK", math.floor(c / 100) / 10)
        else
            c = tostring(c)
        end
    else
        c = tostring(c)
    end

    if disp.showMax and max and max > 0 then
        local m = max
        if disp.abbreviate then
            if m >= 1e6 then
                m = string.format("%.2fM", math.floor(m / 10000) / 100)
            elseif m >= 1e3 then
                m = string.format("%.1fK", math.floor(m / 100) / 10)
            else
                m = tostring(m)
            end
        else
            m = tostring(m)
        end
        c = c .. "/" .. m
    end

    return c
end

function addon:SlashHandler(input)
    input = input and input:trim():lower() or ""
    if input == "options" or input == "config" or input == "opt" then
        LibStub("AceConfigDialog-3.0"):Open("LarlenCurrencyTracker")
    elseif input == "hide" then
        CT.Display:Hide()
    elseif input == "lock" then
        self.db.profile.display.locked = true
        CT.Display:SyncLock(self.db)
        print("|cffffa500Larlen Currency Tracker|r: Frame |cffff4444locked|r.")
    elseif input == "unlock" then
        self.db.profile.display.locked = false
        CT.Display:SyncLock(self.db)
        print("|cffffa500Larlen Currency Tracker|r: Frame |cff44ff44unlocked|r.")
    elseif input == "minimap" then
        local nowVisible = CT.Display:ToggleMinimap()
        print("|cffffa500Larlen Currency Tracker|r: Minimap icon is now " ..
              (nowVisible and "|cff00ff00Shown|r" or "|cffff0000Hidden|r"))
    else
        local attachTo = self.db and self.db.profile.display.attachTo or "SCREEN"
        if attachTo == "SCREEN" then
            CT.Display:Show()
        elseif attachTo == "BAGS" then
            print("|cffffa500Larlen Currency Tracker|r: Window is attached to your |cffffcc00Bags|r - it shows automatically when you open them.")
        elseif attachTo == "CHARACTER" then
            print("|cffffa500Larlen Currency Tracker|r: Window is attached to the |cffffcc00Character Sheet|r - it shows automatically when you open it.")
        end
    end
end
