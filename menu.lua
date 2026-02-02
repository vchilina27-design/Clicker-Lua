--[[
    ✨ ULTIMATE STYLISH UI V6 - "NEON GLASS" (NO FUNCTIONS)
    Language: Luau (Roblox Optimized)
    Design: Glassmorphism, Neon Accents, Ultra-Smooth Transitions
    Features: Strictly Visual UI Menu (Без Функций)
]]

-- Services (Luau-style)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeonGlassUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
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
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
Sidebar.BackgroundTransparency = 0.4
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 15)

local Layout = Instance.new("UIListLayout", Sidebar)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 20)

-- Content Area
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -170, 1, -30)
Container.Position = UDim2.new(0, 160, 0, 15)
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
local CurrentTab = nil

local function CreateTab(name: string, icon: string)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Tab"
    Btn.Size = UDim2.new(0.9, 0, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    Btn.BackgroundTransparency = 1
    Btn.Text = icon .. "  " .. name
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    Btn.TextSize = 14
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
        if CurrentTab == name then return end

        -- Reset previous
        if CurrentTab and Tabs[CurrentTab] then
            local t = Tabs[CurrentTab]
            Tween(t.Btn, 0.3, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180, 180, 180)})
            t.Group.Visible = false
        end

        -- Activate new
        CurrentTab = name
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
    l.TextSize = 15
    l.Parent = parent
end

local function AddButton(parent, text)
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
end

-- Initialize Tabs
local Home = CreateTab("Главная", "🏠")
local Settings = CreateTab("Настройки", "⚙️")
local Credits = CreateTab("Инфо", "🛡️")

-- Fill Tabs (No functions, just style)
AddLabel(Home, "Добро пожаловать", Color3.fromRGB(0, 255, 255))
AddButton(Home, "Красивая Кнопка 1")
AddButton(Home, "Красивая Кнопка 2")

AddLabel(Settings, "Визуальные Настройки")
AddButton(Settings, "Сменить Тему")
AddButton(Settings, "Прозрачность")

AddLabel(Credits, "Neon Glass UI")
AddLabel(Credits, "Автор: vchilina27")
AddLabel(Credits, "Версия: 6.0 Luau")

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
CurrentTab = "Главная"

print("Neon Glass UI (Luau) Loaded Successfully.")
