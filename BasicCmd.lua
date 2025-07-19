-- ChocoKernel iCMD v1.2 (Mobile-Ready Command System)
-- Author: Swimmiel
-- EXXXXXXXXXXXXXXXXXXXXXXTREME LOGIC™

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")

local lp = Players.LocalPlayer
local char, hrp, hum

-- Refs auto updater
local function refresh()
	char = lp.Character or lp.CharacterAdded:Wait()
	hrp = char:WaitForChild("HumanoidRootPart")
	hum = char:WaitForChild("Humanoid")
end
refresh()

-- Chat connection
local function hookChat(callback)
	-- Legacy Chat
	lp.Chatted:Connect(callback)

	-- TextChatService Hook
	if TextChatService.TextChannels then
		local channel = TextChatService.TextChannels.RBXGeneral or TextChatService:FindFirstChildOfClass("TextChannel")
		if channel then
			channel.OnIncomingMessage = function(message)
				if message.TextSource and message.TextSource.UserId == lp.UserId then
					callback(message.Text)
				end
			end
		end
	end
end

-- Command logic
local commands = {}

commands.swim = function()
	refresh()
	local root = hrp
	if not root then return end

	-- Enable Swimming physics
	hum:ChangeState(Enum.HumanoidStateType.Swimming)

	local swimVelocity = Vector3.new(0, 4, 0)
	local swimLoop = RunService.RenderStepped:Connect(function()
		pcall(function()
			root.Velocity = swimVelocity
		end)
	end)

	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[iCMD]: Swimming enabled.",
		Color = Color3.fromRGB(0, 255, 255)
	})
end

commands.noclip = function()
	refresh()
	local con
	con = RunService.Stepped:Connect(function()
		for _, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") and v.CanCollide then
				v.CanCollide = false
			end
		end
	end)

	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[iCMD]: Noclip enabled.",
		Color = Color3.fromRGB(255, 255, 255)
	})
end

commands.ws = function(args)
	refresh()
	local speed = tonumber(args[2])
	if speed and hum then
		hum.WalkSpeed = speed
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[iCMD]: WalkSpeed set to " .. speed,
			Color = Color3.fromRGB(0, 255, 0)
		})
	end
end

commands.jp = function(args)
	refresh()
	local power = tonumber(args[2])
	if power and hum then
		hum.JumpPower = power
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[iCMD]: JumpPower set to " .. power,
			Color = Color3.fromRGB(255, 215, 0)
		})
	end
end

-- Parser
local prefix = "+"
local function onCommand(msg)
	if not msg:lower():sub(1, #prefix) == prefix then return end

	local split = msg:lower():split(" ")
	local cmd = split[1]:sub(#prefix + 1)

	if commands[cmd] then
		pcall(function()
			commands[cmd](split)
		end)
	end
end

-- Hook the chats
hookChat(onCommand)

-- UI boot button (for ChocoKernel)
local btn = Instance.new("TextButton")
btn.Text = "💻 Boot iCMD"
btn.Size = UDim2.new(0, 120, 0, 40)
btn.Position = UDim2.new(0, 10, 1, -50)
btn.AnchorPoint = Vector2.new(0, 1)
btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
btn.TextColor3 = Color3.fromRGB(0, 255, 127)
btn.TextScaled = true
btn.Font = Enum.Font.Code
btn.ZIndex = 10000
btn.Visible = true
btn.Parent = game.CoreGui or lp:WaitForChild("PlayerGui")

btn.MouseButton1Click:Connect(function()
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "[iCMD]: Boot successful. Type +cmd",
		Color = Color3.fromRGB(0, 255, 127)
	})
end)
