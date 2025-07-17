local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local localPlayer = Players.LocalPlayer

local prefixList = {"/", "!", "+"} -- command prefixes

-- Commands table
local commands = {

    speed = function(args)
        local speed = tonumber(args[1]) or 16
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
            print("WalkSpeed set to", speed)
        end
    end,

    jump = function(args)
        local jumpPower = tonumber(args[1]) or 50
        local char = localPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = jumpPower
            print("JumpPower set to", jumpPower)
        end
    end,

    fly = (function()
        local flying = false
        local bodyVelocity

        return function(args)
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            flying = not flying

            if flying then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
                bodyVelocity.Velocity = Vector3.new(0,0,0)
                bodyVelocity.Parent = hrp
                print("Fly enabled")

                task.spawn(function()
                    while flying and bodyVelocity.Parent do
                        bodyVelocity.Velocity = Vector3.new(0,10,0) -- constant slow up movement
                        task.wait(0.1)
                    end
                end)

            else
                if bodyVelocity then
                    bodyVelocity:Destroy()
                    bodyVelocity = nil
                end
                print("Fly disabled")
            end
        end
    end)(),

    airswim = (function()
        local swimming = false
        local bodyVelocity

        return function(args)
            local char = localPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            swimming = not swimming

            if swimming then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e4,1e4,1e4)
                bodyVelocity.Velocity = Vector3.new(0,3,0)
                bodyVelocity.Parent = hrp
                print("AirSwim enabled")

                task.spawn(function()
                    while swimming and bodyVelocity.Parent do
                        bodyVelocity.Velocity = Vector3.new(0,3,0)
                        task.wait(0.1)
                    end
                end)
            else
                if bodyVelocity then
                    bodyVelocity:Destroy()
                    bodyVelocity = nil
                end
                print("AirSwim disabled")
            end
        end
    end)(),

    noclip = (function()
        local noclipEnabled = false

        return function(args)
            noclipEnabled = not noclipEnabled
            local char = localPlayer.Character
            if not char then return end

            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not noclipEnabled
                end
            end
            print("Noclip", noclipEnabled and "enabled" or "disabled")
        end
    end)(),

    tp = function(args)
        local targetName = args[1]
        if not targetName then return print("Usage: tp <playername>") end

        local targetPlayer = Players:FindFirstChild(targetName)
        local char = localPlayer.Character
        if targetPlayer and targetPlayer.Character and char and char:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            print("Teleported to", targetName)
        else
            print("Player not found or missing character")
        end
    end,

    sit = (function()
        local sitting = false
        return function(args)
            local char = localPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                sitting = not sitting
                char.Humanoid.Sit = sitting
                print(sitting and "Sitting down" or "Standing up")
            end
        end
    end)(),

    reset = function(args)
        local char = localPlayer.Character
        if char then
            char:BreakJoints()
            print("Character reset")
        end
    end,

    shield = (function()
        local shieldPart
        return function(args)
            local char = localPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if shieldPart and shieldPart.Parent then
                shieldPart:Destroy()
                shieldPart = nil
                print("Shield disabled")
            else
                shieldPart = Instance.new("Part")
                shieldPart.Shape = Enum.PartType.Ball
                shieldPart.Size = Vector3.new(6,6,6)
                shieldPart.Transparency = 0.5
                shieldPart.Anchored = false
                shieldPart.CanCollide = false
                shieldPart.Material = Enum.Material.Neon
                shieldPart.Color = Color3.fromRGB(0, 170, 255)
                shieldPart.Parent = char

                local weld = Instance.new("WeldConstraint")
                weld.Part0 = root
                weld.Part1 = shieldPart
                weld.Parent = shieldPart

                print("Shield enabled")
            end
        end
    end)(),

    autojump = (function()
        local jumping = false
        local taskConn

        return function(args)
            local char = localPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end

            jumping = not jumping

            if jumping then
                taskConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
                print("Auto jump enabled")
            else
                if taskConn then
                    taskConn:Disconnect()
                    taskConn = nil
                end
                print("Auto jump disabled")
            end
        end
    end)(),

}

-- Utility: check if message starts with any prefix, return prefix or nil
local function getPrefix(msg)
    for _, prefix in ipairs(prefixList) do
        if msg:sub(1, #prefix) == prefix then
            return prefix
        end
    end
    return nil
end

-- Parse command from message string
local function parseCommand(msg)
    local prefix = getPrefix(msg)
    if not prefix then return end
    local content = msg:sub(#prefix + 1)
    local split = {}
    for word in content:gmatch("%S+") do
        table.insert(split, word)
    end
    local cmd = split[1] and split[1]:lower()
    if not cmd then return end
    local args = {}
    for i = 2, #split do
        table.insert(args, split[i])
    end
    return cmd, args
end

-- Handle command if it exists
local function handleCommand(msg)
    local cmd, args = parseCommand(msg)
    if cmd and commands[cmd] then
        commands[cmd](args)
    end
end

-- Listen to Legacy Player.Chatted event
localPlayer.Chatted:Connect(function(msg)
    handleCommand(msg)
end)

-- Listen to TextChatService's OnIncomingMessage (new Roblox chat)
if TextChatService and TextChatService.OnIncomingMessage then
    TextChatService.OnIncomingMessage:Connect(function(textMessage)
        if textMessage.TextSource and textMessage.Text then
            if textMessage.TextSource.UserId == localPlayer.UserId then
                handleCommand(textMessage.Text)
            end
        end
    end)
end

print("Mobile-friendly chat command parser loaded with commands:")
for k in pairs(commands) do
    print(" -", k)
end
