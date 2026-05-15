-- Local test (workspace):
local FoxnameUI = require(script.Parent.main)

-- Remote test (when uploaded):
-- local FoxnameUI = loadstring(game:HttpGet("RAW_LINK_TO_FOXNAME_MAIN_LUA"))()

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname Hub",
    Size = UDim2.fromOffset(640, 440),
})

local Main = Window:Tab("Main")
Main:Toggle({
    Title = "Auto Farm",
    Value = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end,
})

Main:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 120,
    Default = 24,
    Callback = function(v)
        print("Speed:", v)
    end,
})

Main:Button({
    Title = "Rejoin",
    Callback = function()
        print("Rejoin clicked")
    end,
})

local Visual = Window:Tab("Visual")
Visual:Toggle({
    Title = "ESP",
    Value = true,
    Callback = function(v)
        print("ESP:", v)
    end,
})
