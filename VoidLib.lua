--[[
    ██╗   ██╗ ██████╗ ██╗██████╗ ██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔═══██╗██║██╔══██╗╚██╗██╔╝██║   ██║╚════██╗
    ██║   ██║██║   ██║██║██║  ██║ ╚███╔╝ ██║   ██║ █████╔╝
    ╚██╗ ██╔╝██║   ██║██║██║  ██║ ██╔██╗ ╚██╗ ██╔╝██╔═══╝ 
     ╚████╔╝ ╚██████╔╝██║██████╔╝██╔╝ ██╗ ╚████╔╝ ███████╗
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝
    
    VoidxV2 - Modern Roblox UI Library
    Version: 2.1.0
    Author: @ijosephyusufk
    GitHub: https://github.com/ijosephyusufk-dev/VoidXV2
    
    Usage:
        local Library = loadstring(game:HttpGet("URL"))()
        local Window = Library:CreateWindow({ Name = "My Hub" })
        local Tab = Window:CreateTab("Main")
        Tab:CreateButton("Click Me", function() print("Clicked!") end)
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════════════════
-- LIBRARY CORE
-- ═══════════════════════════════════════════════════════════════════════
local Library = {
    Version = "2.1.0",
    Author = "@ijosephyusufk",
    GitHub = "https://github.com/ijosephyusufk-dev/VoidXV2",
    Debug = false,
    
    _internal = {},
    _windows = {},
    _connections = {},
}

-- ═══════════════════════════════════════════════════════════════════════
-- ERROR HANDLING (Developer Friendly)
-- ═══════════════════════════════════════════════════════════════════════
local ErrorTips = {
    ["Notify"] = "Usage: Window:Notify('Title', 'Message', 5, 'info') or Window:Notify({Title='x', Content='y'})",
    ["CreateWindow"] = "Usage: Library:CreateWindow({Name = 'Hub Name', LoadingEnabled = true})",
    ["CreateTab"] = "Usage: Window:CreateTab('Tab Name', 'rbxassetid://icon')",
    ["CreateToggle"] = "Usage: Tab:CreateToggle('Text', false, callback, 'stateKey')",
    ["CreateSlider"] = "Usage: Tab:CreateSlider('Text', min, max, default, callback)",
    ["CreateDropdown"] = "Usage: Tab:CreateDropdown('Text', {'option1', 'option2'}, callback)",
    ["State:Set"] = "Usage: Library.State:Set('key', value)",
    ["State:Get"] = "Usage: Library.State:Get('key')",
    ["KeySystem"] = "Usage: Library.KeySystem:AddKey('YOUR-KEY') then :Verify(input)",
}

local function Log(level, message, functionName)
    local prefix = "[VoidxV2]"
    local tip = functionName and ErrorTips[functionName] or nil
    
    if level == "error" then
        local fullMessage = prefix .. " ❌ ERROR: " .. message
        if tip then
            fullMessage = fullMessage .. "\n" .. prefix .. " 💡 TIP: " .. tip
        end
        warn(fullMessage) -- Use warn instead of error to not break script
        return false
    elseif level == "warn" then
        local fullMessage = prefix .. " ⚠️ WARNING: " .. message
        if tip then
            fullMessage = fullMessage .. "\n" .. prefix .. " 💡 TIP: " .. tip
        end
        warn(fullMessage)
        return true
    elseif level == "info" and Library.Debug then
        print(prefix .. " ℹ️ " .. message)
        return true
    end
    return true
end

local function TypeCheck(value, expectedType, argName, functionName)
    if type(value) ~= expectedType then
        Log("error", string.format(
            "Invalid argument '%s': expected %s, got %s",
            argName, expectedType, type(value)
        ), functionName)
        return false
    end
    return true
end

local function Assert(condition, message, functionName)
    if not condition then
        return Log("error", message, functionName)
    end
    return true
end

-- ═══════════════════════════════════════════════════════════════════════
-- EVENT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
Library.Events = {}
Library._eventListeners = {}

function Library:On(eventName, callback)
    Assert(type(eventName) == "string", "Event name must be a string")
    Assert(type(callback) == "function", "Callback must be a function")
    
    if not self._eventListeners[eventName] then
        self._eventListeners[eventName] = {}
    end
    table.insert(self._eventListeners[eventName], callback)
    
    Log("info", "Registered listener for event: " .. eventName)
    
    return {
        Disconnect = function()
            for i, cb in ipairs(self._eventListeners[eventName]) do
                if cb == callback then
                    table.remove(self._eventListeners[eventName], i)
                    break
                end
            end
        end
    }
end

function Library:Emit(eventName, ...)
    Log("info", "Emitting event: " .. eventName)
    
    if self._eventListeners[eventName] then
        for _, callback in ipairs(self._eventListeners[eventName]) do
            task.spawn(callback, ...)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════
Library.State = {
    _values = {},
    _watchers = {},
}

function Library.State:Set(key, value)
    Assert(type(key) == "string", "State key must be a string")
    
    local oldValue = self._values[key]
    self._values[key] = value
    
    Log("info", string.format("State changed: %s = %s", key, tostring(value)))
    
    -- Notify watchers
    if self._watchers[key] then
        for _, callback in ipairs(self._watchers[key]) do
            task.spawn(callback, value, oldValue)
        end
    end
    
    Library:Emit("StateChanged", key, value, oldValue)
end

function Library.State:Get(key)
    return self._values[key]
end

function Library.State:GetAll()
    return self._values
end

function Library.State:Watch(key, callback)
    Assert(type(key) == "string", "State key must be a string")
    Assert(type(callback) == "function", "Callback must be a function")
    
    if not self._watchers[key] then
        self._watchers[key] = {}
    end
    table.insert(self._watchers[key], callback)
    
    return {
        Disconnect = function()
            for i, cb in ipairs(self._watchers[key]) do
                if cb == callback then
                    table.remove(self._watchers[key], i)
                    break
                end
            end
        end
    }
end

function Library.State:Reset()
    self._values = {}
    Log("info", "State reset")
end

-- ═══════════════════════════════════════════════════════════════════════
-- DEVELOPER UTILITIES PRO
-- ═══════════════════════════════════════════════════════════════════════
Library.Developer = {}

-- ─────────────────────────────────────────────────────────────────────────
-- 1. CREATE LIMITER - Rate limiting for functions
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateLimiter(config)
    config = config or {}
    local maxCalls = config.MaxCalls or 5
    local timeWindow = config.TimeWindow or 60
    local onLimited = config.OnLimited
    
    local limiter = {
        _calls = {},
        _destroyed = false
    }
    
    function limiter:CanCall()
        if self._destroyed then return false end
        local now = os.clock()
        -- Clean old calls
        local validCalls = {}
        for _, callTime in ipairs(self._calls) do
            if now - callTime < timeWindow then
                table.insert(validCalls, callTime)
            end
        end
        self._calls = validCalls
        return #self._calls < maxCalls
    end
    
    function limiter:Call()
        if self._destroyed then return false end
        if self:CanCall() then
            table.insert(self._calls, os.clock())
            return true
        else
            if onLimited then
                local remaining = timeWindow - (os.clock() - self._calls[1])
                task.spawn(onLimited, math.ceil(remaining))
            end
            return false
        end
    end
    
    function limiter:GetRemaining()
        return maxCalls - #self._calls
    end
    
    function limiter:Reset()
        self._calls = {}
    end
    
    function limiter:Destroy()
        self._destroyed = true
        self._calls = {}
    end
    
    Log("info", "Limiter created: " .. maxCalls .. " calls per " .. timeWindow .. "s")
    return limiter
end

-- ─────────────────────────────────────────────────────────────────────────
-- 2. CREATE SNAPSHOT - State capture and restore
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateSnapshot(config)
    config = config or {}
    local keys = config.Keys
    local captureAll = config.CaptureAll or false
    
    local snapshot = {
        _data = {},
        _timestamp = nil
    }
    
    function snapshot:Save()
        self._timestamp = os.time()
        self._data = {}
        
        if captureAll then
            for key, value in pairs(Library.State:GetAll()) do
                self._data[key] = value
            end
        elseif keys then
            for _, key in ipairs(keys) do
                self._data[key] = Library.State:Get(key)
            end
        end
        
        Log("info", "Snapshot saved: " .. #self._data .. " keys")
        return self
    end
    
    function snapshot:Restore()
        for key, value in pairs(self._data) do
            Library.State:Set(key, value)
        end
        Log("info", "Snapshot restored")
        return self
    end
    
    function snapshot:GetData()
        return self._data
    end
    
    function snapshot:GetTimestamp()
        return self._timestamp
    end
    
    return snapshot
end

-- ─────────────────────────────────────────────────────────────────────────
-- 3. CREATE TRACKER - Track objects/players with live data
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateTracker(config)
    config = config or {}
    local target = config.Target
    local onUpdate = config.OnUpdate
    local updateRate = config.UpdateRate or 0.1
    
    local tracker = {
        _running = true,
        _connection = nil,
        Target = target,
        Data = {}
    }
    
    local function getPosition(obj)
        if obj:IsA("Model") then
            local primary = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
            return primary and primary.Position or Vector3.zero
        elseif obj:IsA("BasePart") then
            return obj.Position
        elseif obj:IsA("Player") then
            local char = obj.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            return hrp and hrp.Position or Vector3.zero
        end
        return Vector3.zero
    end
    
    local function isVisible(position)
        local camera = workspace.CurrentCamera
        local localPlayer = Players.LocalPlayer
        local char = localPlayer and localPlayer.Character
        local origin = char and char:FindFirstChild("Head")
        
        if not origin then return false end
        
        local ray = Ray.new(origin.Position, (position - origin.Position).Unit * 500)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        
        return hit == nil or (hit.Position - position).Magnitude < 5
    end
    
    local function update()
        if not tracker._running or not target then return end
        
        local pos = getPosition(target)
        local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local localPos = localHRP and localHRP.Position or Vector3.zero
        
        tracker.Data = {
            Position = pos,
            Distance = (pos - localPos).Magnitude,
            IsVisible = isVisible(pos),
            Direction = (pos - localPos).Unit,
            Target = target
        }
        
        if onUpdate then
            task.spawn(onUpdate, tracker.Data)
        end
    end
    
    -- Start tracking loop
    task.spawn(function()
        while tracker._running do
            update()
            task.wait(updateRate)
        end
    end)
    
    function tracker:SetTarget(newTarget)
        target = newTarget
        self.Target = newTarget
    end
    
    function tracker:Pause()
        self._running = false
    end
    
    function tracker:Resume()
        self._running = true
        task.spawn(function()
            while self._running do
                update()
                task.wait(updateRate)
            end
        end)
    end
    
    function tracker:Destroy()
        self._running = false
    end
    
    Log("info", "Tracker created")
    return tracker
end

-- ─────────────────────────────────────────────────────────────────────────
-- 4. CREATE OBSERVER - Auto-detect game events
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateObserver(config)
    config = config or {}
    
    local observer = {
        _connections = {},
        _destroyed = false
    }
    
    -- Player Joined
    if config.OnPlayerJoined then
        local conn = Players.PlayerAdded:Connect(function(player)
            if not observer._destroyed then
                task.spawn(config.OnPlayerJoined, player)
            end
        end)
        table.insert(observer._connections, conn)
        
        -- Existing players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                task.spawn(config.OnPlayerJoined, player)
            end
        end
    end
    
    -- Player Left
    if config.OnPlayerLeft then
        local conn = Players.PlayerRemoving:Connect(function(player)
            if not observer._destroyed then
                task.spawn(config.OnPlayerLeft, player)
            end
        end)
        table.insert(observer._connections, conn)
    end
    
    -- Character Spawned
    if config.OnCharacterSpawned then
        local function setupCharacter(player)
            local conn = player.CharacterAdded:Connect(function(char)
                if not observer._destroyed then
                    task.spawn(config.OnCharacterSpawned, player, char)
                end
            end)
            table.insert(observer._connections, conn)
            
            -- Current character
            if player.Character then
                task.spawn(config.OnCharacterSpawned, player, player.Character)
            end
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            setupCharacter(player)
        end
        
        local conn = Players.PlayerAdded:Connect(setupCharacter)
        table.insert(observer._connections, conn)
    end
    
    -- Character Died
    if config.OnCharacterDied then
        local function setupDeath(player)
            local function onChar(char)
                local humanoid = char:WaitForChild("Humanoid", 5)
                if humanoid then
                    local conn = humanoid.Died:Connect(function()
                        if not observer._destroyed then
                            task.spawn(config.OnCharacterDied, player, char)
                        end
                    end)
                    table.insert(observer._connections, conn)
                end
            end
            
            if player.Character then onChar(player.Character) end
            local conn = player.CharacterAdded:Connect(onChar)
            table.insert(observer._connections, conn)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            setupDeath(player)
        end
        local conn = Players.PlayerAdded:Connect(setupDeath)
        table.insert(observer._connections, conn)
    end
    
    -- Tool Equipped
    if config.OnToolEquipped then
        local function setupTools(player)
            local function onChar(char)
                local conn = char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") and not observer._destroyed then
                        task.spawn(config.OnToolEquipped, player, child)
                    end
                end)
                table.insert(observer._connections, conn)
            end
            
            if player.Character then onChar(player.Character) end
            local conn = player.CharacterAdded:Connect(onChar)
            table.insert(observer._connections, conn)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            setupTools(player)
        end
        local conn = Players.PlayerAdded:Connect(setupTools)
        table.insert(observer._connections, conn)
    end
    
    function observer:Destroy()
        self._destroyed = true
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        self._connections = {}
    end
    
    Log("info", "Observer created")
    return observer
end

-- ─────────────────────────────────────────────────────────────────────────
-- 5. CREATE FILTER - Filter targets by conditions
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateFilter(config)
    config = config or {}
    
    local filter = {
        Source = config.Source or {},
        Conditions = config.Conditions or {}
    }
    
    function filter:Apply()
        local results = {}
        local cond = self.Conditions
        local localPlayer = Players.LocalPlayer
        local localChar = localPlayer and localPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local localTeam = localPlayer and localPlayer.Team
        
        for _, obj in ipairs(self.Source) do
            local pass = true
            local char, hrp, humanoid, team
            
            if obj:IsA("Player") then
                char = obj.Character
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                humanoid = char and char:FindFirstChild("Humanoid")
                team = obj.Team
            elseif obj:IsA("Model") then
                char = obj
                hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                humanoid = obj:FindFirstChild("Humanoid")
            end
            
            -- Distance check
            if cond.MaxDistance and hrp and localHRP then
                local dist = (hrp.Position - localHRP.Position).Magnitude
                if dist > cond.MaxDistance then pass = false end
            end
            
            if cond.MinDistance and hrp and localHRP then
                local dist = (hrp.Position - localHRP.Position).Magnitude
                if dist < cond.MinDistance then pass = false end
            end
            
            -- Team check
            if cond.TeamCheck and team and localTeam then
                if team == localTeam then pass = false end
            end
            
            -- Health check
            if humanoid then
                if cond.MinHealth and humanoid.Health < cond.MinHealth then pass = false end
                if cond.MaxHealth and humanoid.Health > cond.MaxHealth then pass = false end
            end
            
            -- Alive check
            if cond.AliveOnly and humanoid then
                if humanoid.Health <= 0 then pass = false end
            end
            
            -- Self check
            if cond.ExcludeSelf and obj == localPlayer then
                pass = false
            end
            
            if pass then
                table.insert(results, obj)
            end
        end
        
        return results
    end
    
    function filter:SetSource(newSource)
        self.Source = newSource
    end
    
    function filter:SetConditions(newConditions)
        self.Conditions = newConditions
    end
    
    return filter
end

-- ─────────────────────────────────────────────────────────────────────────
-- 6. CREATE ZONE - Virtual zone detection
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateZone(config)
    config = config or {}
    local zoneType = config.Type or "Sphere"
    local position = config.Position or Vector3.zero
    local size = config.Size or 50
    local onEnter = config.OnEnter
    local onExit = config.OnExit
    local visualize = config.Visualize or false
    
    local zone = {
        _running = true,
        _inside = {},
        _visual = nil,
        Position = position,
        Size = size,
        Type = zoneType
    }
    
    function zone:IsInside(pos)
        if zoneType == "Sphere" then
            return (pos - position).Magnitude <= size
        elseif zoneType == "Box" then
            local halfSize = typeof(size) == "Vector3" and size / 2 or Vector3.new(size, size, size) / 2
            local diff = pos - position
            return math.abs(diff.X) <= halfSize.X and 
                   math.abs(diff.Y) <= halfSize.Y and 
                   math.abs(diff.Z) <= halfSize.Z
        end
        return false
    end
    
    function zone:SetPosition(newPos)
        position = newPos
        self.Position = newPos
        if self._visual then
            self._visual.Position = newPos
        end
    end
    
    -- Create visual
    if visualize then
        local part = Instance.new("Part")
        part.Name = "ZoneVisual"
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.8
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(130, 80, 220)
        part.Position = position
        
        if zoneType == "Sphere" then
            part.Shape = Enum.PartType.Ball
            part.Size = Vector3.new(size * 2, size * 2, size * 2)
        else
            part.Size = typeof(size) == "Vector3" and size or Vector3.new(size, size, size)
        end
        
        part.Parent = workspace
        zone._visual = part
    end
    
    -- Check loop
    task.spawn(function()
        while zone._running do
            for _, player in ipairs(Players:GetPlayers()) do
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    local wasInside = zone._inside[player]
                    local isNowInside = zone:IsInside(hrp.Position)
                    
                    if isNowInside and not wasInside then
                        zone._inside[player] = true
                        if onEnter then task.spawn(onEnter, player) end
                    elseif not isNowInside and wasInside then
                        zone._inside[player] = nil
                        if onExit then task.spawn(onExit, player) end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
    
    function zone:GetPlayersInside()
        local players = {}
        for player in pairs(self._inside) do
            table.insert(players, player)
        end
        return players
    end
    
    function zone:Destroy()
        self._running = false
        if self._visual then
            self._visual:Destroy()
        end
    end
    
    Log("info", "Zone created: " .. zoneType .. " at " .. tostring(position))
    return zone
end

-- ─────────────────────────────────────────────────────────────────────────
-- 7. CREATE HIGHLIGHTER - Object highlighting
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateHighlighter(config)
    config = config or {}
    local target = config.Target
    local mode = config.Mode or "Outline"
    local color = config.Color or Color3.fromRGB(255, 255, 0)
    local transparency = config.Transparency or 0.5
    
    local highlighter = {
        _highlight = nil,
        Target = target
    }
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillTransparency = mode == "Fill" and transparency or 1
    highlight.OutlineTransparency = mode == "Outline" and 0 or 0.5
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = target
    
    highlighter._highlight = highlight
    
    -- Pulse effect
    if mode == "Pulse" then
        task.spawn(function()
            local t = 0
            while highlighter._highlight and highlighter._highlight.Parent do
                t = t + 0.05
                local alpha = (math.sin(t * 3) + 1) / 2
                highlight.OutlineTransparency = alpha * 0.8
                highlight.FillTransparency = 0.5 + alpha * 0.5
                task.wait(0.03)
            end
        end)
    end
    
    function highlighter:SetColor(newColor)
        if self._highlight then
            self._highlight.FillColor = newColor
            self._highlight.OutlineColor = newColor
        end
    end
    
    function highlighter:SetTarget(newTarget)
        if self._highlight then
            self._highlight.Adornee = newTarget
            self.Target = newTarget
        end
    end
    
    function highlighter:Destroy()
        if self._highlight then
            self._highlight:Destroy()
            self._highlight = nil
        end
    end
    
    Log("info", "Highlighter created: " .. mode)
    return highlighter
end

-- ─────────────────────────────────────────────────────────────────────────
-- 8. CREATE ESP - Complete ESP system with Shadow Mode
-- ─────────────────────────────────────────────────────────────────────────
function Library.Developer:CreateESP(config)
    config = config or {}
    local targets = config.Target or Players
    local espColor = config.Color or Color3.fromRGB(255, 100, 100)
    local teamCheck = config.TeamCheck or false
    local maxDistance = config.MaxDistance or 1000
    
    -- Individual toggles (can be changed dynamically)
    local esp = {
        _enabled = true,
        _highlights = {},
        _billboards = {},
        _connections = {},
        Color = espColor,
        
        -- Toggle states
        ShowShadow = config.Shadow ~= false,  -- Shadow ESP (Highlight)
        ShowName = config.Name ~= false,
        ShowHealth = config.Health or false,
        ShowDistance = config.Distance or false,
        ShowBox = config.Box or false,
        ShowTracer = config.Tracer or false,
        TeamCheck = teamCheck,
        MaxDistance = maxDistance
    }
    
    local function getHealthColor(percent)
        return Color3.fromRGB(
            255 * (1 - percent),
            255 * percent,
            0
        )
    end
    
    local function createPlayerESP(player)
        if player == Players.LocalPlayer then return end
        
        local playerData = {
            highlight = nil,
            billboard = nil,
            nameLabel = nil,
            healthBar = nil,
            healthBg = nil,
            distanceLabel = nil,
            tracer = nil,
            tracerLine = nil
        }
        
        -- Shadow ESP (Highlight - covers entire character)
        local function setupHighlight(char)
            if playerData.highlight then
                playerData.highlight:Destroy()
            end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "VoidESP_Shadow"
            highlight.Adornee = char
            highlight.FillColor = espColor
            highlight.OutlineColor = espColor
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = esp.ShowShadow
            highlight.Parent = char
            
            playerData.highlight = highlight
        end
        
        -- Billboard for Name/Health/Distance
        local function setupBillboard(char)
            if playerData.billboard then
                playerData.billboard:Destroy()
            end
            
            local head = char:WaitForChild("Head", 3)
            if not head then return end
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "VoidESP_Info"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 150, 0, 80)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = char
            
            -- Name Label
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "Name"
            nameLabel.Size = UDim2.new(1, 0, 0, 20)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.DisplayName
            nameLabel.TextColor3 = espColor
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextScaled = false
            nameLabel.Visible = esp.ShowName
            nameLabel.Parent = billboard
            
            -- Health Bar Background
            local healthBg = Instance.new("Frame")
            healthBg.Name = "HealthBg"
            healthBg.Size = UDim2.new(0.8, 0, 0, 6)
            healthBg.Position = UDim2.new(0.1, 0, 0, 22)
            healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            healthBg.BorderSizePixel = 0
            healthBg.Visible = esp.ShowHealth
            healthBg.Parent = billboard
            
            local healthCorner = Instance.new("UICorner")
            healthCorner.CornerRadius = UDim.new(0, 3)
            healthCorner.Parent = healthBg
            
            -- Health Bar Fill
            local healthBar = Instance.new("Frame")
            healthBar.Name = "HealthFill"
            healthBar.Size = UDim2.new(1, 0, 1, 0)
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            healthBar.BorderSizePixel = 0
            healthBar.Parent = healthBg
            
            local healthFillCorner = Instance.new("UICorner")
            healthFillCorner.CornerRadius = UDim.new(0, 3)
            healthFillCorner.Parent = healthBar
            
            -- Distance Label
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "Distance"
            distanceLabel.Size = UDim2.new(1, 0, 0, 16)
            distanceLabel.Position = UDim2.new(0, 0, 0, 32)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Text = "[0m]"
            distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distanceLabel.TextStrokeTransparency = 0
            distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            distanceLabel.Font = Enum.Font.Gotham
            distanceLabel.TextSize = 12
            distanceLabel.Visible = esp.ShowDistance
            distanceLabel.Parent = billboard
            
            playerData.billboard = billboard
            playerData.nameLabel = nameLabel
            playerData.healthBg = healthBg
            playerData.healthBar = healthBar
            playerData.distanceLabel = distanceLabel
        end
        
        -- Tracer line (using Beam)
        local function setupTracer(char)
            -- Tracer uses Drawing API for screen-space lines
            -- This will be handled in update loop
        end
        
        -- Setup for current character
        local function onCharacterAdded(char)
            task.wait(0.1)
            setupHighlight(char)
            setupBillboard(char)
            
            -- Connect to humanoid for health updates
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                local healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if playerData.healthBar and humanoid.MaxHealth > 0 then
                        local percent = humanoid.Health / humanoid.MaxHealth
                        playerData.healthBar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
                        playerData.healthBar.BackgroundColor3 = getHealthColor(percent)
                    end
                end)
                table.insert(esp._connections, healthConn)
            end
        end
        
        -- Watch for character changes
        if player.Character then
            onCharacterAdded(player.Character)
        end
        
        local charConn = player.CharacterAdded:Connect(onCharacterAdded)
        table.insert(esp._connections, charConn)
        
        esp._highlights[player] = playerData
    end
    
    local function removePlayerESP(player)
        local data = esp._highlights[player]
        if data then
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            esp._highlights[player] = nil
        end
    end
    
    local function updateESP()
        local localPlayer = Players.LocalPlayer
        local localChar = localPlayer and localPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        local localTeam = localPlayer and localPlayer.Team
        
        for player, data in pairs(esp._highlights) do
            if not esp._enabled then
                if data.highlight then data.highlight.Enabled = false end
                if data.billboard then data.billboard.Enabled = false end
                continue
            end
            
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            
            local shouldShow = false
            local distance = 0
            
            if hrp and humanoid and localHRP then
                distance = (hrp.Position - localHRP.Position).Magnitude
                
                -- Team check
                local passTeam = true
                if esp.TeamCheck and player.Team and localTeam then
                    passTeam = player.Team ~= localTeam
                end
                
                shouldShow = distance <= esp.MaxDistance and passTeam and humanoid.Health > 0
            end
            
            -- Update visibility
            if data.highlight then
                data.highlight.Enabled = shouldShow and esp.ShowShadow
                data.highlight.FillColor = esp.Color
                data.highlight.OutlineColor = esp.Color
            end
            
            if data.billboard then
                data.billboard.Enabled = shouldShow
            end
            
            if data.nameLabel then
                data.nameLabel.Visible = esp.ShowName
                data.nameLabel.TextColor3 = esp.Color
            end
            
            if data.healthBg then
                data.healthBg.Visible = esp.ShowHealth
            end
            
            if data.distanceLabel then
                data.distanceLabel.Visible = esp.ShowDistance
                data.distanceLabel.Text = string.format("[%dm]", math.floor(distance))
            end
            
            -- Update health bar
            if data.healthBar and humanoid and humanoid.MaxHealth > 0 then
                local percent = humanoid.Health / humanoid.MaxHealth
                data.healthBar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
                data.healthBar.BackgroundColor3 = getHealthColor(percent)
            end
        end
    end
    
    -- Setup for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        createPlayerESP(player)
    end
    
    -- New players
    local addConn = Players.PlayerAdded:Connect(function(player)
        createPlayerESP(player)
    end)
    table.insert(esp._connections, addConn)
    
    -- Leaving players
    local removeConn = Players.PlayerRemoving:Connect(function(player)
        removePlayerESP(player)
    end)
    table.insert(esp._connections, removeConn)
    
    -- Update loop
    local renderConn = RunService.Heartbeat:Connect(updateESP)
    table.insert(esp._connections, renderConn)
    
    -- ═══ PUBLIC METHODS ═══
    
    function esp:Toggle(enabled)
        self._enabled = enabled
    end
    
    function esp:SetColor(newColor)
        self.Color = newColor
    end
    
    -- Individual feature toggles
    function esp:ToggleShadow(enabled)
        self.ShowShadow = enabled
    end
    
    function esp:ToggleName(enabled)
        self.ShowName = enabled
    end
    
    function esp:ToggleHealth(enabled)
        self.ShowHealth = enabled
    end
    
    function esp:ToggleDistance(enabled)
        self.ShowDistance = enabled
    end
    
    function esp:ToggleBox(enabled)
        self.ShowBox = enabled
    end
    
    function esp:ToggleTracer(enabled)
        self.ShowTracer = enabled
    end
    
    function esp:SetMaxDistance(dist)
        self.MaxDistance = dist
    end
    
    function esp:Destroy()
        self._enabled = false
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        for player in pairs(self._highlights) do
            removePlayerESP(player)
        end
        self._highlights = {}
    end
    
    Log("info", "ESP created with Shadow mode: " .. tostring(esp.ShowShadow))
    return esp
end

-- ═══════════════════════════════════════════════════════════════════════
-- UTILITY MODULE
-- ═══════════════════════════════════════════════════════════════════════
local Utility = {}

function Utility:Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
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

function Utility:List(instance, padding, direction)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 5)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.Parent = instance
    return l
