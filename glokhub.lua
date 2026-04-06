repeat task.wait() until game:IsLoaded()

game.StarterGui:SetCore("SendNotification", {
    Title = "glok hub",
    Text = "SCRIPT LOADED",
    Duration = 5
})

local gui = Instance.new("ScreenGui")
pcall(function() gui.Parent = game.CoreGui end)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,100)
frame.Position = UDim2.new(0.5,-100,0.5,-50)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local text = Instance.new("TextLabel", frame)
text.Size = UDim2.new(1,0,1,0)
text.Text = "GLOK HUB WORKING"
text.TextColor3 = Color3.new(1,1,1)
text.BackgroundTransparency = 1

print("GLOK HUB LOADED")
