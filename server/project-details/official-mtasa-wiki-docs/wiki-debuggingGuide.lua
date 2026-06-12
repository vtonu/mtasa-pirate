--================================--
-- DEBUGGING GUIDE
-- MTA:SA SCRIPTING REFERENCE
--================================--

local DebugGuide = {

```
overview = [[
```

Debugging is the process of finding, understanding, and fixing problems in scripts.
Most MTA issues come from invalid elements, nil values, incorrect event usage,
resource startup order, synchronization problems, or logic errors.

Learning how to debug efficiently is one of the most important skills for MTA development.
]],

```
tools = {
    "outputDebugString",
    "debugscript 3",
    "outputChatBox",
    "iprint",
    "inspect",
    "Element Browser",
    "Performance Browser"
},

debugLevels = {
    [0] = "Errors only",
    [1] = "Errors and warnings",
    [2] = "Errors, warnings and information",
    [3] = "Full debugging output"
},

commonProblems = {

    {
        issue = "Bad Argument",
        example = "Bad argument @ setElementPosition",
        cause = "Invalid element or incorrect parameter type",
        solution = "Verify the element exists and all arguments are valid"
    },

    {
        issue = "Attempt To Index A Nil Value",
        example = "playerData.money",
        cause = "Variable does not exist",
        solution = "Check variable creation and scope"
    },

    {
        issue = "Resource Not Starting",
        example = "Script does nothing",
        cause = "Meta.xml errors or startup failures",
        solution = "Check server logs and debugscript output"
    },

    {
        issue = "Event Not Firing",
        example = "onMarkerHit never runs",
        cause = "Incorrect source or event registration",
        solution = "Verify addEventHandler usage"
    },

    {
        issue = "Element Doesn't Exist",
        example = "setVehicleColor(vehicle)",
        cause = "Element was destroyed or never created",
        solution = "Check with isElement() first"
    }
},

usefulCommands = {

    {
        command = "debugscript 3",
        description = "Shows all debug messages"
    },

    {
        command = "refresh",
        description = "Refresh resource list"
    },

    {
        command = "start resourceName",
        description = "Start a resource"
    },

    {
        command = "restart resourceName",
        description = "Restart a resource"
    },

    {
        command = "stop resourceName",
        description = "Stop a resource"
    }
},

examples = {

    outputDebugString = [[
```

outputDebugString("Vehicle spawned successfully")
]],

```
    printElement = [[
```

outputDebugString("Element Type: " .. getElementType(element))
]],

```
    validateElement = [[
```

if isElement(vehicle) then
outputDebugString("Vehicle exists")
end
]],

```
    inspectData = [[
```

iprint(getElementData(player, "Money"))
]],

```
    eventDebug = [[
```

addEventHandler("onPlayerJoin", root,
function ()
outputDebugString(getPlayerName(source) .. " joined")
end
)
]]
},

```
debuggingChecklist = {

    "Is the resource running?",
    "Does debugscript show any errors?",
    "Are all variables valid?",
    "Are all elements valid?",
    "Did the event actually fire?",
    "Are client and server scripts separated correctly?",
    "Does the function require root, source or localPlayer?",
    "Is the resource exported correctly?",
    "Does the meta.xml contain all files?",
    "Are dimensions and interiors correct?"
},

elementDebugging = {

    "Use isElement before manipulating elements",
    "Use getElementType to verify types",
    "Check element parents using getElementParent",
    "Inspect children using getElementChildren",
    "Verify streamed elements on clientside",
    "Use Element Browser for hierarchy inspection"
},

performanceDebugging = {

    "Avoid unnecessary timers",
    "Avoid loops every frame unless required",
    "Cache frequently used elements",
    "Destroy unused elements",
    "Remove unused event handlers",
    "Profile resources using Performance Browser"
},

bestPractices = {

    "Always use outputDebugString while developing",
    "Validate every element before use",
    "Keep scripts modular",
    "Use descriptive variable names",
    "Check return values from functions",
    "Handle unexpected situations gracefully",
    "Test resources independently before integration",
    "Debug one problem at a time"
}
```

}

return DebugGuide

--================================--
-- QUICK REFERENCE
--================================--

-- Show a debug message
outputDebugString("Hello World")

-- Validate an element
if isElement(vehicle) then
-- Safe code here
end

-- Print complex tables
iprint(myTable)

-- Enable maximum debugging
-- debugscript 3

-- Most useful question:
-- "What exactly is nil?"
-------------------------

-- Example:
-- outputDebugString(tostring(variable))
----------------------------------------

-- If it prints nil, you've found the problem.
