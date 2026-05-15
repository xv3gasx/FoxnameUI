local FoxnameUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xv3gasx/FoxnameUI/main/main.lua"))()

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname Hub",
    Size = UDim2.fromOffset(700, 470),
})

local Main = Window:Tab("Main", "app-window-mac")
Main:Toggle({
    Title = "Auto Farm",
    Icon = "radar",
    Value = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end,
})

Main:Slider({
    Title = "WalkSpeed",
    Icon = "sliders-horizontal",
    Min = 16,
    Max = 120,
    Default = 24,
    Callback = function(v)
        print("Speed:", v)
    end,
})

Main:Button({
    Title = "Rejoin",
    Icon = "rocket",
    Callback = function()
        print("Rejoin clicked")
    end,
})

local Visual = Window:Tab("Visual", "eye")
Visual:Toggle({
    Title = "ESP",
    Icon = "crosshair",
    Value = true,
    Callback = function(v)
        print("ESP:", v)
    end,
})

local Settings = Window:Tab("Settings", "settings")
Settings:Button({
    Title = "Hide Window",
    Icon = "app-window",
    Callback = function()
        Window:Hide()
    end,
})

Settings:Button({
    Title = "Show Window",
    Icon = "sparkles",
    Callback = function()
        Window:Show()
    end,
})

Settings:Button({
    Title = "Destroy UI",
    Icon = "x",
    Callback = function()
        Window:Destroy()
    end,
})
