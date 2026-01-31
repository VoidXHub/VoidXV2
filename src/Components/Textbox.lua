local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(parent, text, placeholder, callback)
    local self = setmetatable({}, Textbox)
    self.Callback = callback
    
    local Frame = Utility:Create("Frame", {
        Name = text .. "Textbox",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.ContentBg,
        BackgroundTransparency = 0.5,
        Parent = parent
    })
    Utility:Corner(Frame, UDim.new(0, 8))
    
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
    
    local InputBox = Utility:Create("TextBox", {
        Text = "",
        PlaceholderText = placeholder or "Input...",
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 15, 0, 25), -- Below label
        BackgroundColor3 = Color3.fromRGB(30,25,40),
        TextColor3 = Theme.TextWhite,
        PlaceholderColor3 = Color3.fromRGB(100,100,120),
        Font = Theme.FontBody,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = Frame
    })
    Utility:Corner(InputBox, UDim.new(0, 6))
    local Stroke = Utility:Stroke(InputBox, Theme.Outline, 1, 0.5)
    Utility:Padding(InputBox, 10, 0, 0, 0)
    
    -- Focus Logic
    InputBox.Focused:Connect(function()
        Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Theme.AccentStart, Transparency = 0})
    end)
    
    InputBox.FocusLost:Connect(function(enterPressed)
        Utility:Tween(Stroke, TweenInfo.new(0.2), {Color = Theme.Outline, Transparency = 0.5})
        if self.Callback then
            task.spawn(self.Callback, InputBox.Text, enterPressed)
        end
    end)
    
    self.Frame = Frame
    self.Input = InputBox
    
    return self
end

return Textbox
