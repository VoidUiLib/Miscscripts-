-- Eclair Roblox GUI (compact + optimized) by Swimmiel

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local UIS = game:GetService("UserInputService")

-- Rainbow color generator (hue cycling)
local function rainbowColor(t)
    local hue = (t * 60) % 360
    return Color3.fromHSV(hue / 360, 1, 1)
end

-- State
local guiOpen = true

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EclairUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame (smaller)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -55)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Visible = guiOpen

-- Rounded corners
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Rainbow outline frame
local outline = Instance.new("Frame")
outline.Name = "RainbowOutline"
outline.BackgroundTransparency = 1
outline.Size = UDim2.new(1, 6, 1, 6)
outline.Position = UDim2.new(0, -3, 0, -3)
outline.ZIndex = 0
outline.Parent = mainFrame

local outlineStroke = Instance.new("UIStroke")
outlineStroke.Thickness = 3
outlineStroke.Transparency = 0
outlineStroke.Parent = outline
outlineStroke.Color = Color3.fromRGB(255, 0, 0)

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Eclair Speed Editor"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, 0, 0, 24)
titleLabel.Position = UDim2.new(0, 0, 0, 8)
titleLabel.Parent = mainFrame

-- Dropdown Container
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 130, 0, 28)
dropdownFrame.Position = UDim2.new(0, 12, 0, 38)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.Parent = mainFrame
dropdownFrame.ClipsDescendants = true
dropdownFrame.ZIndex = 1
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 6)

local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Size = UDim2.new(1, -24, 1, 0)
dropdownLabel.Position = UDim2.new(0, 8, 0, 0)
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.TextSize = 14
dropdownLabel.TextColor3 = Color3.new(1,1,1)
dropdownLabel.Text = "WalkSpeed"
dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
dropdownLabel.Parent = dropdownFrame

local dropdownArrow = Instance.new("TextLabel")
dropdownArrow.Size = UDim2.new(0, 16, 1, 0)
dropdownArrow.Position = UDim2.new(1, -20, 0, 0)
dropdownArrow.BackgroundTransparency = 1
dropdownArrow.Text = "▼"
dropdownArrow.TextColor3 = Color3.new(1,1,1)
dropdownArrow.Font = Enum.Font.GothamBold
dropdownArrow.TextSize = 18
dropdownArrow.Parent = dropdownFrame

-- Dropdown Options Frame (hidden by default)
local dropdownOptionsFrame = Instance.new("Frame")
dropdownOptionsFrame.Size = UDim2.new(0, 130, 0, 56)
dropdownOptionsFrame.Position = UDim2.new(0, 0, 1, 4)
dropdownOptionsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
dropdownOptionsFrame.Visible = false
dropdownOptionsFrame.Parent = dropdownFrame
dropdownOptionsFrame.ClipsDescendants = true
dropdownOptionsFrame.ZIndex = 2
Instance.new("UICorner", dropdownOptionsFrame).CornerRadius = UDim.new(0, 6)

local options = {"WalkSpeed", "JumpPower"}

for i, option in ipairs(options) do
    local optionLabel = Instance.new("TextButton")
    optionLabel.Size = UDim2.new(1, 0, 0, 28)
    optionLabel.Position = UDim2.new(0, 0, 0, (i-1)*28)
    optionLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    optionLabel.AutoButtonColor = false
    optionLabel.Font = Enum.Font.Gotham
    optionLabel.TextSize = 14
    optionLabel.TextColor3 = Color3.new(1,1,1)
    optionLabel.Text = option
    optionLabel.Parent = dropdownOptionsFrame

    optionLabel.MouseEnter:Connect(function()
        optionLabel.BackgroundColor3 = Color3.fromRGB(70,70,70)
    end)
    optionLabel.MouseLeave:Connect(function()
        optionLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
    end)

    optionLabel.MouseButton1Click:Connect(function()
        dropdownLabel.Text = option
        dropdownOptionsFrame.Visible = false
        dropdownArrow.Text = "▼"
    end)
end

-- Toggle dropdown visibility on click
dropdownFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dropdownOptionsFrame.Visible = not dropdownOptionsFrame.Visible
        dropdownArrow.Text = dropdownOptionsFrame.Visible and "▲" or "▼"
    end
end)

-- TextBox for input value
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 70, 0, 28)
inputBox.Position = UDim2.new(0, 155, 0, 38)
inputBox.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
inputBox.TextColor3 = Color3.new(0, 0, 0)
inputBox.ClearTextOnFocus = false
inputBox.PlaceholderText = "Value"
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.Text = ""
inputBox.Parent = mainFrame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

-- Apply button
local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0, 70, 0, 28)
applyBtn.Position = UDim2.new(0, 75, 0, 78)
applyBtn.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
applyBtn.TextColor3 = Color3.new(0, 0, 0)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 16
applyBtn.Text = "Apply"
applyBtn.Parent = mainFrame
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)

local applyOutline = Instance.new("UIStroke")
applyOutline.Thickness = 2
applyOutline.Color = Color3.fromHSV(0,1,1)
applyOutline.Parent = applyBtn

-- Rainbow outlines updater (less calls: one RunService Heartbeat for both outlines)
RunService.Heartbeat:Connect(function()
    local time = tick()
    local color = rainbowColor(time)
    applyOutline.Color = color
    outlineStroke.Color = color
end)

-- Apply action
applyBtn.MouseButton1Click:Connect(function()
    local selected = dropdownLabel.Text
    local val = tonumber(inputBox.Text)
    if not val then return end

    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if selected == "WalkSpeed" then
        humanoid.WalkSpeed = val
    elseif selected == "JumpPower" then
        humanoid.JumpPower = val
    end
end)

-- Toggle button (small rainbow button)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 32, 0, 32)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
toggleBtn.Text = "≡"
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local toggleOutline = Instance.new("UIStroke")
toggleOutline.Thickness = 3
toggleOutline.Parent = toggleBtn

-- Animate toggle outline rainbow with offset for difference
RunService.Heartbeat:Connect(function()
    local time = tick() + 1000
    toggleOutline.Color = rainbowColor(time)
end)

toggleBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    mainFrame.Visible = guiOpen
end)
