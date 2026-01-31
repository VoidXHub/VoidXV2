local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Utility = {}

function Utility:Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

function Utility:Corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = instance
    return c
end

function Utility:Stroke(instance, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1,1,1)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

function Utility:List(instance, padding, align)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    if align then l.HorizontalAlignment = align end
    l.Parent = instance
    return l
end

function Utility:Padding(instance, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = instance
    return p
end

function Utility:Gradient(instance, props)
    local g = Instance.new("UIGradient")
    if props.Color then g.Color = ColorSequence.new(props.Color) else 
        -- Handle table of keypoints or simple colors if passed differently
        -- For now assume ColorSequenceKeypoints are passed in 'props' map logic if needed
        -- Simplified for this usage:
        g.Color = ColorSequence.new(props)
    end
    if props.Transparency then g.Transparency = NumberSequence.new(props.Transparency) end
    if props.Rotation then g.Rotation = props.Rotation end
    g.Parent = instance
    return g
end

function Utility:Tween(instance, tweenInfo, goals)
    local t = TweenService:Create(instance, tweenInfo, goals)
    t:Play()
    return t
end

function Utility:Drag(frame)
    local dragToggle = nil
    local dragSpeed = 0.1
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        -- TweenService:Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
        frame.Position = position -- Instant is better for some feels, or tween.
    end
    
    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if (input.UserInputState == Enum.UserInputState.End) then
                    dragToggle = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input == dragInput and dragToggle) then
            updateInput(input)
        end
    end)
end

return Utility
