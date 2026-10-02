local nametagconfig = NametagConfig
local perkColors = {
    indica = {184, 140, 255},
    sativa = {255, 230, 109},
    hybrid = {0, 255, 157}
}

local screenW, screenH = guiGetScreenSize()

local function renderNameTags()
    -- Hide default MTA tags

    local players = getElementsByType("player")
    local lx, ly, lz = getElementPosition(localPlayer)

    for _, player in ipairs(players) do
        setPlayerNametagShowing(player, false)
        -- REMOVED: player ~= localPlayer check so you can see yourself
        if isElementStreamedIn(player) or player == localPlayer then
            local x, y, z = getElementPosition(player)
            local dist = getDistanceBetweenPoints3D(lx, ly, lz, x, y, z)

            if dist < nametagconfig.maxDistance then
                local sx, sy = getScreenFromWorldPosition(x, y, z + 1)

                if sx and sy then
                    local name = getPlayerName(player)
                    local health = getElementHealth(player) or 100

                    local halfWidth = nametagconfig.width / 2
                    local barWidth = nametagconfig.width * (health / 100)

                    -- Name
                    dxDrawText(name, sx - 50, sy - 20, sx + 50, sy, tocolor(unpack(nametagconfig.colors.name)), 1,
                        nametagconfig.font, "center", "bottom", false, false, false, true -- The 4th boolean here enables hex color codes!
                    )

                    if isPedDead(player) or health <= 0 then
                        local nameWidth = dxGetTextWidth(name, 1, nametagconfig.font, true)
                        local iconX = sx + (nameWidth / 2) + nametagconfig.brokenSkullGap
                        local iconY = sy - 17

                        dxDrawImage(iconX, iconY, nametagconfig.brokenSkullSize, nametagconfig.brokenSkullSize,
                            nametagconfig.brokenSkullIcon)
                    end

                    -- Background Bar
                    dxDrawRectangle(sx - halfWidth, sy, nametagconfig.width, 6, tocolor(0, 0, 0, 150))

                    -- Health Bar
                    local fullColor = perkColors[getElementData(player, "weed.perk")]
                        or nametagconfig.colors.healthFull
                    local lowColor = nametagconfig.colors.healthLow
                    local healthFraction = math.max(0, math.min(health / 100, 1))
                    dxDrawRectangle(sx - halfWidth, sy, barWidth, 6,
                        tocolor(
                            lowColor[1] + (fullColor[1] - lowColor[1]) * healthFraction,
                            lowColor[2] + (fullColor[2] - lowColor[2]) * healthFraction,
                            lowColor[3] + (fullColor[3] - lowColor[3]) * healthFraction,
                            200))
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, renderNameTags)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, player in ipairs(getElementsByType("player")) do
        setPlayerNametagShowing(player, true)
    end
end)
