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
local NotifyHost = nil

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
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 10, 0, iconPosY or 10),
        Image = img,
        ImageRectSize = meta.ImageRectSize,
        ImageRectOffset = meta.ImageRectPosition,
        ImageColor3 = color or Theme.Text,
    })

    local label = target:FindFirstChild("FxLabel")
    if label and label:IsA("TextLabel") then
        label.Position = UDim2.new(0, labelX or 32, label.Position.Y.Scale, label.Position.Y.Offset)
    end
    return icon ~= nil
end

local function CreateElements(theme)
    local Elements = {}
    local activeKeybindCapture = nil
    local function addDesc(parent, text, top, iconOffset)
        if type(text) ~= "string" or text == "" then return 0 end
        local y = top or 28
        mk("TextLabel", {
            Parent = parent, BackgroundTransparency = 1,
            Position = UDim2.new(0, iconOffset or 10, 0, y),
            Size = UDim2.new(1, -(iconOffset or 10) - 8, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = text,
            TextColor3 = theme.MutedText,
            Font = Enum.Font.Gotham,
            TextSize = 12,
        })
        return 16
    end

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
        local hasDesc = (cfg.Description and cfg.Description ~= "")
        local cardH = hasDesc and 66 or 40
        local b = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, cardH),
            BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        })
        mk("UICorner", {Parent = b, CornerRadius = UDim.new(0, 10)})
        local stroke = mk("UIStroke", {Parent = b, Color = theme.Border, Thickness = 1, Transparency = 0.35})

        local titleY = hasDesc and 10 or 0
        local titleH = hasDesc and 20 or cardH
        local label = mk("TextLabel", {
            Parent = b,
            Name = "FxLabel",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, cfg.Icon and 34 or 12, 0, titleY),
            Size = UDim2.new(1, -(cfg.Icon and 42 or 16), 0, titleH),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = cfg.Title or "Button",
            TextColor3 = theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 30/2,
        })
        -- Element-level icons disabled by design.
        if hasDesc then
            mk("TextLabel", {
                Parent = b, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 34),
                Size = UDim2.new(1, -16, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
                Text = cfg.Description, TextColor3 = theme.MutedText, Font = Enum.Font.GothamMedium, TextSize = 24/2,
            })
        end

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
        local hasDesc = (cfg.Description and cfg.Description ~= "")
        local cardH = hasDesc and 54 or 36
        local state = cfg.Value == true
        local btn = mk("TextButton", {
            Parent = parent, Size = UDim2.new(1, 0, 0, cardH), BackgroundColor3 = theme.Surface2,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})

        local titleY = hasDesc and 12 or 0
        local titleH = hasDesc and 16 or cardH
        mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, titleY),
            Size = UDim2.new(1, -52, 0, titleH), TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = cfg.Title or "Toggle", TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 32/2,
        })
        -- Element-level icons disabled by design.
        if hasDesc then
            mk("TextLabel", {
                Parent = btn, BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 30),
                Size = UDim2.new(1, -52, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
                Text = cfg.Description, TextColor3 = theme.MutedText, Font = Enum.Font.GothamMedium, TextSize = 24/2,
            })
        end

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
        local hasDesc = (cfg.Description and cfg.Description ~= "")
        local cardH = hasDesc and 68 or 52
        local holder = mk("Frame", {
            Parent = parent, Size = UDim2.new(1, 0, 0, cardH),
            BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = holder, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = holder, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        local hasIcon = false
        local titleY = hasDesc and 8 or 6
        local titleH = 18
        mk("TextLabel", {
            Parent = holder, Name = "FxLabel", BackgroundTransparency = 1,
            Position = UDim2.new(0, hasIcon and 34 or 8, 0, titleY),
            Size = UDim2.new(1, hasIcon and -44 or -20, 0, titleH),
            TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Title or "Input",
            TextYAlignment = Enum.TextYAlignment.Center,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 15,
        })
        -- Element-level icons disabled by design.
        addDesc(holder, cfg.Description, 28, hasIcon and 34 or 8)

        local box = mk("TextBox", {
            Parent = holder, Position = UDim2.new(0, 6, 0, hasDesc and 44 or 24), Size = UDim2.new(1, -12, 0, 22),
            BackgroundColor3 = theme.Surface3, BorderSizePixel = 0,
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

        local hasDesc = (cfg.Description and cfg.Description ~= "")
        local cardH = hasDesc and 64 or 50
        local holder = mk("Frame", {
            Parent = parent, Size = UDim2.new(1, 0, 0, cardH),
            BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
        })
        mk("UICorner", {Parent = holder, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = holder, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        local hasIcon = false
        local titleY = hasDesc and 8 or 6
        local titleH = 18
        local label = mk("TextLabel", {
            Parent = holder, Name = "FxLabel",
            Position = UDim2.new(0, hasIcon and 34 or 8, 0, titleY),
            Size = UDim2.new(1, hasIcon and -44 or -20, 0, titleH), BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left, Text = string.format("%s: %s", cfg.Title or "Slider", tostring(value)),
            TextYAlignment = Enum.TextYAlignment.Center,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 15,
            ZIndex = 3,
        })
        -- Element-level icons disabled by design.
        addDesc(holder, cfg.Description, 28, hasIcon and 34 or 8)

        local bar = mk("Frame", {
            Parent = holder, Position = UDim2.new(0, 6, 0, hasDesc and 44 or 24), Size = UDim2.new(1, -12, 0, 14),
            BackgroundColor3 = theme.Surface3, BorderSizePixel = 0,
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
            Parent = bar, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
            ZIndex = 3,
        })
        mk("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})
        mk("UIStroke", {Parent = knob, Color = Color3.fromRGB(18, 20, 28), Thickness = 1.2, Transparency = 0.15})

        local dragging = false
        local function setFromX(x)
            local p = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            value = math.floor(min + (max - min) * p + 0.5)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -8, 0.5, -8)
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
        local rowHeight = 30
        local headerHeight = 36
        local expanded = false

        local holder = mk("Frame", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, headerHeight),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
        })
        local btn = mk("TextButton", {
            Parent = holder, Size = UDim2.new(1, 0, 0, headerHeight), BackgroundColor3 = theme.Surface2, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = btn, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        local label = mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -36, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        })
        -- Element-level icons disabled by design.

        local arrow = mk("TextLabel", {
            Parent = btn, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -26, 0, 0),
            Text = "v", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.MutedText,
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        local panel = mk("Frame", {
            Parent = holder, Position = UDim2.new(0, 0, 0, headerHeight + 6), Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.Surface2, BorderSizePixel = 0, ClipsDescendants = true,
        })
        mk("UICorner", {Parent = panel, CornerRadius = UDim.new(0, 10)})
        mk("UIStroke", {Parent = panel, Color = theme.Border, Thickness = 1, Transparency = 0.25})
        mk("UIListLayout", {Parent = panel, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
        mk("UIPadding", {Parent = panel, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})

        local optionButtons = {}

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

        local function applyExpandState(animated)
            local count = #values
            local panelHeight = expanded and (count * rowHeight + math.max(count - 1, 0) * 4 + 12) or 0
            local holderHeight = headerHeight + (expanded and (6 + panelHeight) or 0)
            if animated then
                tween(panel, 0.16, {Size = UDim2.new(1, 0, 0, panelHeight)})
                tween(holder, 0.16, {Size = UDim2.new(1, 0, 0, holderHeight)})
            else
                panel.Size = UDim2.new(1, 0, 0, panelHeight)
                holder.Size = UDim2.new(1, 0, 0, holderHeight)
            end
            arrow.Text = expanded and "^" or "v"
        end

        local function rebuildOptions()
            for _, b in ipairs(optionButtons) do
                if b and b.Parent then b:Destroy() end
            end
            optionButtons = {}

            for _, v in ipairs(values) do
                local opt = mk("TextButton", {
                    Parent = panel, Size = UDim2.new(1, 0, 0, rowHeight), BackgroundColor3 = theme.Surface3, BorderSizePixel = 0,
                    Text = tostring(v), TextColor3 = theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false,
                })
                mk("UICorner", {Parent = opt, CornerRadius = UDim.new(0, 8)})
                table.insert(optionButtons, opt)

                opt.MouseButton1Click:Connect(function()
                    if multi then
                        selected[v] = not selected[v]
                        if cfg.Callback then cfg.Callback(selected) end
                    else
                        selected = v
                        if cfg.Callback then cfg.Callback(selected) end
                        expanded = false
                    end
                    updateLabel()
                    applyExpandState(true)
                end)
            end
        end

        if multi and type(cfg.Default) == "table" then
            for _, v in ipairs(cfg.Default) do selected[v] = true end
        end

        updateLabel()
        rebuildOptions()
        applyExpandState(false)

        btn.MouseButton1Click:Connect(function()
            if #values == 0 then return end
            expanded = not expanded
            applyExpandState(true)
        end)

        return {
            Refresh = function(newValues)
                values = newValues or {}
                if not multi then
                    selected = values[1] or ""
                end
                rebuildOptions()
                updateLabel()
                expanded = false
                applyExpandState(false)
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
            TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        })
        -- Element-level icons disabled by design.

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
    local gui = NotifyHost
    if not gui or not gui.Parent then
        gui = mk("ScreenGui", {Name = "FoxnameNotify", Parent = parent, ResetOnSpawn = false, IgnoreGuiInset = true})
        NotifyHost = gui
        local stack = mk("Frame", {
            Parent = gui, Name = "Stack", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 300, 1, -32), BackgroundTransparency = 1,
        })
        local layout = mk("UIListLayout", {Parent = stack, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    end
    local stack = gui:FindFirstChild("Stack")
    local wrap = mk("Frame", {
        Parent = stack, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(280, 70), LayoutOrder = os.clock() * 1000,
    })
    local card = mk("Frame", {
        Parent = wrap, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 360, 1, 0),
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
    local progressBg = mk("Frame", {
        Parent = card, Position = UDim2.new(0, 10, 1, -8), Size = UDim2.new(1, -20, 0, 3),
        BackgroundColor3 = Theme.Surface3, BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = progressBg, CornerRadius = UDim.new(1, 0)})
    local progress = mk("Frame", {
        Parent = progressBg, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0,
    })
    mk("UICorner", {Parent = progress, CornerRadius = UDim.new(1, 0)})
    -- Entry: right -> left
    tween(card, 0.48, {Position = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quart)
    local duration = cfg.Duration or 3
    tween(progress, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        -- Exit: left -> right
        tween(card, 0.48, {Position = UDim2.new(1, 360, 1, 0), BackgroundTransparency = 0.2}, Enum.EasingStyle.Quart)
        task.wait(0.5)
        if wrap and wrap.Parent then wrap:Destroy() end
    end)
end

function FoxnameUI:CreateWindow(cfg)
    cfg = cfg or {}
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = mk("ScreenGui", {Name = "FoxnameUI", Parent = parent, ResetOnSpawn = false, IgnoreGuiInset = true})

    local defaultSize = cfg.DefaultSize or cfg.Size or UDim2.fromOffset(680, 460)
    local minSize = cfg.MinSize or UDim2.fromOffset(520, 340)
    local maxSize = cfg.MaxSize or UDim2.fromOffset(980, 700)
    local main = mk("Frame", {
        Parent = gui, Size = defaultSize, Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
        ClipsDescendants = false,
    })
    mk("UICorner", {Parent = main, CornerRadius = UDim.new(0, 14)})
    mk("UIStroke", {Parent = main, Color = Theme.Border, Thickness = 1, Transparency = 0.2})

    local top = mk("Frame", {Parent = main, Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0})
    mk("UICorner", {Parent = top, CornerRadius = UDim.new(0, 14)})

    local titleLabel = mk("TextLabel", {
        Parent = top, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -120, 0, 24), TextXAlignment = Enum.TextXAlignment.Left, Text = cfg.Title or "Foxname UI",
        TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 18,
    })
    local authorText = mk("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Position = UDim2.new(0, 38, 0, 37),
        Size = UDim2.new(1, -130, 0, 16), TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, Text = tostring(cfg.Author or ""),
        TextColor3 = Theme.MutedText, Font = Enum.Font.Gotham, TextSize = 12,
    })
    authorText.Visible = (type(cfg.Author) == "string" and cfg.Author ~= "")
    attachIcon(top, (cfg.Icon or "zap"), Theme.Text, 14, 38)
    local topIcon = top:FindFirstChild("FxIcon")
    if topIcon and topIcon:IsA("ImageLabel") then
        topIcon.Size = UDim2.new(0, 20, 0, 20)
    end

    local hideBtn = mk("TextButton", {
        Parent = top, Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, -66, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = "-", TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0, AutoButtonColor = false,
    })
    mk("UICorner", {Parent = hideBtn, CornerRadius = UDim.new(0, 8)})
    local hideHover = mk("Frame", {
        Parent = hideBtn, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = hideBtn.ZIndex - 1,
    })
    mk("UICorner", {Parent = hideHover, CornerRadius = UDim.new(0, 8)})

    local closeBtn = mk("TextButton", {
        Parent = top, Size = UDim2.new(0, 28, 0, 24), Position = UDim2.new(1, -34, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1, Text = "X", TextColor3 = Color3.fromRGB(255, 110, 120),
        Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, AutoButtonColor = false,
    })
    mk("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 8)})
    local closeHover = mk("Frame", {
        Parent = closeBtn, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.92, BorderSizePixel = 0, ZIndex = closeBtn.ZIndex - 1,
    })
    mk("UICorner", {Parent = closeHover, CornerRadius = UDim.new(0, 8)})
    local function styleHeaderBtnHover(btn, textColor)
        local hoverLayer = btn:FindFirstChildOfClass("Frame")
        btn.MouseEnter:Connect(function()
            if hoverLayer then tween(hoverLayer, 0.12, {BackgroundTransparency = 0.78}) end
            tween(btn, 0.12, {TextColor3 = textColor})
        end)
        btn.MouseLeave:Connect(function()
            if hoverLayer then tween(hoverLayer, 0.12, {BackgroundTransparency = 0.92}) end
            tween(btn, 0.12, {TextColor3 = textColor})
        end)
    end
    styleHeaderBtnHover(hideBtn, Theme.Text)
    styleHeaderBtnHover(closeBtn, Color3.fromRGB(255, 110, 120))
    top:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local h = top.AbsoluteSize.Y
        local bh = math.clamp(math.floor(h * 0.42), 22, 26)
        local bw = math.clamp(math.floor(h * 0.48), 26, 32)
        hideBtn.Size = UDim2.fromOffset(bw, bh)
        closeBtn.Size = UDim2.fromOffset(bw, bh)
        hideBtn.Position = UDim2.new(1, -(bw * 2 + 10), 0.5, -math.floor(bh / 2))
        closeBtn.Position = UDim2.new(1, -(bw + 4), 0.5, -math.floor(bh / 2))
    end)

    local openCfg = cfg.OpenButton or {}
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local openVisible = not (openCfg.OnlyMobile == true and not isMobile)
    local openDefault = openCfg.DefaultSize or UDim2.fromOffset(44, 44)
    local openMin = openCfg.MinSize or UDim2.fromOffset(36, 30)
    local openMax = openCfg.MaxSize or UDim2.fromOffset(140, 60)
    local openW = math.clamp(openDefault.X.Offset, openMin.X.Offset, openMax.X.Offset)
    local openH = math.clamp(openDefault.Y.Offset, openMin.Y.Offset, openMax.Y.Offset)
    local openBtn = mk("TextButton", {
        Parent = gui, Size = UDim2.fromOffset(openW, openH), Position = UDim2.new(0, 20, 0.5, -22),
        BackgroundColor3 = Theme.Accent, Text = "=", TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 18, Visible = false, BorderSizePixel = 0, AutoButtonColor = false,
    })
    openBtn.Text = openCfg.Title or "Open"
    openBtn.Visible = false and openVisible
    local shape = tostring(openCfg.Shape or "Circle")
    local corner = mk("UICorner", {Parent = openBtn, CornerRadius = UDim.new(1, 0)})
    if shape == "Pill" then
        local s = openCfg.Size or UDim2.fromOffset(86, 34)
        openBtn.Size = UDim2.fromOffset(math.clamp(s.X.Offset, openMin.X.Offset, openMax.X.Offset), math.clamp(s.Y.Offset, openMin.Y.Offset, openMax.Y.Offset))
        corner.CornerRadius = UDim.new(0, 999)
    elseif shape == "Square" then
        local s = openCfg.Size or UDim2.fromOffset(40, 40)
        openBtn.Size = UDim2.fromOffset(math.clamp(s.X.Offset, openMin.X.Offset, openMax.X.Offset), math.clamp(s.Y.Offset, openMin.Y.Offset, openMax.Y.Offset))
        corner.CornerRadius = UDim.new(0, 10)
    else
        local s = openCfg.Size or UDim2.fromOffset(44, 44)
        openBtn.Size = UDim2.fromOffset(math.clamp(s.X.Offset, openMin.X.Offset, openMax.X.Offset), math.clamp(s.Y.Offset, openMin.Y.Offset, openMax.Y.Offset))
        corner.CornerRadius = UDim.new(1, 0)
    end
    local savedSize = defaultSize
    local savedPos = main.Position

    local tabButtons = mk("Frame", {
        Parent = main, Size = UDim2.new(0, 168, 1, -58), Position = UDim2.new(0, 0, 0, 58),
        BackgroundColor3 = Theme.Surface, BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    mk("UICorner", {Parent = tabButtons, CornerRadius = UDim.new(0, 14)})
    local btnList = mk("UIListLayout", {Parent = tabButtons, Padding = UDim.new(0, 7)})
    btnList.SortOrder = Enum.SortOrder.LayoutOrder
    mk("UIPadding", {Parent = tabButtons, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local contentArea = mk("Frame", {
        Parent = main, Position = UDim2.new(0, 168, 0, 58), Size = UDim2.new(1, -168, 1, -58), BackgroundTransparency = 1,
    })
    local resizeHandle = mk("Frame", {
        Parent = main, Name = "ResizeHandle", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 9, 1, 9),
        Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 60,
    })
    local resizeGlyph = mk("TextLabel", {
        Parent = resizeHandle, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        Text = ")", TextColor3 = Theme.Border, Font = Enum.Font.GothamBold, TextSize = 30,
        TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Bottom, ZIndex = 61,
    })
    resizeGlyph.Rotation = 32
    local dragBar = mk("Frame", {
        Parent = main, Name = "DragBar", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -6),
        Size = UDim2.fromOffset(90, 5), BackgroundColor3 = Theme.Surface3, BorderSizePixel = 0, ZIndex = 20,
    })
    mk("UICorner", {Parent = dragBar, CornerRadius = UDim.new(1, 0)})
    mk("UIStroke", {Parent = dragBar, Color = Theme.Border, Thickness = 1, Transparency = 0.35})

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
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    local resizing, resizeStart, resizeStartSize = false, nil, nil
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = main.Size
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local w = math.clamp(resizeStartSize.X.Offset + delta.X, minSize.X.Offset, maxSize.X.Offset)
            local h = math.clamp(resizeStartSize.Y.Offset + delta.Y, minSize.Y.Offset, maxSize.Y.Offset)
            main.Size = UDim2.fromOffset(w, h)
            savedSize = main.Size
        end
    end)

    hideBtn.MouseButton1Click:Connect(function()
        savedSize = main.Size
        savedPos = main.Position
        local miniSize = UDim2.fromOffset(math.max(220, savedSize.X.Offset - 120), math.max(160, savedSize.Y.Offset - 120))
        tween(main, 0.18, {Size = miniSize, BackgroundTransparency = 0.1}, Enum.EasingStyle.Quad)
        task.wait(0.18)
        main.Visible = false
        openBtn.Visible = openVisible
    end)

    openBtn.MouseButton1Click:Connect(function()
        local miniSize = UDim2.fromOffset(math.max(220, savedSize.X.Offset - 120), math.max(160, savedSize.Y.Offset - 120))
        main.Size = miniSize
        main.Position = savedPos
        main.BackgroundTransparency = 0.15
        main.Visible = true
        openBtn.Visible = false
        tween(main, 0.22, {Size = savedSize, Position = savedPos, BackgroundTransparency = 0}, Enum.EasingStyle.Back)
    end)
    if openCfg.Draggable ~= false then
        local oDrag, oStart, oPos = false, nil, nil
        openBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                oDrag = true; oStart = input.Position; oPos = openBtn.Position
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                oDrag = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if oDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - oStart
                openBtn.Position = UDim2.new(oPos.X.Scale, oPos.X.Offset + d.X, oPos.Y.Scale, oPos.Y.Offset + d.Y)
            end
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        local overlay = mk("Frame", {
            Parent = gui, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1000,
        })
        local confirm = mk("Frame", {
            Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(320, 150), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, ZIndex = 1001,
        })
        mk("UICorner", {Parent = confirm, CornerRadius = UDim.new(0, 12)})
        mk("UIStroke", {Parent = confirm, Color = Theme.Border, Thickness = 1, Transparency = 0.2})
        local confirmScale = mk("UIScale", {Parent = confirm, Scale = 0.85})
        mk("TextLabel", {
            Parent = confirm, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 12), Size = UDim2.new(1, -28, 0, 24),
            Text = "Are you sure?", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1002,
        })
        mk("TextLabel", {
            Parent = confirm, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 42), Size = UDim2.new(1, -28, 0, 34),
            Text = "This will destroy the UI and close all tabs.", TextWrapped = true,
            TextColor3 = Theme.MutedText, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 1002,
        })
        local yes = mk("TextButton", {
            Parent = confirm, Position = UDim2.new(0, 14, 1, -44), Size = UDim2.new(0.5, -20, 0, 30),
            BackgroundColor3 = Theme.Danger, BorderSizePixel = 0, Text = "Yes, Destroy",
            TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 1002,
        })
        mk("UICorner", {Parent = yes, CornerRadius = UDim.new(0, 8)})
        local no = mk("TextButton", {
            Parent = confirm, Position = UDim2.new(0.5, 6, 1, -44), Size = UDim2.new(0.5, -20, 0, 30),
            BackgroundColor3 = Theme.Surface3, BorderSizePixel = 0, Text = "Cancel",
            TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 1002,
        })
        mk("UICorner", {Parent = no, CornerRadius = UDim.new(0, 8)})
        tween(overlay, 0.14, {BackgroundTransparency = 0.45}, Enum.EasingStyle.Quad)
        tween(confirmScale, 0.18, {Scale = 1}, Enum.EasingStyle.Back)

        no.MouseButton1Click:Connect(function()
            tween(confirmScale, 0.12, {Scale = 0.9}, Enum.EasingStyle.Quad)
            tween(overlay, 0.12, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            task.wait(0.12)
            overlay:Destroy()
        end)
        yes.MouseButton1Click:Connect(function()
            tween(confirmScale, 0.1, {Scale = 0.9}, Enum.EasingStyle.Quad)
            tween(overlay, 0.1, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
            tween(main, 0.14, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 0.2})
            task.wait(0.14)
            gui:Destroy()
        end)
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
            BorderSizePixel = 0, Text = "", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold,
            TextSize = 13, AutoButtonColor = false,
        })
        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 9)})
        mk("TextLabel", {
            Parent = btn, Name = "FxLabel", BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
            Text = name, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
        })
        attachIcon(btn, icon, Theme.Text, 5, 36)

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

    function windowApi:Hide() savedSize = main.Size; savedPos = main.Position; main.Visible = false; openBtn.Visible = openVisible end
    function windowApi:Show() main.Position = savedPos; main.Size = savedSize; main.Visible = true; openBtn.Visible = false end
    function windowApi:Destroy() gui:Destroy() end

    return windowApi
end

FoxnameUI.Theme = Theme
FoxnameUI.IconProvider = IconsProvider
return FoxnameUI






