-- Eclair GUI HyperPolished™ by Swimmiel (Eman)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Helper: rainbow hue generator
local function rainbowColor(t)
	return Color3.fromHSV((t * 0.25) % 1, 1, 1)
end

-- Helper: Create rounded corner
local function roundify(inst, rad)
	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, rad or 8)
	uic.Parent = inst
end

-- Core GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "EclairGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0.5, -120, 0.45, -80)
frame.BackgroundColor3 = Color3.new(0,0,0)
roundify(frame, 10)

-- Rainbow outline
local outline = Instance.new("UIStroke", frame)
outline.Thickness = 3
outline.Color = Color3.fromRGB(255,0,0)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "Eclair GUI"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.Size = UDim2.new(1,0,0,28)
title.BackgroundTransparency = 1

-- Dropdown
local dropdown = Instance.new("TextButton", frame)
dropdown.Position = UDim2.new(0, 10, 0, 36)
dropdown.Size = UDim2.new(0, 100, 0, 26)
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.TextColor3 = Color3.new(1,1,1)
dropdown.TextSize = 14
dropdown.Text = "WalkSpeed"
dropdown.Font = Enum.Font.Gotham
roundify(dropdown)

local optionsFrame = Instance.new("Frame", dropdown)
optionsFrame.Position = UDim2.new(0, 0, 1, 2)
optionsFrame.Size = UDim2.new(1, 0, 0, 54)
optionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
optionsFrame.Visible = false
roundify(optionsFrame)

local options = {"WalkSpeed", "JumpPower"}
for i, opt in ipairs(options) do
	local btn = Instance.new("TextButton", optionsFrame)
	btn.Size = UDim2.new(1, 0, 0, 26)
	btn.Position = UDim2.new(0, 0, 0, (i - 1) * 26)
	btn.Text = opt
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.MouseButton1Click:Connect(function()
		dropdown.Text = opt
		optionsFrame.Visible = false
	end)
end

dropdown.MouseButton1Click:Connect(function()
	optionsFrame.Visible = not optionsFrame.Visible
end)

-- Textbox
local input = Instance.new("TextBox", frame)
input.Position = UDim2.new(0, 120, 0, 36)
input.Size = UDim2.new(0, 110, 0, 26)
input.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
input.PlaceholderText = "Enter value"
input.TextColor3 = Color3.new(0, 0, 0)
input.Font = Enum.Font.Gotham
input.TextSize = 14
roundify(input)

-- Tooltip
local tooltip = Instance.new("TextLabel", frame)
tooltip.Size = UDim2.new(1, 0, 0, 20)
tooltip.Position = UDim2.new(0, 0, 1, -20)
tooltip.BackgroundTransparency = 1
tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
tooltip.TextSize = 13
tooltip.Font = Enum.Font.Gotham
tooltip.Text = ""
tooltip.Visible = false

local function showTooltip(text)
	tooltip.Text = text
	tooltip.Visible = true
end

local function hideTooltip()
	tooltip.Visible = false
end

-- Live Preview Toggle
local previewToggle = Instance.new("TextButton", frame)
previewToggle.Position = UDim2.new(0, 10, 0, 68)
previewToggle.Size = UDim2.new(0, 100, 0, 24)
previewToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
previewToggle.Text = "Live Preview: OFF"
previewToggle.Font = Enum.Font.Gotham
previewToggle.TextColor3 = Color3.new(1,1,1)
previewToggle.TextSize = 13
roundify(previewToggle)

local livePreview = false
previewToggle.MouseButton1Click:Connect(function()
	livePreview = not livePreview
	previewToggle.Text = "Live Preview: " .. (livePreview and "ON" or "OFF")
end)

-- Apply Button
local apply = Instance.new("TextButton", frame)
apply.Position = UDim2.new(0, 120, 0, 68)
apply.Size = UDim2.new(0, 50, 0, 24)
apply.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
apply.Text = "Apply"
apply.Font = Enum.Font.GothamBold
apply.TextColor3 = Color3.new(0, 0, 0)
apply.TextSize = 13
roundify(apply)

-- Reset Button
local reset = Instance.new("TextButton", frame)
reset.Position = UDim2.new(0, 180, 0, 68)
reset.Size = UDim2.new(0, 50, 0, 24)
reset.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
reset.Text = "Reset"
reset.Font = Enum.Font.GothamBold
reset.TextColor3 = Color3.new(0, 0, 0)
reset.TextSize = 13
roundify(reset)

-- Action logic
local function applyValue()
	local val = tonumber(input.Text)
	if not val then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		if dropdown.Text == "WalkSpeed" then
			hum.WalkSpeed = val
		else
			hum.JumpPower = val
		end
	end
end

apply.MouseButton1Click:Connect(applyValue)
reset.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 16
		hum.JumpPower = 50
	end
end)

-- Live Preview Update
input:GetPropertyChangedSignal("Text"):Connect(function()
	if livePreview then
		applyValue()
	end
end)

-- Tooltips
apply.MouseEnter:Connect(function() showTooltip("Set value to character") end)
apply.MouseLeave:Connect(hideTooltip)
reset.MouseEnter:Connect(function() showTooltip("Reset to default") end)
reset.MouseLeave:Connect(hideTooltip)
previewToggle.MouseEnter:Connect(function() showTooltip("Toggles live mode") end)
previewToggle.MouseLeave:Connect(hideTooltip)

-- Rainbow Outline Pulse
RunService.Heartbeat:Connect(function()
	local t = tick()
	outline.Color = rainbowColor(t)
end)

-- Rainbow Toggle Button
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 36, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "≡"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
roundify(toggleBtn)

local toggleOutline = Instance.new("UIStroke", toggleBtn)
toggleOutline.Thickness = 3

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

RunService.Heartbeat:Connect(function()
	toggleOutline.Color = rainbowColor(tick() + 1)
end)
