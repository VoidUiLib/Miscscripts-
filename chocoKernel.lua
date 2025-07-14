--// ChocoKernel Terminal v1.0 [CachyOS Terminal Style]
--// Launch Code: CHK-BOOTSPLASH-33X

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Create UI
local screen = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
screen.Name = "ChocoKernel"
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 480, 0, 280)
frame.Position = UDim2.new(0.5, -240, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.05
frame.ClipsDescendants = true

-- Draggable
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 8)

local terminalText = Instance.new("TextLabel", frame)
terminalText.Size = UDim2.new(1, -20, 1, -60)
terminalText.Position = UDim2.new(0, 10, 0, 10)
terminalText.TextXAlignment = Enum.TextXAlignment.Left
terminalText.TextYAlignment = Enum.TextYAlignment.Top
terminalText.BackgroundTransparency = 1
terminalText.Font = Enum.Font.Code
terminalText.TextColor3 = Color3.fromRGB(0, 255, 0)
terminalText.TextSize = 14
terminalText.Text = "[choco@kernel ~]$ "
terminalText.TextWrapped = true

local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 1, -40)
inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 14
inputBox.PlaceholderText = "Type a ChocoKernel command..."
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.ClearTextOnFocus = false
inputBox.Text = ""

local inputUICorner = Instance.new("UICorner", inputBox)
inputUICorner.CornerRadius = UDim.new(0, 4)

-- Script logic
local Registry = {
    eclair = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/Slop.lua",
    explus = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/Misc1.lua"
}

local function log(text)
    terminalText.Text = terminalText.Text .. "\n[choco@kernel ~]$ " .. text
end

local function runCommand(cmd)
    local args = string.split(cmd, " ")
    local main = args[1]:lower()
    local param = args[2] and args[2]:lower()

    if main == "choco" then
        local subcmd = args[2] and args[2]:lower()
        local target = args[3] and args[3]:lower()
        if subcmd == "get" then
            if Registry[target] then
                local success, result = pcall(function()
                    return game:HttpGet(Registry[target])
                end)
                if success then
                    writefile("Workspace/RbxOS/ChocoKernel/"..target..".lua", result)
                    log("Package '"..target.."' installed successfully.")
                else
                    log("Failed to install '"..target.."': "..tostring(result))
                end
            else
                log("Unknown package: "..tostring(target))
            end
        elseif subcmd == "run" then
            local path = "Workspace/RbxOS/ChocoKernel/"..target..".lua"
            if isfile(path) then
                local chunk = readfile(path)
                local success, err = pcall(function()
                    loadstring(chunk)()
                end)
                if success then
                    log("Running '"..target.."'...")
                else
                    log("Error running '"..target.."': "..err)
                end
            else
                log("Package not found. Use 'choco get "..target.."' first.")
            end
        else
            log("Unknown subcommand: "..tostring(subcmd))
        end
    elseif main == "clear" then
        terminalText.Text = "[choco@kernel ~]$ "
    elseif main == "help" then
        log("Available commands:")
        log(" - choco get <package>")
        log(" - choco run <package>")
        log(" - clear")
        log(" - help")
    else
        log("Unknown command: "..main)
    end
end

inputBox.FocusLost:Connect(function(enter)
    if enter and inputBox.Text ~= "" then
        runCommand(inputBox.Text)
        inputBox.Text = ""
    end
end)
