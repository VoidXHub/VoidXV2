local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Button = {}
Button.__index = Button

function Button.new(parent, text, callback)
    local self = setmetatable({}, Button)
    
    local Frame = Utility:Create("TextButton", {
        Name = text .. "Btn",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.ContentBg,
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    
    Utility:Corner(Frame, UDim.new(0, 8))
    local Stroke = Utility:Stroke(Frame, Theme.AccentStart, 1, 0.5)
    
    local Label = Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBody,
        TextSize = 14,
        BackgroundTransparency = 1,
        Parent = Frame
    })

    -- Hover Logic
    Frame.MouseEnter:Connect(function()
        Utility:Tween(Stroke, TweenInfo.new(0.2), {Transparency = 0.1, Color = Theme.AccentStart})
        Utility:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,40)})
    end)
    
    Frame.MouseLeave:Connect(function()
        Utility:Tween(Stroke, TweenInfo.new(0.2), {Transparency = 0.5, Color = Theme.AccentStart})
        Utility:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ContentBg})
    end)
    
    Frame.MouseButton1Click:Connect(function()
        Utility:Tween(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, -4, 0, 36)})
        task.wait(0.1)
        Utility:Tween(Frame, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 40)})
        
        if callback then
            task.spawn(callback)
        end
    end)
    
    return self
end

return Button
