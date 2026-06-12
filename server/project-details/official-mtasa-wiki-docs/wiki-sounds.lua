-- sounds.lua
-- GTA San Andreas / MTA:SA Sound ID Reference
-- Used with playSoundFrontEnd and other audio functions

--[[
INTRODUCTION
This file lists all known sound IDs that can be used with playSoundFrontEnd.
It also provides reference to related audio functions for scripting.

Example usage:
    playSoundFrontEnd(0) -- Plays a selection sound
]]

local soundIDs = {
    -- Selection sounds
    [0] = "Selection sound 0",
    [1] = "Selection sound 1",
    [2] = "Selection sound 2",
    [3] = "Selection sound 3",
    [4] = "Selection sound 4",
    [5] = "Selection sound 5",
    [6] = "Selection sound 6",
    [7] = "Selection sound 7",
    [8] = "Selection sound 8",
    [9] = "Selection sound 9",
    [10] = "Selection sound 10",
    [11] = "Selection sound 11",
    [12] = "Selection sound 12",
    [13] = "Selection sound 13",
    [14] = "Selection sound 14",
    [15] = "Selection sound 15",
    [16] = "Selection sound 16",
    [17] = "Selection sound 17",
    [18] = "Selection sound 18",
    [19] = "Selection sound 19",
    [20] = "Selection sound 20",

    -- Bullet sounds
    [27] = "Bullet sound 27",
    [28] = "Bullet sound 28",
    [29] = "Bullet sound 29",
    [30] = "Bullet sound 30",

    -- More selection sounds
    [32] = "Selection sound 32",
    [33] = "Selection sound 33",

    -- Radio static
    [34] = "Radio static",
    [35] = "Stop radio static",

    -- Tick sounds
    [37] = "Tick",
    [38] = "Tick",

    -- Selection sound
    [40] = "Selection sound 40",

    -- Tick (no ammo)
    [41] = "Tick (no ammo)",
    [42] = "Tick (no ammo)",

    -- Race countdown
    [43] = "Race countdown 1",
    [44] = "Race countdown 2",
    [45] = "Race countdown 3",

    -- Repair sound
    [46] = "Repair",

    -- White noise static
    [47] = "White noise static",
    [48] = "Stop white noise static",
    [49] = "Static short",

    -- Countdown / selection
    [101] = "Countdown/selection"
}

-- Audio utility functions (provided by MTA)
local audioFunctions = {
    "getRadioChannel",
    "getRadioChannelName",
    "getSFXStatus",
    "getSoundBPM",
    "getSoundBufferLength",
    "getSoundEffectParameters",
    "getSoundEffects",
    "getSoundFFTData",
    "getSoundLength",
    "getSoundLevelData",
    "getSoundMaxDistance",
    "getSoundMetaTags",
    "getSoundMinDistance",
    "getSoundPan",
    "getSoundPosition",
    "getSoundProperties",
    "getSoundSpeed",
    "getSoundVolume",
    "getSoundWaveData",
    "isSoundLooped",
    "isSoundPanningEnabled",
    "isSoundPaused",
    "playSFX3D",
    "playSFX",
    "playSound3D",
    "playSound",
    "setRadioChannel",
    "setSoundEffectEnabled",
    "setSoundEffectParameter",
    "setSoundLooped",
    "setSoundMaxDistance",
    "setSoundMinDistance",
    "setSoundPan",
    "setSoundPanningEnabled",
    "setSoundPaused",
    "setSoundPosition",
    "setSoundProperties",
    "setSoundSpeed",
    "setSoundVolume",
    "stopSound",
    "playSoundFrontEnd"
}

return {
    sounds = soundIDs,
    audioFunctions = audioFunctions
}