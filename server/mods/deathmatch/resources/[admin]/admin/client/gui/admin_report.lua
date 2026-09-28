--[[**********************************
*
*	Multi Theft Auto - Admin Panel
*
*	gui\admin_report.lua
*
*	Original File by lil_Toady
*
**************************************]] aReportForm = nil
local reportCategories
local aSelectPlayer = nil
local reportInputMode

function aReport()

    if (aReportForm == nil) then
        reportInputMode = guiGetInputMode()
        reportCategories = {}
        for i, cat in ipairs(split(g_Prefs.reportCategories, string.byte(','))) do
            table.insert(reportCategories, {
                subject = cat
            })
        end
        for i, cat in ipairs(split(g_Prefs.playerReportCategories, string.byte(','))) do
            table.insert(reportCategories, {
                subject = cat,
                playerReport = true
            })
        end

        local x, y = guiGetScreenSize()
        aReportForm = guiCreateWindow(x / 2 - 150, y / 2 - 170, 300, 340, "Bug Report", false)
        guiCreateLabel(0.05, 0.11, 0.20, 0.07, "Category:", true, aReportForm)
        guiCreateLabel(0.05, 0.19, 0.20, 0.07, "Subject:", true, aReportForm)
        guiCreateLabel(0.05, 0.34, 0.20, 0.07, "Message:", true, aReportForm)
        aReportLblPlayer = guiCreateLabel(0.05, 0.27, 0.20, 0.07, "Player:", true, aReportForm)
        aReportBtnPlayer = guiCreateButton(0.75, 0.27, 0.20, 0.07, "Select", true, aReportForm)
        aReportCategory = guiCreateComboBox(0.30, 0.10, 0.65, 0.55, "", true, aReportForm)
        for _, category in ipairs(reportCategories) do
            guiComboBoxAddItem(aReportCategory, category.subject)
        end
        guiComboBoxSetSelected(aReportCategory, 0)
        aReportSubject = guiCreateEdit(0.30, 0.18, 0.65, 0.07, "", true, aReportForm)
        aReportPlayer = guiCreateLabel(0.30, 0.27, 0.50, 0.07, "", true, aReportForm)
        aReportMessage = guiCreateMemo(0.05, 0.41, 0.90, 0.42, "", true, aReportForm)
        aReportAccept = guiCreateButton(0.25, 0.88, 0.40, 0.09, "Submit Report", true, aReportForm)
        aReportCancel = guiCreateButton(0.70, 0.88, 0.25, 0.09, "Cancel", true, aReportForm)

        if (not reportCategories[1].playerReport) then
            guiSetVisible(aReportPlayer, false)
            guiSetVisible(aReportLblPlayer, false)
            guiSetVisible(aReportBtnPlayer, false)
        end

        addEventHandler("onClientGUIClick", aReportForm, aClientReportClick)
        addEventHandler("onClientGUIComboBoxAccepted", aReportCategory, aClientReportCategoryChanged, false)
    end
    guiSetInputMode("no_binds")
    guiBringToFront(aReportForm)
    showCursor(true)
end
addEventHandler("aClientReports", root, aReport)

function aReportClose()
    if (aReportForm) then
        removeEventHandler("onClientGUIClick", aReportForm, aClientReportClick)
        removeEventHandler("onClientGUIComboBoxAccepted", aReportCategory, aClientReportCategoryChanged)
        if isElement(aSelectPlayer) then
            destroyElement(aSelectPlayer)
        end
        aSelectPlayer = nil
        destroyElement(aReportForm)
        aReportForm = nil
        guiSetInputMode(reportInputMode or "allow_binds")
        reportInputMode = nil
        showCursor(false)
    end
end

function aReportSelectPlayer()
    if (aSelectPlayer == nil) then
        local x, y = guiGetScreenSize()
        aSelectPlayer = guiCreateWindow(x / 2 - 155, y / 2 - 250, 310, 500, "Select player", false)
        local playerList = guiCreateGridList(0.03, 0.06, 0.97, 0.78, true, aSelectPlayer)
        local searchBox = guiCreateEdit(0.115, 0.86, 0.77, 0.06, "", true, aSelectPlayer)
        addEventHandler("onClientGUIChanged", searchBox, function()
            guiGridListClear(playerList)
            local text = guiGetText(source)
            for _, player in pairs(getElementsByType("player")) do
                local playerName = getPlayerName(player)
                if (string.find(string.upper(playerName), string.upper(text), 1, true)) then
                    guiGridListSetItemText(playerList, guiGridListAddRow(playerList), 1, playerName, false, false)
                end
            end
        end)
        guiGridListAddColumn(playerList, "Player name", 0.85)
        for _, player in pairs(getElementsByType("player")) do
            guiGridListSetItemText(playerList, guiGridListAddRow(playerList), 1, getPlayerName(player), false, false)
        end
        local btnSelectPlayer = guiCreateButton(0.57, 0.93, 0.33, 0.05, "Select", true, aSelectPlayer)
        addEventHandler("onClientGUIClick", btnSelectPlayer, function()
            guiSetText(aReportPlayer, guiGridListGetItemText(playerList, guiGridListGetSelectedItem(playerList), 1))
            destroyElement(aSelectPlayer)
            aSelectPlayer = nil
        end, false)
        local btnClose = guiCreateButton(0.10, 0.93, 0.33, 0.05, "Close", true, aSelectPlayer)
        addEventHandler("onClientGUIClick", btnClose, function()
            destroyElement(aSelectPlayer)
            aSelectPlayer = nil
        end, false)
    end
end

function aClientReportCategoryChanged()
    local category = reportCategories[guiComboBoxGetSelected(aReportCategory) + 1]
    local playerReport = category and category.playerReport == true or false
    guiSetVisible(aReportPlayer, playerReport)
    guiSetVisible(aReportLblPlayer, playerReport)
    guiSetVisible(aReportBtnPlayer, playerReport)
end

function aClientReportClick(button)
    if (button == "left") then
        if (source == aReportAccept) then
            if ((string.len(guiGetText(aReportSubject)) < 1) or (string.len(guiGetText(aReportMessage)) < 5)) then
                aMessageBox("error", "Subject/Message missing.")
            else
                local tableOut = {}
                if (guiGetVisible(aReportPlayer)) then
                    local text = guiGetText(aReportPlayer)
                    if (text ~= "") then
                        tableOut.suspect = text
                    end
                end
                tableOut.category = guiComboBoxGetItemText(aReportCategory, guiComboBoxGetSelected(aReportCategory))
                tableOut.subject = guiGetText(aReportSubject)
                tableOut.message = guiGetText(aReportMessage)
                triggerServerEvent("aMessage", localPlayer, "new", tableOut)
                aReportClose()
                outputChatBox("[NOTIFICATION] Your message has been submitted.", 205, 250, 80)
            end
            -- elseif ( source == aReportSubject ) then

            -- elseif ( source == aReportMessage ) then

        elseif (source == aReportCancel) then
            aReportClose()
        elseif (source == aReportBtnPlayer) then
            aReportSelectPlayer()
        end
    end
end
