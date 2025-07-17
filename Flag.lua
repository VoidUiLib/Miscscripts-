--// FAKE LAG SIMULATOR v3 - Curved UI & Rainbow Outline

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Runtime memory
local memory = {
    Preset = "Custom",
    IsLagging = false,
    CustomFreezeChance = 0.2,
    CustomFreezeDuration = 0.5,
}

-- Presets
local presets = {
    ["Custom"] = {
        walkSpeedMultiplier = 0.4,
        freezeChance = function() return memory.CustomFreezeChance end,
        freezeDuration = function() return memory.CustomFreezeDuration end,
        gravity = 1,
        jitterAmt = 1,
    },
    ["Apple II"] = {
        walkSpeedMultiplier = 0.1,
        freezeChance = function() return 0.9 end,
        freezeDuration = function() return 0.5 end,
        gravity = 1,
        jitterAmt = 3,
    },
    ["BLU Phone"] = {
        walkSpeedMultiplier = 0.3,
        freezeChance = function() return 0.5 end,
        freezeDuration = function() return 0.8 end,
        gravity = 1,
        jitterAmt = 1.5,
    },
    ["Samsung Evergreen"] = {
        walkSpeedMultiplier = 0.08,
        freezeChance = function() return 0.7 end,
        freezeDuration = function() return 1.5 end,
        gravity = 0.1,       -- near zero gravity
        jitterAmt = 4.5,
    }
}

-- UI Creation
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FakeLagSimulatorGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 260)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0

-- Curved corners
local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 16)

-- Rainbow outline
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 3

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Fake Lag Simulator"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Toggle Button
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Text = "Toggle Lag"
local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(0, 8)

-- Preset Label
local presetLbl = Instance.new("TextLabel", frame)
presetLbl.Size = UDim2.new(0.4, 0, 0, 24)
presetLbl.Position = UDim2.new(0, 10, 0, 100)
presetLbl.BackgroundTransparency = 1
presetLbl.Text = "Preset:"
presetLbl.TextColor3 = Color3.fromRGB(255,255,255)
presetLbl.Font = Enum.Font.SourceSans
presetLbl.TextSize = 16

-- Preset Dropdown
local presetBtn = Instance.new("TextButton", frame)
presetBtn.Size = UDim2.new(0.6, -10, 0, 28)
presetBtn.Position = UDim2.new(0.4, 0, 0, 98)
presetBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
presetBtn.TextColor3 = Color3.fromRGB(255,255,255)
presetBtn.Text = memory.Preset
presetBtn.Font = Enum.Font.SourceSansBold
presetBtn.TextSize = 14
local presetCorner = Instance.new("UICorner", presetBtn)
presetCorner.CornerRadius = UDim.new(0, 8)

-- Custom controls for Custom mode
local freezeChanceLbl = Instance.new("TextLabel", frame)
freezeChanceLbl.Size = UDim2.new(0.5, -15, 0, 24)
freezeChanceLbl.Position = UDim2.new(0, 10, 0, 140)
freezeChanceLbl.BackgroundTransparency = 1
freezeChanceLbl.Text = "Freeze %:"
freezeChanceLbl.TextColor3 = Color3.fromRGB(255,255,255)
freezeChanceLbl.Font = Enum.Font.SourceSans
freezeChanceLbl.TextSize = 14

local freezeChanceBox = Instance.new("TextBox", frame)
freezeChanceBox.Size = UDim2.new(0.5, -15, 0, 28)
freezeChanceBox.Position = UDim2.new(0, 10, 0, 165)
freezeChanceBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
freezeChanceBox.TextColor3 = Color3.fromRGB(255,255,255)
freezeChanceBox.Text = tostring(memory.CustomFreezeChance)
freezeChanceBox.ClearTextOnFocus = false
local fcCorner = Instance.new("UICorner", freezeChanceBox)
fcCorner.CornerRadius = UDim.new(0, 8)

local freezeDurLbl = Instance.new("TextLabel", frame)
freezeDurLbl.Size = UDim2.new(0.5, -15, 0, 24)
freezeDurLbl.Position = UDim2.new(0.5, 5, 0, 140)
freezeDurLbl.BackgroundTransparency = 1
freezeDurLbl.Text = "Duration s:"
freezeDurLbl.TextColor3 = Color3.fromRGB(255,255,255)
freezeDurLbl.Font = Enum.Font.SourceSans
freezeDurLbl.TextSize = 14