end

function Utility:Padding(instance, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = instance
    return p
end

function Utility:Tween(instance, info, goals)
    local t = TweenService:Create(instance, info, goals)
    t:Play()
    return t
end

function Utility:Drag(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════════════
local Themes = {
    Purple = {
        Name = "Purple",
        Background = Color3.fromRGB(18, 14, 28),
        Sidebar = Color3.fromRGB(22, 18, 35),
        Card = Color3.fromRGB(28, 22, 42),
        CardHover = Color3.fromRGB(35, 28, 52),
        AccentPrimary = Color3.fromRGB(130, 80, 220),
        AccentSecondary = Color3.fromRGB(80, 50, 160),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 155, 180),
        TextMuted = Color3.fromRGB(100, 95, 120),
        Border = Color3.fromRGB(50, 40, 70)
    },
    Blue = {
        Name = "Blue",
        Background = Color3.fromRGB(12, 18, 28),
        Sidebar = Color3.fromRGB(15, 22, 35),
        Card = Color3.fromRGB(20, 28, 45),
        CardHover = Color3.fromRGB(25, 35, 55),
        AccentPrimary = Color3.fromRGB(60, 130, 220),
        AccentSecondary = Color3.fromRGB(40, 90, 160),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(155, 170, 190),
        TextMuted = Color3.fromRGB(95, 110, 130),
        Border = Color3.fromRGB(35, 50, 75)
    },
    Red = {
        Name = "Red",
        Background = Color3.fromRGB(25, 12, 15),
        Sidebar = Color3.fromRGB(32, 15, 18),
        Card = Color3.fromRGB(42, 20, 25),
        CardHover = Color3.fromRGB(55, 28, 32),
        AccentPrimary = Color3.fromRGB(220, 60, 80),
        AccentSecondary = Color3.fromRGB(160, 40, 55),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(190, 160, 165),
        TextMuted = Color3.fromRGB(130, 100, 105),
        Border = Color3.fromRGB(70, 35, 40)
    },
    Green = {
        Name = "Green",
        Background = Color3.fromRGB(12, 22, 18),
        Sidebar = Color3.fromRGB(15, 28, 22),
        Card = Color3.fromRGB(18, 38, 28),
        CardHover = Color3.fromRGB(22, 48, 35),
        AccentPrimary = Color3.fromRGB(50, 200, 120),
        AccentSecondary = Color3.fromRGB(35, 140, 85),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 190, 175),
        TextMuted = Color3.fromRGB(100, 130, 115),
        Border = Color3.fromRGB(35, 60, 45)
    },
    Orange = {
        Name = "Orange",
        Background = Color3.fromRGB(25, 18, 12),
        Sidebar = Color3.fromRGB(32, 22, 15),
        Card = Color3.fromRGB(45, 30, 18),
        CardHover = Color3.fromRGB(58, 38, 22),
        AccentPrimary = Color3.fromRGB(240, 140, 50),
        AccentSecondary = Color3.fromRGB(180, 100, 35),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 160),
        TextMuted = Color3.fromRGB(140, 120, 100),
        Border = Color3.fromRGB(75, 55, 35)
    },
    Pink = {
        Name = "Pink",
        Background = Color3.fromRGB(25, 14, 22),
        Sidebar = Color3.fromRGB(32, 18, 28),
        Card = Color3.fromRGB(45, 22, 38),
        CardHover = Color3.fromRGB(58, 28, 48),
        AccentPrimary = Color3.fromRGB(240, 80, 160),
        AccentSecondary = Color3.fromRGB(180, 55, 120),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 165, 185),
        TextMuted = Color3.fromRGB(140, 105, 125),
        Border = Color3.fromRGB(75, 40, 60)
    },
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(20, 20, 24),
        Card = Color3.fromRGB(28, 28, 32),
        CardHover = Color3.fromRGB(38, 38, 42),
        AccentPrimary = Color3.fromRGB(100, 100, 110),
        AccentSecondary = Color3.fromRGB(70, 70, 80),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 175),
        TextMuted = Color3.fromRGB(110, 110, 115),
        Border = Color3.fromRGB(50, 50, 55)
    }
}

