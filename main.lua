local FoxnameUI = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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

local function mk(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        i[k] = v
    end
    return i
end

local function tween(obj, t, props, style, dir)
    if typeof(obj) ~= "Instance" then return nil end
    local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local ok, tw = pcall(function()
        return TweenService:Create(obj, ti, props)
    end)
    if ok and tw then tw:Play(); return tw end
    return nil
end

-- WindUI-like icon provider (lucide names)
local IconsProvider = nil
local ICONS_URL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"

do
    local ok, mod = pcall(function()
        local src = game.HttpGetAsync and game:HttpGetAsync(ICONS_URL) or HttpService:GetAsync(ICONS_URL)
        src = src:gsub("^\239\187\191", "")
        local fn = loadstring(src)
        return fn and fn()
    end)
    if ok and mod then
        IconsProvider = mod
        pcall(function() IconsProvider.SetIconsType("lucide") end)
    end
end

local function normalizeLucideName(icon)
    if type(icon) ~= "string" then return nil end
    icon = icon:lower():gsub("^%s+", ""):gsub("%s+$", "")
    icon = icon:gsub("https?://lucide%.dev/icons/", "")
    icon = icon:gsub("/$", "")
    return icon
end

local function getIconSprite(iconName)
    if not IconsProvider then return nil end
    local key = normalizeLucideName(iconName)
    if not key or key == "" then return nil end
    local ok, iconData = pcall(function()
        return IconsProvider.Icon2(key, "lucide")
    end)
    if ok and iconData and type(iconData) == "table" and iconData[1] and iconData[2] then
        return iconData[1], iconData[2]
    end
    return nil
end

local function attachIcon(target, iconName, color, iconPosY, labelX)
    local img, meta = getIconSprite(iconName)
    if not img then return false end

    local icon = mk("ImageLabel", {
        Parent = target,
        Name = "FxIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0, iconPosY or 10),
        Image = img,
        ImageRectSize = meta.ImageRectSize,
        ImageRectOffset = meta.ImageRectPosition,
        ImageColor3 = color or Theme.Text,
    })

    local label = target:FindFirstChild("FxLabel")
    if label and label:IsA("TextLabel") then
        label.Position = UDim2.new(0, labelX or 32, 0, 0)
        label.Size = UDim2.new(1, -42, label.Size.Y.Scale, label.Size.Y.Offset)
    end
    return icon ~= nil
end

local function CreateElements(theme)
    local Elements = {}
    local activeKeybindCapture = nil

    function Elements:Section(parent, cfg)
        local label = mk("TextLabel", {
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = cfg.Title or "Section",
            TextColor3 = theme.MutedText,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
        })
        return label
    end

    function Elements:Divider(parent)
        local line = mk("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = theme.Border,
            BorderSizePixel = 0,
        })
        return line
    end

    function Elements:Button(parent, cfg)
        local b = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = b, CornerRadius = UDim.new(0, 10)})
        local stroke = mk("UIStroke", {Parent = b, Color = theme.Border, Thickness = 1, Transparency = 0.35})

        local label = mk("TextLabel", {
            Parent = b,
            Name = "FxLabel",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = cfg.Title or "Button",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
        })

        attachIcon(b, cfg.Icon, theme.Text)

        b.MouseEnter:Connect(function()
            tween(b, 0.12, {BackgroundColor3 = theme.Surface3})
            tween(stroke, 0.12, {Transparency = 0.05})
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.12, {BackgroundColor3 = theme.Surface2})
            tween(stroke, 0.12, {Transparency = 0.35})
        end)
        b.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
        return b
    end

    function Elements:Toggle(parent, cfg)
        local state = cfg.Value == true
        local btn = mk("TextButton", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})

        mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Size = UDim2.new(1, -52, 1, 0),
            Position = UDim2.new(0, 12, 0, 0), TextXAlignment = Enum.TextXAlignment.Left,
            Text = cfg.Title or "Toggle", TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        })
        attachIcon(btn, cfg.Icon, theme.Text)

        local rail = mk("Frame", {
            Parent = btn, Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -42, 0.5, -9), BorderSizePixel = 0,
            BackgroundColor3 = state and theme.Accent or theme.Border,
        })
        mk("UICorner", {Parent = rail, CornerRadius = UDim.new(1, 0)})
        local knob = mk("Frame", {
            Parent = rail, Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
            BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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
        return {SetValue = function(v) state = v == true; sync(true) end}
    end

    function Elements:Input(parent, cfg)
        local holder = mk("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1})
        local hasIcon = cfg.Icon ~= nil and cfg.Icon ~= ""
        mk("TextLabel", {
            Parent = holder, Name = "FxLabel", BackgroundTransparency = 1,
            Position = UDim2.new(0, hasIcon and 30 or 0, 0, 0),
            Size = UDim2.new(1, hasIcon and -30 or 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Title or "Input",
            TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        })
        if hasIcon then attachIcon(holder, cfg.Icon, theme.Text, 1, 30) end

        local box = mk("TextBox", {
            Parent = holder, Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
            PlaceholderText = cfg.Placeholder or "Type here...",
            Text = cfg.Default or "", ClearTextOnFocus = false,
            TextColor3 = theme.Text, PlaceholderColor3 = theme.MutedText,
            Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        })
        mk("UICorner", {Parent = box, CornerRadius = UDim.new(0, 9)})
        mk("UIPadding", {Parent = box, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        box.FocusLost:Connect(function(enterPressed)
            if cfg.Callback then cfg.Callback(box.Text, enterPressed) end
        end)
        return {SetValue = function(v) box.Text = tostring(v or "") end, Object = box}
    end

    function Elements:Slider(parent, cfg)
        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min

        local holder = mk("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1})
        local hasIcon = cfg.Icon ~= nil and cfg.Icon ~= ""
        local label = mk("TextLabel", {
            Parent = holder, Name = "FxLabel",
            Position = UDim2.new(0, hasIcon and 30 or 0, 0, 0),
            Size = UDim2.new(1, hasIcon and -30 or 0, 0, 18), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, Text = string.format("%s: %s", cfg.Title or "Slider", tostring(value)),
            TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
            ZIndex = 3,
        })
        if hasIcon then
            attachIcon(holder, cfg.Icon, theme.Text, 1, 30)
        end

        local bar = mk("Frame", {
            Parent = holder, Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 16),
            BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
            ZIndex = 1,
        })
        mk("UICorner", {Parent = bar, CornerRadius = UDim.new(0, 8)})
        local fill = mk("Frame", {
            Parent = bar, Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = theme.Accent, BorderSizePixel = 0,
            ZIndex = 2,
        })
        mk("UICorner", {Parent = fill, CornerRadius = UDim.new(0, 8)})
        local knob = mk("Frame", {
            Parent = bar, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(fill.Size.X.Scale, -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
            ZIndex = 3,
        })
        mk("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

        local dragging = false
        local function setFromX(x)
            local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            value = math.floor(min + (max - min) * p + 0.5)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -6, 0.5, -6)
            label.Text = string.format("%s: %s", cfg.Title or "Slider", tostring(value))
            if cfg.Callback then cfg.Callback(value) end
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; setFromX(i.Position.X) end
        end)
        bar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end
        end)
        return holder
    end

    function Elements:Dropdown(parent, cfg)
        local values = cfg.Values or {}
        local multi = cfg.Multi == true
        local selected = multi and {} or (cfg.Default or values[1] or "")

        local holder = mk("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1})
        local btn = mk("TextButton", {
            Parent = holder, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        local label = mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        })
        attachIcon(btn, cfg.Icon, theme.Text)

        local index = 1
        local function updateLabel()
            if multi then
                local count = 0
                local first = nil
                for k, v in pairs(selected) do
                    if v then count = count + 1; first = first or k end
                end
                if count == 0 then
                    label.Text = string.format("%s: None", cfg.Title or "Dropdown")
                elseif count == 1 then
                    label.Text = string.format("%s: %s", cfg.Title or "Dropdown", first)
                else
                    label.Text = string.format("%s: %d selected", cfg.Title or "Dropdown", count)
                end
            else
                label.Text = string.format("%s: %s", cfg.Title or "Dropdown", tostring(selected))
            end
        end

        if multi and type(cfg.Default) == "table" then
            for _, v in ipairs(cfg.Default) do selected[v] = true end
        elseif not multi then
            for i, v in ipairs(values) do
                if v == selected then index = i break end
            end
        end
        updateLabel()

        btn.MouseButton1Click:Connect(function()
            if #values == 0 then return end
            if multi then
                local current = values[index]
                selected[current] = not selected[current]
                if cfg.Callback then cfg.Callback(selected) end
                index = (index % #values) + 1
            else
                index = (index % #values) + 1
                selected = values[index]
                if cfg.Callback then cfg.Callback(selected) end
            end
            updateLabel()
        end)

        return {
            Refresh = function(newValues)
                values = newValues or {}
                index = 1
                updateLabel()
            end
        }
    end

    function Elements:Keybind(parent, cfg)
        local key = tostring(cfg.Default or "G")
        local waiting = false

        local btn = mk("TextButton", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        local label = mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        })
        attachIcon(btn, cfg.Icon, theme.Text)

        local function syncText()
            label.Text = string.format("%s: [%s]", cfg.Title or "Keybind", waiting and "..." or key)
        end
        syncText()

        btn.MouseButton1Click:Connect(function()
            waiting = true
            activeKeybindCapture = true
            syncText()
        end)

        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode.Name
                waiting = false
                activeKeybindCapture = nil
                syncText()
                if cfg.Callback then cfg.Callback(key) end
                return
            end
            if not waiting and not activeKeybindCapture and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
                if cfg.Pressed then cfg.Pressed() end
            end
        end)
        return btn
    end

    return Elements
end

function FoxnameUI:Notify(cfg)
    cfg = cfg or {}
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = mk("ScreenGui", {Name = "FoxnameNotify", Parent = parent, ResetOnSpawn = false, IgnoreGuiInset = true})
    local card = mk("Frame", {
        Parent = gui, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(280, 70), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = card, CornerRadius = UDim.new(0, 12)})
    mk("UIStroke", {Parent = card, Color = Theme.Border, Thickness = 1, Transparency = 0.2})
    mk("TextLabel", {
        Parent = card, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 20),
        Text = cfg.Title or "Notification", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    mk("TextLabel", {
        Parent = card, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 32),
        Text = cfg.Content or "...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.MutedText,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    })
    card.Position = UDim2.new(1, 320, 0, 16)
    tween(card, 0.2, {Position = UDim2.new(1, -16, 0, 16)})
    task.delay(cfg.Duration or 3, function()
        tween(card, 0.2, {Position = UDim2.new(1, 320, 0, 16)})
        task.wait(0.22)
        gui:Destroy()
    end)
end

function FoxnameUI:CreateWindow(cfg)
    cfg = cfg or {}
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = mk("ScreenGui", {Name = "FoxnameUI", Parent = parent, ResetOnSpawn = false, IgnoreGuiInset = true})

    local main = mk("Frame", {
        Parent = gui, Size = cfg.Size or UDim2.fromOffset(680, 460), Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    mk("UICorner", {Parent = main, CornerRadius = UDim.new(0, 14)})
    mk("UIStroke", {Parent = main, Color = Theme.Border, Thickness = 1, Transparency = 0.2})

    local top = mk("Frame", {Parent = main, Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0})
    mk("UICorner", {Parent = top, CornerRadius = UDim.new(0, 14)})

    local titleLabel = mk("TextLabel", {
        Parent = top, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -120, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Title or "Foxname UI",
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14,
    })
    attachIcon(top, (cfg.Icon or "zap"), Theme.Text)

    local hideBtn = mk("TextButton", {
        Parent = top, Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, -66, 0.5, -12),
        BackgroundColor3 = Theme.Surface2, Text = "-", TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0, AutoButtonColor = false,
    })
    mk("UICorner", {Parent = hideBtn, CornerRadius = UDim.new(0, 8)})

    local closeBtn = mk("TextButton", {
        Parent = top, Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, -34, 0.5, -12),
        BackgroundColor3 = Theme.Danger, Text = "X", TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false,
    })
    mk("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 8)})

    local openBtn = mk("TextButton", {
        Parent = gui, Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 20, 0.5, -22),
        BackgroundColor3 = Theme.Accent, Text = "=", TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 18, Visible = false, BorderSizePixel = 0, AutoButtonColor = false,
    })
    mk("UICorner", {Parent = openBtn, CornerRadius = UDim.new(1, 0)})

    local tabButtons = mk("Frame", {
        Parent = main, Size = UDim2.new(0, 168, 1, -46), Position = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    local btnList = mk("UIListLayout", {Parent = tabButtons, Padding = UDim.new(0, 7)})
    btnList.SortOrder = Enum.SortOrder.LayoutOrder
    mk("UIPadding", {Parent = tabButtons, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local contentArea = mk("Frame", {
        Parent = main, Position = UDim2.new(0, 168, 0, 46), Size = UDim2.new(1, -168, 1, -46), BackgroundTransparency = 1,
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    hideBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        openBtn.Visible = true
    end)

    openBtn.MouseButton1Click:Connect(function()
        main.Size = cfg.Size or UDim2.fromOffset(680, 460)
        main.Visible = true
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
        if not tab then return end
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
            Parent = tabButtons, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold,
            TextSize = 13, AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 9)})
        mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
            Text = name, TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13,
        })
        attachIcon(btn, icon, Theme.Text)

        local container = mk("ScrollingFrame", {
            Parent = contentArea, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
        })
        local layout = mk("UIListLayout", {Parent = container, Padding = UDim.new(0, 8)})
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        mk("UIPadding", {
            Parent = container,
            PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
        end)

        local tab = {Button = btn, Container = container}
        function tab:Button(c) return elements:Button(container, c) end
        function tab:Toggle(c) return elements:Toggle(container, c) end
        function tab:Slider(c) return elements:Slider(container, c) end
        function tab:Input(c) return elements:Input(container, c) end
        function tab:Dropdown(c) return elements:Dropdown(container, c) end
        function tab:Keybind(c) return elements:Keybind(container, c) end
        function tab:Section(c) return elements:Section(container, c or {}) end
        function tab:Divider() return elements:Divider(container) end

        btn.MouseButton1Click:Connect(function() show(tab) end)
        table.insert(tabs, tab)
        if #tabs == 1 then show(tab) end
        return tab
    end

    function windowApi:Hide() main.Visible = false; openBtn.Visible = true end
    function windowApi:Show() main.Visible = true; openBtn.Visible = false end
    function windowApi:Destroy() gui:Destroy() end

    return windowApi
end

FoxnameUI.Theme = Theme
FoxnameUI.IconProvider = IconsProvider
return FoxnameUI




