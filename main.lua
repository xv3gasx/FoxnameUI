-- Foxname UI single-file loader build
local FoxnameUI = {}

local Theme = {
    Name = "Foxname Ember",
    Accent = Color3.fromRGB(255, 120, 40),
    Background = Color3.fromRGB(18, 20, 26),
    Surface = Color3.fromRGB(28, 31, 40),
    Surface2 = Color3.fromRGB(36, 40, 52),
    Text = Color3.fromRGB(236, 238, 245),
    MutedText = Color3.fromRGB(165, 172, 190),
    Border = Color3.fromRGB(62, 68, 84),
    Success = Color3.fromRGB(80, 210, 120),
    Danger = Color3.fromRGB(240, 90, 90),
}

local function mk(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        i[k] = v
    end
    return i
end

local function CreateElements(theme)
    local Elements = {}

    function Elements:Button(parent, cfg)
        local b = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = cfg.Title or "Button",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            AutoButtonColor = false,
        })
        b.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
        return b
    end

    function Elements:Toggle(parent, cfg)
        local state = cfg.Value == true
        local btn = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})

        mk("TextLabel", {
            Parent = btn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = cfg.Title or "Toggle",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })

        local pill = mk("Frame", {
            Parent = btn,
            Size = UDim2.new(0, 28, 0, 16),
            Position = UDim2.new(1, -34, 0.5, -8),
            BorderSizePixel = 0,
            BackgroundColor3 = state and theme.Accent or theme.Border,
        })
        mk("UICorner", {Parent = pill, CornerRadius = UDim.new(1, 0)})

        local function sync()
            pill.BackgroundColor3 = state and theme.Accent or theme.Border
        end

        btn.MouseButton1Click:Connect(function()
            state = not state
            sync()
            if cfg.Callback then cfg.Callback(state) end
        end)

        sync()
        return {SetValue = function(v) state = v == true; sync() end}
    end

    function Elements:Slider(parent, cfg)
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min

        local holder = mk("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundTransparency = 1,
        })

        local label = mk("TextLabel", {
            Parent = holder,
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = string.format("%s: %s", cfg.Title or "Slider", tostring(value)),
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })

        local bar = mk("Frame", {
            Parent = holder,
            Position = UDim2.new(0, 0, 0, 22),
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 7)})

        local fill = mk("Frame", {
            Parent = bar,
            Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = fill, CornerRadius = UDim.new(0, 7)})

        local dragging = false
        local function setFromX(x)
            local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            value = math.floor(min + (max - min) * p + 0.5)
            fill.Size = UDim2.new(p, 0, 1, 0)
            label.Text = string.format("%s: %s", cfg.Title or "Slider", tostring(value))
            if cfg.Callback then cfg.Callback(value) end
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                setFromX(i.Position.X)
            end
        end)
        bar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                setFromX(i.Position.X)
            end
        end)

        return holder
    end

    return Elements
end

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
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = main, CornerRadius = UDim.new(0, 12)})

    local top = mk("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = top, CornerRadius = UDim.new(0, 12)})

    mk("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = cfg.Title or "Foxname UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    })

    local tabButtons = mk("Frame", {
        Parent = main,
        Size = UDim2.new(0, 150, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    })
    local btnList = mk("UIListLayout", {Parent = tabButtons, Padding = UDim.new(0, 6)})
    btnList.SortOrder = Enum.SortOrder.LayoutOrder
    mk("UIPadding", {Parent = tabButtons, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

    local contentArea = mk("Frame", {
        Parent = main,
        Position = UDim2.new(0, 150, 0, 44),
        Size = UDim2.new(1, -150, 1, -44),
        BackgroundTransparency = 1,
    })

    local elements = CreateElements(Theme)
    local tabs = {}
    local currentTab

    local function show(tab)
        if currentTab then currentTab.Container.Visible = false end
        currentTab = tab
        tab.Container.Visible = true
    end

    local windowApi = {}
    function windowApi:Tab(name)
        local btn = mk("TextButton", {
            Parent = tabButtons,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})

        local container = mk("ScrollingFrame", {
            Parent = contentArea,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
        })
        local layout = mk("UIListLayout", {Parent = container, Padding = UDim.new(0, 8)})
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        mk("UIPadding", {
            Parent = container,
            PaddingTop = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
        end)

        local tab = {Button = btn, Container = container}
        function tab:Button(c) return elements:Button(container, c) end
        function tab:Toggle(c) return elements:Toggle(container, c) end
        function tab:Slider(c) return elements:Slider(container, c) end

        btn.MouseButton1Click:Connect(function() show(tab) end)
        table.insert(tabs, tab)
        if #tabs == 1 then show(tab) end
        return tab
    end

    function windowApi:Destroy()
        gui:Destroy()
    end

    return windowApi
end

FoxnameUI.Theme = Theme
return FoxnameUI