local freezeDurBox = Instance.new("TextBox", frame)
freezeDurBox.Size = UDim2.new(0.5, -15, 0, 28)
freezeDurBox.Position = UDim2.new(0.5, 5, 0, 165)
freezeDurBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
freezeDurBox.TextColor3 = Color3.fromRGB(255,255,255)
freezeDurBox.Text = tostring(memory.CustomFreezeDuration)
freezeDurBox.ClearTextOnFocus = false
local fdCorner = Instance.new("UICorner", freezeDurBox)
fdCorner.CornerRadius = UDim.new(0, 8)

-- Status Label
local statusLbl = Instance.new("TextLabel", frame)
statusLbl.Size = UDim2.new(1, -20, 0, 24)
statusLbl.Position = UDim2.new(0, 10, 0, 210)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status: Idle"
statusLbl.TextColor3 = Color3.fromRGB(255,255,255)
statusLbl.Font = Enum.Font.SourceSansBold
statusLbl.TextSize = 14

-- Rainbow outline updater
spawn(function()
    local hue = 0
    while true do
        hue = (hue + 1) % 360
        uiStroke.Color = Color3.fromHSV(hue/360, 1, 1)
        task.wait(0.05)
    end
end)

-- Helper: clamp function
local function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Lag routines
local lagConn
local currentConfig = presets[memory.Preset]

local function startLag()
    memory.IsLagging = true
    statusLbl.Text = "Status: Lagging..."
    Humanoid.WalkSpeed = 16 * currentConfig.walkSpeedMultiplier

    lagConn = RunService.Heartbeat:Connect(function()
        if not memory.IsLagging then return end
        local cfg = presets[memory.Preset]
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- apply gravity override
        hrp.Velocity = Vector3.new(hrp.Velocity.X, -workspace.Gravity * cfg.gravity, hrp.Velocity.Z)

        -- freeze chance and duration
        if math.random() < cfg.freezeChance() then
            hrp.Anchored = true
            task.wait(cfg.freezeDuration())
            hrp.Anchored = false
        end

        -- frame skip (simulated delay)
        if math.random() < cfg.frameSkipChance then
            task.wait(0.05)
        end

        -- jitter position + slight rotation
        if math.random() < 0.7 then
            local j = cfg.jitterAmt
            hrp.CFrame = hrp.CFrame
                * CFrame.new((math.random() - 0.5) * j, 0, (math.random() - 0.5) * j)
                * CFrame.Angles(0, math.rad(math.random(-2, 2)), 0)
        end
    end)
end

local function stopLag()
    memory.IsLagging = false
    if lagConn then lagConn:Disconnect() end
    Humanoid.WalkSpeed = 16
    statusLbl.Text = "Status: Idle"
end

-- UI event bindings
toggleBtn.MouseButton1Click:Connect(function()
    if memory.IsLagging then
        stopLag()
    else
        startLag()
    end
end)

local presetNames = {"Custom", "Apple II", "BLU Phone", "Samsung Evergreen"}
presetBtn.MouseButton1Click:Connect(function()
    local idx = table.find(presetNames, memory.Preset)
    memory.Preset = presetNames[(idx % #presetNames) + 1]
    presetBtn.Text = memory.Preset
    currentConfig = presets[memory.Preset]
end)

freezeChanceBox.FocusLost:Connect(function()
    local v = tonumber(freezeChanceBox.Text)
    memory.CustomFreezeChance = clamp(v or memory.CustomFreezeChance, 0, 1)
    freezeChanceBox.Text = tostring(memory.CustomFreezeChance)
end)

freezeDurBox.FocusLost:Connect(function()
    local v = tonumber(freezeDurBox.Text)
    memory.CustomFreezeDuration = clamp(v or memory.CustomFreezeDuration, 0.01, 5)
    freezeDurBox.Text = tostring(memory.CustomFreezeDuration)
end)

-- Respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    task.wait(1)
    if memory.IsLagging then
        startLag()
    else
        stopLag()
    end
end)

print("Fake Lag Simulator v3 loaded!")
