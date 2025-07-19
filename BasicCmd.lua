local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local prefix = ";"
local commands = {}
local aliases = {}

-- swim toggle flag
local swimEnabled = false

local function notify(msg, dur)
    StarterGui:SetCore("SendNotification", {
        Title = "iCMD",
        Text = msg,
        Duration = dur or 4
    })
end

local function parseArgs(text)
    local t = {}
    for word in text:gmatch("%S+") do
        table.insert(t, word)
    end
    return t
end

local function runCommand(msg)
    if not msg or msg:sub(1, #prefix) ~= prefix then return end
    local args = parseArgs(msg:sub(#prefix + 1))
    local cmd = table.remove(args, 1):lower()
    if aliases[cmd] then cmd = aliases[cmd] end
    local fn = commands[cmd]
    if fn then
        local ok, err = pcall(function()
            fn(args)
        end)
        if not ok then
            notify("Error: " .. tostring(err), 3)
        end
    else
        notify("Unknown command: " .. cmd, 2)
    end
end

-- Legacy Chat support
LocalPlayer.Chatted:Connect(runCommand)

-- TextChatService support (RBXGeneral only)
local general = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
if general then
    general.OnIncomingMessage = function(msg)
        if msg.TextSource and msg.TextSource.UserId == LocalPlayer.UserId then
            runCommand(msg.Text)
        end
    end
end

-- Commands:

commands["walkspeed"] = function(args)
    local val = tonumber(args[1])
    if val then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = val
            notify("WalkSpeed = " .. val)
        end
    end
end

commands["jump"] = commands["jp"] = function(args)
    local val = tonumber(args[1])
    if val then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = val
            notify("JumpPower = " .. val)
        end
    end
end

commands["prefix"] = function(args)
    local newPrefix = args[1]
    if newPrefix and #newPrefix == 1 then
        prefix = newPrefix
        notify("Prefix set to '" .. newPrefix .. "'")
    else
        notify("Prefix must be 1 character")
    end
end

commands["swim"] = function()
    local char = LocalPlayer.Character
    if not char then return notify("Character missing") end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return notify("Humanoid missing") end

    if swimEnabled then
        return notify("Already swimming")
    end

    swimEnabled = true
    workspace.Gravity = 0
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    notify("Swim mode enabled")
end

commands["unswim"] = function()
    local char = LocalPlayer.Character
    if not char then return notify("Character missing") end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return notify("Humanoid missing") end

    if not swimEnabled then
        return notify("Swim not active")
    end

    swimEnabled = false
    workspace.Gravity = 196.2
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        hum:SetStateEnabled(state, true)
    end
    hum:ChangeState(Enum.HumanoidStateType.Running)
    notify("Swim mode disabled")
end

commands["airswim"] = (function()
    local enabled = false
    local bv = nil
    return function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return notify("No HRP") end
        enabled = not enabled
        if enabled then
            bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 3, 0)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
            notify("AirSwim enabled")
            task.spawn(function()
                while enabled and bv and bv.Parent do
                    bv.Velocity = Vector3.new(0, 3, 0)
                    task.wait(0.1)
                end
            end)
        else
            if bv then bv:Destroy() end
            notify("AirSwim disabled")
        end
    end
end)()

commands["fly"] = (function()
    local enabled = false
    local bv = nil
    return function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return notify("No HRP") end
        enabled = not enabled
        if enabled then
            bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 10, 0)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
            notify("Fly enabled")
        else
            if bv then bv:Destroy() end
            notify("Fly disabled")
        end
    end
end)()

commands["sit"] = function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.Sit = true
        notify("Sitting")
    end
end

commands["reset"] = function()
    local char = LocalPlayer.Character
    if char then
        char:BreakJoints()
        notify("Character reset")
    end
end

print("iCMD loaded successfully")
