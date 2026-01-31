--[[
    VOIDX LIBRARY - DESIGN PREVIEW v12 (THUNDERZ REPLICA)
    Style: "Midnight Accordion" - Deep Purple/Blue Gradients, Accordion Lists, Integrated Sidebar.
    Reference: User Image (ThunderZ HUB).
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- --- THEME (THUNDERZ) ---
local Theme = {
    MainBg = Color3.fromRGB(15, 10, 25),      -- Very Dark Purple
    SidebarBg = Color3.fromRGB(12, 8, 20),
    ContentBg = Color3.fromRGB(20, 15, 30),
    AccentStart = Color3.fromRGB(80, 50, 200),-- Purple Gradient Start
    AccentEnd = Color3.fromRGB(20, 20, 80),   -- Dark Blue Gradient End
    TextWhite = Color3.fromRGB(255, 255, 255),
    TextGray = Color3.fromRGB(180, 180, 200),
    Glow = Color3.fromRGB(100, 80, 255),
    Corner = UDim.new(0, 12)
}

-- --- 1. CLEANUP ---
if PlayerGui:FindFirstChild("ThunderZPreview") then
    PlayerGui.ThunderZPreview:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ThunderZPreview"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- --- 2. MAIN WINDOW ---
local Root = Instance.new("Frame")
Root.Size = UDim2.new(0, 750, 0, 480)
Root.Position = UDim2.new(0.5, 0, 0.5, 0)
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.BackgroundTransparency = 1
Root.Parent = ScreenGui

-- Main Container with Gradient
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(1, 0, 1, 0)
Main.BackgroundColor3 = Theme.MainBg
Main.BorderSizePixel = 0
Main.Parent = Root

local MCorner = Instance.new("UICorner")
MCorner.CornerRadius = Theme.Corner
MCorner.Parent = Main

-- Subtle Background Gradient (Top to Bottom)
local MGrad = Instance.new("UIGradient")
MGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 15, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 15))
}
MGrad.Rotation = 90
MGrad.Parent = Main

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 80, 1, 80)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.new(0,0,0)
Shadow.ImageTransparency = 0.4
Shadow.ZIndex = -1
Shadow.Parent = Root

-- --- 3. SIDEBAR (Integrated Left) ---
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 220, 1, 0)
Sidebar.BackgroundColor3 = Theme.SidebarBg
Sidebar.BackgroundTransparency = 1 -- Merged with Main
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

-- Divider Line
local Div = Instance.new("Frame")
Div.Size = UDim2.new(0, 2, 1, -40)
Div.Position = UDim2.new(1, 0, 0, 20)
Div.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
Div.BorderSizePixel = 0
Div.Parent = Sidebar
local DGrad = Instance.new("UIGradient")
DGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.2, 0),
    NumberSequenceKeypoint.new(0.8, 0),
    NumberSequenceKeypoint.new(1, 1)
}
DGrad.Rotation = 90
DGrad.Parent = Div

-- Logo Area
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(1, 0, 0, 80)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = Sidebar

local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 32, 0, 32)
LogoIcon.Position = UDim2.new(0, 20, 0.5, -16)
LogoIcon.Image = "rbxassetid://6034299940" -- Lightning bolt mockup
LogoIcon.ImageColor3 = Color3.fromRGB(0, 150, 255) -- Cyan/Blue icon
LogoIcon.BackgroundTransparency = 1
LogoIcon.Parent = LogoFrame

local LogoText = Instance.new("TextLabel")
LogoText.Text = "ThunderZ <font color=\"rgb(130,100,255)\">HUB</font>"
LogoText.RichText = true
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 18
LogoText.TextColor3 = Theme.TextWhite
LogoText.Size = UDim2.new(1, -60, 0, 20)
LogoText.Position = UDim2.new(0, 60, 0.5, -10)
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.BackgroundTransparency = 1
LogoText.Parent = LogoFrame