local ThemeNames = {"Purple", "Blue", "Red", "Green", "Orange", "Pink", "Dark"}
local Theme = Themes.Purple
Theme.Font = Enum.Font.GothamMedium
Theme.FontBold = Enum.Font.GothamBold

-- ═══════════════════════════════════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════

-- BUTTON
local function CreateButton(parent, text, callback)
    local btn = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Text = "",
        AutoButtonColor = false,
        Parent = parent
    })
    Utility:Corner(btn, UDim.new(0, 6))
    
    local stroke = Utility:Stroke(btn, Theme.Border, 1, 0.5)
    
    local label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    btn.MouseEnter:Connect(function()
        Utility:Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover})
        Utility:Tween(stroke, TweenInfo.new(0.15), {Color = Theme.AccentPrimary, Transparency = 0.3})
    end)
    
    btn.MouseLeave:Connect(function()
        Utility:Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card})
        Utility:Tween(stroke, TweenInfo.new(0.15), {Color = Theme.Border, Transparency = 0.5})
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
    
    return btn
end

-- TOGGLE (with State integration)
local function CreateToggle(parent, text, default, callback, stateKey)
    local state = default or false
    
    -- Register with State if key provided
    if stateKey then
        Library.State:Set(stateKey, state)
    end
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    local label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local track = Utility:Create("Frame", {
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -54, 0.5, -12),
        BackgroundColor3 = state and Theme.AccentPrimary or Color3.fromRGB(60, 55, 75),
        Parent = container
    })
    Utility:Corner(track, UDim.new(1, 0))
    
    local knob = Utility:Create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track
    })
    Utility:Corner(knob, UDim.new(1, 0))
    
    local btn = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    local function update()
        if state then
            Utility:Tween(track, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentPrimary})
            Utility:Tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(1, -22, 0.5, -10)})
        else
            Utility:Tween(track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 55, 75)})
            Utility:Tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(0, 2, 0.5, -10)})
        end
        if stateKey then
            Library.State:Set(stateKey, state)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then task.spawn(callback, state) end
    end)
    
    return {
        Set = function(_, val)
            state = val
            update()
        end,
        Get = function()
            return state
        end,
        StateKey = stateKey
    }
