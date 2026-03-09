-- CurrencyDB.lua
-- Static database of known currencies, mapped to their expansion.
-- This allows categorisation and filtering even before a character has discovered them.
-- Expansions are sorted newest → oldest via the sortLetter field.
--
-- To add new currencies: add an entry to LarlenCurrencyTrackerDB_Currencies below.
-- Format: [currencyID] = { expansion = "TAG", name = "Readable Name" }
-- Expansion tags and their display order:
--   Mid  = Midnight          (A)
--   TWW  = The War Within    (B)
--   DF   = Dragonflight      (C)
--   SL   = Shadowlands       (D)
--   BFA  = Battle for Azeroth(E)
--   Leg  = Legion            (F)
--   WoD  = Warlords of Draenor(G)
--   MoP  = Mists of Pandaria  (H)
--   Cata = Cataclysm          (I)
--   WotLK= Wrath of the Lich King(J)
--   BC   = The Burning Crusade(K)
--   Misc = Miscellaneous      (L)
--   PvP  = PvP                (M)

LarlenCurrencyTrackerExpansions = {
    Mid   = { letter = "A", label = "Midnight" },
    TWW   = { letter = "B", label = "The War Within" },
    DF    = { letter = "C", label = "Dragonflight" },
    SL    = { letter = "D", label = "Shadowlands" },
    BFA   = { letter = "E", label = "Battle for Azeroth" },
    Leg   = { letter = "F", label = "Legion" },
    WoD   = { letter = "G", label = "Warlords of Draenor" },
    MoP   = { letter = "H", label = "Mists of Pandaria" },
    Cata  = { letter = "I", label = "Cataclysm" },
    WotLK = { letter = "J", label = "Wrath of the Lich King" },
    BC    = { letter = "K", label = "The Burning Crusade" },
    Misc  = { letter = "L", label = "Miscellaneous" },
    PvP   = { letter = "M", label = "PvP" },
}

