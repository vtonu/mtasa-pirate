--================================--
-- WEATHER IDS
--================================--

local WeatherInfo = {
    -- LOS SANTOS
    [0] = {
        name = "EXTRASUNNY_LA",
        description = "Clear Los Santos weather with blue skies and heat haze."
    },
    [1] = {
        name = "SUNNY_LA",
        description = "Standard sunny Los Santos weather."
    },
    [2] = {
        name = "EXTRASUNNY_SMOG_LA",
        description = "Extra sunny weather with light smog."
    },
    [3] = {
        name = "SUNNY_SMOG_LA",
        description = "Sunny weather with visible smog."
    },
    [4] = {
        name = "CLOUDY_LA",
        description = "Cloudy Los Santos weather."
    },

    -- SAN FIERRO
    [5] = {
        name = "SUNNY_SF",
        description = "Clear San Fierro weather."
    },
    [6] = {
        name = "EXTRASUNNY_SF",
        description = "Extra sunny San Fierro weather."
    },
    [7] = {
        name = "CLOUDY_SF",
        description = "Cloudy San Fierro weather."
    },
    [8] = {
        name = "RAINY_SF",
        description = "Thunderstorm with rain and lightning."
    },
    [9] = {
        name = "FOGGY_SF",
        description = "Dense fog and cloudy atmosphere."
    },

    -- LAS VENTURAS
    [10] = {
        name = "SUNNY_VEGAS",
        description = "Dry desert weather."
    },
    [11] = {
        name = "EXTRASUNNY_VEGAS",
        description = "Scorching hot weather with heat haze."
    },
    [12] = {
        name = "CLOUDY_VEGAS",
        description = "Cloudy Las Venturas weather."
    },

    -- COUNTRYSIDE
    [13] = {
        name = "EXTRASUNNY_COUNTRYSIDE",
        description = "Bright countryside weather."
    },
    [14] = {
        name = "SUNNY_COUNTRYSIDE",
        description = "Standard countryside weather."
    },
    [15] = {
        name = "CLOUDY_COUNTRYSIDE",
        description = "Cloudy countryside weather."
    },
    [16] = {
        name = "RAINY_COUNTRYSIDE",
        description = "Thunderstorm in the countryside."
    },

    -- DESERT
    [17] = {
        name = "EXTRASUNNY_DESERT",
        description = "Hot desert weather with heat haze."
    },
    [18] = {
        name = "SUNNY_DESERT",
        description = "Sunny desert weather with heat haze."
    },
    [19] = {
        name = "SANDSTORM_DESERT",
        description = "Dense sandstorm."
    },

    -- SPECIAL
    [20] = {
        name = "UNDERWATER",
        description = "Greenish underwater style weather."
    },
    [21] = {
        name = "EXTRACOLOURS_1",
        description = "Purple tinted sky and environment."
    },
    [22] = {
        name = "EXTRACOLOURS_2",
        description = "Black and white sky with flat lighting."
    },

    -- CUSTOM WEATHER RANGES
    [23] = {
        name = "CUSTOM_RANGE_23_26",
        description = "Pale orange weather."
    },
    [27] = {
        name = "CUSTOM_RANGE_27_29",
        description = "Fresh blue weather."
    },
    [30] = {
        name = "CUSTOM_RANGE_30_32",
        description = "Dark cloudy teal weather."
    },
    [33] = {
        name = "CUSTOM_33",
        description = "Dark cloudy brown weather."
    },
    [34] = {
        name = "CUSTOM_34",
        description = "Blue purple regular weather."
    },
    [35] = {
        name = "CUSTOM_35",
        description = "Dull brown weather."
    },
    [36] = {
        name = "CUSTOM_RANGE_36_38",
        description = "Bright foggy orange weather."
    },
    [39] = {
        name = "CUSTOM_39",
        description = "Extremely bright weather. Nights appear like daytime."
    },
    [40] = {
        name = "CUSTOM_RANGE_40_42",
        description = "Blue purple cloudy weather."
    },
    [43] = {
        name = "CUSTOM_43",
        description = "Toxic contaminated cloud weather."
    },
    [44] = {
        name = "CUSTOM_44",
        description = "Black and white sky similar to weather 22."
    },
    [45] = {
        name = "CUSTOM_RANGE_45_60",
        description = "Normal weather with evening graphical glitches."
    },
    [100] = {
        name = "CUSTOM_100",
        description = "Strange weather that causes objects to disappear."
    },
    [118] = {
        name = "CUSTOM_118",
        description = "Stormy weather with pink skies and crystal clear water."
    },
    [126] = {
        name = "CUSTOM_RANGE_126_150",
        description = "Bugged flashing red weather."
    },
    [151] = {
        name = "CUSTOM_RANGE_151_175",
        description = "Very long draw distance with pink, purple and turquoise clouds."
    }
}

return WeatherInfo