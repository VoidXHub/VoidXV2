local TweenService = game:GetService("TweenService")
local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local Section = {}
Section.__index = Section

function Section.new(parent, text, icon)
    local self = setmetatable({}, Section)
    
    -- Main Container (Accordion Header)
    local Container = Utility:Create("Frame", {
        Name = text,
        Size = UDim2.new(1, 0, 0, 45), -- Starts closed
        BackgroundTransparency = 1,
        Parent = parent,
        ClipsDescendants = true
    })
    
    local Button = Utility:Create("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Color3.fromRGB(30, 25, 45),
        Text = "",
        AutoButtonColor = false,
        Parent = Container,
        ZIndex = 2
    })
    
    Utility:Corner(Button, UDim.new(0, 10))
    local Stroke = Utility:Stroke(Button, Theme.AccentStart, 1, 0.6)
    
    local Gradient = Utility:Gradient(Button, {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.AccentStart),
            ColorSequenceKeypoint.new(1, Theme.AccentEnd)
        },
        Rotation = 90
    })
    
    -- Icon & Label
    if icon then
        Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 15, 0.5, -10),
            Image = icon,
            ImageColor3 = Theme.TextWhite,
            BackgroundTransparency = 1,
            Parent = Button
        })
    end
    
    Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        Font = Theme.FontBody,
        TextSize = 14,
        TextColor3 = Theme.TextWhite,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Button
    })
    
    -- Chevron
    local Arrow = Utility:Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -30, 0.5, -8),
        Image = "rbxassetid://6031091004",
        ImageColor3 = Theme.TextWhite,
        BackgroundTransparency = 1,
        Parent = Button
    })
    
    -- Content Container (Items go here)
    local Items = Utility:Create("Frame", {
        Name = "Items",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = Container
    })
    local List = Utility:List(Items, 5)
    
    -- State
    self.Open = false
    self.Container = Container
    self.Items = Items
    self.List = List
    self.Arrow = Arrow
    
    -- Logic
    Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

function Section:Toggle()
    self.Open = not self.Open
    
    local contentSize = self.List.AbsoluteContentSize.Y
    local targetHeight = self.Open and (contentSize + 60) or 45
    
    Utility:Tween(self.Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, targetHeight)})
    Utility:Tween(self.Arrow, TweenInfo.new(0.3), {Rotation = self.Open and 180 or 0})
end

-- Child Component Methods
function Section:CreateButton(text, callback)
    local ButtonModule = require(script.Parent.Button)
    return ButtonModule.new(self.Items, text, callback)
end

function Section:CreateToggle(text, default, callback)
    local ToggleModule = require(script.Parent.Toggle)
    return ToggleModule.new(self.Items, text, default, callback)
end

function Section:CreateSlider(text, options, callback)
    local SliderModule = require(script.Parent.Slider)
    return SliderModule.new(self.Items, text, options, callback)
end

function Section:CreateDropdown(text, options, callback)
    local DropdownModule = require(script.Parent.Dropdown)
    return DropdownModule.new(self.Items, text, options, callback)
end

function Section:CreateTextbox(text, placeholder, callback)
    local TextboxModule = require(script.Parent.Textbox)
    return TextboxModule.new(self.Items, text, placeholder, callback)
end

function Section:CreateColorPicker(text, default, callback)
    local ColorPickerModule = require(script.Parent.ColorPicker)
    return ColorPickerModule.new(self.Items, text, default, callback)
end

return Section
