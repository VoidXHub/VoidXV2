local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, text, default, callback)
    local self = setmetatable({}, Toggle)
    self.State = default or false
    self.Callback = callback
    
    local Frame = Utility:Create("TextButton", {
        Name = text .. "Toggle",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.ContentBg,
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    
    Utility:Corner(Frame, UDim.new(0, 8))
    local Stroke = Utility:Stroke(Frame, Theme.Outline, 1, 0.5)
    
    Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBody,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    -- Switch UI
    local Switch = Utility:Create("Frame", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -55, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.State and Theme.AccentStart or Color3.fromRGB(50,50,60),
        Parent = Frame
    })
    Utility:Corner(Switch, UDim.new(1, 0))
    
    local Knob = Utility:Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = self.State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Color3.new(1,1,1),
        Parent = Switch
    })
    Utility:Corner(Knob, UDim.new(1, 0))
    
    -- Logic
    Frame.MouseButton1Click:Connect(function()
        self:Set(not self.State)
    end)
    
    self.Switch = Switch
    self.Knob = Knob
    self.Stroke = Stroke
    
    return self
end

function Toggle:Set(bool)
    self.State = bool
    
    -- Animate
    if bool then
        Utility:Tween(self.Switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentStart})
        Utility:Tween(self.Knob, TweenInfo.new(0.3, Enum.EasingStyle.Spring), {Position = UDim2.new(1, -20, 0.5, -9)})
        Utility:Tween(self.Stroke, TweenInfo.new(0.2), {Color = Theme.AccentStart, Transparency = 0.2})
    else
        Utility:Tween(self.Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,60)})
        Utility:Tween(self.Knob, TweenInfo.new(0.3, Enum.EasingStyle.Spring), {Position = UDim2.new(0, 2, 0.5, -9)})
        Utility:Tween(self.Stroke, TweenInfo.new(0.2), {Color = Theme.Outline, Transparency = 0.5})
    end
    
    if self.Callback then
        task.spawn(self.Callback, bool)
    end
end

return Toggle
