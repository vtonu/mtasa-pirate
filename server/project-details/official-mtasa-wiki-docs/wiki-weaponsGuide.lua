--================================--
-- WEAPON DATABASE
--================================--

local Weapons = {
    -- HAND
    [0]  = {name = "Fist", slot = 0, model = 0},
    [1]  = {name = "Brassknuckle", slot = 0, model = 331},

    -- MELEE
    [2]  = {name = "Golfclub", slot = 1, model = 333},
    [3]  = {name = "Nightstick", slot = 1, model = 334},
    [4]  = {name = "Knife", slot = 1, model = 335},
    [5]  = {name = "Bat", slot = 1, model = 336},
    [6]  = {name = "Shovel", slot = 1, model = 337},
    [7]  = {name = "Poolstick", slot = 1, model = 338},
    [8]  = {name = "Katana", slot = 1, model = 339},
    [9]  = {name = "Chainsaw", slot = 1, model = 341},

    -- GIFTS
    [10] = {name = "Dildo", slot = 10, model = 321},
    [11] = {name = "Purple Dildo", slot = 10, model = 322},
    [12] = {name = "Vibrator", slot = 10, model = 323},
    [13] = {name = "Silver Vibrator", slot = 10, model = 324},
    [14] = {name = "Flowers", slot = 10, model = 325},
    [15] = {name = "Cane", slot = 10, model = 326},

    -- PROJECTILES
    [16] = {name = "Grenade", slot = 8, model = 342},
    [17] = {name = "Teargas", slot = 8, model = 343},
    [18] = {name = "Molotov", slot = 8, model = 344},

    -- HANDGUNS
    [22] = {name = "Colt 45", slot = 2, model = 346, clip = 17},
    [23] = {name = "Silenced", slot = 2, model = 347, clip = 17},
    [24] = {name = "Deagle", slot = 2, model = 348, clip = 7},

    -- SHOTGUNS
    [25] = {name = "Shotgun", slot = 3, model = 349, clip = 1},
    [26] = {name = "Sawed-off", slot = 3, model = 350, clip = 2},
    [27] = {name = "Combat Shotgun", slot = 3, model = 351, clip = 7},

    -- SUB MACHINE GUNS
    [28] = {name = "Uzi", slot = 4, model = 352, clip = 50},
    [29] = {name = "MP5", slot = 4, model = 353, clip = 30},
    [32] = {name = "Tec-9", slot = 4, model = 372, clip = 50},

    -- ASSAULT RIFLES
    [30] = {name = "AK-47", slot = 5, model = 355, clip = 30},
    [31] = {name = "M4", slot = 5, model = 356, clip = 50},

    -- RIFLES
    [33] = {name = "Rifle", slot = 6, model = 357, clip = 1},
    [34] = {name = "Sniper", slot = 6, model = 358, clip = 1},

    -- HEAVY WEAPONS
    [35] = {name = "Rocket Launcher", slot = 7, model = 359, clip = 1},
    [36] = {name = "Rocket Launcher HS", slot = 7, model = 360, clip = 1},
    [37] = {name = "Flamethrower", slot = 7, model = 361, clip = 50},
    [38] = {name = "Minigun", slot = 7, model = 362, clip = 500},

    -- SPECIAL
    [39] = {name = "Satchel", slot = 8, model = 363},
    [40] = {name = "Bomb", slot = 12, model = 364},

    [41] = {name = "Spraycan", slot = 9, model = 365, clip = 500},
    [42] = {name = "Fire Extinguisher", slot = 9, model = 366, clip = 500},
    [43] = {name = "Camera", slot = 9, model = 367, clip = 36},

    [44] = {name = "Nightvision", slot = 11, model = 368},
    [45] = {name = "Infrared", slot = 11, model = 369},
    [46] = {name = "Parachute", slot = 11, model = 371}
}

--================================--
-- WEAPONS BY SLOT
--================================--

local WeaponsBySlot = {
    [0]  = {0, 1},
    [1]  = {2, 3, 4, 5, 6, 7, 8, 9},
    [2]  = {22, 23, 24},
    [3]  = {25, 26, 27},
    [4]  = {28, 29, 32},
    [5]  = {30, 31},
    [6]  = {33, 34},
    [7]  = {35, 36, 37, 38},
    [8]  = {16, 17, 18, 39},
    [9]  = {41, 42, 43},
    [10] = {10, 11, 12, 13, 14, 15},
    [11] = {44, 45, 46},
    [12] = {40}
}

--================================--
-- COMMON FUNCTIONS
--================================--

local WeaponFunctions = {
    "giveWeapon",
    "takeWeapon",
    "takeAllWeapons",
    "getWeaponProperty",
    "getOriginalWeaponProperty",
    "getSlotFromWeapon",
    "getWeaponIDFromName",
    "getWeaponNameFromID",
    "setWeaponAmmo",
    "setWeaponProperty"
}

return {
    Weapons = Weapons,
    WeaponsBySlot = WeaponsBySlot,
    Functions = WeaponFunctions
}