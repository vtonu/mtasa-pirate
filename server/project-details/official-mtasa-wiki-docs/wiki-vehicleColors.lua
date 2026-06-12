--[[
wiki-vehicleColors.lua
Documentation for vehicle colors and functions in the server.
Author: [Your Name]
Date: [Insert Date]
Description:
    This file contains all the information about vehicle colors 
    and related vehicle functions available in the server.
--]]

-- ============================================================================
-- Vehicle Colors
-- ============================================================================
-- These are the vehicle colors you can retrieve with getVehicleColor.
-- Colors are identified by numerical indices.
-- Usage: getVehicleColor(vehicle)

vehicleColors = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
    110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
    120, 121, 122, 123, 124, 125, 126
}

-- ============================================================================
-- Vehicle Functions
-- ============================================================================
-- List of vehicle-related functions available in the server.
-- Functions are grouped by category for easier reference.

vehicleFunctions = {
    -- Vehicle Modifications
    "addVehicleUpgrade",
    "removeVehicleUpgrade",
    "getVehicleCompatibleUpgrades",
    "getVehicleUpgrades",
    "getVehicleUpgradeOnSlot",
    "getVehicleUpgradeSlotName",
    
    -- Vehicle Creation & Destruction
    "createVehicle",
    "blowVehicle",
    
    -- Vehicle Attachments
    "attachTrailerToVehicle",
    "detachTrailerFromVehicle",
    
    -- Vehicle Repairs & Damage
    "fixVehicle",
    "isVehicleBlown",
    "setVehicleDamageProof",
    "isVehicleDamageProof",
    
    -- Vehicle Engine & Movement
    "setVehicleEngineState",
    "getVehicleEngineState",
    "setVehicleFuelTankExplodable",
    "isVehicleFuelTankExplodable",
    "getVehicleController",
    "getVehicleOccupant",
    "getVehicleOccupants",
    "getVehicleMaxPassengers",
    "isVehicleOnGround",
    
    -- Vehicle Appearance
    "getVehicleColor",
    "setVehicleColor",
    "getVehiclePaintjob",
    "setVehiclePaintjob",
    "getVehicleHeadLightColor",
    "setVehicleHeadLightColor",
    "getVehicleLightState",
    "setVehicleLightState",
    "getVehicleWheelStates",
    "setVehicleWheelStates",
    "getVehiclePanelState",
    "setVehiclePanelState",
    "getVehiclePlateText",
    "setVehiclePlateText",
    "getVehicleName",
    "getVehicleNameFromModel",
    "getVehicleModelFromName",
    "getVehicleVariant",
    "setVehicleVariant",
    
    -- Vehicle Sirens & Extras
    "addVehicleSirens",
    "removeVehicleSirens",
    "getVehicleSirens",
    "getVehicleSirenParams",
    "setVehicleSirens",
    "getVehicleSirensOn",
    "setVehicleSirensOn",
    "setVehicleTaxiLightOn",
    "getVehicleTaxiLightOn",
    "setVehicleNitroActivated",
    
    -- Vehicle Doors & Panels
    "getVehicleDoorState",
    "setVehicleDoorState",
    "getVehicleDoorOpenRatio",
    "setVehicleDoorOpenRatio",
    "setVehicleDoorsUndamageable",
    
    -- Vehicle Towing
    "getVehicleTowedByVehicle",
    "getVehicleTowingVehicle",
    
    -- Vehicle Turret & Landing Gear
    "getVehicleTurretPosition",
    "setVehicleTurretPosition",
    "getVehicleLandingGearDown",
    "setVehicleLandingGearDown",
    
    -- Train Functions
    "getTrainSpeed",
    "setTrainSpeed",
    "getTrainPosition",
    "setTrainPosition",
    "getTrainDirection",
    "setTrainDirection",
    "isTrainDerailable",
    "setTrainDerailable",
    "isTrainDerailed",
    "setTrainDerailed",
    
    -- Vehicle Handling
    "getOriginalHandling",
    "getVehicleHandling",
    "setVehicleHandling",
    "getVehicleType",
    "getVehicleOverrideLights",
    "setVehicleOverrideLights",
    "isVehicleLocked",
    "setVehicleLocked"
}

-- ============================================================================
-- Notes
-- ============================================================================
-- Added/Updated in Version 1.6.0 r22771:
-- spawnVehicleFlyingComponent
-- setVehicleHandling
-- setVehicleHeadLightColor
-- setVehicleLandingGearDown
-- setVehicleLightState
-- setVehicleLocked
-- setVehicleOverrideLights
-- setVehiclePaintjob
-- setVehiclePanelState
-- setVehiclePlateText
-- setVehicleSirens
-- setVehicleSirensOn
-- setVehicleTaxiLightOn
-- setVehicleTurretPosition
-- setVehicleVariant
-- setVehicleWheelStates