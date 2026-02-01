--[[
    ██╗   ██╗ ██████╗ ██╗██████╗ ██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔═══██╗██║██╔══██╗╚██╗██╔╝██║   ██║╚════██╗
    ██║   ██║██║   ██║██║██║  ██║ ╚███╔╝ ██║   ██║ █████╔╝
    ╚██╗ ██╔╝██║   ██║██║██║  ██║ ██╔██╗ ╚██╗ ██╔╝██╔═══╝ 
     ╚████╔╝ ╚██████╔╝██║██████╔╝██╔╝ ██╗ ╚████╔╝ ███████╗
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
    
    Complete Example - All Components Demo
    Version: 2.1.0
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/VoidXHub/VoidXV2/refs/heads/main/VoidLib.lua"))()

--[[
═══════════════════════════════════════════════════════════════════════════════
                           LIBRARY CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════
]]

-- Enable debug mode (logs to console)
Library:SetDebug(true)

-- Show Library info
print("📚 Library Version:", Library:GetVersion())
print("👤 Author:", Library.Author)
print("🔗 GitHub:", Library.GitHub)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           EVENT SYSTEM SETUP
═══════════════════════════════════════════════════════════════════════════════
]]

-- Event listeners - Register before GUI creation
Library:On("WindowCreated", function(window)
    print("🪟 [Event] Window created:", window.Name)
end)

Library:On("StateChanged", function(key, newValue, oldValue)
    print("📊 [Event] State changed:", key, "=", newValue, "(was:", oldValue, ")")
end)

Library:On("ThemeChanged", function(themeName)
    print("🎨 [Event] Theme changed to:", themeName)
end)

Library:On("KeyVerified", function(key)
    print("🔑 [Event] Key verified!")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           KEY SYSTEM SETUP
═══════════════════════════════════════════════════════════════════════════════
]]

-- Valid key'leri ekle
Library.KeySystem:AddKeys({
    "VOIDX-FREE-2024",
    "VOIDX-VIP-PREMIUM",
    "DEMO-KEY-12345"
})

-- Rate limit ayarla (5 deneme, 60 saniye bekleme)
Library.KeySystem:SetRateLimit(5, 60)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           WINDOW CONFIG
═══════════════════════════════════════════════════════════════════════════════
]]

local Window = Library:CreateWindow({
    -- Gerekli
    Name = "VoidxV2 Complete Demo",
    
    -- Opsiyonel
    Subtitle = "Example Script • v2.1.0",  -- NEW! Subtitle feature
    LoadingEnabled = true,
    -- LoadingTitle = "Loading...",  -- Loading başlık (varsayılan: VoidxV2 HUB)
    -- LoadingSubtitle = "Please wait", -- Loading alt başlık
})

--[[
═══════════════════════════════════════════════════════════════════════════════
                           CUSTOM THEME OLUŞTURMA
═══════════════════════════════════════════════════════════════════════════════
]]

Library:CreateTheme("Neon", {
    Background = Color3.fromRGB(10, 10, 20),
    Sidebar = Color3.fromRGB(15, 15, 25),
    Card = Color3.fromRGB(20, 20, 35),
    CardHover = Color3.fromRGB(30, 30, 50),
    AccentPrimary = Color3.fromRGB(0, 255, 200),  -- Neon cyan
    AccentSecondary = Color3.fromRGB(0, 200, 150),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextMuted = Color3.fromRGB(100, 100, 100),
    Border = Color3.fromRGB(40, 40, 60),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
})

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 1: ALL COMPONENTS
═══════════════════════════════════════════════════════════════════════════════
]]

local ComponentsTab = Window:CreateTab("Components", "rbxassetid://7733960981")

-- ═══════════════════════════════════════
-- SECTION
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Buttons & Actions")

-- ═══════════════════════════════════════
-- BUTTON
-- ═══════════════════════════════════════
ComponentsTab:CreateButton("Simple Button", function()
    print("Button clicked!")
    Window:Notify("Click!", "Button was pressed", 2, "info")
end)

-- ═══════════════════════════════════════
-- TOGGLE (with State)
-- ═══════════════════════════════════════
local autoFarmToggle = ComponentsTab:CreateToggle("Auto Farm", false, function(state)
    print("AutoFarm:", state)
end, "AutoFarm") -- "AutoFarm" = State key