end

-- SLIDER
local function CreateSlider(parent, text, min, max, default, callback)
    local value = default or min
    local dragging = false
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Card,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    local label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local valueLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -55, 0, 5),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    local bar = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.fromRGB(45, 40, 60),
        Parent = container
    })
    Utility:Corner(bar, UDim.new(1, 0))
    
    local fill = Utility:Create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.AccentPrimary,
        Parent = bar
    })
    Utility:Corner(fill, UDim.new(1, 0))
    
    -- Input Sink - Prevents GUI drag when using slider
    local inputSink = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = container
    })
    
    local function update(inputX)
        local barPos = bar.AbsolutePosition.X
        local barSize = bar.AbsoluteSize.X
        
        local percent = math.clamp((inputX - barPos) / barSize, 0, 1)
        value = math.floor(min + (max - min) * percent)
        
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        if callback then task.spawn(callback, value) end
    end
    
    inputSink.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = UserInputService:GetMouseLocation()
        update(mouse.X)
    end)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {
        Value = value,
        
        -- Get current value
        Get = function()
            return value
        end,
        
        -- Set value programmatically
        Set = function(_, v)
            value = math.clamp(v, min, max)
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then task.spawn(callback, value) end
        end
    }
end

-- DROPDOWN
local function CreateDropdown(parent, text, options, callback)
    local selected = options[1] or "None"
    local open = false
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Card,
        ClipsDescendants = true,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    local header = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local valueLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -30, 0, 18),
        Position = UDim2.new(0, 10, 0, 22),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local arrow = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextMuted,
        Font = Theme.Font,
        TextSize = 10,
        Parent = header
    })
    
    local optionHolder = Utility:Create("Frame", {
        Size = UDim2.new(1, -10, 0, #options * 30),
        Position = UDim2.new(0, 5, 0, 50),
        BackgroundTransparency = 1,
        Parent = container
    })
    Utility:List(optionHolder, 2)
    
    for _, opt in ipairs(options) do
        local optBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Theme.Card,
            Text = opt,
            TextColor3 = Theme.TextSecondary,
            Font = Theme.Font,
            TextSize = 13,
            Parent = optionHolder
        })
        Utility:Corner(optBtn, UDim.new(0, 4))
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            valueLabel.Text = opt
            open = false
            Utility:Tween(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)})
            Utility:Tween(arrow, TweenInfo.new(0.2), {Rotation = 0})
            if callback then task.spawn(callback, opt) end
        end)
    end
    
    header.MouseButton1Click:Connect(function()
        open = not open
        local height = open and (55 + #options * 30) or 45
        Utility:Tween(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, height)})
        Utility:Tween(arrow, TweenInfo.new(0.2), {Rotation = open and 180 or 0})
    end)
    
    -- Store references for API
    local currentOptions = options
    
    return {
        Selected = selected,
        
        -- Get current selection
        Get = function()
            return selected
        end,
        
        -- Set selection by value
        Set = function(_, value)
            for _, opt in ipairs(currentOptions) do
                if opt == value then
                    selected = value
                    valueLabel.Text = value
                    if callback then task.spawn(callback, value) end
                    return true
                end
            end
            Log("warn", "Dropdown:Set failed - option not found: " .. tostring(value))
            return false
        end,
        
        -- Refresh options list
        Refresh = function(_, newOptions)
            currentOptions = newOptions
            
            -- Clear old options
            for _, child in ipairs(optionHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Recreate options
            optionHolder.Size = UDim2.new(1, -10, 0, #newOptions * 30)
            
            for _, opt in ipairs(newOptions) do
                local optBtn = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Card,
                    Text = opt,
                    TextColor3 = Theme.TextSecondary,
                    Font = Theme.Font,
                    TextSize = 13,
                    Parent = optionHolder
                })
                Utility:Corner(optBtn, UDim.new(0, 4))
                
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    valueLabel.Text = opt
                    open = false
                    Utility:Tween(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 45)})
                    Utility:Tween(arrow, TweenInfo.new(0.2), {Rotation = 0})
                    if callback then task.spawn(callback, opt) end
                end)
            end
            
            -- Reset selection if not in new options
            local found = false
            for _, opt in ipairs(newOptions) do
                if opt == selected then found = true break end
            end
            if not found and #newOptions > 0 then
                selected = newOptions[1]
                valueLabel.Text = selected
            end
            
            Log("info", "Dropdown refreshed with " .. #newOptions .. " options")
        end
    }
