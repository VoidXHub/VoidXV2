local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, text, options, callback)
    local self = setmetatable({}, Slider)
    
    local min = options.min or 0
    local max = options.max or 100
    local default = options.default or min
    
    self.Value = default
    self.Min = min
    self.Max = max
    self.Callback = callback
    
    local Frame = Utility:Create("Frame", {
        Name = text .. "Slider",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.ContentBg,
        BackgroundTransparency = 0.5,
        Parent = parent
    })
    Utility:Corner(Frame, UDim.new(0, 8))
    
    Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        TextColor3 = Theme.TextGray,
        Font = Theme.FontBody,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    local ValueLabel = Utility:Create("TextLabel", {
        Text = tostring(default),
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0, 5),
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBody,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    -- Slider Bar
    local BarBase = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(40,30,60),
        Parent = Frame
    })
    Utility:Corner(BarBase, UDim.new(1, 0))
    
    local Fill = Utility:Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.AccentStart,
        Parent = BarBase
    })
    Utility:Corner(Fill, UDim.new(1, 0))
    
    local Knob = Utility:Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -7, 0.5, -7),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent = Fill
    })
    Utility:Corner(Knob, UDim.new(1, 0))
    
    -- Logic
    local dragging = false
    
    local function Update(input)
        local pos = input.Position.X
        local start = BarBase.AbsolutePosition.X
        local width = BarBase.AbsoluteSize.X
        
        local percent = math.clamp((pos - start) / width, 0, 1)
        self.Value = math.floor((min + (max - min) * percent) * 100 + 0.5) / 100 -- 2 decimal places?
        -- Integer vs Float logic could be improved here based on options.precison
        
        ValueLabel.Text = tostring(self.Value)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        
        if self.Callback then
            task.spawn(self.Callback, self.Value)
        end
    end
    
    BarBase.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return self
end

return Slider
