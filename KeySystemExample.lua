--[[
    VOIDX LIBRARY - KEY SYSTEM
    Validates key before loading main script
]]

local Config = {
    Keys = {"VOIDX-FREE-2024", "VOIDX-PREMIUM", "VOIDX-VIP"},
    KeyLink = "https://your-link.com",
    SaveKey = true,
    FileName = "VoidxKey.txt"
 }

local function Save(k) if Config.SaveKey then pcall(function() writefile(Config.FileName, k) end) end end
local function Load() if Config.SaveKey then local s,r = pcall(function() return readfile(Config.FileName) end) if s then return r end end return nil end
local function Valid(k) for _,v in ipairs(Config.Keys) do if k == v then return true end end return false end

local saved = Load()
if saved and Valid(saved) then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ijosephyusufk-dev/VoidXV2/main/ExampleScript.lua"))()
    return
end

local TS = game:GetService("TweenService")
local P = game:GetService("Players")
local CG = game:GetService("CoreGui")

local G = Instance.new("ScreenGui")
G.Name = "VoidxKey"
G.ResetOnSpawn = false
if syn then syn.protect_gui(G) G.Parent = CG elseif gethui then G.Parent = gethui() else G.Parent = P.LocalPlayer:WaitForChild("PlayerGui") end

local F = Instance.new("Frame")
F.Size = UDim2.new(0, 320, 0, 180)
F.Position = UDim2.new(0.5, -160, 0.5, -90)
F.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
F.BorderSizePixel = 0
F.Parent = G

local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 8) C.Parent = F
local S = Instance.new("UIStroke") S.Color = Color3.fromRGB(138, 43, 226) S.Thickness = 2 S.Parent = F

local T = Instance.new("TextLabel")
T.Size = UDim2.new(1, 0, 0, 40)
T.BackgroundTransparency = 1
T.Text = "VOIDX KEY SYSTEM"
T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.GothamBold
T.TextSize = 18
T.Parent = F

local IF = Instance.new("Frame")
IF.Size = UDim2.new(1, -30, 0, 35)
IF.Position = UDim2.new(0, 15, 0, 50)
IF.BackgroundColor3 = Color3.fromRGB(30, 26, 45)
IF.Parent = F
Instance.new("UICorner", IF).CornerRadius = UDim.new(0, 6)

local I = Instance.new("TextBox")
I.Size = UDim2.new(1, -15, 1, 0)
I.Position = UDim2.new(0, 8, 0, 0)
I.BackgroundTransparency = 1
I.PlaceholderText = "Enter key..."
I.Text = ""
I.TextColor3 = Color3.new(1, 1, 1)
I.Font = Enum.Font.Gotham
I.TextSize = 13
I.TextXAlignment = Enum.TextXAlignment.Left
I.Parent = IF

local SL = Instance.new("TextLabel")
SL.Size = UDim2.new(1, 0, 0, 15)
SL.Position = UDim2.new(0, 0, 0, 90)
SL.BackgroundTransparency = 1
SL.Text = ""
SL.TextColor3 = Color3.fromRGB(231, 76, 60)
SL.Font = Enum.Font.Gotham
SL.TextSize = 11
SL.Parent = F

local B1 = Instance.new("TextButton")
B1.Size = UDim2.new(0, 130, 0, 35)
B1.Position = UDim2.new(0, 15, 0, 115)
B1.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
B1.Text = "Submit"
B1.TextColor3 = Color3.new(1, 1, 1)
B1.Font = Enum.Font.GothamBold
B1.TextSize = 13
B1.Parent = F
Instance.new("UICorner", B1).CornerRadius = UDim.new(0, 6)

local B2 = Instance.new("TextButton")
B2.Size = UDim2.new(0, 130, 0, 35)
B2.Position = UDim2.new(1, -145, 0, 115)
B2.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
B2.Text = "Get Key"
B2.TextColor3 = Color3.new(1, 1, 1)
B2.Font = Enum.Font.GothamBold
B2.TextSize = 13
B2.Parent = F
Instance.new("UICorner", B2).CornerRadius = UDim.new(0, 6)

B1.MouseButton1Click:Connect(function()
    local k = I.Text
    if k == "" then SL.Text = "Enter a key!" SL.TextColor3 = Color3.fromRGB(241, 196, 15) return end
    if Valid(k) then
        SL.Text = "Valid! Loading..." SL.TextColor3 = Color3.fromRGB(46, 204, 113)
        Save(k)
        task.wait(0.3) G:Destroy()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ijosephyusufk-dev/VoidXV2/main/ExampleScript.lua"))()
    else
        SL.Text = "Invalid key!" SL.TextColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

B2.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(Config.KeyLink) end)
    SL.Text = "Link copied!" SL.TextColor3 = Color3.fromRGB(46, 204, 113)
end)
