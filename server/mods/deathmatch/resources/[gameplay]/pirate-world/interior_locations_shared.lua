-- NEW LV DOORS; EACH ENTRANCE HAS ITS OWN ROOM
local casino = {interior = 12, x = 1133.25, y = -15.26, z = 1000.68,
    spawnX = 1133.25, spawnY = -12.76, rotation = 0}
local dragons = {interior = 10, x = 2018.95, y = 1017.09, z = 996.875,
    spawnX = 2015.95, spawnY = 1017.09, rotation = 90}
local dispensary = {interior = 4, x = -27.31, y = -31.38, z = 1003.55,
    spawnX = -27.31, spawnY = -28.38, rotation = 0}
local stripClub = {interior = 2, x = 1204.81, y = -12.79, z = 1001.09,
    spawnX = 1204.81, spawnY = -9.79, rotation = 0}

local doors = {
    {"dispensaryNorthLV", 1854.38477, 2233.88232, 11.12500, dispensary, false},
    {"fourDragonsFront", 2020.15735, 1007.77478, 10.82031, dragons, 44},
    {"casinoSouthStrip", 2015.21716, 1106.41577, 10.82031, casino, 44},
    {"casinoVisage", 2017.86194, 1912.98230, 12.32498, casino, 44},
    {"casinoClownsPocket", 2225.91602, 1838.70032, 10.82031, casino, 44},
    {"casinoNorthStrip", 2163.36865, 2060.56006, 10.82031, casino, 44},
    {"casinoNorthStripUpper", 2169.40942, 2163.23804, 10.82031, casino, 44},
    {"casinoOldStripSouth", 2219.68530, 2123.58936, 10.82031, casino, 44},
    {"casinoOldStripEast", 2329.91235, 2114.49536, 10.82812, casino, 44},
    {"casinoOldStripNorth", 2374.24170, 2168.64258, 10.82431, casino, 44},
    {"stripClubOldStrip", 2506.74634, 2120.67651, 10.83990, stripClub, 21}
}

additionalInteriorRooms = {}
for index, door in ipairs(doors) do
    local id, template = door[1], door[5]
    local room = {}
    for key, value in pairs(template) do room[key] = value end
    room.id = id
    room.entrances = {id .. "Entrance"}
    room.exitID = id .. "Exit"
    room.createEntrance = true
    room.entranceInterior = 0
    room.entranceDimension = 0
    room.entranceX, room.entranceY, room.entranceZ = door[2], door[3], door[4]
    room.dimension = 12110 + index
    if door[6] then
        room.blip = room.entrances[1]
        room.blipIcon = door[6]
    end
    additionalInteriorRooms[#additionalInteriorRooms + 1] = room
end
