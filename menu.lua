--[[
    ELITE CLICKER V3 - GLASS EDITION
    Design: Semi-transparent Glass-morphic UI
    Features: Tabs (Clicker, Misc, Credits), Robust Flight, Bugfixes
]]

-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- logic variables
local Clicks = 0
local Flying = false
local FlySpeed = 50
local FlyUnlocked = false
local ActiveTab = "Clicker"

-- UI state
local dragging, dragInput, dragStart, startPos

-- Utility: Safe parenting
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

-- BUG STAGE 3: Full Cleanup
if targetParent:FindFirstChild("EliteMenuV3") then targetParent.EliteMenuV3:Destroy() end
if targetParent:FindFirstChild("MobileFlyControls") then targetParent.MobileFlyControls:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteMenuV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- Main Frame (Glass Style)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.25 -- Semi-transparent
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8
MainStroke.Thickness = 1.5

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Sidebar.BackgroundTransparency = 0.4
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 110, 0, 10)
ContentArea.Size = UDim2.new(1, -120, 1, -20)
ContentArea.Parent = MainFrame

-- Tab Frames
local TabFrames = {}
local function CreateTabFrame(name)
    local f = Instance.new("ScrollingFrame")
    f.Name = name .. "Tab"
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 2
    f.Visible = false
    f.Parent = ContentArea

    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    TabFrames[name] = f
    return f
end

local clickerTab = CreateTabFrame("Clicker")
local miscTab = CreateTabFrame("Misc")
local creditsTab = CreateTabFrame("Credits")

-- UI Components
local function AddLabel(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.Text = text
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextSize = size or 14
    l.Parent = parent
    return l
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.BackgroundTransparency = 0.3
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    btn.TextSize = 13
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(80, 80, 80)
    s.Transparency = 0.5

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Switching Logic
local function ShowTab(name)
    for k, v in pairs(TabFrames) do v.Visible = false end
    if TabFrames[name] then TabFrames[name].Visible = true end
    ActiveTab = name
end

-- Sidebar Buttons
local function AddSidebarTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 13
    btn.Parent = Sidebar

    btn.MouseButton1Click:Connect(function()
        ShowTab(name)
    end)
end

local sidebarLayout = Instance.new("UIListLayout", Sidebar)
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

AddSidebarTab("Clicker")
AddSidebarTab("Misc")
AddSidebarTab("Credits")

-- CLICKER TAB
AddLabel(clickerTab, "CLICKER GAME", 18, Color3.fromRGB(0, 255, 180))
local clickDisplay = AddLabel(clickerTab, "Total Clicks: 0", 14)

AddButton(clickerTab, "CLICK! (+1)", function()
    Clicks = Clicks + 1
    clickDisplay.Text = "Total Clicks: " .. tostring(Clicks)
end)

-- MISC TAB (FLY)
AddLabel(miscTab, "UTILITIES", 18, Color3.fromRGB(255, 100, 0))

local MobileFlyGui = Instance.new("ScreenGui")
MobileFlyGui.Name = "MobileFlyControls"
MobileFlyGui.Enabled = false
MobileFlyGui.Parent = targetParent

local function CreateMobileBtn(name, text, pos, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 50, 0, 50)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.BackgroundTransparency = 0.4
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 25
    b.Parent = MobileFlyGui
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 25)
    local s = Instance.new("UIStroke", b)
    s.Color = color
    s.Thickness = 2
    return b
end

local upBtn = CreateMobileBtn("Up", "↑", UDim2.new(1, -120, 0.5, -60), Color3.fromRGB(0, 255, 150))
local downBtn = CreateMobileBtn("Down", "↓", UDim2.new(1, -120, 0.5, 10), Color3.fromRGB(255, 50, 50))

local moveUp, moveDown = false, false
upBtn.MouseButton1Down:Connect(function() moveUp = true end)
upBtn.MouseButton1Up:Connect(function() moveUp = false end)
downBtn.MouseButton1Down:Connect(function() moveDown = true end)
downBtn.MouseButton1Up:Connect(function() moveDown = false end)

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
            -- BUG STAGE 1: Check humanoid health
            while Flying and char.Parent and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 do
                local cam = workspace.CurrentCamera
                local moveDir = char.Humanoid.MoveDirection
                local velocity = moveDir * FlySpeed

                if moveUp then velocity = velocity + Vector3.new(0, FlySpeed, 0) end
                if moveDown then velocity = velocity + Vector3.new(0, -FlySpeed, 0) end

                bv.Velocity = velocity
                bg.CFrame = cam.CFrame
                task.wait()
            end
            -- BUG STAGE 5: Proper cleanup
            Flying = false
            MobileFlyGui.Enabled = false
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        end)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end

local flyToggleBtn
flyToggleBtn = AddButton(miscTab, "Unlock Fly (2000 Clicks)", function()
    if FlyUnlocked then
        ToggleFly()
        flyToggleBtn.Text = Flying and "Flight: ON" or "Flight: OFF"
    elseif Clicks >= 2000 then
        Clicks = Clicks - 2000
        FlyUnlocked = true
        clickDisplay.Text = "Total Clicks: " .. tostring(Clicks)
        flyToggleBtn.Text = "Flight: OFF"
        flyToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        flyToggleBtn.Text = "Need " .. (2000 - Clicks) .. " more!"
        task.wait(1)
        if not FlyUnlocked then flyToggleBtn.Text = "Unlock Fly (2000 Clicks)" end
    end
end)

-- CREDITS TAB
AddLabel(creditsTab, "CREDITS", 18, Color3.fromRGB(200, 0, 255))
AddLabel(creditsTab, "UI Design: vchilina27-design", 13)
AddLabel(creditsTab, "Code & Logic: Jules AI Agent", 13)
AddLabel(creditsTab, "Ideas: You!", 13)
AddLabel(creditsTab, "Version: 3.0 Glass", 10, Color3.fromRGB(150, 150, 150))

-- Dragging BUG STAGE 2: Refined logic
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

ShowTab("Clicker")
print("Elite Clicker V3 Glass successfully loaded with bugfixes.")
