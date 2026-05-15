-- Do Not Edit This Section!!!
local url = "https://raw.githubusercontent.com/xv3gasx/FoxnameUI/main/main.lua?v=" .. tostring(os.time())
local src = game:HttpGet(url):gsub("^\239\187\191", "")
local FoxnameUI = assert(loadstring(src))()

print("FoxnameUI loaded")
print("Theme:", FoxnameUI.Theme and FoxnameUI.Theme.Name or "N/A")
print("Icon provider ready:", FoxnameUI.IconProvider ~= nil)

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname Hub",
    Icon = "app-window",
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
        print("WalkSpeed:", v)
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

Visual:Slider({
    Title = "ESP Distance",
    Icon = "ruler",
    Min = 50,
    Max = 3000,
    Default = 700,
    Callback = function(v)
        print("ESP Distance:", v)
    end,
})

local Settings = Window:Tab("Settings", "settings")
Settings:Button({
    Title = "Hide Window",
    Icon = "panel-left-close",
    Callback = function()
        Window:Hide()
    end,
})

Settings:Button({
    Title = "Show Window",
    Icon = "panel-left-open",
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