end

-- LABEL (Simple text)
local function CreateLabel(parent, text)
    local label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
    return label
end

-- PARAGRAPH (Multi-line text)
local function CreateParagraph(parent, title, content)
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    Utility:Padding(container, 10, 10, 8, 8)
    
    local titleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local contentLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 22),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = container
    })
    
    return container
end

-- INPUT (TextBox)
local function CreateInput(parent, text, placeholder, callback)
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Card,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local inputBox = Utility:Create("TextBox", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 10, 0, 24),
        BackgroundColor3 = Color3.fromRGB(35, 30, 50),
        Text = "",
        PlaceholderText = placeholder or "Enter text...",
        TextColor3 = Theme.TextPrimary,
        PlaceholderColor3 = Theme.TextMuted,
        Font = Theme.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = container
    })
    Utility:Corner(inputBox, UDim.new(0, 4))
    Utility:Padding(inputBox, 8, 8, 0, 0)
    
    inputBox.FocusLost:Connect(function(enter)
        if callback then task.spawn(callback, inputBox.Text, enter) end
    end)
    
    return {
        SetText = function(_, val) inputBox.Text = val end,
        GetText = function() return inputBox.Text end
    }
end

-- COLORPICKER (HSV + RGB)
local function CreateColorPicker(parent, text, default, callback)
    local color = default or Color3.new(1, 1, 1)
    local open = false
    local h, s, v = Color3.toHSV(color)
    local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
    
    local function updateFromHSV()
        color = Color3.fromHSV(h, s, v)
        r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
    end
    
    local function updateFromRGB()
        color = Color3.fromRGB(r, g, b)
        h, s, v = Color3.toHSV(color)
    end
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        ClipsDescendants = true,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    local header = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container
    })
    
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local preview = Utility:Create("Frame", {
        Size = UDim2.new(0, 30, 0, 20),
        Position = UDim2.new(1, -45, 0.5, -10),
        BackgroundColor3 = color,
        Parent = header
    })
    Utility:Corner(preview, UDim.new(0, 4))
    Utility:Stroke(preview, Color3.new(1,1,1), 1, 0.7)
    
    -- Picker Area
    local pickerHolder = Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 140),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    -- SV Picker (Saturation/Value)
    local svPicker = Utility:Create("Frame", {
        Size = UDim2.new(0, 120, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        Parent = pickerHolder
    })
    Utility:Corner(svPicker, UDim.new(0, 4))
    
    -- White gradient (left to right)
    Utility:Create("UIGradient", {
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
        Transparency = NumberSequence.new(0, 1),
        Parent = svPicker
    })
    
    -- Black overlay (bottom to top)
    local blackOverlay = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        Parent = svPicker
    })
    Utility:Corner(blackOverlay, UDim.new(0, 4))
    Utility:Create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new(1, 0),
        Parent = blackOverlay
    })
    
    -- SV Cursor
    local svCursor = Utility:Create("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(s, -5, 1 - v, -5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = svPicker
    })
    Utility:Corner(svCursor, UDim.new(1, 0))
    Utility:Stroke(svCursor, Color3.new(0, 0, 0), 1, 0)
    
    -- Hue Slider
    local hueBar = Utility:Create("Frame", {
        Size = UDim2.new(0, 20, 0, 80),
        Position = UDim2.new(0, 130, 0, 0),
        Parent = pickerHolder
    })
    Utility:Corner(hueBar, UDim.new(0, 4))
    
    Utility:Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        }),
        Parent = hueBar
    })
    
    local hueCursor = Utility:Create("Frame", {
        Size = UDim2.new(1, 4, 0, 6),
        Position = UDim2.new(0, -2, h, -3),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = hueBar
    })
    Utility:Corner(hueCursor, UDim.new(0, 2))
    Utility:Stroke(hueCursor, Color3.new(0, 0, 0), 1, 0)
    
    -- RGB Sliders
    local function createRGBSlider(name, y, getValue, setValue, sliderColor)
        local bar = Utility:Create("Frame", {
            Size = UDim2.new(1, -160, 0, 14),
            Position = UDim2.new(0, 155, 0, y),
            BackgroundTransparency = 1,
            Parent = pickerHolder
        })
        
        Utility:Create("TextLabel", {
            Size = UDim2.new(0, 15, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = sliderColor,
            Font = Theme.FontBold,
            TextSize = 11,
            Parent = bar
        })
        
        local track = Utility:Create("Frame", {
            Size = UDim2.new(1, -40, 0, 8),
            Position = UDim2.new(0, 18, 0.5, -4),
            BackgroundColor3 = Color3.fromRGB(40, 35, 55),
            Parent = bar
        })
        Utility:Corner(track, UDim.new(1, 0))
        
        local fill = Utility:Create("Frame", {
            Size = UDim2.new(getValue() / 255, 0, 1, 0),
            BackgroundColor3 = sliderColor,
            Parent = track
        })
        Utility:Corner(fill, UDim.new(1, 0))
        
        local valLabel = Utility:Create("TextLabel", {
            Size = UDim2.new(0, 25, 1, 0),
            Position = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(getValue()),
            TextColor3 = Theme.TextSecondary,
            Font = Theme.Font,
            TextSize = 10,
            Parent = bar
        })
        
        local dragging = false
        
        local sink = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = track
        })
        
        sink.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(pct * 255)
                setValue(val)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                valLabel.Text = tostring(val)
                updateFromRGB()
                preview.BackgroundColor3 = color
                svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
                hueCursor.Position = UDim2.new(0, -2, h, -3)
                if callback then task.spawn(callback, color) end
            end
        end)
        
        return {fill = fill, valLabel = valLabel, getValue = getValue}
    end
    
    local rSlider = createRGBSlider("R", 0, function() return r end, function(val) r = val end, Color3.fromRGB(255, 80, 80))
    local gSlider = createRGBSlider("G", 22, function() return g end, function(val) g = val end, Color3.fromRGB(80, 255, 80))
    local bSlider = createRGBSlider("B", 44, function() return b end, function(val) b = val end, Color3.fromRGB(80, 150, 255))
    
    local function updateRGBSliders()
        rSlider.fill.Size = UDim2.new(r / 255, 0, 1, 0)
        rSlider.valLabel.Text = tostring(r)
        gSlider.fill.Size = UDim2.new(g / 255, 0, 1, 0)
        gSlider.valLabel.Text = tostring(g)
        bSlider.fill.Size = UDim2.new(b / 255, 0, 1, 0)
        bSlider.valLabel.Text = tostring(b)
    end
    
    -- SV Picker interaction
    local svDragging = false
    local svSink = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 5,
        Parent = svPicker
    })
    
    svSink.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = true end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then svDragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            s = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            updateFromHSV()
            preview.BackgroundColor3 = color
            updateRGBSliders()
            if callback then task.spawn(callback, color) end
        end
    end)
    
    -- Hue interaction
    local hueDragging = false
    local hueSink = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = hueBar
    })
    
    hueSink.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            hueCursor.Position = UDim2.new(0, -2, h, -3)
            svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            updateFromHSV()
            preview.BackgroundColor3 = color
            updateRGBSliders()
            if callback then task.spawn(callback, color) end
        end
    end)
    
    header.MouseButton1Click:Connect(function()
        open = not open
        Utility:Tween(container, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, open and 195 or 38)})
    end)
    
    return {
        SetColor = function(_, c)
            color = c
            h, s, v = Color3.toHSV(c)
            r, g, b = math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255)
            preview.BackgroundColor3 = c
            svPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            hueCursor.Position = UDim2.new(0, -2, h, -3)
            updateRGBSliders()
        end,
        GetColor = function()
            return color
        end
    }
