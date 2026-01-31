local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)
local Section = require(script.Parent.Section)

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, icon)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Selected = false
    
    -- 1. Sidebar Button
    local Button = Utility:Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, -20, 0, 36),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.AccentStart,
        Text = "",
        AutoButtonColor = false,
        Parent = window.Tabs.Container -- Assuming Window passes the container
    })
    
    Utility:Corner(Button, UDim.new(0, 8))
    
    -- Icon
    local IconLabel
    if icon then
        IconLabel = Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            Image = icon,
            ImageColor3 = Theme.TextGray,
            BackgroundTransparency = 1,
            Parent = Button
        })
    end
    
    -- Text
    local TextLabel = Utility:Create("TextLabel", {
        Text = name,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        Font = Theme.FontBody,
        TextSize = 14,
        TextColor3 = Theme.TextGray,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Button
    })
    
    -- 2. Content Page
    local Page = Utility:Create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false, -- Hidden by default
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentStart,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = window.Content -- Assuming Window passes ContentArea
    })
    
    Utility:List(Page, 10)
    Utility:Padding(Page, 0, 10, 0, 0)
    
    self.Button = Button
    self.Page = Page
    self.Icon = IconLabel
    self.Label = TextLabel
    
    -- Click Event
    Button.MouseButton1Click:Connect(function()
        self:Select()
    end)
    
    return self
end

function Tab:Select()
    -- Deselect all others
    for _, tab in pairs(self.Window.Tabs.List) do
        tab:Deselect()
    end
    
    self.Selected = true
    self.Page.Visible = true
    
    -- Visual Update
    Utility:Tween(self.Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.85})
    Utility:Tween(self.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextWhite})
    if self.Icon then
        Utility:Tween(self.Icon, TweenInfo.new(0.2), {ImageColor3 = Theme.TextWhite})
    end
end

function Tab:Deselect()
    self.Selected = false
    self.Page.Visible = false
    
    -- Visual Reset
    Utility:Tween(self.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    Utility:Tween(self.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextGray})
    if self.Icon then
        Utility:Tween(self.Icon, TweenInfo.new(0.2), {ImageColor3 = Theme.TextGray})
    end
end

-- Child Component Methods
function Tab:CreateSection(text, icon)
    return Section.new(self.Page, text, icon)
end

function Tab:CreateButton(text, callback)
    local ButtonModule = require(script.Parent.Button)
    return ButtonModule.new(self.Page, text, callback)
end

function Tab:CreateToggle(text, default, callback)
    local ToggleModule = require(script.Parent.Toggle)
    return ToggleModule.new(self.Page, text, default, callback)
end

function Tab:CreateSlider(text, options, callback)
    local SliderModule = require(script.Parent.Slider)
    return SliderModule.new(self.Page, text, options, callback)
end

function Tab:CreateDropdown(text, options, callback)
    local DropdownModule = require(script.Parent.Dropdown)
    return DropdownModule.new(self.Page, text, options, callback)
end

function Tab:CreateTextbox(text, placeholder, callback)
    local TextboxModule = require(script.Parent.Textbox)
    return TextboxModule.new(self.Page, text, placeholder, callback)
end

function Tab:CreateColorPicker(text, default, callback)
    local ColorPickerModule = require(script.Parent.ColorPicker)
    return ColorPickerModule.new(self.Page, text, default, callback)
end

return Tab
