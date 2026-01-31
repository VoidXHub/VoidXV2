--[[
    VOIDX LIBRARY - TEST SCRIPT
    Run this with Rojo served to test the UI.
]]

local Library = require(script.Parent)

local Window = Library:CreateWindow({
    Name = "ThunderZ HUB",
    LoadingTitle = "Initializing...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ThunderZConfig",
        FileName = "Config"
    }
})

-- Tab: Home
local HomeTab = Window:CreateTab("Home", "rbxassetid://6031763426")
local MainSection = HomeTab:CreateSection("Main Features", "rbxassetid://6034299940")

MainSection:CreateToggle("Auto Farm", false, function(val)
    print("Auto Farm:", val)
end)

MainSection:CreateSlider("WalkSpeed", {min = 16, max = 100, default = 16}, function(val)
    print("Speed:", val)
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

MainSection:CreateDropdown("Select Weapon", {"Rifle", "Pistol", "Knife"}, function(val)
    print("Selected:", val)
end)

-- Tab: Visuals
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://6034509993")
local EspSection = VisualsTab:CreateSection("ESP Settings")

EspSection:CreateToggle("Enable ESP", true, function(val)
    print("ESP Toggled", val)
end)

EspSection:CreateColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(col)
    print("ESP Color Changed", col)
end)

-- Tab: Settings
local SettingsTab = Window:CreateTab("Settings", "rbxassetid://6031280882")
SettingsTab:CreateButton("Unload UI", function()
    Window.Gui:Destroy()
end)

print("UI Loaded!")
