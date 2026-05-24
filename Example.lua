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

FoxnameUI:AddTheme({
    Name = "CyberMint",
    Accent = Color3.fromRGB(0, 220, 170),
    Accent2 = Color3.fromRGB(90, 255, 210),
    Background = Color3.fromRGB(10, 16, 18),
    Surface = Color3.fromRGB(16, 26, 30),
    Surface2 = Color3.fromRGB(24, 36, 40),
    Surface3 = Color3.fromRGB(34, 48, 54),
    Text = Color3.fromRGB(232, 255, 248),
    MutedText = Color3.fromRGB(144, 186, 172),
    Border = Color3.fromRGB(52, 92, 84),
    Success = Color3.fromRGB(70, 225, 150),
    Danger = Color3.fromRGB(240, 92, 110),
})

FoxnameUI:Notify({
    Title = "Foxname UI",
    Content = "Library loaded successfully",
    Duration = 2,
})

local Window = FoxnameUI:CreateWindow({
    Title = "Foxname - Murder Mystery 2",
    Icon = "app-window",
    Author = "discord.gg/v8ZPq4y2nD",
    DefaultSize = UDim2.fromOffset(840, 620),
    MinSize = UDim2.fromOffset(720, 500),
    MaxSize = UDim2.fromOffset(1280, 900),
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

local MiscSection = Window:Section({
    Title = "Misc",
    Opened = true,
    Icon = "file-code-2",
    IconColor = Color3.fromRGB(170, 170, 170),
})

local Main = MiscSection:Tab({
    Title = "Main",
    Icon = "app-window-mac",
    Locked = false,
    Badge = "NEW",
    Tooltip = "Main farming controls",
})
Main:Section({ Title = "Main Features" })
Main:Paragraph({
    Title = "Welcome",
    Content = "Search now checks tab names + section names + feature texts.",
})
Main:Space({ Height = 4 })

Main:Toggle({
    Title = "Auto Farm",
    Value = false,
    Tooltip = "Starts the farm routine",
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
        print("WalkSpeed:", v)
    end,
})

Main:Input({
    Title = "Player Name",
    Placeholder = "Type player...",
    Badge = "OPT",
    MaxLength = 20,
    Callback = function(text, enter)
        print("Input:", text, "Enter:", enter)
    end,
})

Main:Input({
    Title = "Custom WalkSpeed",
    Placeholder = "Only numbers...",
    NumbersOnly = true,
    MaxLength = 3,
    Callback = function(text)
        print("Custom WalkSpeed Input:", text)
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
    Callback = function()
        print("Rejoin clicked")
    end,
})

Main:Divider()

local quickGroup = Main:Group({
    Title = "Quick Actions",
    Opened = true,
})

quickGroup:Button({
    Title = "Teleport Spawn",
    Tooltip = "Example grouped action button",
    Callback = function()
        print("Teleport spawn clicked")
    end,
})

quickGroup:Toggle({
    Title = "Auto Vote",
    Value = false,
    Callback = function(v)
        print("Auto Vote:", v)
    end,
})

local Visual = MiscSection:Tab({ Title = "Visual", Icon = "eye", Locked = false })
Visual:Section({ Title = "ESP" })

Visual:Toggle({
    Title = "ESP",
    Value = true,
    Callback = function(v)
        print("ESP:", v)
    end,
})

Visual:Slider({
    Title = "ESP Distance",
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

local Settings = MiscSection:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false,
    Tooltip = "Theme, keybind and window settings",
})
local Premium = MiscSection:Tab({
    Title = "Premium",
    Icon = "lock",
    Locked = true,
    LockedTitle = "Premium Required",
})
local uiVisible = true
Settings:Section({ Title = "Window Controls" })

Premium:Paragraph({
    Title = "Locked Tab Demo",
    Content = "This tab is locked. Overlay title uses LockedTitle.",
})

Settings:Colorpicker({
    Title = "Accent Preview",
    Description = "Drag on palette or hue bar, or type hex.",
    Default = Color3.fromRGB(255, 120, 40),
    Callback = function(c)
        print("Picked color:", c)
    end,
})

local themeNames = {}
for themeName, _ in pairs(FoxnameUI:GetThemes()) do
    table.insert(themeNames, themeName)
end
table.sort(themeNames, function(a, b)
    return string.lower(a) < string.lower(b)
end)

local selectedTheme = Window:GetCurrentTheme() or themeNames[1]
Settings:Dropdown({
    Title = "Theme",
    Values = themeNames,
    Default = selectedTheme,
    Callback = function(v)
        selectedTheme = v
    end,
})

Settings:Button({
    Title = "Apply Selected Theme",
    Callback = function()
        if selectedTheme and selectedTheme ~= "" then
            Window:SetThemeByName(selectedTheme)
            FoxnameUI:Notify({
                Type = "success",
                Title = "Theme Applied",
                Content = "Current theme: " .. tostring(selectedTheme),
                Duration = 2.5,
            })
        end
    end,
})

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
    Callback = function()
        Window:Hide()
        uiVisible = false
    end,
})

Settings:Button({
    Title = "Show Window",
    Callback = function()
        Window:Show()
        uiVisible = true
    end,
})

Settings:Button({
    Title = "Test Notify",
    Callback = function()
        FoxnameUI:Notify({
            Title = "Test",
            Content = "This is a test notification",
            Duration = 3,
        })
        FoxnameUI:Notify({
            Type = "success",
            Title = "Success",
            Content = "Theme applied successfully",
            Duration = 3,
        })
        FoxnameUI:Notify({
            Type = "warning",
            Title = "Warning",
            Content = "This is a warning notification",
            Duration = 3,
        })
        FoxnameUI:Notify({
            Type = "error",
            Title = "Error",
            Content = "Something went wrong",
            Duration = 3,
        })
    end,
})

Settings:Button({
    Title = "Destroy UI",
    Callback = function()
        Window:Dialog({
            Title = "Destroy UI",
            Content = "Are you sure you want to destroy the UI?",
            ConfirmText = "Yes, Destroy",
            CancelText = "Cancel",
            OnConfirm = function()
                Window:Destroy()
            end,
        })
    end,
})

