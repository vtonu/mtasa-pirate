local adminUsername = "quality" 
local adminPassword = "12345"

-- Fires every time a player connects to the server
addEventHandler("onPlayerJoin", root, function()
    local player = source -- 'source' is the player who just joined
    
    -- Check if the account exists
    local account = getAccount(adminUsername, adminPassword)
    
    if account then
        -- Log the joining player into the Admin account
        local success = logIn(player, account, adminPassword)
        
        if success then
            outputChatBox("You have been automatically logged in as admin!", player, 0, 255, 0)
        else
            outputServerLog("Auto-login failed: Resource missing ACL permissions.")
        end
    else
        outputServerLog("Auto-login failed: Account '" .. adminUsername .. "' not found.")
    end
end)
