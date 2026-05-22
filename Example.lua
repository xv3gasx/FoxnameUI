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
    Title = "Foxname - Murder Mystery 2",
    Icon = "app-window",
    Author = "discord.gg/v8ZPq4y2nD",
    DefaultSize = UDim2.fromOffset(730, 525),
    MinSize = UDim2.fromOffset(640, 430),
    MaxSize = UDim2.fromOffset(1200, 820),
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

local Main = MiscSection:Tab({ Title = "Main", Icon = "app-window-mac", Locked = false })
Main:Section({ Title = "Main Features" })
Main:Paragraph({
    Title = "Welcome",
    Content = "Search now checks tab names + section names + feature texts.",
})
Main:Space({ Height = 4 })

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
        print("WalkSpeed:", v)
    end,
})

Main:Input({
    Title = "Player Name",
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
    Callback = function()
        print("Rejoin clicked")
    end,
})

Main:Divider()

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

local Settings = MiscSection:Tab({ Title = "Settings", Icon = "settings", Locked = false })
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

Settings:Button({
    Title = "Apply Ocean Theme",
    Callback = function()
        Window:SetTheme({
            Accent = Color3.fromRGB(40, 160, 255),
            Background = Color3.fromRGB(12, 18, 28),
            Surface = Color3.fromRGB(18, 26, 40),
            Surface2 = Color3.fromRGB(28, 38, 56),
            Surface3 = Color3.fromRGB(42, 54, 76),
            Text = Color3.fromRGB(238, 245, 255),
            MutedText = Color3.fromRGB(160, 180, 210),
            Border = Color3.fromRGB(68, 88, 120),
            Danger = Color3.fromRGB(240, 90, 90),
        })
    end,
})

Settings:Button({
    Title = "Save + Use Ember Copy",
    Callback = function()
        Window:AddTheme("EmberCopy", {
            Accent = Color3.fromRGB(255, 120, 40),
            Background = Color3.fromRGB(16, 18, 24),
            Surface = Color3.fromRGB(24, 27, 36),
            Surface2 = Color3.fromRGB(32, 36, 48),
            Surface3 = Color3.fromRGB(40, 45, 60),
            Text = Color3.fromRGB(238, 241, 248),
            MutedText = Color3.fromRGB(156, 164, 184),
            Border = Color3.fromRGB(58, 64, 84),
            Danger = Color3.fromRGB(240, 90, 90),
        })
        Window:UseTheme("EmberCopy")
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

Settings:Button({
    Title = "Use Rose Theme",
    Callback = function()
        Window:UseTheme("Rose")
    end,
})