end

-- KEYBIND
local function CreateKeybind(parent, text, default, callback)
    local key = default or Enum.KeyCode.E
    local listening = false
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Card,
        Parent = parent
    })
    Utility:Corner(container, UDim.new(0, 6))
    
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local keyBtn = Utility:Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -70, 0.5, -13),
        BackgroundColor3 = Theme.AccentSecondary,
        Text = key.Name,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = container
    })
    Utility:Corner(keyBtn, UDim.new(0, 4))
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            key = input.KeyCode
            keyBtn.Text = key.Name
            listening = false
        elseif not listening and input.KeyCode == key then
            if callback then task.spawn(callback) end
        end
    end)
    
    return {
        GetKey = function() return key end,
        SetKey = function(_, k) key = k; keyBtn.Text = k.Name end
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- SECTION (Collapsible)
-- ═══════════════════════════════════════════════════════════════════════
local function CreateSection(parent, title)
    local open = true
    
    local container = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent
    })
    
    local header = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.AccentSecondary,
        Text = "",
        AutoButtonColor = false,
        Parent = container
    })
    Utility:Corner(header, UDim.new(0, 8))
    
    local titleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.FontBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local arrow = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextPrimary,
        Font = Theme.Font,
        TextSize = 10,
        Parent = header
    })
    
    local content = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = container
    })
    local contentList = Utility:List(content, 6)
    Utility:Padding(content, 0, 0, 4, 4)
    
    header.MouseButton1Click:Connect(function()
        open = not open
        if open then
            content.Visible = true
            container.AutomaticSize = Enum.AutomaticSize.Y
        else
            content.Visible = false
            container.AutomaticSize = Enum.AutomaticSize.None
            container.Size = UDim2.new(1, 0, 0, 40)
        end
        arrow.Rotation = open and 0 or -90
    end)
    
    local section = {}
    
    function section:CreateButton(text, callback)
        return CreateButton(content, text, callback)
    end
    
    function section:CreateToggle(text, default, callback)
        return CreateToggle(content, text, default, callback)
    end
    
    function section:CreateSlider(text, min, max, default, callback)
        return CreateSlider(content, text, min, max, default, callback)
    end
    
    function section:CreateDropdown(text, options, callback)
        return CreateDropdown(content, text, options, callback)
    end
    
    function section:CreateKeybind(text, default, callback)
        return CreateKeybind(content, text, default, callback)
    end
    
    function section:CreateInput(text, placeholder, callback)
        return CreateInput(content, text, placeholder, callback)
    end
    
    function section:CreateColorPicker(text, default, callback)
        return CreateColorPicker(content, text, default, callback)
    end
    
    function section:CreateParagraph(title, text)
        return CreateParagraph(content, title, text)
    end
    
    function section:CreateLabel(text)
        return CreateLabel(content, text)
    end
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════════════════════════════════
local function CreateTab(window, name, icon)
    local tab = {Selected = false}
    
    -- Sidebar Button
    local btn = Utility:Create("TextButton", {
        Size = UDim2.new(1, -16, 0, 36),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.AccentPrimary,
        Text = "",
        AutoButtonColor = false,
        Parent = window._sidebarContent
    })
    Utility:Corner(btn, UDim.new(0, 6))
    
    if icon then
        Utility:Create("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 10, 0.5, -9),
            BackgroundTransparency = 1,
            Image = icon,
            ImageColor3 = Theme.TextSecondary,
            Parent = btn
        })
    end
    
    local label = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, icon and 35 or 10, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    -- Page (content container)
    local page = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentPrimary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = window._contentArea
    })
    Utility:List(page, 8)
    Utility:Padding(page, 12, 12, 12, 12)
    
    tab._btn = btn
    tab._label = label
    tab._page = page
    
    function tab:Select()
        -- Deselect others
        for _, t in ipairs(window._tabs) do
            t:Deselect()
        end
        
        tab.Selected = true
        page.Visible = true
        Utility:Tween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85})
        Utility:Tween(label, TweenInfo.new(0.15), {TextColor3 = Theme.TextPrimary})
    end
    
    function tab:Deselect()
        tab.Selected = false
        page.Visible = false
        Utility:Tween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1})
        Utility:Tween(label, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary})
    end
    
    function tab:CreateSection(title)
        return CreateSection(page, title)
    end
    
    function tab:CreateButton(text, callback)
        return CreateButton(page, text, callback)
    end
    
    function tab:CreateToggle(text, default, callback)
        return CreateToggle(page, text, default, callback)
    end
    
    function tab:CreateSlider(text, min, max, default, callback)
        return CreateSlider(page, text, min, max, default, callback)
    end
    
    function tab:CreateDropdown(text, options, callback)
        return CreateDropdown(page, text, options, callback)
    end
    
    function tab:CreateKeybind(text, default, callback)
        return CreateKeybind(page, text, default, callback)
    end
    
    function tab:CreateInput(text, placeholder, callback)
        return CreateInput(page, text, placeholder, callback)
    end
    
    function tab:CreateColorPicker(text, default, callback)
        return CreateColorPicker(page, text, default, callback)
    end
    
    function tab:CreateParagraph(title, text)
        return CreateParagraph(page, title, text)
    end
    
    function tab:CreateLabel(text)
        return CreateLabel(page, text)
    end
    
    btn.MouseButton1Click:Connect(function()
        tab:Select()
    end)
    
    return tab
