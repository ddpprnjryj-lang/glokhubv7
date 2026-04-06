repeat task.wait() until game:IsLoaded()

if _G.GlokHubLoaded then return end
_G.GlokHubLoaded = true

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

_G.finderMenu = false
_G.xray = false

local basePosition = nil

-- GET HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- NOTIFY
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Glok Hub",
            Text = msg,
            Duration = 5
        })
    end)
end

-- BELL
local function playBell()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118823104"
    sound.Volume = 5
    sound.Parent = workspace
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

-- SAFE TELEPORT
local function stepTeleport(destination)
    local hrp = getHRP()
    local distance = (hrp.Position - destination).Magnitude
    local steps = math.clamp(math.floor(distance / 6), 5, 100)

    for i = 1, steps do
        local newPos = hrp.Position:Lerp(destination, i / steps)
        hrp.CFrame = CFrame.new(newPos + Vector3.new(0,3,0))
        task.wait(0.03)
    end

    hrp.CFrame = CFrame.new(destination + Vector3.new(0,3,0))
end

-- SET BASE
function setBase()
    basePosition = getHRP().Position
    notify("Base Saved")
end

-- TP TO BASE (NO DEATH)
function tpToBase()
    if not basePosition then
        notify("Set Base First")
        return
    end

    local char = player.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP()

    if hum then hum.PlatformStand = true end

    stepTeleport(basePosition)

    for i = 1, 25 do
        hrp.CFrame = CFrame.new(basePosition + Vector3.new(0,5,0))
        task.wait(0.04)
    end

    if hum then hum.PlatformStand = false end
end

-- MONEY PARSER
local function parseMoney(text)
    if not text then return 0 end
    text = string.lower(text)

    local num = string.match(text, "%d+%.?%d*")
    if not num then return 0 end

    num = tonumber(num)

    if text:find("b") then
        num = num * 1e9
    elseif text:find("m") then
        num = num * 1e6
    elseif text:find("k") then
        num = num * 1e3
    end

    return num
end

-- GRAB BRAINROT
local function grabBrainrot(model)
    if not basePosition then
        notify("Set Base First!")
        return
    end

    local targetPart =
        model:FindFirstChild("HumanoidRootPart") or
        model:FindFirstChild("Head") or
        model:FindFirstChildWhichIsA("BasePart")

    if targetPart then
        notify("Grabbing...")

        stepTeleport(targetPart.Position)
        task.wait(0.5)

        local grabbed = false

        for _, v in pairs(model:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                fireproximityprompt(v)
                grabbed = true
            end
        end

        if not grabbed then
            notify("No prompt found")
        end

        task.wait(0.5)

        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = getHRP()

        if hum then hum.PlatformStand = true end

        stepTeleport(basePosition)

        for i = 1, 25 do
            hrp.CFrame = CFrame.new(basePosition + Vector3.new(0,5,0))
            task.wait(0.04)
        end

        if hum then hum.PlatformStand = false end
    end
end

-- X RAY
task.spawn(function()
    while task.wait(1) do
        if _G.xray then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency < 0.6 then
                    v.Transparency = 0.6
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0.6 then
                    v.Transparency = 0
                end
            end
        end
    end
end)

-- FINDER LOOP
task.spawn(function()
    while task.wait(3) do
        if _G.finderMenu then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    if obj.Text and string.find(string.lower(obj.Text), "sec") then
                        local money = parseMoney(obj.Text)

                        if money >= 100000000 then
                            local model = obj:FindFirstAncestorOfClass("Model")

                            if model then
                                notify("Found: "..obj.Text)
                                playBell()
                                grabBrainrot(model)
                                task.wait(5)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- GUI
pcall(function()
    game.CoreGui:FindFirstChild("GlokHubUI"):Destroy()
end)

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GlokHubUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,220,0,340)
frame.Position = UDim2.new(0,50,0,100)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB V7"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,-20,0,30)
    button.Position = UDim2.new(0,10,0,yPos)
    button.Text = text.." : OFF"
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local state = false

    button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            button.Text = text.." : ON"
            button.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            button.Text = text.." : OFF"
            button.BackgroundColor3 = Color3.fromRGB(30,30,30)
        end
        callback(state)
    end)
end

createButton("Set Base", 40, function() setBase() end)
createButton("TP To Base", 80, function() tpToBase() end)
createButton("Brainrot Finder", 120, function(v) _G.finderMenu = v end)
createButton("X-Ray", 160, function(v) _G.xray = v end)
