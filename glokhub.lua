repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
repeat task.wait() until player.Character
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

getgenv().Settings = {
    Notifier = false,
    AutoGrab = false,
    AutoExecute = false,
    ServerHop = false,
    AutoTPBase = false
}

local MoneyTarget = 100
local basePosition = nil
local visitedServers = {}

-- NOTIFY
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "glok hub",
            Text = msg,
            Duration = 5
        })
    end)
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,230,0,320)
frame.Position = UDim2.new(0.5,-115,0.5,-160)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- CLOSE BUTTON (X)
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(80,0,0)

-- OPEN BUTTON (GH)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,60,0,30)
openBtn.Position = UDim2.new(0.5,-30,0,0)
openBtn.Text = "GH"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
openBtn.Visible = false

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
end)

-- BUTTON MAKERS
local function toggleButton(name, y, setting)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        if Settings[setting] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end)
end

local function normalButton(name, y, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.MouseButton1Click:Connect(callback)
end

-- MENU BUTTONS
toggleButton("Notifier", 40, "Notifier")
toggleButton("Auto Grab", 80, "AutoGrab")
toggleButton("Auto Execute", 120, "AutoExecute")
toggleButton("Server Hop", 160, "ServerHop")
toggleButton("Auto TP Base", 200, "AutoTPBase")

normalButton("Set Base", 240, function()
    basePosition = player.Character.HumanoidRootPart.Position
    notify("Base Set")
end)

normalButton("TP To Base", 280, function()
    if basePosition then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(basePosition)
    end
end)

-- FIND BRAINROT
local function findBrainrot()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") then
            local text = string.lower(v.Text)
            if string.find(text, "m/sec") then
                local num = tonumber(string.match(text, "%d+"))
                if num and num >= MoneyTarget then
                    return v:FindFirstAncestorOfClass("Model")
                end
            end
        end
    end
end

-- GRAB
local function grab(model)
    if not model then return end
    if not Settings.AutoGrab then return end

    for _, v in pairs(model:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            player.Character.HumanoidRootPart.CFrame = v.Parent.CFrame + Vector3.new(0,3,0)
            task.wait(0.3)
            fireproximityprompt(v)
            task.wait(0.5)

            if Settings.AutoTPBase and basePosition then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(basePosition)
            end
            break
        end
    end
end

-- SERVER HOP
local function hop()
    if not Settings.ServerHop then return end
    local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local data = HttpService:JSONDecode(game:HttpGet(url))
    for _, s in pairs(data.data) do
        if s.playing < s.maxPlayers and not visitedServers[s.id] then
            visitedServers[s.id] = true
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end

-- LOOP
spawn(function()
    while task.wait(3) do
        if Settings.Notifier then
            local brainrot = findBrainrot()
            if brainrot then
                notify("100M Brainrot Found!")
                if Settings.AutoExecute then
                    grab(brainrot)
                end
            else
                hop()
            end
        end
    end
end)
