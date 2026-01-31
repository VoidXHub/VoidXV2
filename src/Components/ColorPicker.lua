local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utility)
local Theme = require(script.Parent.Parent.Themes.Default)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent, text, default, callback)
    local self = setmetatable({}, ColorPicker)
    self.Color = default or Color3.new(1,1,1)
    self.Callback = callback
    self.Open = false
    
    local Frame = Utility:Create("Frame", {
        Name = text .. "ColorPicker",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.ContentBg,
        BackgroundTransparency = 0.5,
        Parent = parent,
        ClipsDescendants = true
    })
    Utility:Corner(Frame, UDim.new(0, 8))
    
    Utility:Create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -60, 0, 40),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = Theme.TextWhite,
        Font = Theme.FontBody,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    -- Color Preview / Toggle Button
    local Preview = Utility:Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -55, 0.5, -10),
        BackgroundColor3 = self.Color,
        Text = "",
        AutoButtonColor = false,
        Parent = Frame
    })
    Utility:Corner(Preview, UDim.new(0, 4))
    Utility:Stroke(Preview, Theme.TextWhite, 1, 0.8)
    
    -- Picker Container (Hidden)
    local PickerContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Parent = Frame
    })
    
    -- RGB Sliders Logic (Simplified for robustness)
    -- Creating a utility for tiny sliders inside picker
    local function CreateMiniSlider(name, yPos, colorComp, updateFunc)
        local SFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, yPos),
            BackgroundTransparency = 1,
            Parent = PickerContainer
        })
        
        local Bar = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0.5, -2),
            BackgroundColor3 = Color3.fromRGB(50,50,60),
            Parent = SFrame
        })
        Utility:Corner(Bar, UDim.new(1,0))
        
        local Fill = Utility:Create("Frame", {
            Size = UDim2.new(colorComp, 0, 1, 0), -- 0-1
            BackgroundColor3 = name == "R" and Color3.new(1,0,0) or (name == "G" and Color3.new(0,1,0) or Color3.new(0,0,1)),
            Parent = Bar
        })
        Utility:Corner(Fill, UDim.new(1,0))
        
        local CompBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = SFrame
        })
        
        -- Drag Logic
        local dragging = false
        CompBtn.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position.X
                local start = Bar.AbsolutePosition.X
                local width = Bar.AbsoluteSize.X
                local pct = math.clamp((pos - start) / width, 0, 1)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                updateFunc(pct)
            end
        end)
        
        -- Initial click update
         CompBtn.MouseButton1Down:Connect(function()
             local mouse = UserInputService:GetMouseLocation()
             -- Logic duplication, but quick fix
             local start = Bar.AbsolutePosition.X
             local width = Bar.AbsoluteSize.X
             local pct = math.clamp((mouse.X - start) / width, 0, 1)
             Fill.Size = UDim2.new(pct, 0, 1, 0)
             updateFunc(pct)
         end)
         
         return Fill -- Return fill to update later if needed
    end
    
    local r, g, b = self.Color.R, self.Color.G, self.Color.B
    
    CreateMiniSlider("R", 0, r, function(v) r = v; self:UpdateColor(r,g,b) end)
    CreateMiniSlider("G", 30, g, function(v) g = v; self:UpdateColor(r,g,b) end)
    CreateMiniSlider("B", 60, b, function(v) b = v; self:UpdateColor(r,g,b) end)

    self.Frame = Frame
    self.Preview = Preview
    
    Preview.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

function ColorPicker:UpdateColor(r, g, b)
    self.Color = Color3.new(r, g, b)
    self.Preview.BackgroundColor3 = self.Color
    if self.Callback then
        task.spawn(self.Callback, self.Color)
    end
end

function ColorPicker:Toggle()
    self.Open = not self.Open
    local targetHeight = self.Open and 150 or 40
    Utility:Tween(self.Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetHeight)})
end

return ColorPicker