LarlenCurrencyTrackerCurrencies = {

    -- ══════════════════════════════════════════════════════════
    -- MIDNIGHT
    -- ══════════════════════════════════════════════════════════
    [3376] = { expansion = "Mid", name = "Shard of Dundun" },
    [3377] = { expansion = "Mid", name = "Unalloyed Abundance" },
    [3385] = { expansion = "Mid", name = "Luminous Dust" },
    [3316] = { expansion = "Mid", name = "Voidlight Marl" },
    [3379] = { expansion = "Mid", name = "Brimming Arcana" },
    [3256] = { expansion = "Mid", name = "Artisan Alchemist's Moxie" },
    [3400] = { expansion = "Mid", name = "Uncontaminated Void Sample" },
    [3260] = { expansion = "Mid", name = "Artisan Herbalist's Moxie" },
    [3264] = { expansion = "Mid", name = "Artisan Miner's Moxie" },
    [3392] = { expansion = "Mid", name = "Remnant of Anguish" },
    [3319] = { expansion = "Mid", name = "Twilight's Blade Insignia" },
    [3265] = { expansion = "Mid", name = "Artisan Skinner's Moxie" },
    [3258] = { expansion = "Mid", name = "Artisan Enchanter's Moxie" },
    [3266] = { expansion = "Mid", name = "Artisan Tailor's Moxie" },
    [3257] = { expansion = "Mid", name = "Artisan Blacksmith's Moxie" },
    [3263] = { expansion = "Mid", name = "Artisan Leatherworker's Moxie" },
    [3262] = { expansion = "Mid", name = "Artisan Jewelcrafter's Moxie" },
    [3261] = { expansion = "Mid", name = "Artisan Scribe's Moxie" },
    [3259] = { expansion = "Mid", name = "Artisan Engineer's Moxie" },
    [3158] = { expansion = "Mid", name = "Midnight Mining Knowledge" },
    [3154] = { expansion = "Mid", name = "Midnight Herbalism Knowledge" },
    [3373] = { expansion = "Mid", name = "Angler Pearls" },
    [3352] = { expansion = "Mid", name = "Party Favor" },
    [3349] = { expansion = "Mid", name = "[PH] Evergreen Initiative Currency" },

    -- ══════════════════════════════════════════════════════════
    -- THE WAR WITHIN
    -- ══════════════════════════════════════════════════════════
    [2815] = { expansion = "TWW", name = "Resonance Crystals" },
    [3056] = { expansion = "TWW", name = "Kej" },
    [3226] = { expansion = "TWW", name = "Market Research" },
    [3090] = { expansion = "TWW", name = "Flame-Blessed Iron" },
    [3218] = { expansion = "TWW", name = "Empty Kaja'Cola Can" },
    [3303] = { expansion = "TWW", name = "Untethered Coin" },
    [3089] = { expansion = "TWW", name = "Residual Memories" },
    [3149] = { expansion = "TWW", name = "Displaced Corrupted Mementos" },
    [3055] = { expansion = "TWW", name = "Mereldar Derby Mark" },
    [3220] = { expansion = "TWW", name = "Vintage Kaja'Cola Can" },
    [3093] = { expansion = "TWW", name = "Nerub-ar Finery" },
    [3223] = { expansion = "TWW", name = "Titan Disc" },
    [2839] = { expansion = "TWW", name = "[DNT] Awakening Currency" },
    [3216] = { expansion = "TWW", name = "Bounty's Remnants" },

    -- ══════════════════════════════════════════════════════════
    -- DRAGONFLIGHT
    -- (common DF currencies — extend as needed)
    -- ══════════════════════════════════════════════════════════
    [2003] = { expansion = "DF",  name = "Dragon Isles Supplies" },
    [2245] = { expansion = "DF",  name = "Elemental Overflow" },
    [2307] = { expansion = "DF",  name = "Valdrakken Accord" },
    [2544] = { expansion = "DF",  name = "Flightstones" },
    [2657] = { expansion = "DF",  name = "Resonance Crystals (DF)" },
    [2678] = { expansion = "DF",  name = "Aspects' Token of Merit" },
    [2792] = { expansion = "DF",  name = "Spores" },
    [2032] = { expansion = "Misc", name = "Trader's Tender" },  -- Trading Post (cross-expansion)
    [2033] = { expansion = "DF",  name = "Blacksmithing Knowledge (DF)" },
    [2034] = { expansion = "DF",  name = "Leatherworking Knowledge (DF)" },
    [2035] = { expansion = "DF",  name = "Tailoring Knowledge (DF)" },
    [2036] = { expansion = "DF",  name = "Jewelcrafting Knowledge (DF)" },
    [2037] = { expansion = "DF",  name = "Inscription Knowledge (DF)" },
    [2038] = { expansion = "DF",  name = "Alchemy Knowledge (DF)" },
    [2039] = { expansion = "DF",  name = "Engineering Knowledge (DF)" },
    [2040] = { expansion = "DF",  name = "Enchanting Knowledge (DF)" },
    [2041] = { expansion = "DF",  name = "Herbalism Knowledge (DF)" },
    [2042] = { expansion = "DF",  name = "Artisan's Acuity" },
    [2043] = { expansion = "DF",  name = "Mining Knowledge (DF)" },
    [2044] = { expansion = "DF",  name = "Skinning Knowledge (DF)" },
    [2048] = { expansion = "DF",  name = "Fishing Knowledge (DF)" },
    [2122] = { expansion = "DF",  name = "Whelpling's Shadowflame Crest Fragment" },
    [2123] = { expansion = "DF",  name = "Drake's Shadowflame Crest Fragment" },
    [2124] = { expansion = "DF",  name = "Wyrm's Shadowflame Crest Fragment" },
    [2125] = { expansion = "DF",  name = "Aspect's Shadowflame Crest Fragment" },

    -- ══════════════════════════════════════════════════════════
    -- SHADOWLANDS
    -- ══════════════════════════════════════════════════════════
    [1813] = { expansion = "SL",  name = "Reservoir Anima" },
    [1816] = { expansion = "SL",  name = "Stygia" },
    [1822] = { expansion = "SL",  name = "Renown" },
    [1767] = { expansion = "SL",  name = "Soul Cinders" },
    [1906] = { expansion = "SL",  name = "Soul Ash" },
    [1979] = { expansion = "SL",  name = "Cosmic Flux" },
    [1828] = { expansion = "SL",  name = "Tower Knowledge" },
    [1884] = { expansion = "SL",  name = "Attendant's Token of Merit" },

    -- ══════════════════════════════════════════════════════════
    -- BATTLE FOR AZEROTH
    -- ══════════════════════════════════════════════════════════
    [1553] = { expansion = "BFA", name = "War Resources" },
    [1560] = { expansion = "BFA", name = "Azerite" },
    [1580] = { expansion = "BFA", name = "Honorbound Service Medal" },
    [1586] = { expansion = "BFA", name = "7th Legion Service Medal" },
    [1697] = { expansion = "BFA", name = "Prismatic Manapearl" },
    [1718] = { expansion = "BFA", name = "Corrupted Mementos" },
    [1755] = { expansion = "BFA", name = "Echoes of Ny'alotha" },
    [1594] = { expansion = "BFA", name = "Seafarer's Dubloon" },
    [1533] = { expansion = "BFA", name = "Coalescing Visions" },

    -- ══════════════════════════════════════════════════════════
    -- LEGION
    -- ══════════════════════════════════════════════════════════
    [1171] = { expansion = "Leg", name = "Nethershard" },
    [1226] = { expansion = "Leg", name = "Veiled Argunite" },
    [1273] = { expansion = "Leg", name = "Wakening Essence" },
    [1154] = { expansion = "Leg", name = "Curious Coin" },
    [1220] = { expansion = "Leg", name = "Echoes of Battle" },
    [1342] = { expansion = "Leg", name = "Legionfall War Supplies" },

    -- ══════════════════════════════════════════════════════════
    -- WARLORDS OF DRAENOR
    -- ══════════════════════════════════════════════════════════
    [823]  = { expansion = "WoD", name = "Apexis Crystal" },
    [824]  = { expansion = "WoD", name = "Garrison Resources" },
    [980]  = { expansion = "WoD", name = "Timewarped Badge (WoD)" },
    [1101] = { expansion = "WoD", name = "Seal of Broken Fate" },

    -- ══════════════════════════════════════════════════════════
    -- MISTS OF PANDARIA
    -- ══════════════════════════════════════════════════════════
    [697]  = { expansion = "MoP", name = "Valor" },
    [752]  = { expansion = "MoP", name = "Lesser Charm of Good Fortune" },
    [776]  = { expansion = "MoP", name = "Timeless Coin" },
    [777]  = { expansion = "MoP", name = "Elder Charm of Good Fortune" },
    [778]  = { expansion = "MoP", name = "Mogu Rune of Fate" },

    -- ══════════════════════════════════════════════════════════
    -- CATACLYSM
    -- ══════════════════════════════════════════════════════════
    [614]  = { expansion = "Cata", name = "Justice Points" },
    [615]  = { expansion = "Cata", name = "Conquest Points" },

    -- ══════════════════════════════════════════════════════════
    -- WRATH OF THE LICH KING
    -- ══════════════════════════════════════════════════════════
    [301]  = { expansion = "WotLK", name = "Emblem of Heroism" },
    [302]  = { expansion = "WotLK", name = "Emblem of Valor" },
    [341]  = { expansion = "WotLK", name = "Emblem of Conquest" },
    [361]  = { expansion = "WotLK", name = "Emblem of Triumph" },
    [400]  = { expansion = "WotLK", name = "Emblem of Frost" },
    [416]  = { expansion = "WotLK", name = "Timewarped Badge (WotLK)" },

    -- ══════════════════════════════════════════════════════════
    -- THE BURNING CRUSADE
    -- ══════════════════════════════════════════════════════════
    [101]  = { expansion = "BC",  name = "Badge of Justice" },

    -- ══════════════════════════════════════════════════════════
    -- PvP
    -- ══════════════════════════════════════════════════════════
    [1792] = { expansion = "PvP", name = "Honor" },
    [1602] = { expansion = "PvP", name = "Conquest" },
    [1585] = { expansion = "PvP", name = "War Games" },

    -- ══════════════════════════════════════════════════════════
    -- MISCELLANEOUS / TIMEWALKING / EVENT
    -- ══════════════════════════════════════════════════════════
    [1166] = { expansion = "Misc", name = "Timewarped Badge" },
    [515]  = { expansion = "Misc", name = "Darkmoon Prize Ticket" },
    [241]  = { expansion = "Misc", name = "Champion's Seal" },

}

-- ──────────────────────────────────────────────────────────────
-- Helper: look up expansion data for a currency ID.
-- Returns the expansion table entry, or a Misc fallback.
-- ──────────────────────────────────────────────────────────────
function LarlenCurrencyTrackerGetExpansion(currencyID)
    local entry = LarlenCurrencyTrackerCurrencies[currencyID]
    if entry then
        local expKey = entry.expansion
        return LarlenCurrencyTrackerExpansions[expKey] or LarlenCurrencyTrackerExpansions["Misc"]
    end
    return LarlenCurrencyTrackerExpansions["Misc"]
end
