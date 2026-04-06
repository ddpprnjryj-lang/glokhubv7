repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- NOTIFICATION
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "glok hub",
        Text = "Loaded!",
        Duration = 5
    })
end)

-- BASE POSITION (CHANGE THIS TO YOUR BASE)
local basePosition = Vector3.new(0,0,0)

-- SETTINGS
getgenv().AutoGrab = false
getgenv().ESPPlayers = false
getgenv().ESPBrainrot = false
getgenv().XRay = false
getgenv().Desync = false
getgenv().MoneyTarget = 100000000

-- GUI
local gui = Instance.new("ScreenGui")
pcall(function()
    gui.Parent = game.CoreGui
end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,260)
frame.Position = UDim2.new(0.5,-110,0.5,-130)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function makeButton(name, y, setting)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,-20,0,30)
    button.Position = UDim2.new(0,10,0,y)
    button.Text = name
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)

    button.MouseButton1Click:Connect(function()
        getgenv()[setting] = not getgenv()[setting]
        if getgenv()[setting] then
            button.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            button.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end)
end

makeButton("Auto Grab", 40, "AutoGrab")
makeButton("ESP Players", 80, "ESPPlayers")
makeButton("ESP Brainrot", 120, "ESPBrainrot")
makeButton("X-Ray", 160, "XRay")
makeButton("Desync", 200, "Desync")

-- SAFE TELEPORT
local function safeTP(pos)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(0,0,0)
        task.wait(0.2)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
    end
end

-- XRAY
RunService.RenderStepped:Connect(function()
    if getgenv().XRay then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0.5
            end
        end
    end
end)

-- DESYNC
local fakePos
RunService.Heartbeat:Connect(function()
    if getgenv().Desync and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not fakePos then fakePos = hrp.CFrame end
            hrp.CFrame = fakePos
        end
    end
end)

-- SIMPLE SCANNER (won’t crash)
spawn(function()
    while task.wait(5) do
        if getgenv().AutoGrab then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "ProximityPrompt" then
                    local model = v.Parent
                    if model and model:FindFirstChild("HumanoidRootPart") then
                        safeTP(model.HumanoidRootPart.Position)
                        task.wait(0.5)
                        pcall(function()
                            fireproximityprompt(v)
                        end)
                        task.wait(1)
                        safeTP(basePosition)
                        break
                    end
                end
            end
        end
    end
end)
