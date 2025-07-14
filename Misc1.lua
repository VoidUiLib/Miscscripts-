-- Honeycomb 9.1 Beta 🐝
-- Full GUI, Themes, Command Parser, and Chat Execution

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")

local prefix = "+"
_G.HoneyTheme = "pie"
_G.NoclipEnabled = false

local Themes = {
    pie = {
        Card = Color3.fromRGB(25, 25, 30),
        Accent = Color3.fromRGB(255, 120, 0),
        Text = Color3.fromRGB(255, 255, 255)
    },
    flame = {
        Card = Color3.fromRGB(40, 20, 20),
        Accent = Color3.fromRGB(255, 100, 0),
        Text = Color3.fromRGB(255, 220, 220)
    },
    rainbow = {
        Card = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromHSV(tick() % 1, 1, 1),
        Text = Color3.fromRGB(255, 255, 255)
    },
    holo = {
        Card = Color3.fromRGB(10, 10, 20),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(200, 255, 255)
    }
}

local function getTheme()
    return Themes[_G.HoneyTheme] or Themes.pie
end

-- GUI setup
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "Honeycomb"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

-- Dock
local dock = Instance.new("Frame", gui)
dock.Size = UDim2.new(0, 60, 1, 0)
dock.Position = UDim2.new(0, 0, 0, 0)
dock.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dock.Visible = false

-- Main Window
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 200)
main.Position = UDim2.new(0.5, -160, 0.4, 0)
main.BackgroundColor3 = getTheme().Card
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🐝 Honeycomb 9.1 Beta"
title.TextColor3 = getTheme().Accent
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(0.9, 0, 0, 30)
input.Position = UDim2.new(0.05, 0, 0, 50)
input.PlaceholderText = prefix .. "ws 100"
input.Text = ""
input.Font = Enum.Font.Gotham
input.TextScaled = true
input.TextColor3 = getTheme().Text
input.BackgroundColor3 = getTheme().Card
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local run = Instance.new("TextButton", main)
run.Size = UDim2.new(0.9, 0, 0, 30)
run.Position = UDim2.new(0.05, 0, 0, 90)
run.Text = "Run"
run.Font = Enum.Font.GothamBold
run.TextScaled = true
run.TextColor3 = getTheme().Text
run.BackgroundColor3 = getTheme().Accent
Instance.new("UICorner", run).CornerRadius = UDim.new(0, 8)

-- Run command function
local function executeCommand(text)
    local parts = text:lower():split(" ")
    local cmd = parts[1]
    table.remove(parts, 1)

    if cmd == prefix.."ws" then
        local v = tonumber(parts[1])
        if v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end

    elseif cmd == prefix.."jp" then
        local v = tonumber(parts[1])
        if v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = v end
        end

    elseif cmd == prefix.."noclip" then
        _G.NoclipEnabled = true

    elseif cmd == prefix.."unnoclip" then
        _G.NoclipEnabled = false

    elseif cmd == prefix.."jumpscare" then
        local sc = Instance.new("ScreenGui", PlayerGui)
        sc.IgnoreGuiInset = true
        sc.ZIndexBehavior = Enum.ZIndexBehavior.Global

        local img = Instance.new("ImageLabel", sc)
        img.Size = UDim2.new(1,0,1,0)
        img.Position = UDim2.new(0,0,0,0)
        img.BackgroundTransparency = 1
        img.Image = "rbxassetid://449643110"
        img.ImageTransparency = 1

        local sound = Instance.new("Sound", sc)
        sound.SoundId = "rbxassetid://4642015776"
        sound.Volume = 5
        sound:Play()

        TweenService:Create(img, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()

        wait(1.4)
        sc:Destroy()

    elseif cmd == prefix.."theme" and parts[1] then
        _G.HoneyTheme = parts[1]:lower()
        main.BackgroundColor3 = getTheme().Card
        title.TextColor3 = getTheme().Accent
        input.TextColor3 = getTheme().Text
        input.BackgroundColor3 = getTheme().Card
        run.TextColor3 = getTheme().Text
        run.BackgroundColor3 = getTheme().Accent

    elseif cmd == prefix.."cmds" then
        local msg = Instance.new("Message", workspace)
        msg.Text = "Commands: +ws, +jp, +noclip, +unnoclip, +theme [name], +cmds, +jumpscare"
        game:GetService("Debris"):AddItem(msg, 6)

    elseif cmd == prefix.."prefix" and parts[1] then
        prefix = parts[1]
    end
end

-- Noclip Handler
RunService.Stepped:Connect(function()
    if _G.NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Run Button
run.MouseButton1Click:Connect(function()
    executeCommand(input.Text)
end)

-- Chat Parser (TextChatService)
TextChatService.OnIncomingMessage = function(msg)
    if msg.TextSource and msg.Text then
        local speaker = Players:GetPlayerByUserId(msg.TextSource.UserId)
        if speaker == LocalPlayer then
            if msg.Text:sub(1, #prefix) == prefix then
                executeCommand(msg.Text)
            end
        end
    end
end
