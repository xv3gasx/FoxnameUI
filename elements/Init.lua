local function CreateElements(ctx)
    local mk = ctx.mk
    local theme = ctx.theme

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
        local label = mk("TextLabel", {
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
        local fill = mk("Frame", {
            Parent = bar,
            Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
        })

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

return CreateElements
