-- Not So Basic Now??
-- CommandLib.lua
local CommandUI = {}
CommandUI.__index = CommandUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Helper to create UI objects
local function new(inst, props)
	local obj = Instance.new(inst)
	for i,v in pairs(props) do
		obj[i] = v
	end
	return obj
end

-- UI builder
function CommandUI:CreateWindow(config)
	config = config or {}
	local self = setmetatable({}, CommandUI)

	self.Name = config.Name or "Command UI"
	self.Width = config.Width or 360
	self.Height = config.Height or 180
	self.Position = config.Position or "BottomLeft"
	self.Commands = {}
	self.Aliases = {}

	-- Build UI
	local gui = LocalPlayer:WaitForChild("PlayerGui")
	self.Window = new("Frame", {
		Size = UDim2.new(0, self.Width, 0, self.Height),
		AnchorPoint = Vector2.new(0,1),
		Position = UDim2.new(0, 10, 1, -10),
		BackgroundColor3 = Color3.fromRGB(30,30,30),
		BackgroundTransparency = 0.15,
		ClipsDescendants = true,
		Parent = gui,
		Name = self.Name:gsub(" ", "")
	})

	new("UICorner", {
		CornerRadius = UDim.new(0,10),
		Parent = self.Window
	})

	new("UIStroke", {
		Color = Color3.fromRGB(60, 60, 60),
		Thickness = 1,
		Parent = self.Window
	})

	-- Output
	local outputScroll = new("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -60),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0,0,0,0),
		ScrollBarThickness = 4,
		Parent = self.Window
	})

	self.Output = new("TextLabel", {
		Size = UDim2.new(1,0,0,0),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255,255,255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextWrapped = true,
		Text = "",
		Parent = outputScroll
	})

	self.Output:GetPropertyChangedSignal("Text"):Connect(function()
		self.Output.Size = UDim2.new(1,0,0,self.Output.TextBounds.Y + 5)
		outputScroll.CanvasSize = UDim2.new(0, 0, 0, self.Output.AbsoluteSize.Y)
		outputScroll.CanvasPosition = Vector2.new(0, self.Output.AbsoluteSize.Y)
	end)

	-- Input
	self.Input = new("TextBox", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 1, -40),
		BackgroundColor3 = Color3.fromRGB(40,40,40),
		TextColor3 = Color3.new(1,1,1),
		Font = Enum.Font.SourceSans,
		TextSize = 18,
		PlaceholderText = "Enter command...",
		ClearTextOnFocus = false,
		Parent = self.Window
	})

	-- Notify
	self.Notification = new("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 1, -70),
		BackgroundColor3 = Color3.fromRGB(70, 70, 70),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSans,
		TextSize = 14,
		TextStrokeTransparency = 0.7,
		Text = "",
		Visible = false,
		Parent = self.Window
	})

	-- Dropdown
	self.Dropdown = new("Frame", {
		Size = UDim2.new(1, -20, 0, 100),
		Position = UDim2.new(0, 10, 1, -10 - 100),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = 0.2,
		Visible = false,
		Parent = self.Window
	})
	new("UICorner", {CornerRadius = UDim.new(0,10), Parent = self.Dropdown})

	self.Input:GetPropertyChangedSignal("Text"):Connect(function()
		local input = self.Input.Text:lower()
		self:UpdateDropdown(input)
	end)

	self.Input.FocusLost:Connect(function(enter)
		if enter then
			local text = self.Input.Text
			self:Print("> " .. text)
			self:Run(text)
			self.Input.Text = ""
			self.Dropdown.Visible = false
		end
	end)

	return self
end

function CommandUI:AddCommand(data)
	assert(data.Name and typeof(data.Callback) == "function", "Invalid command format")
	local name = data.Name:lower()
	self.Commands[name] = data.Callback
	if data.Aliases then
		for _, alias in pairs(data.Aliases) do
			self.Commands[alias:lower()] = data.Callback
		end
	end
end

function CommandUI:Run(commandText)
	local args = {}
	for word in commandText:gmatch("%S+") do table.insert(args, word) end
	local cmd = table.remove(args, 1)
	if not cmd then return end
	cmd = cmd:lower()
	local func = self.Commands[cmd]
	if func then
		local ok, err = pcall(func, args)
		if not ok then self:Notify("Error: "..err, true) end
	else
		self:Notify("Unknown command: "..cmd, true)
	end
end

function CommandUI:Print(text)
	self.Output.Text = self.Output.Text .. text .. "\n"
end

function CommandUI:Notify(text, isError)
	self.Notification.Text = text
	self.Notification.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 255, 150)
	self.Notification.Visible = true
	local tweenIn = TweenService:Create(self.Notification, TweenInfo.new(0.3), {
		TextTransparency = 0, BackgroundTransparency = 0.5
	})
	local tweenOut = TweenService:Create(self.Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 1.5), {
		TextTransparency = 1, BackgroundTransparency = 1
	})
	tweenIn:Play()
	tweenIn.Completed:Wait()
	tweenOut:Play()
	tweenOut.Completed:Wait()
	self.Notification.Visible = false
end

function CommandUI:UpdateDropdown(input)
	for _, child in ipairs(self.Dropdown:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local matches = {}
	for name in pairs(self.Commands) do
		if name:sub(1, #input) == input then
			table.insert(matches, name)
		end
	end

	if #matches == 0 then
		self.Dropdown.Visible = false
		return
	end

	table.sort(matches)
	for _, match in ipairs(matches) do
		local btn = new("TextButton", {
			Size = UDim2.new(1, -10, 0, 24),
			BackgroundTransparency = 0.8,
			Text = match,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.SourceSans,
			TextSize = 16,
			Parent = self.Dropdown
		})
		btn.MouseButton1Click:Connect(function()
			self.Input.Text = match .. " "
			self.Input:CaptureFocus()
			self.Dropdown.Visible = false
		end)
	end

	self.Dropdown.Visible = true
end

return CommandUI