ComponentsTab:CreateToggle("God Mode", false, function(state)
    print("GodMode:", state)
end, "GodMode")

-- ═══════════════════════════════════════
-- SLIDER
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Sliders")

local speedSlider = ComponentsTab:CreateSlider("Walk Speed", 16, 200, 16, function(value)
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    print("Speed:", value)
end)

local jumpSlider = ComponentsTab:CreateSlider("Jump Power", 50, 500, 50, function(value)
    print("Jump:", value)
end)

-- Slider'ı programatik olarak ayarla
ComponentsTab:CreateButton("Set Speed to 100", function()
    speedSlider:Set(100)
    Window:Notify("Speed", "Walk speed set to 100!", 2, "success")
end)

-- ═══════════════════════════════════════
-- DROPDOWN
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Dropdowns")

local zoneDropdown = ComponentsTab:CreateDropdown("Select Zone", {
    "Spawn",
    "Zone 1",
    "Zone 2",
    "Zone 3",
    "Boss Area"
}, function(selected)
    print("Zone selected:", selected)
    Library.State:Set("CurrentZone", selected)
end)

-- Dropdown'ı güncelle
ComponentsTab:CreateButton("Refresh Zones", function()
    zoneDropdown:Refresh({
        "Spawn",
        "Zone 1", "Zone 2", "Zone 3", "Zone 4", "Zone 5",
        "Secret Zone",
        "Boss Area",
        "Final Boss"
    })
    Window:Notify("Updated", "9 zones available now!", 2, "success")
end)

-- ═══════════════════════════════════════
-- INPUT (Text Box)
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Text Input")

ComponentsTab:CreateInput("Username", "Enter username...", function(text)
    print("Input:", text)
    Library.State:Set("Username", text)
end)

ComponentsTab:CreateInput("Target Player", "Player name...", function(text)
    print("Target:", text)
end)

-- ═══════════════════════════════════════
-- KEYBIND
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Keybinds")

ComponentsTab:CreateKeybind("Toggle Farm", Enum.KeyCode.F, function()
    local current = autoFarmToggle:Get()
    autoFarmToggle:Set(not current)
    print("Farm toggled via keybind!")
end)

ComponentsTab:CreateKeybind("Speed Boost", Enum.KeyCode.G, function()
    speedSlider:Set(200)
    Window:Notify("BOOST!", "MAX SPEED!", 1, "warning")
end)

-- ═══════════════════════════════════════
-- COLORPICKER (HSV + RGB)
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Color Picker")

ComponentsTab:CreateColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color)
    print("Color:", color.R, color.G, color.B)
    Library.State:Set("ESPColor", color)
end)

ComponentsTab:CreateColorPicker("Highlight Color", Color3.fromRGB(0, 255, 0), function(color)
    print("Highlight:", color)
end)

-- ═══════════════════════════════════════
-- LABEL & PARAGRAPH
-- ═══════════════════════════════════════
ComponentsTab:CreateSection("Text Elements")

ComponentsTab:CreateLabel("This is a simple label")
ComponentsTab:CreateLabel("───────────────────")

ComponentsTab:CreateParagraph("Information", "This is a paragraph with a title and description. You can use it to display information or instructions to the user.")

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 2: NOTIFICATIONS
═══════════════════════════════════════════════════════════════════════════════
]]

local NotifyTab = Window:CreateTab("Notifications", "rbxassetid://7733715400")

NotifyTab:CreateSection("Notification Types")

NotifyTab:CreateButton("Info Notification", function()
    Window:Notify("Information", "This is an info notification", 3, "info")
end)

NotifyTab:CreateButton("Success Notification", function()
    Window:Notify("Success!", "Operation completed successfully", 3, "success")
end)

NotifyTab:CreateButton("Warning Notification", function()
    Window:Notify("Warning", "Be careful with this action!", 3, "warning")
end)

NotifyTab:CreateButton("Error Notification", function()
    Window:Notify("Error", "Something went wrong!", 3, "error")
end)

NotifyTab:CreateSection("Config Format")

