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
getgenv().MoneyTarget = 100000000 -- 100M/sec notifier
getgenv().ServerHop = true
getgenv().AutoGrab = false
getgenv().ESPPlayers = false
getgenv().ESPBrainrot = false
getgenv().XRay = false
getgenv().Desync = false
getgenv().AutoTeleportBase = true

local basePosition = Vector3.new(0,0,0) -- PUT YOUR BASE POSITION HERE
local visitedServers = {}

-- NOTIFICATION
local function playBell()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9118823104"
        sound.Volume = 3
        sound.Parent = workspace
        sound:Play()
        game.Debris:AddItem(sound, 3)
    end)
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
frame.Size = UDim2.new(0,260,0,320)
frame.Position = UDim2.new(0.5,-130,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

local function makeButton(name, posY, setting)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1,-20,0,30)
    button.Position = UDim2.new(0,10,0,posY)
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
makeButton("Server Hop", 240, "ServerHop")

-- DESYNC
local fakePos
RunService.Heartbeat:Connect(function()
    if getgenv().Desync and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if not fakePos then
                fakePos = hrp.CFrame
            end
            hrp.CFrame = fakePos
        end
    end
end)

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

-- ESP PLAYERS
local function updatePlayerESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            if getgenv().ESPPlayers then
                if not p.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.Parent = p.Character
                end
            else
                if p.Character:FindFirstChild("Highlight") then
                    p.Character.Highlight:Destroy()
                end
            end
        end
    end
end

-- ESP BRAINROT
local function espBrainrot(model)
    if not model:FindFirstChild("Highlight") then
        local hl = Instance.new("Highlight")
        hl.Parent = model
    end
end

-- PARSE MONEY
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

-- AUTO GRAB
local function grabBrainrot(model)
    if getgenv().AutoGrab and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and model:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = model.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
            task.wait(0.5)
            local prompt = model:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
            task.wait(0.5)
            if getgenv().AutoTeleportBase then
                hrp.CFrame = CFrame.new(basePosition)
            end
        end
    end
end

-- FIND BRAINROT
local function scan()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "MoneyPerSecond" or v.Name == "$/sec" then
            local val = 0
            pcall(function()
                val = parseMoney(v.Value or v.Text)
            end)

            if val >= getgenv().MoneyTarget then
                local model = v:FindFirstAncestorOfClass("Model")
                if model then
                    notify("100M+/sec Brainrot Found!")
                    if getgenv().ESPBrainrot then
                        espBrainrot(model)
                    end
                    grabBrainrot(model)
                    return true
                end
            end
        end
    end
    return false
end

-- SERVER HOP
local function hopServer()
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
    local data = HttpService:JSONDecode(game:HttpGet(url))
    for _, server in pairs(data.data) do
        if server.playing < server.maxPlayers and not visitedServers[server.id] then
            visitedServers[server.id] = true
            TeleportService:TeleportToPlaceInstance(placeId, server.id)
            task.wait(2)
        end
    end
end

-- LOOP
spawn(function()
    while task.wait(5) do
        updatePlayerESP()
        local found = scan()
        if not found and getgenv().ServerHop then
            hopServer()
        end
    end
end)
