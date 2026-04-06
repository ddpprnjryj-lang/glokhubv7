repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
repeat task.wait() until player.Character
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

-- SETTINGS
local Settings = {
    AutoGrab = false,
    ESPPlayers = false,
    ESPBrainrot = false,
    XRay = false,
    Desync = false,
    ServerHop = false,
    AutoExecute = false
}

local MoneyTarget = 100000000
local basePosition = nil
local visitedServers = {}

-- NOTIFY
local function playBell()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9118823104"
    sound.Volume = 3
    sound.Parent = workspace
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "glok hub",
            Text = msg,
            Duration = 5
        })
    end)
    playBell()
end

notify("glok hub loaded")

-- GUI
local gui = Instance.new("ScreenGui")
pcall(function() gui.Parent = game.CoreGui end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,420)
frame.Position = UDim2.new(0.5,-130,0.5,-210)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function makeToggle(name, posY, settingName)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,-20,0,30)
    button.Position = UDim2.new(0,10,0,posY)
    button.Text = name
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(40,40,40)

    button.MouseButton1Click:Connect(function()
        Settings[settingName] = not Settings[settingName]
        if Settings[settingName] then
            button.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            button.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end)
end

local function makeButton(name, posY, callback)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,-20,0,30)
    button.Position = UDim2.new(0,10,0,posY)
    button.Text = name
    button.TextColor3 = Color3.new(1,1,1)
    button.BackgroundColor3 = Color3.fromRGB(70,70,70)

    button.MouseButton1Click:Connect(callback)
end

makeToggle("Auto Grab", 40, "AutoGrab")
makeToggle("ESP Players", 80, "ESPPlayers")
makeToggle("ESP Brainrot", 120, "ESPBrainrot")
makeToggle("X-Ray", 160, "XRay")
makeToggle("Desync", 200, "Desync")
makeToggle("Server Hop", 240, "ServerHop")
makeToggle("Auto Execute", 280, "AutoExecute")

makeButton("Set Base", 320, function()
    basePosition = player.Character.HumanoidRootPart.Position
    notify("Base position set!")
end)

makeButton("TP To Base", 360, function()
    if basePosition then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(basePosition)
    else
        notify("Set base first!")
    end
end)

-- XRAY
RunService.RenderStepped:Connect(function()
    if Settings.XRay then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0.5
            end
        end
    end
end)

-- ESP PLAYERS
RunService.RenderStepped:Connect(function()
    if Settings.ESPPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            end
        end
    end
end)

-- ESP BRAINROT
local function espBrainrot(model)
    if Settings.ESPBrainrot and model then
        if not model:FindFirstChild("Highlight") then
            Instance.new("Highlight", model)
        end
    end
end

-- MONEY PARSER
local function parseMoney(str)
    if not str then return 0 end
    str = tostring(str):lower()
    if str:find("b") then
        return tonumber(str:gsub("b","")) * 1000000000
    elseif str:find("m") then
        return tonumber(str:gsub("m","")) * 1000000
    elseif str:find("k") then
        return tonumber(str:gsub("k","")) * 1000
    end
    return tonumber(str) or 0
end

-- FIND BRAINROT
local function findBrainrot()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("StringValue") then
            local val = parseMoney(v.Text or v.Value)
            if val >= MoneyTarget then
                return v:FindFirstAncestorOfClass("Model")
            end
        end
    end
end

-- AUTO GRAB
local function grabBrainrot(model)
    if not model then return end
    if not Settings.AutoGrab then return end

    local hrp = player.Character.HumanoidRootPart

    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("ProximityPrompt") then
            hrp.CFrame = part.Parent.CFrame + Vector3.new(0,3,0)
            task.wait(0.3)
            fireproximityprompt(part)
            task.wait(0.5)

            if basePosition then
                hrp.CFrame = CFrame.new(basePosition)
            end
            break
        end
    end
end

-- SERVER HOP
local function hopServer()
    if not Settings.ServerHop then return end
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local data = HttpService:JSONDecode(game:HttpGet(url))
    for _, server in pairs(data.data) do
        if server.playing < server.maxPlayers and not visitedServers[server.id] then
            visitedServers[server.id] = true
            TeleportService:TeleportToPlaceInstance(placeId, server.id)
            break
        end
    end
end

-- LOOP
spawn(function()
    while task.wait(3) do
        local brainrot = findBrainrot()
        if brainrot then
            notify("100M+/sec Brainrot Found!")
            espBrainrot(brainrot)
            if Settings.AutoExecute then
                grabBrainrot(brainrot)
            end
        else
            hopServer()
        end
    end
end)