NotifyTab:CreateButton("Config Table Format", function()
    Window:Notify({
        Title = "Config Format",
        Content = "You can also use a config table!",
        Duration = 5,
        Type = "info"
    })
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 3: STATE MANAGEMENT
═══════════════════════════════════════════════════════════════════════════════
]]

local StateTab = Window:CreateTab("State", "rbxassetid://7734053495")

StateTab:CreateSection("State System")

StateTab:CreateParagraph("About State", "State allows you to store and track values globally. Components can auto-register with State using the stateKey parameter.")

StateTab:CreateButton("Get All States", function()
    local states = Library.State:GetAll()
    local text = ""
    for key, value in pairs(states) do
        text = text .. key .. " = " .. tostring(value) .. "\n"
    end
    Window:Notify("All States", text ~= "" and text or "No states set", 5, "info")
end)

StateTab:CreateButton("Set Custom State", function()
    Library.State:Set("CustomValue", math.random(1, 100))
    Window:Notify("State Set", "CustomValue set to random number!", 2, "success")
end)

StateTab:CreateButton("Watch State Demo", function()
    Library.State:Watch("WatchDemo", function(newVal, oldVal)
        Window:Notify("Watch Triggered", "Value: " .. tostring(oldVal) .. " → " .. tostring(newVal), 3, "info")
    end)
    Window:Notify("Watcher Added", "Now changing WatchDemo state...", 2, "info")
    task.wait(1)
    Library.State:Set("WatchDemo", "Hello!")
    task.wait(1)
    Library.State:Set("WatchDemo", "World!")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 4: THEMES
═══════════════════════════════════════════════════════════════════════════════
]]

local ThemeTab = Window:CreateTab("Themes", "rbxassetid://7734068854")

ThemeTab:CreateSection("Built-in Themes")

ThemeTab:CreateDropdown("Select Theme", {
    "Purple", "Blue", "Red", "Green", "Orange", "Pink", "Dark", "Neon"
}, function(theme)
    Window:SetTheme(theme)
    Window:Notify("Theme Applied", "Switched to " .. theme .. " theme!", 2, "success")
end)

ThemeTab:CreateSection("Theme Override")

ThemeTab:CreateButton("Override Accent (Red)", function()
    Library:OverrideTheme({
        AccentPrimary = Color3.fromRGB(255, 50, 50)
    })
    Window:Notify("Override", "Accent color changed to red!", 2, "info")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 5: KEY SYSTEM
═══════════════════════════════════════════════════════════════════════════════
]]

local KeyTab = Window:CreateTab("Key System", "rbxassetid://7734053830")

KeyTab:CreateSection("Key Verification")

KeyTab:CreateParagraph("Valid Keys", "VOIDX-FREE-2024\nVOIDX-VIP-PREMIUM\nDEMO-KEY-12345")

local keyInput = ""
KeyTab:CreateInput("Enter Key", "VOIDX-XXXX-XXXX", function(text)
    keyInput = text
end)

KeyTab:CreateButton("Verify Key", function()
    local success, message = Library.KeySystem:Verify(keyInput, {
        OnChecking = function()
            Window:Notify("Checking", "Verifying key...", 1, "info")
        end,
        OnSuccess = function()
            Window:Notify("Welcome!", "Key verified successfully!", 3, "success")
        end,
        OnFailed = function(remaining)
            Window:Notify("Invalid", remaining .. " attempts remaining", 3, "error")
        end,
        OnRateLimited = function(seconds)
            Window:Notify("Rate Limited", "Wait " .. seconds .. " seconds", 5, "warning")
        end
    })
end)

KeyTab:CreateButton("Check Status", function()
    local verified = Library.KeySystem:IsVerified()
    Window:Notify("Status", verified and "✅ Key is verified!" or "❌ Key not verified", 3, verified and "success" or "error")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 6: DEVELOPER UTILITIES
═══════════════════════════════════════════════════════════════════════════════
]]

local DevTab = Window:CreateTab("Developer", "rbxassetid://7734053495")

DevTab:CreateSection("📦 Rate Limiting")

-- CreateLimiter Demo
local actionLimiter = Library.Developer:CreateLimiter({
    MaxCalls = 3,
    TimeWindow = 10,
    OnLimited = function(remaining)
        Window:Notify("Rate Limited", "Wait " .. remaining .. "s", 2, "warning")
    end
})

