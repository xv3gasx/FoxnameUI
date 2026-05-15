-- Do Not Edit This Section!!!
local url = "https://raw.githubusercontent.com/xv3gasx/FoxnameUI/main/main.lua?v=" .. tostring(os.time())
local src = game:HttpGet(url)
src = src:gsub("^\239\187\191", "")

local fn, err = loadstring(src)
if not fn then
    error("Compile error: " .. tostring(err))
end

local FoxnameUI = fn()
if not FoxnameUI then
    error("FoxnameUI nil dondu")
end

FoxnameUI:Notify({
    Title = "Foxname UI",
    Content = "Library loaded successfully",
    Duration = 2,
})

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname Hub",
    Icon = "app-window",
    Size = UDim2.fromOffset(700, 470),
})

local Main = Window:Tab("Main", "app-window-mac")
Main:Section({ Title = "Main Features" })

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

Main:Input({
    Title = "Player Name",
    Icon = "user",
    Placeholder = "Type player...",
    Callback = function(text, enter)
        print("Input:", text, "Enter:", enter)
    end,
})

Main:Dropdown({
    Title = "Farm Mode",
    Icon = "list",
    Values = {"Normal", "Fast", "Safe"},
    Default = "Normal",
    Callback = function(v)
        print("Farm Mode:", v)
    end,
})

Main:Button({
    Title = "Rejoin",
    Icon = "rocket",
    Callback = function()
        print("Rejoin clicked")
    end,
})

Main:Divider()

local Visual = Window:Tab("Visual", "eye")
Visual:Section({ Title = "ESP" })
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

Visual:Dropdown({
    Title = "ESP Targets",
    Icon = "filter",
    Values = {"Players", "NPC", "Items"},
    Multi = true,
    Default = {"Players"},
    Callback = function(map)
        print("ESP Targets changed")
        for k, val in pairs(map) do
            if val then print(" -", k) end
        end
    end,
})

local Settings = Window:Tab("Settings", "settings")
Settings:Section({ Title = "Window Controls" })

Settings:Keybind({
    Title = "Toggle Key",
    Icon = "keyboard",
    Default = "RightControl",
    Callback = function(newKey)
        print("New keybind:", newKey)
    end,
    Pressed = function()
        if not Window then return end
        _G.FoxnameVisible = not (_G.FoxnameVisible == false)
        if _G.FoxnameVisible then
            Window:Hide()
            _G.FoxnameVisible = false
        else
            Window:Show()
            _G.FoxnameVisible = true
        end
    end,
})

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
    Title = "Test Notify",
    Icon = "bell",
    Callback = function()
        FoxnameUI:Notify({
            Title = "Test",
            Content = "This is a test notification",
            Duration = 3,
        })
    end,
})

Settings:Button({
    Title = "Destroy UI",
    Icon = "x",
    Callback = function()
        Window:Destroy()
    end,
})

