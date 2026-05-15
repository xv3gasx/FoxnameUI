-- Foxname UI v2 (single-file, loadstring-ready)
local FoxnameUI = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Theme = {
    Name = "Foxname Ember",
    Accent = Color3.fromRGB(255, 120, 40),
    Accent2 = Color3.fromRGB(255, 175, 90),
    Background = Color3.fromRGB(16, 18, 24),
    Surface = Color3.fromRGB(24, 27, 36),
    Surface2 = Color3.fromRGB(32, 36, 48),
    Surface3 = Color3.fromRGB(40, 45, 60),
    Text = Color3.fromRGB(238, 241, 248),
    MutedText = Color3.fromRGB(156, 164, 184),
    Border = Color3.fromRGB(58, 64, 84),
    Success = Color3.fromRGB(80, 210, 120),
    Danger = Color3.fromRGB(240, 90, 90),
}

local Icons = {
    close = "?",
    hide = "—",
    menu = "?",
    bolt = "?",
    eye = "?",
    gear = "?",
}

local LucideMap = {
    ["app-window-mac"] = "?",
    ["app-window"] = "?",
    ["settings"] = "?",
    ["radar"] = "?",
    ["zap"] = "?",
    ["eye"] = "?",
    ["home"] = "¦",
    ["user"] = "?",
    ["terminal"] = ">_",
    ["shield"] = "?",
    ["gamepad-2"] = "??",
    ["sword"] = "??",
    ["crosshair"] = "?",
    ["sliders-horizontal"] = "?",
    ["mouse-pointer-click"] = "?",
    ["sparkles"] = "?",
    ["rocket"] = "??",
    ["activity"] = "?",
    ["circle"] = "?",
}