DevTab:CreateButton("Call Limited Action (3/10s)", function()
    if actionLimiter:Call() then
        Window:Notify("Success", "Action called! Remaining: " .. actionLimiter:GetRemaining(), 2, "success")
    end
end)

DevTab:CreateButton("Reset Limiter", function()
    actionLimiter:Reset()
    Window:Notify("Reset", "Limiter reset!", 1, "info")
end)

DevTab:CreateSection("📸 Snapshot System")

-- CreateSnapshot Demo
local gameSnapshot = Library.Developer:CreateSnapshot({
    CaptureAll = true
})

DevTab:CreateButton("Save State Snapshot", function()
    gameSnapshot:Save()
    local data = gameSnapshot:GetData()
    local count = 0
    for _ in pairs(data) do count = count + 1 end
    Window:Notify("Snapshot Saved", count .. " keys captured", 2, "success")
end)

DevTab:CreateButton("Restore Snapshot", function()
    gameSnapshot:Restore()
    Window:Notify("Restored", "State restored from snapshot", 2, "info")
end)

DevTab:CreateSection("👁️ Observer System")

-- CreateObserver Demo
local gameObserver = nil

DevTab:CreateToggle("Enable Observer", false, function(enabled)
    if enabled then
        gameObserver = Library.Developer:CreateObserver({
            OnPlayerJoined = function(player)
                Window:Notify("Player Joined", player.Name .. " joined!", 3, "info")
            end,
            OnPlayerLeft = function(player)
                Window:Notify("Player Left", player.Name .. " left!", 3, "warning")
            end,
            OnCharacterSpawned = function(player, char)
                print("[Observer] " .. player.Name .. " spawned")
            end,
            OnCharacterDied = function(player, char)
                Window:Notify("Player Died", player.Name .. " died!", 2, "error")
            end
        })
        print("[Observer] Started watching game events")
    else
        if gameObserver then
            gameObserver:Destroy()
            gameObserver = nil
        end
    end
end)

DevTab:CreateSection("🎯 Player Filter")

-- CreateFilter Demo
DevTab:CreateButton("Get Nearby Players (<100 studs)", function()
    local filter = Library.Developer:CreateFilter({
        Source = game.Players:GetPlayers(),
        Conditions = {
            MaxDistance = 100,
            ExcludeSelf = true,
            AliveOnly = true
        }
    })
    
    local nearby = filter:Apply()
    if #nearby > 0 then
        local names = {}
        for _, p in ipairs(nearby) do
            table.insert(names, p.Name)
        end
        Window:Notify("Nearby Players", table.concat(names, ", "), 4, "info")
    else
        Window:Notify("No Players", "No players within 100 studs", 2, "warning")
    end
end)

