--[[
    VoidxV2 - Real World Example
    
    This example demonstrates:
    - Key System with lifecycle events
    - State Management for feature toggles
    - Event hooks for tracking actions
    - Complete script structure
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ijosephyusufk-dev/VoidXV2/main/VoidLib.lua"))()

-- Enable debug mode for development
Library:SetDebug(true)

-- ═══════════════════════════════════════════════════════════════════════
-- KEY SYSTEM SETUP
-- ═══════════════════════════════════════════════════════════════════════
Library.KeySystem:AddKeys({
    "VOIDX-FREE-2024",
    "VOIDX-PREMIUM-VIP",
    "VOIDX-TRIAL-TEST"
})
Library.KeySystem:SetRateLimit(5, 60) -- 5 attempts, 60s cooldown

-- ═══════════════════════════════════════════════════════════════════════
-- EVENT LISTENERS
-- ═══════════════════════════════════════════════════════════════════════
Library:On("WindowCreated", function(window)
    print("[Event] Window created:", window.Name)
end)

Library:On("ThemeChanged", function(themeName)
    print("[Event] Theme changed to:", themeName)
end)

Library:On("StateChanged", function(key, newValue, oldValue)
    print("[Event] State:", key, "changed from", oldValue, "to", newValue)
end)

Library:On("KeyVerified", function(key)
    print("[Event] Key verified:", key)
end)

Library:On("KeyFailed", function(attemptsLeft)
    print("[Event] Key failed, attempts left:", attemptsLeft)
end)

-- ═══════════════════════════════════════════════════════════════════════
-- KEY VERIFICATION UI
-- ═══════════════════════════════════════════════════════════════════════
local function ShowKeyUI()
    local KeyWindow = Library:CreateWindow({
        Name = "VoidxV2 - Key System",
        LoadingEnabled = true
    })
    
    local KeyTab = KeyWindow:CreateTab("Key Verification")
    
    KeyTab:CreateParagraph("Welcome", "Please enter your key to access the hub.\nGet a key from our Discord server.")
    
    local keyInput = ""
    KeyTab:CreateInput("Enter Key", "VOIDX-XXXX-XXXX", function(text)
        keyInput = text
    end)
    
    KeyTab:CreateButton("Verify Key", function()
        local success, message = Library.KeySystem:Verify(keyInput, {
            OnChecking = function()
                KeyWindow:Notify("Checking", "Verifying your key...", 2)
            end,
            OnSuccess = function()
                KeyWindow:Notify("Success", "Key verified! Loading hub...", 2)
                task.wait(1)
                KeyWindow:Destroy()
                ShowMainUI()
            end,
            OnFailed = function(remaining)
                KeyWindow:Notify("Error", "Invalid key! " .. remaining .. " attempts left.", 3)
            end,
            OnRateLimited = function(seconds)
                KeyWindow:Notify("Warning", "Too many attempts! Wait " .. seconds .. "s", 5)
            end
        })
    end)
    
    KeyTab:CreateButton("Get Key (Discord)", function()
        setclipboard("https://discord.gg/voidxv2")
        KeyWindow:Notify("Copied", "Discord link copied to clipboard!", 2)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- MAIN UI (After Key Verification)
-- ═══════════════════════════════════════════════════════════════════════
local function ShowMainUI()
    local Window = Library:CreateWindow({
        Name = "VoidxV2 Hub - Example Game",
        LoadingEnabled = true
    })
    
    -- ═══════════════════════════════════════════════════
    -- MAIN TAB
    -- ═══════════════════════════════════════════════════
    local MainTab = Window:CreateTab("Main")
    
    MainTab:CreateSection("Auto Features")
    
    MainTab:CreateToggle("Auto Farm", false, function(state)
        if state then
            Window:Notify("Enabled", "Auto Farm started!", 2)
            -- Your auto farm logic here
        else
            Window:Notify("Disabled", "Auto Farm stopped!", 2)
        end
    end, "AutoFarm") -- State key for global access
    
    MainTab:CreateToggle("Auto Collect", false, function(state)
        -- Your auto collect logic
    end, "AutoCollect")
    
    MainTab:CreateSlider("Farm Speed", 1, 10, 5, function(value)
        Library.State:Set("FarmSpeed", value)
    end)
    
    MainTab:CreateSection("Actions")
    
    MainTab:CreateButton("Collect All", function()
        Window:Notify("Info", "Collecting all items...", 2)
        -- Your collect logic
    end)
    
    MainTab:CreateDropdown("Select Zone", {"Zone 1", "Zone 2", "Zone 3", "Boss Zone"}, function(selected)
        Library.State:Set("CurrentZone", selected)
        Window:Notify("Zone", "Switched to " .. selected, 2)
    end)
    
    -- ═══════════════════════════════════════════════════
    -- PLAYER TAB
    -- ═══════════════════════════════════════════════════
    local PlayerTab = Window:CreateTab("Player")
    
    PlayerTab:CreateSection("Movement")
    
    PlayerTab:CreateSlider("Walk Speed", 16, 200, 16, function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end)
    
    PlayerTab:CreateSlider("Jump Power", 50, 300, 50, function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end)
    
    PlayerTab:CreateToggle("Infinite Jump", false, function(state)
        Library.State:Set("InfJump", state)
    end, "InfJump")
    
    PlayerTab:CreateSection("Teleport")
    
    PlayerTab:CreateButton("Teleport to Spawn", function()
        -- Teleport logic
        Window:Notify("Teleport", "Teleported to spawn!", 2)
    end)
    
    -- ═══════════════════════════════════════════════════
    -- VISUALS TAB
    -- ═══════════════════════════════════════════════════
    local VisualsTab = Window:CreateTab("Visuals")
    
    VisualsTab:CreateSection("ESP")
    
    VisualsTab:CreateToggle("Player ESP", false, function(state)
        -- ESP logic
    end, "PlayerESP")
    
    VisualsTab:CreateColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
        Library.State:Set("ESPColor", color)
    end)
    
    VisualsTab:CreateToggle("Item ESP", false, function(state)
        -- Item ESP logic
    end, "ItemESP")
    
    -- ═══════════════════════════════════════════════════
    -- STATE WATCHER EXAMPLE
    -- ═══════════════════════════════════════════════════
    Library.State:Watch("AutoFarm", function(newValue, oldValue)
        if newValue then
            -- Start auto farm loop
            while Library.State:Get("AutoFarm") do
                local speed = Library.State:Get("FarmSpeed") or 5
                -- Farm action with speed
                task.wait(1 / speed)
            end
        end
    end)
    
    -- Show welcome notification
    Window:Notify("Welcome", "VoidxV2 Hub loaded successfully!", 5)
end

-- ═══════════════════════════════════════════════════════════════════════
-- START
-- ═══════════════════════════════════════════════════════════════════════
if Library.KeySystem:IsVerified() then
    ShowMainUI()
else
    ShowKeyUI()
end
