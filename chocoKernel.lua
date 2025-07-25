--// ChocoKernel Terminal v1.2  
--// Launch Code: CHK-BOOTSPLASH-33X

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Utility JSON encode/decode (basic)
local function encodeJSON(tbl)
    local success, json = pcall(function()
        return game:GetService("HttpService"):JSONEncode(tbl)
    end)
    return success and json or "{}"
end
local function decodeJSON(str)
    local success, tbl = pcall(function()
        return game:GetService("HttpService"):JSONDecode(str)
    end)
    return success and tbl or {}
end

-- Folders & Config
local installDir = "Workspace/Apt/"
local configPath = installDir .. "config.json"
if not isfolder(installDir) then
    makefolder(installDir)
end

-- Load saved hardware mode from config or default AMD
local config = {}
if isfile(configPath) then
    local contents = readfile(configPath)
    config = decodeJSON(contents)
end
local hardwareMode = config.hardwareMode or "AMD"

-- Package registry
local Registry = {
    eclair  = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/Slop.lua",
    explus  = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/Misc1.lua",
    blume   = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/Flag.lua",
    admin   = "https://raw.githubusercontent.com/VoidUiLib/Miscscripts-/refs/heads/main/BasicCmd.lua"
}

-- Create UI
local screen = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
screen.Name = "ChocoKernel"
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 480, 0, 300) -- increased height for topbar
frame.Position = UDim2.new(0.5, -240, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.05
frame.ClipsDescendants = true
frame.Active = true
frame.Draggable = true

local uicorner = Instance.new("UICorner", frame)
uicorner.CornerRadius = UDim.new(0, 8)

-- Topbar frame
local topbar = Instance.new("Frame", frame)
topbar.Size = UDim2.new(1, 0, 0, 30)
topbar.Position = UDim2.new(0, 0, 0, 0)
topbar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topbar.BorderSizePixel = 0

local topbarUICorner = Instance.new("UICorner", topbar)
topbarUICorner.CornerRadius = UDim.new(0, 8)

-- Left terminal icon (3 circles like Linux/macOS window controls)
local iconContainer = Instance.new("Frame", topbar)
iconContainer.Size = UDim2.new(0, 70, 0, 30)
iconContainer.Position = UDim2.new(0, 10, 0, 0)
iconContainer.BackgroundTransparency = 1

local function createCircle(color, xOffset)
    local circle = Instance.new("Frame", iconContainer)
    circle.Size = UDim2.new(0, 12, 0, 12)
    circle.Position = UDim2.new(0, xOffset, 0, 9)
    circle.BackgroundColor3 = color
    circle.BorderSizePixel = 0
    circle.AnchorPoint = Vector2.new(0, 0)
    local circleCorner = Instance.new("UICorner", circle)
    circleCorner.CornerRadius = UDim.new(1, 0)
    return circle
end

createCircle(Color3.fromRGB(255, 95, 86), 0)    -- red (close)
createCircle(Color3.fromRGB(255, 189, 46), 20)   -- yellow (minimize)
createCircle(Color3.fromRGB(39, 201, 63), 40)    -- green (maximize)

-- Title label (center)
local titleLabel = Instance.new("TextLabel", topbar)
titleLabel.Size = UDim2.new(1, -140, 1, 0)
titleLabel.Position = UDim2.new(0, 70, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.Text = "ChocoKernel Terminal"
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Minimize & Close Buttons (right side)
local buttonContainer = Instance.new("Frame", topbar)
buttonContainer.Size = UDim2.new(0, 60, 1, 0)
buttonContainer.Position = UDim2.new(1, -70, 0, 0)
buttonContainer.BackgroundTransparency = 1

local function createButton(text, xPos)
    local btn = Instance.new("TextButton", buttonContainer)
    btn.Size = UDim2.new(0, 25, 0, 20)
    btn.Position = UDim2.new(0, xPos, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Code
    btn.TextSize = 18
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Text = text
    btn.AutoButtonColor = true
    local uic = Instance.new("UICorner", btn)
    uic.CornerRadius = UDim.new(0, 4)
    return btn
end

local minimizeBtn = createButton("-", 0)
local closeBtn = createButton("×", 35)

-- Terminal content container (everything except topbar)
local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1

-- Terminal text label
local terminalText = Instance.new("TextLabel", contentFrame)
terminalText.Size = UDim2.new(1, -20, 1, -60)
terminalText.Position = UDim2.new(0, 10, 0, 10)
terminalText.TextXAlignment = Enum.TextXAlignment.Left
terminalText.TextYAlignment = Enum.TextYAlignment.Top
terminalText.BackgroundTransparency = 1
terminalText.Font = Enum.Font.Code
terminalText.TextColor3 = Color3.fromRGB(0, 255, 0)
terminalText.TextSize = 14
terminalText.TextWrapped = true

-- Hardware specs text for modes
local hardwareSpecs = {
    Intel = [[
CPU: Intel Core i7-10700K
GPU: NVIDIA RTX 2080 Ti
RAM: 32GB DDR4
OS: ChocoLinux 1.0
]],
    AMD = [[
CPU: AMD Ryzen 7 7800X3D
GPU: Radeon RX 6600
RAM: 32GB DDR5
OS: ChocoLinux 1.0
]],
    Joke = [[
CPU: Intel i8 8700X3D
GPU: GTX 6600XT
RAM: 48GB DDR9
OS: ChocoLinux Joke Edition
]]
}

-- Input box
local inputBox = Instance.new("TextBox", contentFrame)
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

-- Initial terminal text with hardware specs
terminalText.Text = (hardwareSpecs[hardwareMode] or hardwareSpecs.AMD) .. "\n[choco@kernel ~]$ "

-- Button functionality
minimizeBtn.MouseButton1Click:Connect(function()
    contentFrame.Visible = not contentFrame.Visible
    minimizeBtn.Text = contentFrame.Visible and "-" or "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    screen:Destroy()
end)

-- Logger function
local function log(text)
    local base = terminalText.Text:gsub("_$", "")
    terminalText.Text = base .. "\n[choco@kernel ~]$ " .. text
end

-- Save hardware mode to config file
local function saveConfig()
    config.hardwareMode = hardwareMode
    local success, err = pcall(function()
        writefile(configPath, encodeJSON(config))
    end)
    if not success then
        log("Failed to save config: " .. tostring(err))
    end
end

-- Command runner logic
local function runCommand(cmd)
    local args = string.split(cmd, " ")
    local main = args[1] and args[1]:lower() or ""
    local param1 = args[2] and args[2]:lower()
    local param2 = args[3] and args[3]:lower()

    if main == "choco" then
        if param1 == "get" and param2 then
            if Registry[param2] then
                local success, result = pcall(function()
                    return game:HttpGet(Registry[param2])
                end)
                if success then
                    if not isfolder(installDir) then
                        makefolder(installDir)
                    end
                    writefile(installDir .. param2 .. ".lua", result)
                    log("Package '" .. param2 .. "' installed successfully.")
                else
                    log("Failed to install '" .. param2 .. "': " .. tostring(result))
                end
            else
                log("Unknown package: " .. tostring(param2))
            end
        elseif param1 == "run" and param2 then
            local path = installDir .. param2 .. ".lua"
            if isfile(path) then
                local chunk = readfile(path)
                local success, err = pcall(function()
                    loadstring(chunk)()
                end)
                if success then
                    log("Running '" .. param2 .. "'...")
                else
                    log("Error running '" .. param2 .. "': " .. err)
                end
            else
                log("Package not found. Use 'choco get " .. param2 .. "' first.")
            end
        elseif param1 == "set" and param2 then
            local modes = {intel = true, amd = true, joke = true}
            if modes[param2] then
                hardwareMode = param2:sub(1,1):upper() .. param2:sub(2) -- Capitalize first letter
                saveConfig()
                log("Hardware mode set to " .. hardwareMode .. ". Restart to apply.")
            else
                log("Unknown hardware mode. Available: Intel, AMD, Joke")
            end
        else
            log("Unknown subcommand or missing argument. Use 'help' for commands.")
        end

    elseif main == "ls" then
        if not isfolder(installDir) then
            log("No packages installed.")
            return
        end
        local files = listfiles(installDir)
        if #files == 0 then
            log("No packages installed.")
            return
        end
        local names = {}
        for _, f in ipairs(files) do
            local filename = f:match("([^/\\]+)%.lua$")
            if filename then
                table.insert(names, filename)
            end
        end
        log("Installed packages:\n" .. table.concat(names, ", "))

    elseif main == "rm" then
        if not param1 then
            log("Usage: rm <package>")
            return
        end
        local path = installDir .. param1 .. ".lua"
        if isfile(path) then
            delfile(path)
            log("Removed package '" .. param1 .. "'.")
        else
            log("Package '" .. param1 .. "' not found.")
        end

    elseif main == "clear" then
        terminalText.Text = (hardwareSpecs[hardwareMode] or hardwareSpecs.AMD) .. "\n[choco@kernel ~]$ "

    elseif main == "help" then
        log("Available commands:")
        log(" - choco get <package>")
        log(" - choco run <package>")
        log(" - choco set <Intel|AMD|Joke>")
        log(" - ls")
        log(" - rm <package>")
        log(" - clear")
        log(" - help")

    else
        log("Unknown command: " .. main)
    end
end

-- Input handler
inputBox.FocusLost:Connect(function(enter)
    if enter and inputBox.Text ~= "" then
        runCommand(inputBox.Text)
        inputBox.Text = ""
    end
end)

-- Blinking cursor effect
local showCursor = true
spawn(function()
    while screen.Parent do
        local baseText = terminalText.Text:gsub("_$", "")
        if showCursor then
            terminalText.Text = baseText .. "_"
        else
            terminalText.Text = baseText
        end
        showCursor = not showCursor
        task.wait(0.6)
    end
end)
