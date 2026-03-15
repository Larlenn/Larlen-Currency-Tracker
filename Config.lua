-- Config.lua
-- AceConfig options table and registration

local _, CT = ...
CT.Config = {}
local Config = CT.Config

function Config:Setup(db)
    local options = {
        name    = "Larlen Currency Tracker",
        handler = CT.addon,
        type    = "group",
        args    = {

            -- ── General ───────────────────────────────────────────
            generalHeader = {
                order = 1, type = "header", name = "General",
            },
            showInCombat = {
                order = 2, type = "toggle", name = "Show in Combat",
                desc  = "Keep the currency list visible while in combat.",
                get   = function() return db.profile.display.showInCombat end,
                set   = function(_, v)
                    db.profile.display.showInCombat = v
                    CT.Display:Refresh(db)
                end,
            },
            minimapIcon = {
                order = 3, type = "toggle", name = "Show Minimap Button",
                desc  = "Show or hide the minimap button. Saved per character.",
                get = function()
                    return not (LarlenCurrencyTrackerCharDB and LarlenCurrencyTrackerCharDB.hide)
                end,
                set = function(_, v)
                    LarlenCurrencyTrackerCharDB = LarlenCurrencyTrackerCharDB or {}
                    LarlenCurrencyTrackerCharDB.hide = not v
                    CT.Display:SyncMinimapVisibility()
                end,
            },
            background = {
                order = 4, type = "toggle", name = "Show Background",
                desc  = "Draw a dark background behind the currency list.",
                get   = function() return db.profile.display.background end,
                set   = function(_, v)
                    db.profile.display.background = v
                    CT.Display:Refresh(db)
                end,
            },
            bgAlpha = {
                order = 5, type = "range", name = "Background Opacity",
                min = 0, max = 1, step = 0.05,
                get = function() return db.profile.display.bgAlpha end,
                set = function(_, v)
                    db.profile.display.bgAlpha = v
                    CT.Display:Refresh(db)
                end,
            },

            -- ── Appearance ────────────────────────────────────────
            appearanceHeader = {
                order = 10, type = "header", name = "Appearance",
            },
            scale = {
                order = 11, type = "range", name = "Frame Scale",
                min = 0.5, max = 2.0, step = 0.05,
                get = function() return db.profile.display.scale end,
                set = function(_, v)
                    db.profile.display.scale = v
                    if _G["LarlenCurrencyTrackerFrame"] then
                        _G["LarlenCurrencyTrackerFrame"]:SetScale(v)
                    end
                end,
            },
            alpha = {
                order = 12, type = "range", name = "Frame Opacity",
                min = 0.1, max = 1.0, step = 0.05,
                get = function() return db.profile.display.alpha end,
                set = function(_, v)
                    db.profile.display.alpha = v
                    if _G["LarlenCurrencyTrackerFrame"] then
                        _G["LarlenCurrencyTrackerFrame"]:SetAlpha(v)
                    end
                end,
            },
            fontSize = {
                order = 13, type = "range", name = "Font Size",
                min = 8, max = 24, step = 1,
                get = function() return db.profile.display.fontSize end,
                set = function(_, v)
                    db.profile.display.fontSize = v
                    CT.Display:Refresh(db)
                end,
            },
            iconSize = {
                order = 14, type = "range", name = "Icon Size",
                min = 10, max = 36, step = 1,
                get = function() return db.profile.display.iconSize end,
                set = function(_, v)
                    db.profile.display.iconSize = v
                    CT.Display:Refresh(db)
                end,
            },
            rowSpacing = {
                order = 15, type = "range", name = "Row Spacing",
                min = 0, max = 10, step = 1,
                get = function() return db.profile.display.rowSpacing end,
                set = function(_, v)
                    db.profile.display.rowSpacing = v
                    CT.Display:Refresh(db)
                end,
            },
            showIconAppearance = {
                order = 16, type = "toggle", name = "Show Currency Icon",
                get = function() return db.profile.display.showIcon end,
                set = function(_, v)
                    db.profile.display.showIcon = v
                    CT.Display:Refresh(db)
                end,
            },
            showCloseButton = {
                order = 17, type = "toggle", name = "Show Close Button (X)",
                desc  = "Show or hide the X button. Only applies in Always Visible mode — in Bags and Character Sheet modes the frame auto-hides, so the X is not shown.",
                get   = function() return db.profile.display.showCloseButton end,
                set   = function(_, v)
                    db.profile.display.showCloseButton = v
                    CT.Display:SyncButtons(db)
                end,
            },
            showOptionsButton = {
                order = 18, type = "toggle", name = "Show Options Button (?)",
                desc  = "Show or hide the ? options button on the currency tracker frame.",
                get   = function() return db.profile.display.showOptionsButton end,
                set   = function(_, v)
                    db.profile.display.showOptionsButton = v
                    CT.Display:SyncButtons(db)
                end,
            },

            -- ── Text Format ───────────────────────────────────────
            textHeader = {
                order = 20, type = "header", name = "Text Formatting",
            },
            font = {
                order = 20.5, type = "select", name = "Font",
                desc  = "Choose the font for currency text. More fonts available if LibSharedMedia addons (ElvUI, DBM, BigWigs etc.) are installed.",
                values = function()
                    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
                    if LSM then
                        local fonts = LSM:HashTable("font")
                        local t = {}
                        for name, _ in pairs(fonts) do t[name] = name end
                        return t
                    end
                    return {
                        ["Friz Quadrata TT"]  = "Friz Quadrata (Default UI)",
                        ["Arial Narrow"]      = "Arial Narrow",
                        ["Skurri"]            = "Skurri",
                        ["Morpheus"]          = "Morpheus",
                        ["Adventure Normal"]  = "Adventure Normal",
                        ["Expressway"]        = "Expressway",
                        ["PT Sans Narrow"]    = "PT Sans Narrow",
                    }
                end,
                get = function()
                    return db.profile.display.font or "Friz Quadrata TT"
                end,
                set = function(_, v)
                    db.profile.display.font = v
                    CT.Display:Refresh(db)
                end,
            },
            fontOutline = {
                order = 20.7, type = "select", name = "Font Outline",
                desc  = "Style of outline drawn around each character.",
                values = {
                    ["none"]       = "None",
                    ["outline"]    = "Outline",
                    ["thick"]      = "Thick Outline",
                    ["monochrome"] = "Monochrome",
                },
                get = function() return db.profile.display.fontOutline or "outline" end,
                set = function(_, v)
                    db.profile.display.fontOutline = v
                    CT.Display:Refresh(db)
                end,
            },
            textLayout = {
                order = 21, type = "select", name = "Text Layout",
                desc  = "How to arrange the count and name text.",
                values = {
                    [1] = "Count  Name  (one column)",
                    [2] = "Name  Count  (one column)",
                    [3] = "Count only",
                    [4] = "Count | Name  (two columns)",
                    [5] = "Name | Count  (two columns)",
                },
                get = function() return db.profile.display.textLayout end,
                set = function(_, v)
                    db.profile.display.textLayout = v
                    CT.Display:Refresh(db)
                end,
            },
            reverseDirection = {
                order = 21.5, type = "toggle", name = "Reverse Row Direction",
                desc  = "Flip the entire row so it reads right-to-left.\nDefault: icon → count → name\nReversed: name → count → icon",
                get   = function() return db.profile.display.reverseDirection end,
                set   = function(_, v)
                    db.profile.display.reverseDirection = v
                    CT.Display:Refresh(db)
                end,
            },
            nameShorten = {
                order = 21.6, type = "select", name = "Shorten Names",
                desc  = "Abbreviate long currency names to save space.\n\n|cffffcc00Off:|r Trader's Tender\n|cffffcc00First 3 letters:|r Tra Ten\n|cffffcc00Initials:|r TT",
                values = {
                    [0] = "Off (full name)",
                    [1] = "First 3 letters  (Tra Ten)",
                    [2] = "Initials only  (TT)",
                },
                get = function() return db.profile.display.nameShorten or 0 end,
                set = function(_, v)
                    db.profile.display.nameShorten = v
                    CT.Display:Refresh(db)
                end,
            },
            abbreviate = {
                order = 22, type = "toggle", name = "Abbreviate Numbers",
                desc  = "Show 1.2K instead of 1200, etc.",
                get   = function() return db.profile.display.abbreviate end,
                set   = function(_, v)
                    db.profile.display.abbreviate = v
                    CT.Display:Refresh(db)
                end,
            },
            showMax = {
                order = 23, type = "toggle", name = "Show Maximum",
                desc  = "Append the cap amount (e.g. 1500/2000) for capped currencies.",
                get   = function() return db.profile.display.showMax end,
                set   = function(_, v)
                    db.profile.display.showMax = v
                    CT.Display:Refresh(db)
                end,
            },
            colorize = {
                order = 24, type = "toggle", name = "Color by Quality",
                desc  = "Color currency names and amounts using their item quality color.",
                get   = function() return db.profile.display.colorize end,
                set   = function(_, v)
                    db.profile.display.colorize = v
                    CT.Display:Refresh(db)
                end,
            },

            -- ── Sorting ───────────────────────────────────────────
            sortHeader = {
                order = 30, type = "header", name = "Sorting",
            },
            sortBy = {
                order = 31, type = "select", name = "Sort By",
                values = { [1] = "Name", [2] = "Amount", [3] = "ID" },
                get = function() return db.profile.display.sortBy end,
                set = function(_, v)
                    db.profile.display.sortBy = v
                    CT.Display:Refresh(db)
                end,
            },
            sortCategory = {
                order = 32, type = "toggle", name = "Group by Expansion",
                desc  = "Keep currencies grouped by their expansion when sorting by name.",
                get   = function() return db.profile.display.sortCategory end,
                set   = function(_, v)
                    db.profile.display.sortCategory = v
                    CT.Display:Refresh(db)
                end,
            },

            -- ── Position / Attach ─────────────────────────────────
            posHeader = {
                order = 40, type = "header", name = "Position & Attachment",
            },
            attachTo = {
                order = 41, type = "select", name = "Attach To",
                desc  = "Where to anchor the frame.\n\n|cffffcc00Bags:|r shows beside your bag, hides when bags close.\n|cffffcc00Character Sheet:|r shows to the right of the character panel, hides when it closes.\n|cffffcc00Always Visible:|r frame stays on screen at all times.\n\nDragging the frame saves your custom position within the current mode.",
                values = {
                    BAGS      = "Bags",
                    SCREEN    = "Always Visible",
                    CHARACTER = "Character Sheet",
                },
                get = function() return db.profile.display.attachTo end,
                set = function(_, v)
                    db.profile.display.attachTo = v
                    if v == "SCREEN" then
                        db.profile.display.point    = "CENTER"
                        db.profile.display.relPoint = "CENTER"
                        db.profile.display.x        = 0
                        db.profile.display.y        = 0
                    elseif v == "CHARACTER" then
                        db.profile.display.point    = "TOPLEFT"
                        db.profile.display.relPoint = "TOPRIGHT"
                        db.profile.display.x        = 4
                        db.profile.display.y        = 0
                    else -- BAGS
                        db.profile.display.point    = "TOPRIGHT"
                        db.profile.display.relPoint = "TOPLEFT"
                        db.profile.display.x        = -4
                        db.profile.display.y        = 0
                    end
                    CT.Display:UpdateVisibility(db)
                    CT.Display:SyncButtons(db)
                end,
            },
            resetPos = {
                order = 42, type = "execute", name = "Reset to Default Position",
                desc  = "Snap back to the default anchor for the current Attach To mode.",
                func  = function()
                    local v = db.profile.display.attachTo
                    if v == "CHARACTER" then
                        db.profile.display.point    = "TOPLEFT"
                        db.profile.display.relPoint = "TOPRIGHT"
                        db.profile.display.x        = 4
                        db.profile.display.y        = 0
                    elseif v == "BAGS" then
                        db.profile.display.point    = "TOPRIGHT"
                        db.profile.display.relPoint = "TOPLEFT"
                        db.profile.display.x        = -4
                        db.profile.display.y        = 0
                    else
                        db.profile.display.point    = "CENTER"
                        db.profile.display.relPoint = "CENTER"
                        db.profile.display.x        = 0
                        db.profile.display.y        = 0
                    end
                    CT.Display:UpdateVisibility(db)
                end,
            },
            locked = {
                order = 43, type = "toggle", name = "Lock Position",
                desc  = "Prevent the frame from being dragged. Use |cff00ff00/lct lock|r and |cff00ff00/lct unlock|r as quick toggles.",
                get   = function() return db.profile.display.locked end,
                set   = function(_, v)
                    db.profile.display.locked = v
                    CT.Display:SyncLock(db)
                end,
            },

            -- ── Currencies to Display ─────────────────────────────
            currencyHeader = {
                order = 60, type = "header", name = "Currencies to Display",
            },
            currencyDesc = {
                order = 61, type = "description",
                name  = "Toggle individual currencies on or off. Only currencies your character has discovered will appear. Reload options after visiting a new currency source.",
            },
            currencies = {
                order = 62, type = "group", name = "Currencies",
                inline = true,
                args   = {},  -- populated dynamically below
            },
        },
    }

    Config:PopulateCurrencyToggles(options.args.currencies.args, db)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("LarlenCurrencyTracker", options)
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfigDialog:AddToBlizOptions("LarlenCurrencyTracker", "Larlen Currency Tracker")
    AceConfigDialog:SetDefaultSize("LarlenCurrencyTracker", 820, 650)
