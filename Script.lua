--[[
    ✨ ULTIMATE STYLISH UI V7 - "NEON GLASS ELITE"
    Language: Luau (Roblox Optimized)
    Design: Glassmorphism, Neon Accents, Ultra-Smooth Transitions
    Features: Stylish UI + Flight + ESP + Remote Spy
]]

-- Services (Luau-style)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer

-- Robust Environment Detection
local function GetGuiParent(): Instance
    local success, coreGui = pcall(function() return CoreGui end)
    if success and coreGui then
        local test = Instance.new("Frame")
        local canParent = pcall(function() test.Parent = coreGui end)
        if canParent then test:Destroy() return coreGui end
    end
    return lp:WaitForChild("PlayerGui", 10)
end

local targetParent = GetGuiParent()
if not targetParent then return end

-- Cleanup previous
if targetParent:FindFirstChild("NeonGlassUI") then targetParent.NeonGlassUI:Destroy() end
if targetParent:FindFirstChild("FlyControlsUI") then targetParent.FlyControlsUI:Destroy() end

-- Global State
local State = {
    Flying = false,
    FlySpeed = 50,
    EspEnabled = false,
    RemoteSpyEnabled = false,
    CurrentTabName = nil
}

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonGlassUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.3 -- Glass effect
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Stylish Border
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 200, 255)
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Neon Gradient
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
Sidebar.BackgroundTransparency = 0.4
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 15)

local Layout = Instance.new("UIListLayout", Sidebar)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 20)

-- Content Area
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -160, 1, -30)
Container.Position = UDim2.new(0, 150, 0, 15)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Utility: Animation
local function Tween(obj, time, props)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- Tab Management
local Tabs = {}
local CurrentTabName = nil

local function CreateTab(name: string, icon: string)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Tab"
    Btn.Size = UDim2.new(0.9, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = icon .. "  " .. name
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    Btn.TextSize = 13
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

    local Group = Instance.new("CanvasGroup")
    Group.Name = name .. "Content"
    Group.Size = UDim2.new(1, 0, 1, 0)
    Group.BackgroundTransparency = 1
    Group.Visible = false
    Group.Parent = Container

    local ContentLayout = Instance.new("UIListLayout", Group)
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Btn.MouseButton1Click:Connect(function()
        if CurrentTabName == name then return end

        -- Reset previous
        if CurrentTabName and Tabs[CurrentTabName] then
            local t = Tabs[CurrentTabName]
            Tween(t.Btn, 0.3, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 180)})
            t.Group.Visible = false
        end

        -- Activate new
        CurrentTabName = name
        Tween(Btn, 0.3, {BackgroundTransparency = 0.7, TextColor3 = Color3.fromRGB(255, 255, 255)})
        Group.Visible = true
        Group.GroupTransparency = 1
        Tween(Group, 0.4, {GroupTransparency = 0})
    end)

    Tabs[name] = {Btn = Btn, Group = Group}
    return Group
end

-- UI Components
local function AddLabel(parent, text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 30)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextSize = 14
    l.Parent = parent
    return l
end

local function AddButton(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95, 0, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.BackgroundTransparency = 0.5
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 13
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(100, 100, 120)
    s.Transparency = 0.6

    b.MouseEnter:Connect(function()
        Tween(b, 0.2, {BackgroundColor3 = Color3.fromRGB(60, 60, 80), BackgroundTransparency = 0.3})
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.2, {BackgroundColor3 = Color3.fromRGB(40, 40, 50), BackgroundTransparency = 0.5})
    end)

    if callback then
        b.MouseButton1Click:Connect(callback)
    end
    return b
end

-- FLY LOGIC
local FlyControls = Instance.new("ScreenGui")
FlyControls.Name = "FlyControlsUI"
FlyControls.Enabled = false
FlyControls.Parent = targetParent

local function CreateFlyBtn(name, text, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 60, 0, 60)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    b.BackgroundTransparency = 0.4
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 30
    b.Parent = FlyControls
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 30)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(0, 180, 255)
    s.Thickness = 2
    return b
end

local upBtn = CreateFlyBtn("Up", "↑", UDim2.new(1, -140, 0.5, -70))
local downBtn = CreateFlyBtn("Down", "↓", UDim2.new(1, -140, 0.5, 10))

local flyDir = {up = false, down = false}
upBtn.MouseButton1Down:Connect(function() flyDir.up = true end)
upBtn.MouseButton1Up:Connect(function() flyDir.up = false end)
downBtn.MouseButton1Down:Connect(function() flyDir.down = true end)
downBtn.MouseButton1Up:Connect(function() flyDir.down = false end)

local bv, bg
local function ToggleFly()
    State.Flying = not State.Flying
    FlyControls.Enabled = State.Flying

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
            FlyControls.Enabled = false
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