local function mk(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        i[k] = v
    end
    return i
end

local function tween(obj, t, props, style, dir)
    local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

local function normalizeLucideName(icon)
    if type(icon) ~= "string" then return nil end
    icon = icon:lower():gsub("^%s+", ""):gsub("%s+$", "")
    icon = icon:gsub("https?://lucide%.dev/icons/", "")
    icon = icon:gsub("/$", "")
    return icon
end

local function resolveIcon(icon)
    if icon == nil then return nil end
    if type(icon) ~= "string" then return icon end

    local key = normalizeLucideName(icon)
    if not key or key == "" then return nil end

    if LucideMap[key] then
        return LucideMap[key]
    end

    return key
end

local function iconTitle(icon, title)
    local resolved = resolveIcon(icon)
    if resolved and resolved ~= "" then
        return string.format("%s  %s", resolved, title or "")
    end
    return title or ""
end

local function CreateElements(theme)
    local Elements = {}

    function Elements:Button(parent, cfg)
        local b = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = iconTitle(cfg.Icon, cfg.Title or "Button"),
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = b, CornerRadius = UDim.new(0, 10)})
        local stroke = mk("UIStroke", {Parent = b, Color = theme.Border, Thickness = 1, Transparency = 0.35})

        b.MouseEnter:Connect(function()
            tween(b, 0.12, {BackgroundColor3 = theme.Surface3})
            tween(stroke, 0.12, {Transparency = 0.05})
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.12, {BackgroundColor3 = theme.Surface2})
            tween(stroke, 0.12, {Transparency = 0.35})
        end)
        b.MouseButton1Down:Connect(function()
            tween(b, 0.08, {Size = UDim2.new(1, -2, 0, 32)})
        end)
        b.MouseButton1Up:Connect(function()
            tween(b, 0.08, {Size = UDim2.new(1, 0, 0, 34)})
        end)
        b.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
        return b
    end

    function Elements:Toggle(parent, cfg)
        local state = cfg.Value == true

        local btn = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})

        mk("TextLabel", {
            Parent = btn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -52, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = iconTitle(cfg.Icon, cfg.Title or "Toggle"),
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })

        local rail = mk("Frame", {
            Parent = btn,
            Size = UDim2.new(0, 34, 0, 18),
            Position = UDim2.new(1, -42, 0.5, -9),
            BorderSizePixel = 0,
            BackgroundColor3 = state and theme.Accent or theme.Border,
        })
        mk("UICorner", {Parent = rail, CornerRadius = UDim.new(1, 0)})

        local knob = mk("Frame", {
            Parent = rail,
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        })
        mk("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

        local function sync(animated)
            local kPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            local rCol = state and theme.Accent or theme.Border
            if animated then
                tween(knob, 0.16, {Position = kPos}, Enum.EasingStyle.Back)
                tween(rail, 0.16, {BackgroundColor3 = rCol})
            else
                knob.Position = kPos
                rail.BackgroundColor3 = rCol
            end
        end

        btn.MouseButton1Click:Connect(function()
            state = not state
            sync(true)
            if cfg.Callback then cfg.Callback(state) end
        end)

        sync(false)
        return {
            SetValue = function(v)
                state = v == true
                sync(true)
            end,
        }
    end

    function Elements:Slider(parent, cfg)
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min

        local holder = mk("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundTransparency = 1,
        })

        local label = mk("TextLabel", {
            Parent = holder,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = string.format("%s: %s", iconTitle(cfg.Icon, cfg.Title or "Slider"), tostring(value)),
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })

        local bar = mk("Frame", {
            Parent = holder,
            Position = UDim2.new(0, 0, 0, 26),
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 8)})

        local fill = mk("Frame", {
            Parent = bar,
            Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = fill, CornerRadius = UDim.new(0, 8)})

        local knob = mk("Frame", {
            Parent = bar,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(fill.Size.X.Scale, -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

        local dragging = false
        local function setFromX(x)
            local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            value = math.floor(min + (max - min) * p + 0.5)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -6, 0.5, -6)
            label.Text = string.format("%s: %s", iconTitle(cfg.Icon, cfg.Title or "Slider"), tostring(value))
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
        UIS.InputChanged:Connect(function(i)
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
        Size = cfg.Size or UDim2.fromOffset(680, 460),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = main, CornerRadius = UDim.new(0, 14)})
    mk("UIStroke", {Parent = main, Color = Theme.Border, Thickness = 1, Transparency = 0.2})

    local top = mk("Frame", {
        Parent = main,
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = top, CornerRadius = UDim.new(0, 14)})

    mk("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = iconTitle(Icons.bolt, cfg.Title or "Foxname UI"),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    })

    local hideBtn = mk("TextButton", {
        Parent = top,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -66, 0.5, -12),
        BackgroundColor3 = Theme.Surface2,
        Text = Icons.hide,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    })
    mk("UICorner", {Parent = hideBtn, CornerRadius = UDim.new(0, 8)})

    local closeBtn = mk("TextButton", {
        Parent = top,
        Size = UDim2.new(0, 28, 0, 24),
        Position = UDim2.new(1, -34, 0.5, -12),
        BackgroundColor3 = Theme.Danger,
        Text = Icons.close,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    })
    mk("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 8)})

    local openBtn = mk("TextButton", {
        Parent = gui,
        Size = UDim2.fromOffset(44, 44),
        Position = UDim2.new(0, 20, 0.5, -22),
        BackgroundColor3 = Theme.Accent,
        Text = Icons.menu,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Visible = false,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    })
    mk("UICorner", {Parent = openBtn, CornerRadius = UDim.new(1, 0)})

    local tabButtons = mk("Frame", {
        Parent = main,
        Size = UDim2.new(0, 168, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    })
    local btnList = mk("UIListLayout", {Parent = tabButtons, Padding = UDim.new(0, 7)})
    btnList.SortOrder = Enum.SortOrder.LayoutOrder
    mk("UIPadding", {Parent = tabButtons, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local contentArea = mk("Frame", {
        Parent = main,
        Position = UDim2.new(0, 168, 0, 46),
        Size = UDim2.new(1, -168, 1, -46),
        BackgroundTransparency = 1,
    })

    local dragging = false
    local dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    hideBtn.MouseButton1Click:Connect(function()
        tween(main, 0.18, {Size = UDim2.fromOffset(main.AbsoluteSize.X, 0), BackgroundTransparency = 0.15})
        task.wait(0.18)
        main.Visible = false
        openBtn.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        main.Size = UDim2.fromOffset(cfg.Size and cfg.Size.X.Offset or 680, 0)
        tween(main, 0.18, {Size = cfg.Size or UDim2.fromOffset(680, 460), BackgroundTransparency = 0})
        openBtn.Visible = false
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tween(main, 0.14, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.2})
        task.wait(0.14)
        gui:Destroy()
    end)

    local elements = CreateElements(Theme)
    local tabs = {}
    local currentTab

    local function show(tab)
        if currentTab then
            currentTab.Container.Visible = false
            tween(currentTab.Button, 0.12, {BackgroundColor3 = Theme.Surface2})
        end
        currentTab = tab
        tab.Container.Visible = true
        tab.Container.CanvasPosition = Vector2.new(0, 0)
        tween(tab.Button, 0.12, {BackgroundColor3 = Theme.Accent})
    end

    local windowApi = {}
    function windowApi:Tab(name, icon)
        local btn = mk("TextButton", {
            Parent = tabButtons,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Text = iconTitle(icon, name),
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 9)})

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
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
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

    function windowApi:Hide()
        main.Visible = false
        openBtn.Visible = true
    end

    function windowApi:Show()
        main.Visible = true
        openBtn.Visible = false
    end

    function windowApi:Destroy()
        gui:Destroy()
    end

    return windowApi
end

FoxnameUI.Theme = Theme
FoxnameUI.Icons = Icons
FoxnameUI.LucideMap = LucideMap
return FoxnameUI
