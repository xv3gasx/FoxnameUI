local FoxnameUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xv3gasx/FoxnameUI/main/main.lua"))()

print("Theme:", FoxnameUI.Theme and FoxnameUI.Theme.Name)

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname Hub",
    Size = UDim2.fromOffset(700, 470),
})

-- Function 1: Tab()
local Main = Window:Tab("Main", "app-window-mac")

-- Function 2: Toggle()
Main:Toggle({
    Title = "Auto Farm",
    Icon = "radar",
    Value = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end,
})

-- Function 3: Slider()
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

-- Function 4: Button()
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

-- Function 5: Hide()
Settings:Button({
    Title = "Hide Window",
    Icon = "app-window",
    Callback = function()
        Window:Hide()
        print("Window hidden")
    end,
})

-- Function 6: Show()
Settings:Button({
    Title = "Show Window",
    Icon = "sparkles",
    Callback = function()
        Window:Show()
        print("Window shown")
    end,
})

-- Function 7: Destroy()
Settings:Button({
    Title = "Destroy UI",
    Icon = "x",
    Callback = function()
        Window:Destroy()
        print("Window destroyed")
    end,
})
