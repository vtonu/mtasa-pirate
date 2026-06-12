-- materialIds.lua
-- San Andreas / MTA:SA Material ID Reference Table
-- Generated documentation-style mapping of surfinfo.dat material IDs

--[[

================================================================================
INTRODUCTION
================================================================================
These material IDs represent surface types in GTA: San Andreas.
They are used for collision effects such as footstep sounds, bullet impacts,
vehicle friction, and environmental interactions.

================================================================================
USAGE EXAMPLE
================================================================================
local materialName = materialIds[0]  -- "Default"

]]

local materialIds = {

    -- =========================================================================
    -- DEFAULT
    -- =========================================================================
    [0] = "Default",
    [1] = "Tarmac",
    [2] = "Tarmac (damaged)",
    [3] = "Tarmac (really damaged)",

    -- =========================================================================
    -- CONCRETE
    -- =========================================================================
    [4] = "Pavement",
    [5] = "Pavement (damaged)",
    [7] = "Concrete (damaged)",
    [8] = "Painted Ground",
    [34] = "Concrete (beach)",
    [89] = "Concrete",
    [127] = "Poolside",
    [135] = "Docklands",
    [136] = "Industrial",
    [137] = "Industrial Jetty",
    [138] = "Concrete (litter)",
    [139] = "Alley Rubbish",
    [144] = "Airport Ground",
    [165] = "Floor (concrete)",

    -- =========================================================================
    -- GRAVEL
    -- =========================================================================
    [6] = "Gravel",
    [85] = "Roadside",
    [101] = "Rubble",
    [134] = "Building Site",
    [140] = "Junkyard Piles",

    -- =========================================================================
    -- GRASS
    -- =========================================================================
    [9] = "Grass (short lush)",
    [10] = "Grass (medium lush)",
    [11] = "Grass (long lush)",
    [12] = "Grass (short dry)",
    [13] = "Grass (medium dry)",
    [14] = "Grass (long dry)",
    [15] = "Golf Grass (rough)",
    [16] = "Golf Grass (smooth)",
    [17] = "Steep Slidy Grass",
    [20] = "Meadow",
    [80] = "Grass (short)",
    [81] = "Grass (meadow)",
    [82] = "Grass (dry)",
    [115] = "Grass (wee flowers)",
    [116] = "Grass (dry tall)",
    [117] = "Grass (lush tall)",
    [118] = "Grass (green mix)",
    [119] = "Grass (brown mix)",
    [120] = "Grass (low)",
    [121] = "Grass (rocky)",
    [122] = "Grass (small trees)",
    [125] = "Grass (weeds)",
    [146] = "Grass (light)",
    [147] = "Grass (lighter)",
    [148] = "Grass (lighter 2)",
    [149] = "Grass (mid 1)",
    [150] = "Grass (mid 2)",
    [151] = "Grass (dark)",
    [152] = "Grass (dark 2)",
    [153] = "Grass (dirt mix)",
    [160] = "Park Grass",

    -- =========================================================================
    -- DIRT
    -- =========================================================================
    [19] = "Flower Bed",
    [21] = "Waste Ground",
    [22] = "Woodland Ground",
    [24] = "Mud (wet)",
    [25] = "Mud (dry)",
    [26] = "Dirt",
    [27] = "Dirt Track",
    [40] = "Corn Field",
    [83] = "Woodland",
    [84] = "Wood Dense",
    [87] = "Flowerbed",
    [88] = "Waste Ground (alt)",
    [100] = "Riverbed",
    [110] = "Marsh",
    [123] = "Dirt (rocky)",
    [124] = "Dirt (weeds)",
    [126] = "River Edge",
    [128] = "Forest (stumps)",
    [129] = "Forest (sticks)",
    [130] = "Forest (leaves)",
    [132] = "Forest (dry)",
    [133] = "Sparse Flowers",
    [141] = "Junkyard Ground",
    [142] = "Dump",
    [145] = "Cornfield",
    [155] = "Riverbed (shallow)",
    [156] = "Riverbed (weeds)",

    -- =========================================================================
    -- SAND
    -- =========================================================================
    [28] = "Sand (deep)",
    [29] = "Sand (medium)",
    [30] = "Sand (compact)",
    [31] = "Sand (arid)",
    [32] = "Sand (more)",
    [33] = "Sand (beach)",
    [74] = "Sand",
    [75] = "Sand (dense)",
    [76] = "Sand (arid duplicate)",
    [77] = "Sand (compact duplicate)",
    [78] = "Sand (rocky)",
    [79] = "Sand (beach duplicate)",
    [86] = "Roadside Desert",
    [96] = "Underwater (lush)",
    [97] = "Underwater (barren)",
    [98] = "Underwater (coral)",
    [99] = "Underwater (deep)",
    [131] = "Desert Rocks",
    [143] = "Cactus Dense",
    [157] = "Seaweed",

    -- =========================================================================
    -- GLASS
    -- =========================================================================
    [45] = "Glass",
    [46] = "Glass Windows (large)",
    [47] = "Glass Windows (small)",
    [175] = "Unbreakable Glass",

    -- =========================================================================
    -- WOOD
    -- =========================================================================
    [42] = "Wood (crates)",
    [43] = "Wood (solid)",
    [44] = "Wood (thin)",
    [70] = "Wood (bench)",
    [72] = "Floorboard",
    [73] = "Stairs (wood)",
    [172] = "Wood Picket Fence",
    [173] = "Wood Slatted Fence",
    [174] = "Wood Ranch Fence",

    -- =========================================================================
    -- METAL
    -- =========================================================================
    [50] = "Garage Door",
    [51] = "Thick Metal Plate",
    [52] = "Scaffold Pole",
    [53] = "Lamp Post",
    [54] = "Metal Gate",
    [55] = "Metal Chain Fence",
    [56] = "Girder",
    [57] = "Fire Hydrant",
    [58] = "Container",
    [59] = "News Vendor",
    [63] = "Car Metal",
    [64] = "Car Panel",
    [65] = "Car Moving Component",
    [162] = "Stairs (metal)",
    [164] = "Floor (metal)",
    [167] = "Thin Metal Sheet",
    [168] = "Metal Barrel",
    [171] = "Metal Dumpster",

    -- =========================================================================
    -- STONE
    -- =========================================================================
    [18] = "Steep Cliff",
    [35] = "Rock (dry)",
    [36] = "Rock (wet)",
    [37] = "Rock (cliff)",
    [69] = "Transparent Stone",
    [109] = "Mountain",
    [154] = "Riverbed (stone)",
    [161] = "Stairs (stone)",

    -- =========================================================================
    -- VEGETATION
    -- =========================================================================
    [23] = "Vegetation",
    [41] = "Hedge",
    [111] = "Bushy",
    [112] = "Bushy (mix)",
    [113] = "Bushy (dry)",
    [114] = "Bushy (mid)",

    -- =========================================================================
    -- WATER
    -- =========================================================================
    [38] = "Water (riverbed)",
    [39] = "Water (shallow)",

    -- =========================================================================
    -- MISC
    -- =========================================================================
    [48] = "Empty1",
    [49] = "Empty2",
    [60] = "Wheelbase",
    [61] = "Cardboard Box",
    [62] = "Ped Surface",
    [66] = "Transparent Cloth",
    [67] = "Rubber",
    [68] = "Plastic",
    [71] = "Carpet",
    [90] = "Office Desk",
    [91] = "711 Shelf 1",
    [92] = "711 Shelf 2",
    [93] = "711 Shelf 3",
    [94] = "Restaurant Table",
    [95] = "Bar Table",
    [102] = "Bedroom Floor",
    [103] = "Kitchen Floor",
    [104] = "Livingroom Floor",
    [105] = "Corridor Floor",
    [106] = "711 Floor",
    [107] = "Fast Food Floor",
    [108] = "Skanky Floor",
    [158] = "Door",
    [159] = "Plastic Barrier",
    [163] = "Stairs (carpet)",
    [166] = "Bin Bag",
    [169] = "Plastic Cone",
    [170] = "Plastic Dumpster",
    [176] = "Hay Bale",
    [177] = "Gore",
    [178] = "Rail Track",
}

return materialIds