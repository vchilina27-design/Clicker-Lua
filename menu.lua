--[[
    ✨ ELITE SCRIPT V5 - GLASS NEON EDITION
    Design: Glassmorphic, Neon Accents, Ultra Smooth
    Features: Clicker, Fly (Mobile Support), Tab System
    Fixed: CoreGui permissions, Tab Crash, 404 Support
]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- Utility: Robust Gui Parenting
local function GetGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        -- Test permission
        local test = Instance.new("Frame")
        local canParent, _ = pcall(function() test.Parent = coreGui end)
        if canParent then
            test:Destroy()
            return coreGui
        end
    end
    -- Fallback to PlayerGui
    return lp:WaitForChild("PlayerGui", 10)
end

local targetParent = GetGuiParent()
if not targetParent then return end

-- Cleanup
if targetParent:FindFirstChild("EliteGlassUI") then targetParent.EliteGlassUI:Destroy() end
if targetParent:FindFirstChild("EliteMobileControls") then targetParent.EliteMobileControls:Destroy() end

-- Global State
local State = {
    Clicks = 0,
    Flying = false,
    FlySpeed = 50,
    FlyUnlocked = false,
    CurrentTab = nil
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteGlassUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BackgroundTransparency = 0.2 -- Glass effect
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 180, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6

-- Gradient for depth
local MainGradient = Instance.new("UIGradient", MainFrame)
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 10))
})
MainGradient.Rotation = 45

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 15)

-- Content Area
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -145, 1, -20)
Content.Position = UDim2.new(0, 140, 0, 10)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Helper Functions
local function CreateTween(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(table.unpack(info)), goal)
    tween:Play()
    return tween
end

local Tabs = {}
local function CreateTab(name, icon)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Btn"
    Btn.Size = UDim2.new(0.85, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.BackgroundTransparency = 1
    Btn.Text = icon .. "  " .. name
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    Btn.TextSize = 13
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local Group = Instance.new("CanvasGroup") -- CanvasGroup supports GroupTransparency!
    Group.Name = name .. "Tab"
    Group.Size = UDim2.new(1, 0, 1, 0)
    Group.BackgroundTransparency = 1
    Group.Visible = false
    Group.Parent = Content

    local Layout = Instance.new("UIListLayout", Group)
    Layout.Padding = UDim.new(0, 10)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Btn.MouseButton1Click:Connect(function()
        if State.CurrentTab == name then return end

        -- Deactivate current
        if State.CurrentTab and Tabs[State.CurrentTab] then
            local old = Tabs[State.CurrentTab]
            old.Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            CreateTween(old.Btn, {0.3}, {BackgroundTransparency = 1})
            old.Group.Visible = false
        end

        -- Activate new
        State.CurrentTab = name
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CreateTween(Btn, {0.3}, {BackgroundTransparency = 0.6})

        Group.Visible = true
        Group.GroupTransparency = 1
        CreateTween(Group, {0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out}, {GroupTransparency = 0})
    end)

    Tabs[name] = {Btn = Btn, Group = Group}
    return Group
end

local function AddButton(tab, text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0.95, 0, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    B.BackgroundTransparency = 0.4
    B.Text = text
    B.Font = Enum.Font.GothamSemibold
    B.TextColor3 = Color3.new(1,1,1)
    B.TextSize = 13
    B.Parent = tab

    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)
    local S = Instance.new("UIStroke", B)
    S.Color = Color3.fromRGB(80, 80, 80)
    S.Transparency = 0.5

    B.MouseButton1Click:Connect(callback)
    return B
end

local function AddLabel(tab, text, color)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0.95, 0, 0, 25)
    L.BackgroundTransparency = 1
    L.Text = text
    L.Font = Enum.Font.GothamMedium
    L.TextColor3 = color or Color3.new(1,1,1)
    L.TextSize = 14
    L.Parent = tab
    return L
end

-- TABS
local HomeTab = CreateTab("Clicker", "🖱️")
local UtilsTab = CreateTab("Utils", "🚀")
local CreditsTab = CreateTab("Credits", "💎")

-- CLICKER LOGIC
local clickLabel = AddLabel(HomeTab, "Total Clicks: 0")
AddButton(HomeTab, "CLICK ME!", function()
    State.Clicks = State.Clicks + 1
    clickLabel.Text = "Total Clicks: " .. State.Clicks
end)

-- UTILS (FLY)
local MobileControls = Instance.new("ScreenGui")
MobileControls.Name = "EliteMobileControls"
MobileControls.Enabled = false
MobileControls.Parent = targetParent

local function CreateMobileBtn(name, text, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 60, 0, 60)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    b.BackgroundTransparency = 0.4
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 30
    b.Parent = MobileControls
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 30)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(0, 180, 255)
    return b
end

local upBtn = CreateMobileBtn("Up", "↑", UDim2.new(1, -140, 0.5, -70))
local downBtn = CreateMobileBtn("Down", "↓", UDim2.new(1, -140, 0.5, 10))

local flyDir = {up = false, down = false}
upBtn.MouseButton1Down:Connect(function() flyDir.up = true end)
upBtn.MouseButton1Up:Connect(function() flyDir.up = false end)
downBtn.MouseButton1Down:Connect(function() flyDir.down = true end)
downBtn.MouseButton1Up:Connect(function() flyDir.down = false end)

local bv, bg
local function ToggleFly()
    if not State.FlyUnlocked then return end
    State.Flying = not State.Flying
    MobileControls.Enabled = State.Flying

    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if State.Flying then
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero

        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.CFrame = hrp.CFrame

        char.Humanoid.PlatformStand = true

        task.spawn(function()
            while State.Flying and char.Parent and char.Humanoid.Health > 0 do
                local cam = workspace.CurrentCamera
                local vel = char.Humanoid.MoveDirection * State.FlySpeed
                if flyDir.up then vel = vel + Vector3.new(0, State.FlySpeed, 0) end
                if flyDir.down then vel = vel + Vector3.new(0, -State.FlySpeed, 0) end

                bv.Velocity = vel
                bg.CFrame = cam.CFrame
                task.wait()
            end
            State.Flying = false
            MobileControls.Enabled = false
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            if char.Humanoid then char.Humanoid.PlatformStand = false end
        end)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end

local flyBtn
flyBtn = AddButton(UtilsTab, "Unlock Fly (2000 Clicks)", function()
    if State.FlyUnlocked then
        ToggleFly()
        flyBtn.Text = State.Flying and "Flight: ON" or "Flight: OFF"
    elseif State.Clicks >= 2000 then
        State.Clicks = State.Clicks - 2000
        clickLabel.Text = "Total Clicks: " .. State.Clicks
        State.FlyUnlocked = true
        flyBtn.Text = "Flight: OFF"
        flyBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        local original = flyBtn.Text
        flyBtn.Text = "Need " .. (2000 - State.Clicks) .. " more!"
        task.wait(1.5)
        flyBtn.Text = original
    end
end)

-- CREDITS
AddLabel(CreditsTab, "UI/UX: vchilina27-design", Color3.fromRGB(0, 180, 255))
AddLabel(CreditsTab, "Developer: Jules AI")
AddLabel(CreditsTab, "Version: 5.0 Stable")

-- DRAGGING
local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not UserInputService:GetFocusedTextBox() then
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

-- INIT
Tabs["Clicker"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Clicker"].Btn.BackgroundTransparency = 0.6
Tabs["Clicker"].Group.Visible = true
State.CurrentTab = "Clicker"

print("Elite Script V5 Loaded Successfully.")
