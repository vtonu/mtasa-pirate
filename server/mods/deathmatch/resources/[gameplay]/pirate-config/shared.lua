-- VALIDATE SETTINGS AND KEEP CURRENT DEFAULTS
local promptFonts = {
    default = true, ["default-bold"] = true, clear = true,
    arial = true, sans = true, ["pricedown"] = true,
    bankgothic = true, diploma = true, beckett = true
}

local function numberInRange(value, minimum, maximum, fallback)
    if type(value) == "number" and value == value and value >= minimum and value <= maximum then
        return value
    end
    return fallback
end

function getPromptStyle(name)
    if name ~= "spawn" and name ~= "respawn" then return false end
    local settings = type(config) == "table" and config or {}
    local colors = type(settings.colors) == "table" and settings.colors or {}
    local accent = type(colors.accent) == "table" and colors.accent or {}
    local fonts = type(settings.fonts) == "table" and settings.fonts or {}
    local text = type(settings.text) == "table" and settings.text or {}
    local ui = type(settings.ui) == "table" and settings.ui or {}
    local prompt = type(ui.prompt) == "table" and ui.prompt or {}
    local font = type(fonts.prompt) == "string" and promptFonts[fonts.prompt] and fonts.prompt or "default-bold"
    local label = type(text[name]) == "string" and text[name] ~= "" and text[name]
        or (name == "spawn" and "PRESS 'SPACE' TO SPAWN" or "PRESS 'SPACE' TO RESPAWN")
    return {
        color = {
            numberInRange(accent[1], 0, 255, 127),
            numberInRange(accent[2], 0, 255, 255),
            numberInRange(accent[3], 0, 255, 212),
            numberInRange(accent[4], 0, 255, 255)
        },
        font = font,
        text = label,
        scale = numberInRange(prompt.scale, 0.1, 10, 2),
        bottomOffset = numberInRange(prompt.bottomOffset, 0, 2000, 100)
    }
end
