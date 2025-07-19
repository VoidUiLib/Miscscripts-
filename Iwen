--// Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Aimbot³ | Sirius Edition",
    LoadingTitle = "Aimbot³ Booting...",
    LoadingSubtitle = "Locking... Targeting... Calibrating...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Aimbot3", -- Config folder
        FileName = "AimbotSettings"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false -- disabled FPS punishment system as requested
})

--// Globals
local aimbotEnabled = false
local useSmooth = false
local lockPart = "Torso"
local teamCheck = true
local wallCheck = true

--// Aimbot Functions
local function isVisible(target)
    if not wallCheck then return true end
    local origin = workspace.CurrentCamera.CFrame.Position
    local partPos = target.Position
    local result = workspace:Raycast(origin, (partPos - origin).Unit * 999, RaycastParams.new())
    return not result or result.Instance:IsDescendantOf(target.Parent)
end

local function getClosestTarget()
    local closest = nil
    local shortestDist = math.huge
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            if hum.Health > 0 then
                if not teamCheck or plr.Team ~= game.Players.LocalPlayer.Team then
                    local part = plr.Character:FindFirstChild(lockPart)
                    if part and isVisible(part) then
                        local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                            if dist < shortestDist then
                                closest = part
                                shortestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

--// Aimbot loop
task.spawn(function()
    local RunService = game:GetService("RunService")
    while task.wait() do
        if aimbotEnabled then
            local target = getClosestTarget()
            if target then
                local cam = workspace.CurrentCamera
                local dir = (target.Position - cam.CFrame.Position).Unit
                if useSmooth then
                    cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, target.Position), 0.2)
                else
                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
                end
            end
        end
    end
end)

--// UI Tabs & Elements
local AimbotTab = Window:CreateTab("Aimbot³", 127) -- 127 = crosshair Lucide icon

AimbotTab:CreateToggle({
    Name = "Enable Aimbot³",
    CurrentValue = false,
    Flag = "aimbot_toggle",
    Callback = function(Value)
        aimbotEnabled = Value
        Rayfield:Notify({
            Title = "Aimbot³",
            Content = Value and "Aimbot Activated" or "Aimbot Deactivated",
            Duration = 4,
            Image = 127,
        })
    end
})

AimbotTab:CreateToggle({
    Name = "Use Smooth Aim",
    CurrentValue = false,
    Flag = "smooth_toggle",
    Callback = function(Value)
        useSmooth = Value
    end
})

AimbotTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "Torso"},
    CurrentOption = "Torso",
    Flag = "target_part",
    Callback = function(Option)
        lockPart = Option
    end
})

AimbotTab:CreateToggle({
    Name = "Enable Team Check",
    CurrentValue = true,
    Flag = "team_check",
    Callback = function(Value)
        teamCheck = Value
    end
})

AimbotTab:CreateToggle({
    Name = "Enable Wall Check",
    CurrentValue = true,
    Flag = "wall_check",
    Callback = function(Value)
        wallCheck = Value
    end
})

--// Detection Notification (e.g., enemies behind you)
task.spawn(function()
    while true do
        task.wait(1.5)
        for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild(lockPart) then
                local dir = (plr.Character[lockPart].Position - workspace.CurrentCamera.CFrame.Position).Unit
                local dot = workspace.CurrentCamera.CFrame.LookVector:Dot(dir)
                if dot < 0 and plr.Team ~= game.Players.LocalPlayer.Team then
                    Rayfield:Notify({
                        Title = "Enemy Detected!",
                        Content = plr.Name .. " is behind you!",
                        Duration = 3,
                        Image = 132 -- alert icon
                    })
                end
            end
        end
    end
end)
