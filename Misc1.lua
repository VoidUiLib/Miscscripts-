-- Honeycomb 9.3 EX+ — Sleeker UI, Hide Button & +earthquake

local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local StarterGui      = game:GetService("StarterGui")

local prefix = "+"
local theme = "Pie"
local extremeMode = false
local noclipEnabled = false

-- Commands
local validCommands = {
    ws        = "Set WalkSpeed",
    jp        = "Set JumpPower",
    noclip    = "Enable Noclip",
    unnoclip  = "Disable Noclip",
    theme     = "Change Theme",
    cmds      = "List Commands",
    earthquake= "Screen shake",
}

-- Notification helper
local function notify(text)
    StarterGui:SetCore("SendNotification", {
        Title = "Honeycomb 9.3 EX+",
        Text = text,
        Duration = 4
    })
end

-- Theme definitions
local Themes = {
    Pie = {BG=Color3.fromRGB(20,20,25), Accent=Color3.fromRGB(255,130,0), Text=Color3.new(1,1,1)},
    Flame = {BG=Color3.fromRGB(30,12,12), AccentStart=Color3.fromRGB(255,70,0), AccentEnd=Color3.fromRGB(255,160,30), Text=Color3.fromRGB(255,220,180)},
    Holo = {BG=Color3.fromRGB(12,12,22), Accent=Color3.fromRGB(60,160,255), Text=Color3.fromRGB(200,220,255)},
    Rainbow = {BG=Color3.fromRGB(25,25,30), Text=Color3.new(1,1,1)},
}

-- Build UI
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "HoneycombEXPlus"
gui.ResetOnSpawn = false

-- Hide/Show Button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0,40,0,40)
toggleBtn.Position = UDim2.new(0,10,0,10)
toggleBtn.Text = "🐝"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 24
toggleBtn.BackgroundTransparency = 0.5
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.AutoButtonColor = false
local togCorner = Instance.new("UICorner", toggleBtn); togCorner.CornerRadius = UDim.new(1,0)

-- Main Frame (semi-transparent)
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,300,0,180)
main.Position = UDim2.new(0.5,-150,0.5,-90)
main.BackgroundColor3 = Themes.Pie.BG
main.BackgroundTransparency = 0.2
main.Active = true
main.Draggable = true
local mainCorner = Instance.new("UICorner", main); mainCorner.CornerRadius = UDim.new(0,12)

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Text = "🐝 Honeycomb 9.3 EX+"
title.TextColor3 = Themes.Pie.Accent

-- Input Box
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(0.9,0,0,30)
input.Position = UDim2.new(0.05,0,0,40)
input.PlaceholderText = prefix.."cmd"
input.ClearTextOnFocus = false
input.BackgroundColor3 = Color3.fromRGB(40,40,45)
input.TextColor3 = Themes.Pie.Text
local inCorner = Instance.new("UICorner", input); inCorner.CornerRadius = UDim.new(0,6)

-- Run Button
local runBtn = Instance.new("TextButton", main)
runBtn.Size = UDim2.new(0.9,0,0,30)
runBtn.Position = UDim2.new(0.05,0,0,80)
runBtn.Text = "Run"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 18
runBtn.BackgroundColor3 = Themes.Pie.Accent
runBtn.TextColor3 = Color3.new(1,1,1)
local runCorner = Instance.new("UICorner", runBtn); runCorner.CornerRadius = UDim.new(0,6)

-- Extreme Mode Toggle
local exBtn = Instance.new("TextButton", main)
exBtn.Size = UDim2.new(0.9,0,0,24)
exBtn.Position = UDim2.new(0.05,0,0,120)
exBtn.Text = "Extreme: OFF"
exBtn.Font = Enum.Font.GothamBold
exBtn.TextSize = 16
exBtn.BackgroundColor3 = Color3.fromRGB(120,50,0)
exBtn.TextColor3 = Color3.new(1,1,1)
local exCorner = Instance.new("UICorner", exBtn); exCorner.CornerRadius = UDim.new(0,6)

exBtn.MouseButton1Click:Connect(function()
    extremeMode = not extremeMode
    exBtn.Text = "Extreme: "..(extremeMode and "ON" or "OFF")
end)

-- Hide/Show logic
toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- Theme application
local function applyTheme(tName)
    local key = tName:sub(1,1):upper()..tName:sub(2):lower()
    local t = Themes[key]
    if not t then
        notify("Invalid theme: "..tName)
        return
    end
    theme = key
    main.BackgroundColor3 = t.BG
    title.TextColor3 = t.Accent or title.TextColor3
    runBtn.BackgroundColor3 = t.Accent or runBtn.BackgroundColor3
    input.TextColor3 = t.Text or input.TextColor3
end

applyTheme(theme)

-- Noclip logic
local noclipConn
local function setNoclip(on)
    noclipEnabled = on
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then
                for _,p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end

-- +earthquake command
local function quake()
    local shakeFrame = Instance.new("Frame", gui)
    shakeFrame.Size = UDim2.new(1,0,1,0)
    shakeFrame.BackgroundTransparency = 1
    local dura, inten = 1.5, 8
    local start = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = tick()-start
        if t > dura then
            gui:FindFirstChild(shakeFrame.Name):Destroy()
            conn:Disconnect()
            return
        end
        shakeFrame.Position = UDim2.new(0, math.random(-inten,inten), 0, math.random(-inten,inten))
    end)
    notify("Earthquake!", Color3.fromRGB(200,200,50))
end

-- Command executor
local function runCommand(cmd, args)
    if cmd == "ws" then
        local v = tonumber(args[1])
        if v and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
            notify("WS → "..v)
        else notify("Bad WS") end
    elseif cmd == "jp" then
        local v = tonumber(args[1])
        if v and LocalPlayer.Character then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = v
            notify("JP → "..v)
        else notify("Bad JP") end
    elseif cmd == "noclip" then
        setNoclip(true); notify("Noclip ON")
    elseif cmd == "unnoclip" then
        setNoclip(false); notify("Noclip OFF")
    elseif cmd == "theme" then
        applyTheme(args[1] or "")
        notify("Theme: "..theme)
    elseif cmd == "cmds" then
        local s = "Cmds: "
        for k in pairs(validCommands) do s = s..prefix..k.." " end
        notify(s)
    elseif cmd == "earthquake" then
        quake()
    else
        notify("Unknown: "..cmd)
    end
end

-- Run button click
runBtn.MouseButton1Click:Connect(function()
    local txt = input.Text
    if txt:sub(1,#prefix) == prefix then
        local parts = {}
        for w in txt:sub(#prefix+1):gmatch("%S+") do table.insert(parts,w) end
        local c = table.remove(parts,1) or ""
        runCommand(c, parts)
    else
        notify("Start with '"..prefix.."'")
    end
end)

-- Chat parser
TextChatService.OnIncomingMessage = function(msg)
    if msg.Text:sub(1,#prefix) == prefix then
        local parts = {}
        for w in msg.Text:sub(#prefix+1):gmatch("%S+") do table.insert(parts,w) end
        local c = table.remove(parts,1) or ""
        runCommand(c, parts)
    end
end