local SubText = Instance.new("TextLabel")
SubText.Text = "[✨] Grow a Garden 🌶" -- Demo text from image
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 12
SubText.TextColor3 = Color3.fromRGB(150, 150, 150)
SubText.Size = UDim2.new(1, -60, 0, 15)
SubText.Position = UDim2.new(0, 60, 0.5, 10)
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.BackgroundTransparency = 1
SubText.Parent = LogoFrame


-- Sidebar Items
local TabHolder = Instance.new("ScrollingFrame")
TabHolder.Size = UDim2.new(1, 0, 1, -90)
TabHolder.Position = UDim2.new(0, 0, 0, 90)
TabHolder.BackgroundTransparency = 1
TabHolder.Parent = Sidebar
local TL = Instance.new("UIListLayout"); TL.Padding = UDim.new(0, 5); TL.Parent = TabHolder

-- --- 4. CONTENT & HEADER (RIGHT) ---
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -240, 1, -80)
Content.Position = UDim2.new(0, 240, 0, 70)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Theme.AccentStart
Content.Parent = Main
local CL = Instance.new("UIListLayout"); CL.Padding = UDim.new(0, 10); CL.Parent = Content
local CP = Instance.new("UIPadding"); CP.PaddingRight = UDim.new(0, 10); CP.Parent = Content

-- Header Icons (Right Top)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(0, 150, 0, 40)
Header.Position = UDim2.new(1, -10, 0, 10)
Header.AnchorPoint = Vector2.new(1, 0)
Header.BackgroundTransparency = 1
Header.Parent = Main
local HL = Instance.new("UIListLayout")
HL.FillDirection = Enum.FillDirection.Horizontal
HL.HorizontalAlignment = Enum.HorizontalAlignment.Right
HL.Padding = UDim.new(0, 10)
HL.Parent = Header

local function CreateHeaderIcon(id)
    local B = Instance.new("ImageButton")
    B.Size = UDim2.new(0, 24, 0, 24)
    B.BackgroundTransparency = 1
    B.Image = id
    B.ImageColor3 = Theme.TextGray
    B.Parent = Header
end
CreateHeaderIcon("rbxassetid://6031094678") -- X
CreateHeaderIcon("rbxassetid://6031094670") -- Maximize
CreateHeaderIcon("rbxassetid://6031094675") -- Minimize

-- --- COMPONENTS ---

local function CreateSidebarTab(name, icon, active)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.Position = UDim2.new(0, 10, 0, 0)
    Btn.BackgroundTransparency = active and 0.9 or 1
    Btn.BackgroundColor3 = Theme.AccentStart
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = TabHolder
    
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn
    
    local Ico = Instance.new("ImageLabel")
    Ico.Size = UDim2.new(0, 18, 0, 18)
    Ico.Position = UDim2.new(0, 10, 0.5, -9)
    Ico.BackgroundTransparency = 1
    Ico.Image = icon
    Ico.ImageColor3 = active and Theme.TextWhite or Theme.TextGray
    Ico.Parent = Btn
    
    local Txt = Instance.new("TextLabel")
    Txt.Text = name
    Txt.Size = UDim2.new(1, -40, 1, 0)
    Txt.Position = UDim2.new(0, 35, 0, 0)
    Txt.Font = Enum.Font.GothamMedium
    Txt.TextSize = 14
    Txt.TextColor3 = active and Theme.TextWhite or Theme.TextGray
    Txt.TextXAlignment = Enum.TextXAlignment.Left
    Txt.BackgroundTransparency = 1
    Txt.Parent = Btn
    
    -- Active Glow (Left Bar or full glow)
    if active then
         local G = Instance.new("ImageLabel")
         G.Size = UDim2.new(1.5, 0, 2, 0)
         G.Position = UDim2.new(0.5, 0, 0.5, 0)
         G.AnchorPoint = Vector2.new(0.5, 0.5)
         G.Image = "rbxassetid://6015897843"
         G.ImageColor3 = Theme.AccentStart
         G.ImageTransparency = 0.8
         G.BackgroundTransparency = 1
         G.Parent = Btn
    end
