--[[
    VOIDX LIBRARY - Main Module
    Version: 2.0
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

-- Modules
local Utility = require(script.Utility)
local Components = script.Components
local Themes = script.Themes

-- Theme System
Library.Theme = require(Themes.Default)

function Library:CreateWindow(config)
    config = config or {}
    
    local Window = {}
    Window.Name = config.Name or "Voidx Hub"
    Window.LoadingTitle = config.LoadingTitle or "Loading..."
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VoidxLib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    -- Protect GUI if possible (Synapse/ScriptWare/etc)
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local MainFrame = Utility:Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 750, 0, 480),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.MainBg,
        BorderSizePixel = 0,
        Parent = ScreenGui,
        ClipsDescendants = true
    })
    
    Utility:Corner(MainFrame, Library.Theme.Corner)
    Utility:Gradient(MainFrame, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 15, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 15)),
        Rotation = 90
    })
    Utility:Drag(MainFrame) -- Make Draggable
    
    -- Sidebar
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 220, 1, 0),
        BackgroundColor3 = Library.Theme.SidebarBg,
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    -- Content Area
    local ContentArea = Utility:Create("ScrollingFrame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -240, 1, -80),
        Position = UDim2.new(0, 240, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.AccentStart,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    Utility:List(ContentArea, 10)
    Utility:Padding(ContentArea, 10, 10, 10, 10)
    
    Window.Gui = ScreenGui
    Window.Main = MainFrame
    Window.Content = ContentArea
    Window.Tabs = {
        List = {},
        Container = Sidebar -- Pass container for buttons
    }
    
    -- Tab System
    function Window:CreateTab(name, icon)
        local TabModule = require(Components.Tab)
        local NewTab = TabModule.new(Window, name, icon)
        
        table.insert(Window.Tabs.List, NewTab)
        
        -- Select first tab by default
        if #Window.Tabs.List == 1 then
            NewTab:Select()
        end
        
        return NewTab
    end
    
    -- Notification Container
    local NotifContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = ScreenGui
    })
    Utility:List(NotifContainer, 8)
    
    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Content or ""
        local duration = config.Duration or 5
        local notifType = config.Type or "info"
        
        local typeColors = {
            info = Library.Theme.AccentStart or Color3.fromRGB(138, 43, 226),
            success = Color3.fromRGB(46, 204, 113),
            warning = Color3.fromRGB(241, 196, 15),
            error = Color3.fromRGB(231, 76, 60)
        }
        local accentColor = typeColors[notifType] or typeColors.info
        
        local notif = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Library.Theme.ContentBg or Color3.fromRGB(30, 25, 45),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = NotifContainer
        })
        Utility:Corner(notif, UDim.new(0, 8))
        Utility:Stroke(notif, accentColor, 1, 0.6)
        Utility:Padding(notif, 12, 12, 12, 12)
        
        -- Accent Bar
        Utility:Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            Parent = notif
        })
        
        -- Title
        Utility:Create("TextLabel", {
            Size = UDim2.new(1, -15, 0, 18),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Library.Theme.TextWhite or Color3.new(1,1,1),
            Font = Library.Theme.FontHeader or Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
        
        -- Message
        Utility:Create("TextLabel", {
            Size = UDim2.new(1, -15, 0, 0),
            Position = UDim2.new(0, 10, 0, 20),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = Library.Theme.TextMuted or Color3.fromRGB(180, 180, 180),
            Font = Library.Theme.FontBody or Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
        
        -- Animate in
        Utility:Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1})
        
        -- Auto-dismiss
        task.delay(duration, function()
            Utility:Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            task.wait(0.35)
            if notif and notif.Parent then
                notif:Destroy()
            end
        end)
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Library