end

-- ═══════════════════════════════════════════════════════════════════════
-- THEME OVERRIDE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
function Library:CreateTheme(name, colors)
    Assert(type(name) == "string", "Theme name must be a string")
    Assert(type(colors) == "table", "Theme colors must be a table")
    
    Themes[name] = colors
    Themes[name].Name = name
    table.insert(ThemeNames, name)
    
    Log("info", "Created custom theme: " .. name)
    self:Emit("ThemeCreated", name)
end

function Library:OverrideTheme(overrides)
    Assert(type(overrides) == "table", "Overrides must be a table")
    
    for key, value in pairs(overrides) do
        if Theme[key] ~= nil then
            Theme[key] = value
        end
    end
    
    Log("info", "Theme overridden")
    self:Emit("ThemeOverridden", overrides)
end

function Library:GetThemes()
    return ThemeNames
end

function Library:GetCurrentTheme()
    return Theme.Name or "Purple"
end

-- ═══════════════════════════════════════════════════════════════════════
-- KEY SYSTEM PRO
-- ═══════════════════════════════════════════════════════════════════════
Library.KeySystem = {
    _keys = {},
    _attempts = 0,
    _maxAttempts = 5,
    _cooldown = 30,
    _lastAttempt = 0,
    _verified = false,
}

function Library.KeySystem:AddKey(key)
    Assert(type(key) == "string", "Key must be a string")
    self._keys[key] = true
    Log("info", "Key added to valid keys")
end

