local nametagconfig = NametagConfig
local perkColors = {
    indica = {184, 140, 255},
    sativa = {255, 230, 109},
    hybrid = {127, 255, 212}
}

local screenW, screenH = guiGetScreenSize()
local passiveShield

-- PASSIVE SHIELD
addEventHandler("onClientResourceStart", resourceRoot, function()
    passiveShield = svgCreate(64, 64, [[
        <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
            <path d="M32 5 L54 14 L52 34 Q49 49 32 59 Q15 49 12 34 L10 14 Z"
                fill="#7FFFD4" stroke="#1C1C1C" stroke-width="5" stroke-linejoin="round"/>
            <path d="M32 12 L46 18 L45 33 Q43 43 32 51 Z" fill="#7FFFD4"/>
        </svg>
    ]])
end)

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
                    local name = getPlayerName(player):gsub("#%x%x%x%x%x%x", "")
                    local health = getElementHealth(player) or 100

                    local halfWidth = nametagconfig.width / 2
                    local barWidth = nametagconfig.width * (health / 100)

                    -- Name
                    dxDrawText(name, sx - 50, sy - 20, sx + 50, sy, tocolor(unpack(nametagconfig.colors.name)), 1,
                        nametagconfig.font, "center", "bottom", false, false, false, false
                    )

                    if getElementData(player, "freeroam.passive") == true and isElement(passiveShield) then
                        local nameWidth = dxGetTextWidth(name, 1, nametagconfig.font, false)
                        local shieldSize = dxGetFontHeight(1, nametagconfig.font)
                        dxDrawImage(sx - nameWidth / 2 - shieldSize - 4, sy - shieldSize,
                            shieldSize, shieldSize, passiveShield)
                    end

                    if isPedDead(player) or health <= 0 then
                        local nameWidth = dxGetTextWidth(name, 1, nametagconfig.font, false)
                        local iconX = sx + (nameWidth / 2) + nametagconfig.brokenSkullGap
                        local iconY = sy - 17

                        dxDrawImage(iconX, iconY, nametagconfig.brokenSkullSize, nametagconfig.brokenSkullSize,
                            nametagconfig.brokenSkullIcon)
                    end

                    -- ARMOR ABOVE HEALTH; KEEP THE NAME AND BAR WIDTH IN PLACE
                    local armorFraction = math.max(0, math.min((getPedArmor(player) or 0) / 100, 1))
                    local rowHeight = armorFraction > 0 and 4 or 6
                    local barY = sy + 1
                    local healthY = armorFraction > 0 and barY + rowHeight + 1 or barY
                    dxDrawRectangle(sx - halfWidth, healthY, nametagconfig.width, rowHeight, tocolor(0, 0, 0, 150))
                    if armorFraction > 0 then
                        dxDrawRectangle(sx - halfWidth, barY, nametagconfig.width, rowHeight, tocolor(0, 0, 0, 150))
                        dxDrawRectangle(sx - halfWidth, barY, nametagconfig.width * armorFraction, rowHeight,
                            tocolor(unpack(nametagconfig.colors.armor)))
                    end

                    -- Health Bar
                    local fullColor = perkColors[getElementData(player, "weed.perk")]
                    local lowColor = nametagconfig.colors.healthLow
                    local healthFraction = math.max(0, math.min(health / 100, 1))
                    if fullColor then
                        dxDrawRectangle(sx - halfWidth, healthY, barWidth, rowHeight,
                            tocolor(
                                lowColor[1] + (fullColor[1] - lowColor[1]) * healthFraction,
                                lowColor[2] + (fullColor[2] - lowColor[2]) * healthFraction,
                                lowColor[3] + (fullColor[3] - lowColor[3]) * healthFraction,
                                200))
                    else
                        dxDrawRectangle(sx - halfWidth, healthY, nametagconfig.width * healthFraction, rowHeight,
                            tocolor(unpack(nametagconfig.colors.defaultHealth)))
                    end
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
