local nametagconfig = NametagConfig

local screenW, screenH = guiGetScreenSize()

local function renderNameTags()
    -- Hide default MTA tags
    setPlayerNametagShowing(localPlayer, false)

    local players = getElementsByType("player")
    local lx, ly, lz = getElementPosition(localPlayer)

    for _, player in ipairs(players) do
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
                    dxDrawRectangle(sx - halfWidth, sy, barWidth, 6,
                        tocolor(255 - (health * 2.55), health * 2.55, 0, 200))
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, renderNameTags)