function Library.KeySystem:AddKeys(keys)
    Assert(type(keys) == "table", "Keys must be a table")
    for _, key in ipairs(keys) do
        self._keys[key] = true
    end
    Log("info", "Multiple keys added: " .. #keys)
end

function Library.KeySystem:SetRateLimit(maxAttempts, cooldownSeconds)
    self._maxAttempts = maxAttempts or 5
    self._cooldown = cooldownSeconds or 30
end

function Library.KeySystem:Verify(inputKey, callbacks)
    callbacks = callbacks or {}
    
    -- Rate limiting check
    local now = tick()
    if self._attempts >= self._maxAttempts then
        local timeSinceLast = now - self._lastAttempt
        if timeSinceLast < self._cooldown then
            local remaining = math.ceil(self._cooldown - timeSinceLast)
            if callbacks.OnRateLimited then
                callbacks.OnRateLimited(remaining)
            end
            Library:Emit("KeyRateLimited", remaining)
            return false, "Rate limited. Try again in " .. remaining .. "s"
        else
            self._attempts = 0
        end
    end
    
    self._attempts = self._attempts + 1
    self._lastAttempt = now
    
    -- Emit checking event
    if callbacks.OnChecking then
        callbacks.OnChecking()
    end
    Library:Emit("KeyChecking", inputKey)
    
    -- Validate
    if self._keys[inputKey] then
        self._verified = true
        if callbacks.OnSuccess then
            callbacks.OnSuccess()
        end
        Library:Emit("KeyVerified", inputKey)
        Log("info", "Key verified successfully")
        return true, "Key verified!"
    else
        if callbacks.OnFailed then
            callbacks.OnFailed(self._maxAttempts - self._attempts)
        end
        Library:Emit("KeyFailed", self._maxAttempts - self._attempts)
        Log("warn", "Invalid key attempt: " .. self._attempts .. "/" .. self._maxAttempts)
        return false, "Invalid key. " .. (self._maxAttempts - self._attempts) .. " attempts remaining."
    end
end

function Library.KeySystem:IsVerified()
    return self._verified
end

function Library.KeySystem:Reset()
    self._attempts = 0
    self._verified = false
    Log("info", "KeySystem reset")
end

-- ═══════════════════════════════════════════════════════════════════════
-- UTILITY METHODS
-- ═══════════════════════════════════════════════════════════════════════
function Library:Destroy()
    for _, window in ipairs(self._windows) do
        if window._gui then
            window._gui:Destroy()
        end
    end
    for _, connection in ipairs(self._connections) do
        connection:Disconnect()
    end
    self._windows = {}
    self._connections = {}
    self._eventListeners = {}
    self.State:Reset()
    self:Emit("Destroyed")
    Log("info", "Library destroyed")
end

function Library:GetVersion()
    return self.Version
end

function Library:SetDebug(enabled)
    self.Debug = enabled
    Log("info", "Debug mode: " .. tostring(enabled))
end

-- ═══════════════════════════════════════════════════════════════════════
-- WINDOW CREATION
-- ═══════════════════════════════════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    
    local window = {
        _tabs = {}
    }
    
    -- Anti-Duplicate: Destroy existing GUI
    local guiParent
    if syn and syn.protect_gui then
        guiParent = CoreGui
    elseif gethui then
        guiParent = gethui()
    else
        guiParent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local existingGui = guiParent:FindFirstChild("VoidxLib")
    if existingGui then
        existingGui:Destroy()
    end
    
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "VoidxLib"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = guiParent
    end
    -- Loading Screen
    local blurOverlay = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    local loadingBox = Utility:Create("Frame", {
        Size = UDim2.new(0, 280, 0, 150),
        Position = UDim2.new(0.5, -140, 0.5, -75),
        BackgroundColor3 = Color3.fromRGB(18, 14, 28),
        BorderSizePixel = 0,
        Parent = gui
    })
    Utility:Corner(loadingBox, UDim.new(0, 12))
    Utility:Stroke(loadingBox, Color3.fromRGB(130, 80, 220), 2, 0.3)
    
    local logoText = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "VoidxV2 HUB",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Parent = loadingBox
    })
    
    local spinner = Utility:Create("Frame", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0.5, -15, 0, 65),
        BackgroundColor3 = Color3.fromRGB(130, 80, 220),
        Rotation = 0,
        Parent = loadingBox
    })
    Utility:Corner(spinner, UDim.new(0, 6))
    
    local loadingStatus = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -35),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Color3.fromRGB(130, 120, 160),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = loadingBox
    })
    
    -- Animate spinner
    task.spawn(function()
        while spinner and spinner.Parent do
            Utility:Tween(spinner, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Rotation = spinner.Rotation + 180})
            task.wait(0.5)
        end
    end)
    
    -- Loading steps
    local steps = {"Initializing...", "Loading components...", "Preparing UI...", "Applying theme...", "Ready!"}
    for i, status in ipairs(steps) do
        loadingStatus.Text = status
        task.wait(0.2)
    end
    
    task.wait(0.2)
    
    -- Fade out
    Utility:Tween(loadingBox, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 250, 0, 130),
        Position = UDim2.new(0.5, -125, 0.5, -65)
    })
    Utility:Tween(blurOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    Utility:Tween(logoText, TweenInfo.new(0.2), {TextTransparency = 1})
    Utility:Tween(loadingStatus, TweenInfo.new(0.2), {TextTransparency = 1})
    Utility:Tween(spinner, TweenInfo.new(0.2), {BackgroundTransparency = 1})
    task.wait(0.35)
    blurOverlay:Destroy()
    loadingBox:Destroy()
    
    -- Main Frame
    local main = Utility:Create("Frame", {
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    Utility:Corner(main, UDim.new(0, 10))
    Utility:Stroke(main, Theme.Border, 1, 0.5)
    Utility:Drag(main)
    
    -- Title Bar
    local titleBar = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = main
    })
    
    -- Title
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 15, 0, config.Subtitle and 8 or 14),
        BackgroundTransparency = 1,
        Text = config.Name or "Voidx Hub",
        TextColor3 = Theme.TextPrimary,
        Font = Theme.FontBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Subtitle (optional)
    if config.Subtitle then
        Utility:Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0, 15, 0, 28),
            BackgroundTransparency = 1,
            Text = config.Subtitle,
            TextColor3 = Theme.TextMuted,
            Font = Theme.Font,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.3,
            Parent = titleBar
        })
    end
    
    -- Divider
    Utility:Create("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = titleBar
    })
    
    -- Sidebar
    local sidebar = Utility:Create("Frame", {
        Size = UDim2.new(0, 180, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Theme.Sidebar,
        Parent = main
    })
    Utility:Corner(sidebar, UDim.new(0, 8))
    
    -- Get player info
    local player = Players.LocalPlayer
    local userId = player.UserId
    local displayName = player.DisplayName
    local username = player.Name
    
    -- Profile Container (at TOP)
    local profileContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, -16, 0, 50),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.3,
        Parent = sidebar
    })
    Utility:Corner(profileContainer, UDim.new(0, 6))
    
    -- Avatar
    local avatarImage = Utility:Create("ImageLabel", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 7, 0.5, -18),
        BackgroundColor3 = Theme.Background,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150",
        Parent = profileContainer
    })
    Utility:Corner(avatarImage, UDim.new(1, 0))
    
    -- Display Name
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -85, 0, 14),
        Position = UDim2.new(0, 50, 0, 10),
        BackgroundTransparency = 1,
        Text = displayName,
        TextColor3 = Theme.TextPrimary,
        Font = Theme.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = profileContainer
    })
    
    -- Username
    Utility:Create("TextLabel", {
        Size = UDim2.new(1, -85, 0, 11),
        Position = UDim2.new(0, 50, 0, 25),
        BackgroundTransparency = 1,
        Text = "@" .. username,
        TextColor3 = Theme.TextMuted,
        Font = Theme.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.2,
        Parent = profileContainer
    })
    
    -- Settings Icon Button (gear icon - real image, not emoji)
    local settingsIconBtn = Utility:Create("ImageButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -32, 0.5, -12),
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.5,
        Image = "rbxassetid://7734053495",  -- Gear/settings icon
        ImageColor3 = Theme.TextMuted,
        Parent = profileContainer
    })
    Utility:Corner(settingsIconBtn, UDim.new(0, 4))
    
    -- Settings icon hover effect
    settingsIconBtn.MouseEnter:Connect(function()
        Utility:Tween(settingsIconBtn, TweenInfo.new(0.15), {ImageColor3 = Theme.AccentPrimary})
    end)
    settingsIconBtn.MouseLeave:Connect(function()
        Utility:Tween(settingsIconBtn, TweenInfo.new(0.15), {ImageColor3 = Theme.TextMuted})
    end)
    
    -- Sidebar tabs area (scrollable) - BELOW profile
    local sidebarContent = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -75),  -- Below profile
        Position = UDim2.new(0, 8, 0, 65),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.AccentPrimary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar
    })
    Utility:List(sidebarContent, 4)
    
    -- settingsContainer for compatibility (will be used by Settings tab)
    local settingsContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = sidebar
    })
    
    -- Content Area
    local contentArea = Utility:Create("Frame", {
        Size = UDim2.new(1, -210, 1, -60),
        Position = UDim2.new(0, 200, 0, 55),
        BackgroundTransparency = 1,
        Parent = main
    })
    
    window._gui = gui
    window._main = main
    window._sidebarContent = sidebarContent
    window._contentArea = contentArea
    
    function window:CreateTab(name, icon)
        local tab = CreateTab(window, name, icon)
        table.insert(window._tabs, tab)
        
        if #window._tabs == 1 then
            tab:Select()
        end
        
        return tab
    end
    
    function window:Destroy()
        gui:Destroy()
    end
    
    -- Notification Container
    local notifContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 1, -20),
        Position = UDim2.new(1, -310, 0, 10),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Parent = gui
    })
    Utility:List(notifContainer, 8)
    
    function window:Notify(titleOrConfig, message, duration, notifType)
        local title, content, dur, nType
        
        -- Support both formats:
        -- window:Notify({Title = "x", Content = "y"})
        -- window:Notify("Title", "Message", 5, "info")
        if type(titleOrConfig) == "table" then
            title = titleOrConfig.Title or "Notification"
            content = titleOrConfig.Content or ""
            dur = titleOrConfig.Duration or 5
            nType = titleOrConfig.Type or "info"
        else
            title = titleOrConfig or "Notification"
            content = message or ""
            dur = duration or 5
            nType = notifType or "info"
        end
        
        local typeColors = {
            info = Theme.AccentPrimary,
            success = Color3.fromRGB(46, 204, 113),
            warning = Color3.fromRGB(241, 196, 15),
            error = Color3.fromRGB(231, 76, 60)
        }
        local accentColor = typeColors[nType] or Theme.AccentPrimary
        
        local notif = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 1,
            Parent = notifContainer,
            ClipsDescendants = true
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
            TextColor3 = Theme.TextPrimary,
            Font = Theme.FontBold,
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
            Text = content,
            TextColor3 = Theme.TextSecondary,
            Font = Theme.Font,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
        
        -- Animate in
        Utility:Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.1})
        
        -- Auto-dismiss
        task.delay(dur, function()
            Utility:Tween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
            task.wait(0.35)
            notif:Destroy()
        end)
    end
    
    -- SetTheme Function
    function window:SetTheme(themeName)
        local newTheme = Themes[themeName]
        if not newTheme then return end
        
        Theme.Background = newTheme.Background
        Theme.Sidebar = newTheme.Sidebar
        Theme.Card = newTheme.Card
        Theme.CardHover = newTheme.CardHover
        Theme.AccentPrimary = newTheme.AccentPrimary
        Theme.AccentSecondary = newTheme.AccentSecondary
        Theme.TextPrimary = newTheme.TextPrimary
        Theme.TextSecondary = newTheme.TextSecondary
        Theme.TextMuted = newTheme.TextMuted
        Theme.Border = newTheme.Border
        
        main.BackgroundColor3 = Theme.Background
        sidebar.BackgroundColor3 = Theme.Sidebar
        
        window:Notify({
            Title = "Theme Changed",
            Content = "Applied: " .. themeName,
            Duration = 2,
            Type = "success"
        })
    end
    
    -- Built-in Settings Tab (fixed at bottom)
    local settingsBtn = Utility:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.AccentPrimary,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = settingsContainer
    })
    Utility:Corner(settingsBtn, UDim.new(0, 6))
    
    Utility:Create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "⚙",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = settingsBtn
    })
    
    local settingsLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = Theme.TextSecondary,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = settingsBtn
    })
    
    local settingsPage = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.AccentPrimary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = contentArea
    })
    Utility:List(settingsPage, 10)
    Utility:Padding(settingsPage, 12, 12, 12, 12)
    
    local settingsTab = {
        Name = "Settings",
        Selected = false,
        _btn = settingsBtn,
        _label = settingsLabel,
        _page = settingsPage
    }
    
    function settingsTab:Select()
        for _, t in ipairs(window._tabs) do
            t:Deselect()
        end
        settingsTab.Selected = true
        settingsPage.Visible = true
        Utility:Tween(settingsBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.85})
        Utility:Tween(settingsLabel, TweenInfo.new(0.15), {TextColor3 = Theme.TextPrimary})
    end
    
    function settingsTab:Deselect()
        settingsTab.Selected = false
        settingsPage.Visible = false
        Utility:Tween(settingsBtn, TweenInfo.new(0.15), {BackgroundTransparency = 1})
        Utility:Tween(settingsLabel, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary})
    end
    
    settingsBtn.MouseButton1Click:Connect(function()
        settingsTab:Select()
    end)
    
    -- Profile gear icon click also opens settings
    settingsIconBtn.MouseButton1Click:Connect(function()
        settingsTab:Select()
    end)
    
    table.insert(window._tabs, settingsTab)
    
    CreateLabel(settingsPage, "⚙ General Settings")
    
    CreateDropdown(settingsPage, "Theme", ThemeNames, function(selected)
        window:SetTheme(selected)
    end)
    
    CreateKeybind(settingsPage, "Toggle GUI", Enum.KeyCode.RightShift, function()
        main.Visible = not main.Visible
    end)
    
    CreateButton(settingsPage, "Destroy GUI", function()
        gui:Destroy()
    end)
    
    CreateLabel(settingsPage, "─────────────────")
    CreateParagraph(settingsPage, "Voidx Library", "Version: " .. Library.Version .. "\nDeveloper: " .. Library.Author)
    
    -- Optional: AddSettings for custom settings
    function window:AddSettingsItem(itemType, ...)
        if itemType == "Button" then
            return CreateButton(settingsPage, ...)
        elseif itemType == "Toggle" then
            return CreateToggle(settingsPage, ...)
        elseif itemType == "Slider" then
            return CreateSlider(settingsPage, ...)
        elseif itemType == "Dropdown" then
            return CreateDropdown(settingsPage, ...)
        elseif itemType == "Label" then
            return CreateLabel(settingsPage, ...)
        end
    end
    
    -- Window Destroy method
    function window:Destroy()
        gui:Destroy()
        Library:Emit("WindowDestroyed", self.Name)
        Log("info", "Window destroyed: " .. (self.Name or "unnamed"))
    end
    
    -- Store window reference
    window.Name = config.Name or "VoidxV2"
    table.insert(Library._windows, window)
    
    -- Emit event
    Library:Emit("WindowCreated", window)
    Log("info", "Window created: " .. window.Name)
    
    return window
end

return Library
