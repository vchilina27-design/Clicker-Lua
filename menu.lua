--[[
    STYLISH LUAU MENU (ROBUST VERSION + CLICKER & FLY)
    Design: Modern Dark with Neon Accents
    Features: Clicker, Flight Unlock (2000 Clicks), Mobile Flight Controls
]]

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local Clicks = 0
local Flying = false
local FlySpeed = 50
local FlyUnlocked = false

-- Utility to get the best parent for the GUI
local function GetGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        local test = Instance.new("Frame")
        local canParent, _ = pcall(function() test.Parent = coreGui end)
        if canParent then test:Destroy() return coreGui end
    end
    if lp then return lp:WaitForChild("PlayerGui", 10) end
    return nil
end

local targetParent = GetGuiParent()
if not targetParent then return end

-- Cleanup
if targetParent:FindFirstChild("StylishMenuUI") then targetParent.StylishMenuUI:Destroy() end
if targetParent:FindFirstChild("MobileFlyControls") then targetParent.MobileFlyControls:Destroy() end

-- Main UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StylishMenuUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(70, 70, 80)
UIStroke.Thickness = 1.8
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 15)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "ELITE CLICKER V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Clicks Display
local ClickLabel = Instance.new("TextLabel")
ClickLabel.Name = "ClickLabel"
ClickLabel.BackgroundTransparency = 1
ClickLabel.Position = UDim2.new(0, 20, 0, 40)
ClickLabel.Size = UDim2.new(1, -40, 0, 20)
ClickLabel.Font = Enum.Font.GothamSemibold
ClickLabel.Text = "Clicks: 0"
ClickLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
ClickLabel.TextSize = 14
ClickLabel.TextXAlignment = Enum.TextXAlignment.Left
ClickLabel.Parent = MainFrame

local function UpdateClickLabel()
    ClickLabel.Text = "Clicks: " .. tostring(Clicks)
end

-- Decoration Line
local DecorationLine = Instance.new("Frame")
DecorationLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DecorationLine.Position = UDim2.new(0, 20, 0, 65)
DecorationLine.Size = UDim2.new(1, -40, 0, 2)
DecorationLine.BorderSizePixel = 0
DecorationLine.Parent = MainFrame

local LineGradient = Instance.new("UIGradient")
LineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255))
})
LineGradient.Parent = DecorationLine

-- Scrolling Container
local ButtonContainer = Instance.new("ScrollingFrame")
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 10, 0, 75)
ButtonContainer.Size = UDim2.new(1, -20, 1, -100)
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 400)
ButtonContainer.ScrollBarThickness = 2
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ButtonContainer

-- Mobile Fly Controls UI
local MobileFlyGui = Instance.new("ScreenGui")
MobileFlyGui.Name = "MobileFlyControls"
MobileFlyGui.Enabled = false
MobileFlyGui.Parent = targetParent

local FlyUpBtn = Instance.new("TextButton")
FlyUpBtn.Name = "FlyUp"
FlyUpBtn.Size = UDim2.new(0, 60, 0, 60)
FlyUpBtn.Position = UDim2.new(1, -150, 0.5, -70)
FlyUpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyUpBtn.Text = "↑"
FlyUpBtn.TextColor3 = Color3.new(1,1,1)
FlyUpBtn.TextSize = 30
FlyUpBtn.Parent = MobileFlyGui
Instance.new("UICorner", FlyUpBtn).CornerRadius = UDim.new(0, 30)
Instance.new("UIStroke", FlyUpBtn).Color = Color3.fromRGB(0, 255, 150)

local FlyDownBtn = Instance.new("TextButton")
FlyDownBtn.Name = "FlyDown"
FlyDownBtn.Size = UDim2.new(0, 60, 0, 60)
FlyDownBtn.Position = UDim2.new(1, -150, 0.5, 10)
FlyDownBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyDownBtn.Text = "↓"
FlyDownBtn.TextColor3 = Color3.new(1,1,1)
FlyDownBtn.TextSize = 30
FlyDownBtn.Parent = MobileFlyGui
Instance.new("UICorner", FlyDownBtn).CornerRadius = UDim.new(0, 30)
Instance.new("UIStroke", FlyDownBtn).Color = Color3.fromRGB(255, 50, 50)

-- Flight Variables for Input
local moveUp = false
local moveDown = false

FlyUpBtn.MouseButton1Down:Connect(function() moveUp = true end)
FlyUpBtn.MouseButton1Up:Connect(function() moveUp = false end)
FlyDownBtn.MouseButton1Down:Connect(function() moveDown = true end)
FlyDownBtn.MouseButton1Up:Connect(function() moveDown = false end)

-- Flight Logic
local bv, bg
local function ToggleFly()
    if not FlyUnlocked then return end
    Flying = not Flying
    MobileFlyGui.Enabled = Flying

    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    if Flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        char.Humanoid.PlatformStand = true

        task.spawn(function()
            while Flying and char.Parent do
                local cam = workspace.CurrentCamera
                local moveDir = char.Humanoid.MoveDirection
                local velocity = moveDir * FlySpeed

                if moveUp then
                    velocity = velocity + Vector3.new(0, FlySpeed, 0)
                elseif moveDown then
                    velocity = velocity + Vector3.new(0, -FlySpeed, 0)
                end

                bv.Velocity = velocity
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end

-- UI Helper
local function CreateButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 14
    btn.Parent = ButtonContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1.2
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Actions
CreateButton("CLICK (+1)", Color3.fromRGB(0, 255, 150), function()
    Clicks = Clicks + 1
    UpdateClickLabel()
end)

local flyBtn
flyBtn = CreateButton("UNLOCK FLY (2000 Clicks)", Color3.fromRGB(255, 150, 0), function()
    if FlyUnlocked then
        ToggleFly()
        flyBtn.Text = Flying and "FLY: ON" or "FLY: OFF"
        flyBtn.TextColor3 = Flying and Color3.new(0,1,0) or Color3.new(1,1,1)
    elseif Clicks >= 2000 then
        Clicks = Clicks - 2000
        FlyUnlocked = true
        UpdateClickLabel()
        flyBtn.Text = "FLY: OFF"
        flyBtn.UIStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        flyBtn.Text = "NEED " .. tostring(2000 - Clicks) .. " MORE!"
        task.wait(1)
        if not FlyUnlocked then flyBtn.Text = "UNLOCK FLY (2000 Clicks)" end
    end
end)

-- Draggable MainFrame (Basic)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("Elite Clicker V2 Initialized with Flight Support.")
