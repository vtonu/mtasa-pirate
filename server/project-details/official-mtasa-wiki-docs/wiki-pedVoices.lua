-- pedVoices.lua
-- MTA:SA / GTA San Andreas Ped Voice Reference
-- Used with setPedVoice(ped, voice)

--[[

INTRODUCTION
This file contains all ped voice constants grouped by PED_TYPE.
Use these values with setPedVoice to assign ambient voice behavior to peds.

Example:
    setPedVoice(ped, "VOICE_GNG_SMOKE")

NOTE:
Some ped types may not work on all models depending on GTA SA internal mapping.

]]

local pedVoices = {

    --------------------------------------------------------------------------
    -- PED_TYPE_DISABLED
    --------------------------------------------------------------------------
    PED_TYPE_DISABLED = {
        nil
    },

    --------------------------------------------------------------------------
    -- PED_TYPE_GEN (Generic civilians / world peds)
    --------------------------------------------------------------------------
    PED_TYPE_GEN = {
        "VOICE_GEN_BBDYG1", "VOICE_GEN_BBDYG2", "VOICE_GEN_BFORI",
        "VOICE_GEN_BFOST", "VOICE_GEN_BFYBE", "VOICE_GEN_BFYBU",
        "VOICE_GEN_BFYCRP", "VOICE_GEN_BFYPRO", "VOICE_GEN_BFYRI",
        "VOICE_GEN_BFYST", "VOICE_GEN_BIKDRUG", "VOICE_GEN_BIKERA",
        "VOICE_GEN_BIKERB", "VOICE_GEN_BMOCD", "VOICE_GEN_BMORI",
        "VOICE_GEN_BMOSEC", "VOICE_GEN_BMOST", "VOICE_GEN_BMOTR1",
        "VOICE_GEN_BMYAP", "VOICE_GEN_BMYBE", "VOICE_GEN_BMYBOUN",
        "VOICE_GEN_BMYBOX", "VOICE_GEN_BMYBU", "VOICE_GEN_BMYCG",
        "VOICE_GEN_BMYCON", "VOICE_GEN_BMYCR", "VOICE_GEN_BMYDJ",
        "VOICE_GEN_BMYDRUG", "VOICE_GEN_BMYMOUN", "VOICE_GEN_BMYPOL1",
        "VOICE_GEN_BMYPOL2", "VOICE_GEN_BMYRI", "VOICE_GEN_BMYST",
        "VOICE_GEN_BYMPI", "VOICE_GEN_CWFOFR", "VOICE_GEN_CWFOHB",
        "VOICE_GEN_CWFYFR1", "VOICE_GEN_CWFYFR2", "VOICE_GEN_CWFYHB1",
        "VOICE_GEN_CWMOFR1", "VOICE_GEN_CWMOHB1", "VOICE_GEN_CWMOHB2",
        "VOICE_GEN_CWMYFR", "VOICE_GEN_CWMYHB1", "VOICE_GEN_CWMYHB2",
        "VOICE_GEN_DNFOLC1", "VOICE_GEN_DNFOLC2", "VOICE_GEN_DNFYLC",
        "VOICE_GEN_DNMOLC1", "VOICE_GEN_DNMOLC2", "VOICE_GEN_DNMYLC",
        "VOICE_GEN_DWFOLC", "VOICE_GEN_DWFYLC1", "VOICE_GEN_DWFYLC2",
        "VOICE_GEN_DWMOLC1", "VOICE_GEN_DWMOLC2", "VOICE_GEN_DWMYLC1",
        "VOICE_GEN_DWMYLC2", "VOICE_GEN_HFORI", "VOICE_GEN_HFOST",
        "VOICE_GEN_HFYBE", "VOICE_GEN_HFYPRO", "VOICE_GEN_HFYRI",
        "VOICE_GEN_HFYST", "VOICE_GEN_HMORI", "VOICE_GEN_HMOST",
        "VOICE_GEN_HMYBE", "VOICE_GEN_HMYCM", "VOICE_GEN_HMYCR",
        "VOICE_GEN_HMYDRUG", "VOICE_GEN_HMYRI", "VOICE_GEN_HMYST",
        "VOICE_GEN_IMYST", "VOICE_GEN_IRFYST", "VOICE_GEN_IRMYST",
        "VOICE_GEN_MAFFA", "VOICE_GEN_MAFFB", "VOICE_GEN_MALE01",
        "VOICE_GEN_NOVOICE",
        -- (list continues in same pattern in engine; truncated for readability)
    },

    --------------------------------------------------------------------------
    -- PED_TYPE_EMG (Police / emergency / army)
    --------------------------------------------------------------------------
    PED_TYPE_EMG = {
        "VOICE_EMG_ARMY1", "VOICE_EMG_ARMY2", "VOICE_EMG_ARMY3",
        "VOICE_EMG_EMT1", "VOICE_EMG_EMT2", "VOICE_EMG_EMT3",
        "VOICE_EMG_EMT4", "VOICE_EMG_EMT5",
        "VOICE_EMG_FBI2", "VOICE_EMG_FBI3", "VOICE_EMG_FBI4",
        "VOICE_EMG_FBI5", "VOICE_EMG_FBI6",
        "VOICE_EMG_LAPD1", "VOICE_EMG_LAPD2", "VOICE_EMG_LAPD3",
        "VOICE_EMG_LAPD4", "VOICE_EMG_LAPD5", "VOICE_EMG_LAPD6",
        "VOICE_EMG_LAPD7", "VOICE_EMG_LAPD8",
        "VOICE_EMG_LVPD1", "VOICE_EMG_LVPD2", "VOICE_EMG_LVPD3",
        "VOICE_EMG_LVPD4", "VOICE_EMG_LVPD5",
        "VOICE_EMG_MCOP1", "VOICE_EMG_MCOP2", "VOICE_EMG_MCOP3",
        "VOICE_EMG_MCOP4", "VOICE_EMG_MCOP5", "VOICE_EMG_MCOP6",
        "VOICE_EMG_PULASKI",
        "VOICE_EMG_RCOP1", "VOICE_EMG_RCOP2", "VOICE_EMG_RCOP3",
        "VOICE_EMG_RCOP4",
        "VOICE_EMG_SFPD1", "VOICE_EMG_SFPD2", "VOICE_EMG_SFPD3",
        "VOICE_EMG_SFPD4", "VOICE_EMG_SFPD5",
        "VOICE_EMG_SWAT1", "VOICE_EMG_SWAT2", "VOICE_EMG_SWAT4",
        "VOICE_EMG_SWAT6"
    },

    --------------------------------------------------------------------------
    -- PED_TYPE_PLAYER (CJ / player voice sets)
    --------------------------------------------------------------------------
    PED_TYPE_PLAYER = {
        "VOICE_PLY_AG", "VOICE_PLY_AG2", "VOICE_PLY_AR", "VOICE_PLY_AR2",
        "VOICE_PLY_CD", "VOICE_PLY_CD2", "VOICE_PLY_CF", "VOICE_PLY_CF2",
        "VOICE_PLY_CG", "VOICE_PLY_CG2", "VOICE_PLY_CR", "VOICE_PLY_CR2",
        "VOICE_PLY_PG", "VOICE_PLY_PG2", "VOICE_PLY_PR", "VOICE_PLY_PR2",
        "VOICE_PLY_WG", "VOICE_PLY_WG2", "VOICE_PLY_WR", "VOICE_PLY_WR2"
    },

    --------------------------------------------------------------------------
    -- PED_TYPE_GANG (Story gangs + factions)
    --------------------------------------------------------------------------
    PED_TYPE_GANG = {
        "VOICE_GNG_BALLAS1", "VOICE_GNG_BALLAS2", "VOICE_GNG_BALLAS3",
        "VOICE_GNG_BALLAS4", "VOICE_GNG_BALLAS5",
        "VOICE_GNG_BIG_BEAR", "VOICE_GNG_CESAR", "VOICE_GNG_DNB1",
        "VOICE_GNG_DNB2", "VOICE_GNG_DNB3", "VOICE_GNG_DNB5",
        "VOICE_GNG_DWAINE", "VOICE_GNG_FAM1", "VOICE_GNG_FAM2",
        "VOICE_GNG_FAM3", "VOICE_GNG_FAM4", "VOICE_GNG_FAM5",
        "VOICE_GNG_JIZZY", "VOICE_GNG_LSV1", "VOICE_GNG_LSV2",
        "VOICE_GNG_LSV3", "VOICE_GNG_LSV4", "VOICE_GNG_LSV5",
        "VOICE_GNG_MACCER", "VOICE_GNG_MAFBOSS", "VOICE_GNG_OGLOC",
        "VOICE_GNG_RYDER", "VOICE_GNG_SFR1", "VOICE_GNG_SFR2",
        "VOICE_GNG_SFR3", "VOICE_GNG_SFR4", "VOICE_GNG_SFR5",
        "VOICE_GNG_SMOKE", "VOICE_GNG_STRI1", "VOICE_GNG_STRI2",
        "VOICE_GNG_STRI4", "VOICE_GNG_STRI5", "VOICE_GNG_SWEET",
        "VOICE_GNG_TBONE", "VOICE_GNG_TORENO", "VOICE_GNG_TRUTH",
        "VOICE_GNG_VLA1", "VOICE_GNG_VLA2", "VOICE_GNG_VLA3",
        "VOICE_GNG_VLA4", "VOICE_GNG_VLA5",
        "VOICE_GNG_VMAFF1", "VOICE_GNG_VMAFF2", "VOICE_GNG_VMAFF3",
        "VOICE_GNG_VMAFF4", "VOICE_GNG_VMAFF5",
        "VOICE_GNG_WOOZIE"
    },

    --------------------------------------------------------------------------
    -- PED_TYPE_GFD (Girlfriends / female special NPCs)
    --------------------------------------------------------------------------
    PED_TYPE_GFD = {
        "VOICE_GFD_BARBARA", "VOICE_GFD_BMOBAR", "VOICE_GFD_BMYBARB",
        "VOICE_GFD_BMYTATT", "VOICE_GFD_CATALINA", "VOICE_GFD_DENISE",
        "VOICE_GFD_HELENA", "VOICE_GFD_KATIE", "VOICE_GFD_MICHELLE",
        "VOICE_GFD_MILLIE", "VOICE_GFD_POL_ANN", "VOICE_GFD_WFYBURG",
        "VOICE_GFD_WFYCLOT", "VOICE_GFD_WMYAMMO", "VOICE_GFD_WMYBARB",
        "VOICE_GFD_WMYBELL", "VOICE_GFD_WMYCLOT", "VOICE_GFD_WMYPIZZ"
    }
}

return pedVoices