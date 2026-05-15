local function CreateTabSystem(ctx)
    local mk = ctx.mk
    local theme = ctx.theme
    local elements = ctx.elements

    return function(window, contentArea)
        local tabButtons = mk("Frame", {
            Parent = window,
            Size = UDim2.new(0, 150, 1, -44),
            Position = UDim2.new(0, 0, 0, 44),
            BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0,
        })
        local list = mk("UIListLayout", {Parent = tabButtons, Padding = UDim.new(0, 6)})
        list.SortOrder = Enum.SortOrder.LayoutOrder
        mk("UIPadding", {Parent = tabButtons, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

        local tabs = {}
        local current

        local function show(tab)
            if current then current.Container.Visible = false end
            current = tab
            tab.Container.Visible = true
        end

        local api = {}
        function api:CreateTab(name)
            local btn = mk("TextButton", {
                Parent = tabButtons,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = theme.Surface2,
                BorderSizePixel = 0,
                Text = name,
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamSemibold,
                TextSize = 13,
            })
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
            mk("UIPadding", {Parent = container, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)})
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
            end)

            local tab = {Button = btn, Container = container}
            function tab:Button(cfg) return elements:Button(container, cfg) end
            function tab:Toggle(cfg) return elements:Toggle(container, cfg) end
            function tab:Slider(cfg) return elements:Slider(container, cfg) end

            btn.MouseButton1Click:Connect(function() show(tab) end)
            table.insert(tabs, tab)
            if #tabs == 1 then show(tab) end
            return tab
        end

        return api
    end
end

return CreateTabSystem