end

-- ============================================================
-- Currency toggles grouped by expansion
-- ============================================================
function Config:PopulateCurrencyToggles(args, db)
    local expKeys = {}
    for k, _ in pairs(LarlenCurrencyTrackerExpansions) do
        expKeys[#expKeys + 1] = k
    end
    table.sort(expKeys, function(a, b)
        local la = LarlenCurrencyTrackerExpansions[a].letter
        local lb = LarlenCurrencyTrackerExpansions[b].letter
        local isMiscA = (a == "Misc" or a == "PvP")
        local isMiscB = (b == "Misc" or b == "PvP")
        if isMiscA and not isMiscB then return true  end
        if isMiscB and not isMiscA then return false end
        if isMiscA and isMiscB then return a == "Misc" end
        return la < lb
    end)

    local discovered = {}
    local numCurrencies = C_CurrencyInfo.GetCurrencyListSize()
    for i = 1, numCurrencies do
        local entry = C_CurrencyInfo.GetCurrencyListInfo(i)
        if entry and not entry.isHeader and entry.currencyID then
            local info = C_CurrencyInfo.GetCurrencyInfo(entry.currencyID)
            if info and info.discovered then
                discovered[entry.currencyID] = info.name or ("Currency " .. entry.currencyID)
            end
        end
    end

    local order = 1

    for _, expKey in ipairs(expKeys) do
        local expData  = LarlenCurrencyTrackerExpansions[expKey]
        local expLabel = expData.label

        local expCurrencies = {}
        for id, data in pairs(LarlenCurrencyTrackerCurrencies) do
            if data.expansion == expKey and discovered[id] then
                expCurrencies[#expCurrencies + 1] = { id = id, name = discovered[id], found = true }
            end
        end
        table.sort(expCurrencies, function(a, b) return a.name < b.name end)

        local dbOnly = {}
        for id, data in pairs(LarlenCurrencyTrackerCurrencies) do
            if data.expansion == expKey and not discovered[id] then
                dbOnly[#dbOnly + 1] = { id = id, name = data.name, found = false }
            end
        end
        table.sort(dbOnly, function(a, b) return a.name < b.name end)

        local allExp = {}
        for _, v in ipairs(expCurrencies) do allExp[#allExp + 1] = v end
        for _, v in ipairs(dbOnly)        do allExp[#allExp + 1] = v end

        if #allExp > 0 then
            args["header_exp_" .. expKey] = {
                order = order, type = "header", name = expLabel,
            }
            order = order + 1

            for _, item in ipairs(allExp) do
                local key  = tostring(item.id)
                local desc = item.found
                    and ("Show or hide " .. item.name .. ".")
                    or  (item.name .. " — not yet discovered on this character.")
                args["currency_" .. key] = {
                    order = order, type = "toggle",
                    name  = item.found and item.name or ("|cff888888" .. item.name .. "|r"),
                    desc  = desc,
                    get   = function() return db.profile.currencies[key] == true end,
                    set   = function(_, v)
                        db.profile.currencies[key] = v
                        CT.Display:Refresh(db)
                    end,
                }
                order = order + 1
            end
        end
    end

    local unknownIDs = {}
    for id, name in pairs(discovered) do
        if not LarlenCurrencyTrackerCurrencies[id] then
            unknownIDs[#unknownIDs + 1] = { id = id, name = name }
        end
    end
    table.sort(unknownIDs, function(a, b) return a.name < b.name end)

    if #unknownIDs > 0 then
        args["header_other"] = {
            order = order, type = "header", name = "Uncategorised",
        }
        order = order + 1
        for _, item in ipairs(unknownIDs) do
            local key = tostring(item.id)
            args["currency_" .. key] = {
                order = order, type = "toggle",
                name  = item.name,
                desc  = "Show or hide " .. item.name .. " (ID " .. key .. ").",
                get   = function() return db.profile.currencies[key] == true end,
                set   = function(_, v)
                    db.profile.currencies[key] = v
                    CT.Display:Refresh(db)
                end,
            }
            order = order + 1
        end
    end
end
