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
    Author = "discord.gg/foxname",
    Icon = "app-window",
    DefaultSize = UDim2.fromOffset(700, 470),
    MinSize = UDim2.fromOffset(560, 360),
    MaxSize = UDim2.fromOffset(1100, 760),
    OpenButton = {
        Title = "Fox",
        Shape = "Pill", -- Circle | Pill | Square
        OnlyMobile = false,
        Draggable = true,
        DefaultSize = UDim2.fromOffset(86, 34),
        MinSize = UDim2.fromOffset(60, 30),
        MaxSize = UDim2.fromOffset(140, 56),
    }
})

local Main = Window:Tab("Main", "app-window-mac")
Main:Section({ Title = "Main Features" })

Main:Toggle({
    Title = "Auto Farm",
    Description = "Automatically farms while enabled.",
    Value = false,
    Callback = function(v)
        print("Auto Farm:", v)
    end,
})

Main:Slider({
    Title = "WalkSpeed",
    Description = "Adjust your movement speed.",
    Min = 16,
    Max = 120,
    Default = 24,
    Callback = function(v)
        print("WalkSpeed:", v)
    end,
})

Main:Input({
    Title = "Player Name",
    Description = "Enter a target player name.",
    Placeholder = "Type player...",
    Callback = function(text, enter)
        print("Input:", text, "Enter:", enter)
    end,
})

Main:Dropdown({
    Title = "Farm Mode",
    Values = {"Normal", "Fast", "Safe"},
    Default = "Normal",
    Callback = function(v)
        print("Farm Mode:", v)
    end,
})

Main:Button({
    Title = "Rejoin",
    Description = "Reconnect to the current server.",
    Callback = function()
        print("Rejoin clicked")
    end,
})

Main:Divider()

local Visual = Window:Tab("Visual", "eye")
Visual:Section({ Title = "ESP" })

Visual:Toggle({
    Title = "ESP",
    Description = "Show highlighted targets.",
    Value = true,
    Callback = function(v)
        print("ESP:", v)
    end,
})

Visual:Slider({
    Title = "ESP Distance",
    Description = "Maximum distance for ESP rendering.",
    Min = 50,
    Max = 3000,
    Default = 700,
    Callback = function(v)
        print("ESP Distance:", v)
    end,
})

Visual:Dropdown({
    Title = "ESP Targets",
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
local uiVisible = true
Settings:Section({ Title = "Window Controls" })

Settings:Keybind({
    Title = "Toggle Key",
    Default = "RightControl",
    Callback = function(newKey)
        print("New keybind:", newKey)
    end,
    Pressed = function()
        uiVisible = not uiVisible
        if uiVisible then
            Window:Show()
        else
            Window:Hide()
        end
    end,
})

Settings:Button({
    Title = "Hide Window",
    Description = "Hide the main window.",
    Callback = function()
        Window:Hide()
        uiVisible = false
    end,
})

Settings:Button({
    Title = "Show Window",
    Description = "Show the main window again.",
    Callback = function()
        Window:Show()
        uiVisible = true
    end,
})

Settings:Button({
    Title = "Test Notify",
    Description = "Send a demo notification.",
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
    Description = "Close and remove the UI.",
    Callback = function()
        Window:Destroy()
    end,
})
