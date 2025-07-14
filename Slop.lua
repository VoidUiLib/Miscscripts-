-- Eclair Ultimate EXXXXXXXXXXXXXXXXXXXXXXTREME Logic™ 2.0 (Draggable Version)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local lastValues = { WalkSpeed = nil, JumpPower = nil }
local currentType = "WalkSpeed"
local livePreview = false
local applying = false

local function clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

local function flashGui(guiObject, color, duration)
	duration = duration or 0.3
	local original = guiObject.BackgroundColor3
	TweenService:Create(guiObject, TweenInfo.new(duration / 2), { BackgroundColor3 = color }):Play()
	task.delay(duration / 2, function()
		TweenService:Create(guiObject, TweenInfo.new(duration / 2), { BackgroundColor3 = original }):Play()
	end)
end

-- GUI Core
local gui = Instance.new("ScreenGui")
gui.Name = "EclairUltimate"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 360, 0, 160)
main.Position = UDim2.new(0.5, -180, 0.5, -80)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

-- Dropdown
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 110, 0, 26)
dropdown.Position = UDim2.new(0, 10, 0, 10)
dropdown.Text = currentType
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 14
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.Parent = main

local optionsFrame = Instance.new("Frame")
optionsFrame.Size = UDim2.new(0, 110, 0, 52)
optionsFrame.Position = UDim2.new(0, 10, 0, 36)
optionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
optionsFrame.Visible = false
optionsFrame.Parent = main

-- Input
local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.new(0, 100, 0, 26)
valueBox.Position = UDim2.new(0, 130, 0, 10)
valueBox.PlaceholderText = "Enter Value"
valueBox.Text = ""
valueBox.Font = Enum.Font.Gotham
valueBox.TextSize = 14
valueBox.TextColor3 = Color3.new(1, 1, 1)
valueBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
valueBox.ClearTextOnFocus = false
valueBox.Parent = main

-- Speed display
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 100, 0, 20)
speedLabel.Position = UDim2.new(0, 130, 0, 36)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.Text = ""
speedLabel.Parent = main

-- Button helper
local function makeButton(text, posX, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 26)
	btn.Position = UDim2.new(0, posX, 0, 64)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.Parent = main
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Logic
local function getHumanoid()
	local char = plr.Character or plr.CharacterAdded:Wait()
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyValue()
	if applying then return end
	applying = true

	local hum = getHumanoid()
	local val = tonumber(valueBox.Text)
	if hum and val then
		lastValues[currentType] = hum[currentType]
		if currentType == "WalkSpeed" then val = clamp(val, 0, 100)
		elseif currentType == "JumpPower" then val = clamp(val, 0, 200) end
		hum[currentType] = val
		flashGui(main, Color3.fromRGB(0, 150, 255))
	end
	applying = false
end

local function resetValue()
	local hum = getHumanoid()
	if hum then
		lastValues.WalkSpeed = hum.WalkSpeed
		lastValues.JumpPower = hum.JumpPower
		hum.WalkSpeed = 16
		hum.JumpPower = 50
		flashGui(main, Color3.fromRGB(255, 140, 0))
	end
end

local function undoValue()
	local hum = getHumanoid()
	if hum and lastValues[currentType] then
		hum[currentType] = lastValues[currentType]
		flashGui(main, Color3.fromRGB(100, 255, 100))
	end
end

makeButton("Apply", 10, applyValue)
makeButton("Reset", 110, resetValue)
makeButton("Undo", 210, undoValue)

-- Live preview
valueBox:GetPropertyChangedSignal("Text"):Connect(function()
	local val = tonumber(valueBox.Text)
	if val then
		if currentType == "WalkSpeed" then
			speedLabel.Text = string.format("%.2f m/s", val / 20)
		else
			speedLabel.Text = string.format("%.0f studs", val)
		end
	end
	if livePreview and val then
		applyValue()
	end
end)

local liveToggle = Instance.new("TextButton")
liveToggle.Size = UDim2.new(0, 340, 0, 22)
liveToggle.Position = UDim2.new(0, 10, 0, 120)
liveToggle.Text = "Live Preview: OFF"
liveToggle.Font = Enum.Font.Gotham
liveToggle.TextSize = 13
liveToggle.TextColor3 = Color3.new(1, 1, 1)
liveToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
liveToggle.Parent = main

liveToggle.MouseButton1Click:Connect(function()
	livePreview = not livePreview
	liveToggle.Text = "Live Preview: " .. (livePreview and "ON" or "OFF")
end)

-- Dropdown logic
dropdown.MouseButton1Click:Connect(function()
	optionsFrame.Visible = not optionsFrame.Visible
end)

local function createOption(text, yPos)
	local opt = Instance.new("TextButton")
	opt.Size = UDim2.new(1, 0, 0, 26)
	opt.Position = UDim2.new(0, 0, 0, yPos)
	opt.Text = text
	opt.TextColor3 = Color3.new(1, 1, 1)
	opt.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	opt.Font = Enum.Font.Gotham
	opt.TextSize = 14
	opt.Parent = optionsFrame
	opt.MouseButton1Click:Connect(function()
		currentType = text
		dropdown.Text = text
		optionsFrame.Visible = false
	end)
end

createOption("WalkSpeed", 0)
createOption("JumpPower", 26)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		optionsFrame.Visible = false
	end
end)

-- DRAGGABLE EXXXXXXXX™
local dragging, dragInput, dragStart, startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
