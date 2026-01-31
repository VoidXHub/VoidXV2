local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, text, options, callback)
    local self = setmetatable({}, Dropdown)
    self.Options = options or {}
    self.Callback = callback
    self.Selected = self.Options[1] or "None"
    self.Open = false
    
    local Frame = Utility:Create("Frame", {
        Name = text .. "Dropdown",
        Size = UDim2.new(1, 0, 0, 45), -- Expanded height handled by Open logic
        BackgroundColor3 = Theme.ContentBg,
        BackgroundTransparency = 0.5,
        Parent = parent,
        ZIndex = 5 -- Dropdowns need higher ZIndex
    })
    
    Utility:Corner(Frame, UDim.new(0, 8))
    local Stroke = Utility:Stroke(Frame, Theme.Outline, 1, 0.5)
    
    -- Main Button (Click to open)
    local Button = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Text = "",
        Parent = Frame
    })
    
    Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 15, 0, 5),
        TextColor3 = Theme.TextGray,
        Font = Theme.FontBody,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    local ValueLabel = Utility:Create("TextLabel", {
        Text = self.Selected,
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 15, 0, 22),
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBody,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    local Arrow = Utility:Create("ImageLabel", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -25, 0.5, -7),
        Image = "rbxassetid://6031091004",
        ImageColor3 = Theme.TextGray,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    -- Container handling
    local OptionContainer = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.AccentStart,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Frame,
        Visible = false
    })
    
    local List = Utility:List(OptionContainer, 0)
    
    self.Frame = Frame
    self.OptionContainer = OptionContainer
    self.ValueLabel = ValueLabel
    self.Arrow = Arrow
    
    -- Render Options
    for _, opt in pairs(self.Options) do
        local OptBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.ContentBg,
            BackgroundTransparency = 0,
            Text = opt,
            TextColor3 = Theme.TextGray,
            Font = Theme.FontBody,
            TextSize = 13,
            Parent = OptionContainer
        })
        
        OptBtn.MouseButton1Click:Connect(function()
            self:Select(opt)
            self:Toggle()
        end)
    end
    
    Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

function Dropdown:Toggle()
    self.Open = not self.Open
    
    local optionCount = #self.Options
    local targetHeight = self.Open and math.min(optionCount * 30 + 50, 200) or 45
    -- Frame ZIndex needs to be high when open
    self.Frame.ZIndex = self.Open and 10 or 5
    
    Utility:Tween(self.Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetHeight)})
    Utility:Tween(self.Arrow, TweenInfo.new(0.3), {Rotation = self.Open and 180 or 0})
    self.OptionContainer.Visible = self.Open
end

function Dropdown:Select(val)
    self.Selected = val
    self.ValueLabel.Text = val
    if self.Callback then
        task.spawn(self.Callback, val)
    end
end

return Dropdown