DevTab:CreateButton("Get Enemy Team Players", function()
    local filter = Library.Developer:CreateFilter({
        Source = game.Players:GetPlayers(),
        Conditions = {
            TeamCheck = true,
            ExcludeSelf = true
        }
    })
    
    local enemies = filter:Apply()
    Window:Notify("Enemies Found", #enemies .. " enemy players", 3, "info")
end)

DevTab:CreateSection("📍 Zone Detection")

-- CreateZone Demo
local testZone = nil

DevTab:CreateToggle("Create Test Zone (50 studs)", false, function(enabled)
    if enabled then
        local char = game.Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local pos = hrp and hrp.Position or Vector3.new(0, 5, 0)
        
        testZone = Library.Developer:CreateZone({
            Type = "Sphere",
            Position = pos,
            Size = 50,
            Visualize = true,
            OnEnter = function(p)
                Window:Notify("Zone Enter", p.Name .. " entered zone!", 2, "success")
            end,
            OnExit = function(p)
                Window:Notify("Zone Exit", p.Name .. " left zone!", 2, "warning")
            end
        })
    else
        if testZone then
            testZone:Destroy()
            testZone = nil
        end
    end
end)

DevTab:CreateSection("✨ Highlighter")

-- CreateHighlighter Demo
local currentHighlight = nil

DevTab:CreateDropdown("Highlight Mode", {"Outline", "Fill", "Pulse"}, function(mode)
    -- Remove old highlight
    if currentHighlight then
        currentHighlight:Destroy()
    end
    
    local char = game.Players.LocalPlayer.Character
    if char then
        currentHighlight = Library.Developer:CreateHighlighter({
            Target = char,
            Mode = mode,
            Color = Color3.fromRGB(130, 80, 220)
        })
        Window:Notify("Highlighter", mode .. " mode applied", 2, "info")
    end
end)

DevTab:CreateButton("Remove Highlight", function()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
        Window:Notify("Removed", "Highlight removed", 1, "info")
    end
end)

DevTab:CreateSection("🎮 ESP System")

-- CreateESP Demo (Shadow ESP)
local playerESP = nil

DevTab:CreateToggle("Enable Shadow ESP", false, function(enabled)
    if enabled then
        playerESP = Library.Developer:CreateESP({
            Target = game.Players,
            Shadow = true,    -- Shadow ESP (tüm karakteri kaplar!)
            Name = true,
            Health = true,
            Distance = true,
            TeamCheck = false,
            MaxDistance = 500,
            Color = Color3.fromRGB(255, 100, 100)
        })
        Window:Notify("ESP Enabled", "Shadow ESP activated!", 2, "success")
    else
        if playerESP then
            playerESP:Destroy()
            playerESP = nil
            Window:Notify("ESP Disabled", "Shadow ESP deactivated", 2, "info")
        end
    end
end)

-- Individual toggles (work while ESP is active)
DevTab:CreateToggle("ESP > Shadow Glow", true, function(enabled)
    if playerESP then
        playerESP:ToggleShadow(enabled)
    end
end)

DevTab:CreateToggle("ESP > Name", true, function(enabled)
    if playerESP then
        playerESP:ToggleName(enabled)
    end
end)

DevTab:CreateToggle("ESP > Health Bar", true, function(enabled)
    if playerESP then
        playerESP:ToggleHealth(enabled)
    end
end)

DevTab:CreateToggle("ESP > Distance", true, function(enabled)
    if playerESP then
        playerESP:ToggleDistance(enabled)
    end
end)

DevTab:CreateSlider("ESP Max Distance", 100, 1000, 500, function(value)
    if playerESP then
        playerESP:SetMaxDistance(value)
    end
end)

DevTab:CreateColorPicker("ESP Color", Color3.fromRGB(255, 100, 100), function(color)
    if playerESP then
        playerESP:SetColor(color)
    end
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           TAB 7: ERROR DEMOS
═══════════════════════════════════════════════════════════════════════════════
]]

local ErrorTab = Window:CreateTab("Errors", "rbxassetid://7743875962")

ErrorTab:CreateSection("Developer-Friendly Errors")

ErrorTab:CreateParagraph("Info", "These buttons trigger intentional errors to show developer-friendly error messages in console.")

ErrorTab:CreateButton("Dropdown Error (Invalid Option)", function()
    zoneDropdown:Set("Zone 999") -- Bu zone yok
    Window:Notify("Check Console", "See developer-friendly error!", 3, "error")
end)

ErrorTab:CreateButton("State Error (nil key)", function()
    Library.State:Set(nil, "test") -- nil key
    Window:Notify("Check Console", "See developer-friendly error!", 3, "error")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           CUSTOM SETTINGS
═══════════════════════════════════════════════════════════════════════════════
]]

-- Settings tab'a özel item ekle
Window:AddSettingsItem("Label", "───── Custom Settings ─────")

Window:AddSettingsItem("Toggle", "Custom Setting 1", false, function(state)
    print("Custom Setting 1:", state)
end)

Window:AddSettingsItem("Button", "Reset All States", function()
    Library.State:Reset()
    Window:Notify("Reset", "All states cleared!", 2, "success")
end)

--[[
═══════════════════════════════════════════════════════════════════════════════
                           DONE!
═══════════════════════════════════════════════════════════════════════════════
]]

print("═══════════════════════════════════════════════════")
print("✅ VoidxV2 Complete Demo Loaded!")
print("📚 " .. Library:GetVersion() .. " | " .. Library.Author)
print("═══════════════════════════════════════════════════")

Window:Notify("Welcome!", "VoidxV2 Complete Demo loaded!\nExplore all tabs to see features.", 5, "success")