-- ESP LOGIC
local function CreateHighlight(player)
    if player == lp then return end
    local function apply()
        if player.Character and not player.Character:FindFirstChild("ESPHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = player.Character
            highlight.FillColor = Color3.fromRGB(0, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Enabled = State.EspEnabled
            highlight.Parent = player.Character
        end
    end
    player.CharacterAdded:Connect(apply)
    if player.Character then apply() end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("ESPHighlight") then
            player.Character.ESPHighlight.Enabled = State.EspEnabled
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    CreateHighlight(player)
end
Players.PlayerAdded:Connect(CreateHighlight)

-- REMOTE SPY LOGIC
local SpyLogFrame = Instance.new("ScrollingFrame")
local SpyLogLayout = Instance.new("UIListLayout", SpyLogFrame)
SpyLogLayout.Padding = UDim.new(0, 5)

local function LogRemote(name, args)
    if not State.RemoteSpyEnabled then return end
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 0.8
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Text = string.format("[%s] %s: %s", os.date("%X"), name, HttpService:JSONEncode(args))
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = SpyLogFrame

    Instance.new("UICorner", label).CornerRadius = UDim.new(0, 4)

    SpyLogFrame.CanvasSize = UDim2.new(0, 0, 0, SpyLogLayout.AbsoluteContentSize.Y)
    if SpyLogFrame.CanvasPosition.Y >= SpyLogFrame.CanvasSize.Y.Offset - SpyLogFrame.AbsoluteSize.Y - 50 then
        SpyLogFrame.CanvasPosition = Vector2.new(0, SpyLogFrame.CanvasSize.Y.Offset)
    end
end

-- Hook FireServer
local success, err = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" and self.ClassName == "RemoteEvent" then
            task.spawn(function() LogRemote(self.Name, args) end)
        end

        return oldNamecall(self, ...)
    end)
end)

-- Initialize Tabs
local Home = CreateTab("Главная", "🏠")
local Visuals = CreateTab("Визуалы", "👁️")
local RemoteSpy = CreateTab("Remote Spy", "📡")
local Credits = CreateTab("Инфо", "🛡️")

-- Fill Home
AddLabel(Home, "Основные функции", Color3.fromRGB(0, 255, 255))
local flyBtnUI
flyBtnUI = AddButton(Home, "Полет: ВЫКЛ", function()
    ToggleFly()
    flyBtnUI.Text = State.Flying and "Полет: ВКЛ" or "Полет: ВЫКЛ"
    flyBtnUI.TextColor3 = State.Flying and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

-- Fill Visuals
AddLabel(Visuals, "ESP Функции", Color3.fromRGB(255, 255, 0))
local espBtnUI
espBtnUI = AddButton(Visuals, "Player ESP: ВЫКЛ", function()
    State.EspEnabled = not State.EspEnabled
    UpdateESP()
    espBtnUI.Text = State.EspEnabled and "Player ESP: ВКЛ" or "Player ESP: ВЫКЛ"
    espBtnUI.TextColor3 = State.EspEnabled and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

-- Fill Remote Spy
AddLabel(RemoteSpy, "RemoteEvent Monitor", Color3.fromRGB(255, 0, 255))
local spyBtnUI
spyBtnUI = AddButton(RemoteSpy, "Remote Spy: ВЫКЛ", function()
    State.RemoteSpyEnabled = not State.RemoteSpyEnabled
    spyBtnUI.Text = State.RemoteSpyEnabled and "Remote Spy: ВКЛ" or "Remote Spy: ВЫКЛ"
    spyBtnUI.TextColor3 = State.RemoteSpyEnabled and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

SpyLogFrame.Size = UDim2.new(1, 0, 1, -85)
SpyLogFrame.BackgroundTransparency = 0.9
SpyLogFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SpyLogFrame.BorderSizePixel = 0
SpyLogFrame.ScrollBarThickness = 2
SpyLogFrame.Parent = RemoteSpy

AddButton(RemoteSpy, "Очистить Лог", function()
    for _, child in pairs(SpyLogFrame:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    SpyLogFrame.CanvasSize = UDim2.new(0,0,0,0)
end)

-- Fill Credits
AddLabel(Credits, "Neon Glass Elite v7.0")
AddLabel(Credits, "Автор: vchilina27")
AddLabel(Credits, "Функции: Fly, ESP, Remote Spy")

-- Draggable Logic
local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

-- Default Tab
Tabs["Главная"].Btn.BackgroundTransparency = 0.7
Tabs["Главная"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Главная"].Group.Visible = true
CurrentTabName = "Главная"

print("Neon Glass Elite v7.0 Loaded.")
