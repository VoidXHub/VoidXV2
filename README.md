# VoidxV2 - Modern Roblox UI Framework

![Version](https://img.shields.io/badge/version-2.1.0-purple)
![License](https://img.shields.io/badge/license-MIT-green)

A professional-grade UI framework for Roblox with state management, event system, and full control over your script's UI layer.

---

## 🎯 What VoidxV2 Is (and Isn't)

| ✅ VoidxV2 Provides | ❌ VoidxV2 Does NOT |
|---------------------|---------------------|
| Full UI control | Speed boost |
| State synchronization | Ready-made scripts |
| Event-driven architecture | Magic solutions |
| Professional API structure | Auto-game detection |
| Debug & error tracking | Obfuscation bypass |

**VoidxV2 gives you control. What you build with it is up to you.**

---

## 📦 Installation

```lua
local Void = loadstring(game:HttpGet("https://raw.githubusercontent.com/ijosephyusufk-dev/VoidXV2/main/VoidLib.lua"))()
```

---

## 🛤️ Recommended Usage Flow (Golden Path)

Follow this order for proper initialization:

```lua
-- 1️⃣ LOAD: Get the library
local Void = loadstring(game:HttpGet("URL"))()

-- 2️⃣ CONFIGURE: Set up options
Void:SetDebug(true)                    -- Enable logging
Void.KeySystem:AddKey("YOUR-KEY")      -- Add valid keys

-- 3️⃣ REGISTER: Hook into events
Void:On("StateChanged", function(key, value)
    print(key, "=", value)
end)

-- 4️⃣ CREATE: Build your UI
local Window = Void:CreateWindow({ Name = "My Hub" })
local Tab = Window:CreateTab("Main")

-- 5️⃣ BIND: Add components with state
Tab:CreateToggle("Auto Farm", false, function(state)
    -- Your logic
end, "AutoFarm")  -- State key

-- 6️⃣ RUN: Your script logic uses state
while Void.State:Get("AutoFarm") do
    -- Farm loop
    task.wait(1)
end
```

---

## 📚 API Reference

### Core

#### `Void:CreateWindow(config)`
| | |
|---|---|
| **What** | Creates the main UI window |
| **When** | After configuration, before adding tabs |
| **Required** | ✅ Yes - Entry point for all UI |
| **If wrong** | Nothing will display |

```lua
local Window = Void:CreateWindow({
    Name = "Hub Name",
    LoadingEnabled = true  -- Show loading screen
})
```

---

#### `Void:SetDebug(enabled)`
| | |
|---|---|
| **What** | Enables verbose console logging |
| **When** | Before CreateWindow, during development |
| **Required** | ❌ No - Default is false |
| **If wrong** | Silent failures, hard to debug |

```lua
Void:SetDebug(true)
```

---

#### `Void:Destroy()`
| | |
|---|---|
| **What** | Destroys all windows and cleans up resources |
| **When** | When unloading or resetting the script |
| **Required** | ❌ No - But recommended for clean exit |
| **If wrong** | Memory leaks, duplicate GUIs |

```lua
Void:Destroy()
```

---

### Events

#### `Void:On(eventName, callback)`
| | |
|---|---|
| **What** | Registers a listener for library events |
| **When** | Before CreateWindow to catch all events |
| **Required** | ❌ No - But essential for reactive code |
| **If wrong** | Events fire but nothing responds |

```lua
local connection = Void:On("WindowCreated", function(window)
    print("Window ready:", window.Name)
end)

-- To disconnect:
connection.Disconnect()
```

**Available Events:**

| Event | Payload | Description |
|-------|---------|-------------|
| `WindowCreated` | window | Window initialized |
| `WindowDestroyed` | name | Window removed |
| `TabSelected` | tab | User switched tabs |
| `ThemeChanged` | themeName | Theme applied |
| `StateChanged` | key, new, old | State value changed |
| `KeyChecking` | inputKey | Key verification started |
| `KeyVerified` | key | Valid key entered |
| `KeyFailed` | attemptsLeft | Invalid key entered |
| `KeyRateLimited` | seconds | Too many attempts |
| `Destroyed` | - | Library cleaned up |

---

### State Management

#### `Void.State:Set(key, value)`
| | |
|---|---|
| **What** | Stores a value globally accessible |
| **When** | Anytime you need to track a value |
| **Required** | ❌ No - But enables reactive patterns |
| **If wrong** | Value not tracked, watchers not triggered |

```lua
Void.State:Set("AutoFarm", true)
Void.State:Set("FarmSpeed", 5)
```

---

#### `Void.State:Get(key)`
| | |
|---|---|
| **What** | Retrieves a stored value |
| **When** | In loops, callbacks, anywhere |
| **Required** | ❌ No |
| **If wrong** | Returns nil if key doesn't exist |

```lua
if Void.State:Get("AutoFarm") then
    -- Do something
end
```

---

#### `Void.State:Watch(key, callback)`
| | |
|---|---|
| **What** | Calls callback when value changes |
| **When** | Before the value is expected to change |
| **Required** | ❌ No |
| **If wrong** | Callback never fires |

```lua
Void.State:Watch("AutoFarm", function(newValue, oldValue)
    print("AutoFarm changed:", oldValue, "→", newValue)
end)
```

---

### Key System

#### `Void.KeySystem:AddKey(key)` / `:AddKeys(table)`
| | |
|---|---|
| **What** | Registers valid key(s) |
| **When** | Before any Verify calls |
| **Required** | ✅ Yes - If using key system |
| **If wrong** | All keys will fail |

```lua
Void.KeySystem:AddKey("SINGLE-KEY")
Void.KeySystem:AddKeys({"KEY1", "KEY2", "KEY3"})
```

---

#### `Void.KeySystem:Verify(inputKey, callbacks)`
| | |
|---|---|
| **What** | Validates user input against registered keys |
| **When** | When user submits a key |
| **Required** | ✅ Yes - Core verification |
| **If wrong** | No access control |

```lua
local success, message = Void.KeySystem:Verify(userInput, {
    OnChecking = function() end,
    OnSuccess = function() end,
    OnFailed = function(remaining) end,
    OnRateLimited = function(seconds) end
})
```

---

#### `Void.KeySystem:SetRateLimit(attempts, cooldown)`
| | |
|---|---|
| **What** | Limits verification attempts |
| **When** | Before Verify, during setup |
| **Required** | ❌ No - Default: 5 attempts, 30s cooldown |
| **If wrong** | Brute force possible |

```lua
Void.KeySystem:SetRateLimit(3, 60)  -- 3 attempts, 60s wait
```

---

### Theme System

#### `Window:SetTheme(name)`
| | |
|---|---|
| **What** | Applies a built-in theme |
| **When** | Anytime after window creation |
| **Required** | ❌ No - Default is Purple |
| **If wrong** | Silent fail if theme doesn't exist |

**Built-in themes:** `Purple`, `Blue`, `Red`, `Green`, `Orange`, `Pink`, `Dark`

---

#### `Void:CreateTheme(name, colors)`
| | |
|---|---|
| **What** | Registers a custom theme |
| **When** | Before SetTheme with that name |
| **Required** | ❌ No |
| **If wrong** | Theme not available |

```lua
Void:CreateTheme("Custom", {
    Background = Color3.fromRGB(20, 20, 30),
    AccentPrimary = Color3.fromRGB(255, 100, 50),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    -- ... other properties
})
```

---

## ⚠️ Common Mistakes

### ❌ Using State before Toggle is created

```lua
-- WRONG
local value = Void.State:Get("AutoFarm")  -- nil!
Tab:CreateToggle("Auto Farm", false, callback, "AutoFarm")

-- CORRECT
Tab:CreateToggle("Auto Farm", false, callback, "AutoFarm")
local value = Void.State:Get("AutoFarm")  -- false
```

### ❌ Adding keys after Verify

```lua
-- WRONG
Void.KeySystem:Verify(key)
Void.KeySystem:AddKey("VALID-KEY")

-- CORRECT
Void.KeySystem:AddKey("VALID-KEY")
Void.KeySystem:Verify(key)
```

### ❌ Forgetting to check State in loops

```lua
-- WRONG (infinite loop)
while true do
    farmAction()
    task.wait(1)
end

-- CORRECT
while Void.State:Get("AutoFarm") do
    farmAction()
    task.wait(1)
end
```

### ❌ Creating multiple windows without cleanup

```lua
-- WRONG (duplicate GUIs)
Void:CreateWindow({Name = "Hub"})
Void:CreateWindow({Name = "Hub"})

-- CORRECT (VoidxV2 handles this automatically)
-- But if you need manual control:
Void:Destroy()
Void:CreateWindow({Name = "Hub"})
```

---

## 🎛️ Components Quick Reference

| Component | Usage |
|-----------|-------|
| Button | `Tab:CreateButton(text, callback)` |
| Toggle | `Tab:CreateToggle(text, default, callback, stateKey?)` |
| Slider | `Tab:CreateSlider(text, min, max, default, callback)` |
| Dropdown | `Tab:CreateDropdown(text, options, callback)` |
| Input | `Tab:CreateInput(text, placeholder, callback)` |
| Keybind | `Tab:CreateKeybind(text, default, callback)` |
| ColorPicker | `Tab:CreateColorPicker(text, default, callback)` |
| Section | `Tab:CreateSection(title)` |
| Label | `Tab:CreateLabel(text)` |
| Paragraph | `Tab:CreateParagraph(title, content)` |

---

## 📄 Files

| File | Description |
|------|-------------|
| `VoidLib.lua` | Main library |
| `ExampleScript.lua` | Basic demo |
| `RealWorldExample.lua` | Complete script with key system |
| `CHANGELOG.md` | Version history |

---

## 📝 License

MIT License - Free for personal and commercial use.

## 👤 Author

**@ijosephyusufk** • [GitHub](https://github.com/ijosephyusufk-dev)