end

-- ACCORDION BUTTON (The Big Gradient Buttons)
local function CreateAccordion(text, icon)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 45) -- Expands later
    Frame.BackgroundTransparency = 1
    Frame.Parent = Content
    
    -- Main Button (Top)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.Parent = Frame
    
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = Btn
    
    -- Gradient
    local BG = Instance.new("UIGradient")
    BG.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.AccentStart),
        ColorSequenceKeypoint.new(1, Theme.AccentEnd)
    }
    BG.Parent = Btn
    
    -- Stroke
    local S = Instance.new("UIStroke")
    S.Color = Theme.AccentStart
    S.Transparency = 0.6
    S.Thickness = 1
    S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    S.Parent = Btn
    
    -- Icon & Text
    local Ico = Instance.new("ImageLabel")
    Ico.Size = UDim2.new(0, 20, 0, 20)
    Ico.Position = UDim2.new(0, 15, 0.5, -10)
    Ico.Image = icon
    Ico.BackgroundTransparency = 1
    Ico.ImageColor3 = Theme.TextWhite
    Ico.Parent = Btn
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Text = text
    Lbl.Size = UDim2.new(1, -80, 1, 0)
    Lbl.Position = UDim2.new(0, 50, 0, 0)
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.TextWhite
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.BackgroundTransparency = 1
    Lbl.Parent = Btn
    
    -- Arrow
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -30, 0.5, -8)
    Arrow.Image = "rbxassetid://6031091004" -- Chevron Down
    Arrow.ImageColor3 = Theme.TextWhite
    Arrow.BackgroundTransparency = 1
    Arrow.Parent = Btn
    
    -- Hover effect
    Btn.MouseEnter:Connect(function()
        TweenService:Create(S, TweenInfo.new(0.3), {Transparency = 0.2}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(S, TweenInfo.new(0.3), {Transparency = 0.6}):Play()
    end)
end

local function CreateSlider()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
    Frame.BackgroundTransparency = 0.5
    Frame.Parent = Content
    local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(0, 10); FC.Parent = Frame
    
    local Lbl = Instance.new("TextLabel")
    Lbl.Text = "10.00"
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 14
    Lbl.TextColor3 = Theme.TextGray
    Lbl.Position = UDim2.new(0, 15, 0.5, -7)
    Lbl.BackgroundTransparency = 1
    Lbl.Size = UDim2.new(0, 40, 0, 14)
    Lbl.Parent = Frame
    
    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -70, 0, 6)
    BarBg.Position = UDim2.new(0, 60, 0.5, -3)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    BarBg.Parent = Frame
    local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(1,0); BC.Parent = BarBg
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0.8, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(120, 80, 255) -- Purple Slider
    Fill.Parent = BarBg
    local FCC = Instance.new("UICorner"); FCC.CornerRadius = UDim.new(1,0); FCC.Parent = Fill
    
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(1, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.Parent = Fill
    local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = Knob
end


-- MOCKUP
CreateSidebarTab("Home", "rbxassetid://6031763426", false)
CreateSidebarTab("Automatics", "rbxassetid://6034509993", false)
CreateSidebarTab("Shop", "rbxassetid://6031265976", false)
CreateSidebarTab("Pet", "rbxassetid://6034299940", true) -- Active
CreateSidebarTab("Miscellaneous", "rbxassetid://6031280882", false)
CreateSidebarTab("Webhook", "rbxassetid://6031094678", false)

-- Content Area (Matching reference)
CreateSlider()
CreateAccordion("Feed Pet", "rbxassetid://6034299940") -- Bone icon mock
CreateAccordion("Boost Pet", "rbxassetid://6031265976") -- Up arrow mock
CreateAccordion("Favorite Inventory Pets", "rbxassetid://6031763426") -- Heart mock
CreateAccordion("Egg", "rbxassetid://6034509993") -- Egg mock
