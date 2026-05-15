local mk = require(script.Parent.core.Creator)
local theme = require(script.Parent.themes.Default)
local makeElements = require(script.Parent.elements.Init)
local makeTabs = require(script.Parent.core.Tabs)

local FoxnameUI = {}
FoxnameUI.Theme = theme

function FoxnameUI:CreateWindow(cfg)
    cfg = cfg or {}

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = mk("ScreenGui", {
        Name = "FoxnameUI",
        Parent = parent,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })

    local main = mk("Frame", {
        Parent = gui,
        Size = cfg.Size or UDim2.fromOffset(620, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
    })

    mk("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})

    local top = mk("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = top, CornerRadius = UDim.new(0, 12)})

    local title = mk("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = cfg.Title or "Foxname UI",
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    })

    local content = mk("Frame", {
        Parent = main,
        Position = UDim2.new(0, 150, 0, 44),
        Size = UDim2.new(1, -150, 1, -44),
        BackgroundTransparency = 1,
    })

    local elements = makeElements({mk = mk, theme = theme})
    local tabs = makeTabs({mk = mk, theme = theme, elements = elements})(main, content)

    local api = {}
    function api:Tab(name)
        return tabs:CreateTab(name)
    end
    function api:Destroy()
        gui:Destroy()
    end

    return api
end

return FoxnameUI
