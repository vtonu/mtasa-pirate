-- Function to handle the server-side blur toggle
function toggleBlurCommand(playerSource, commandName, argument)
    -- In server-side, we must check the specific player's current blur level
    local currentBlur = getPlayerBlurLevel(playerSource)

    -- Argument handling: /blurry on or /blurry off
    if argument == "on" then
        setPlayerBlurLevel(playerSource, 0)
        outputChatBox("Motion blur has been disabled.", playerSource, 0, 0, 0)
    elseif argument == "off" then
        setPlayerBlurLevel(playerSource, 36) -- 36 is the default GTA:SA blur level
        outputChatBox("Motion blur has been restored.", playerSource, 0, 0, 0)
    else
        -- Toggle logic if no argument is passed: /blurry
        if currentBlur > 0 then
            setPlayerBlurLevel(playerSource, 0)
            outputChatBox("Motion blur has been disabled.", playerSource, 0, 0, 0)
        else
            setPlayerBlurLevel(playerSource, 36)
            outputChatBox("Motion blur has been restored.", playerSource, 0, 0, 0)
        end
    end
end
-- Registers the command to "blurry"
addCommandHandler("blurry", toggleBlurCommand)

-- Optional: Automatically force blur off for every player when they join the server
addEventHandler("onPlayerJoin", root, function()
    setPlayerBlurLevel(source, 0)
end)
