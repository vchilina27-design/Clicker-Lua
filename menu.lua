--[[
    ELITE CLICKER V4 - PRO GLASS
    Design: Professional semi-transparent UI with smooth animations.
    Features: Tabs (Clicker, Misc, Credits), Fly unlock, ESP unlock, mobile fly controls.
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Logic state
local Clicks = 0
local Flying = false
local FlySpeed = 50
local FlyUnlocked = false

local EspUnlocked = false
local EspEnabled = false

local ActiveTab = "Clicker"

-- Drag state
local dragging, dragStart, startPos

-- ESP state
local espConnections = {}
local espHighlights = {}

local function GetGuiParent()
    local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok and coreGui then
        local test = Instance.new("Frame")
        local canParent = pcall(function() test.Parent = coreGui end)
        if canParent then
            test:Destroy()
            return coreGui
        end
    end

    if lp then
        return lp:WaitForChild("PlayerGui", 10)
    end

    return nil
end

local function tween(inst, info, props)
    local tw = TweenService:Create(inst, info, props)
    tw:Play()
    return tw
end

local function makeCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local targetParent = GetGuiParent()
if not targetParent then return end

-- Cleanup old GUI
if targetParent:FindFirstChild("EliteMenuV3") then targetParent.EliteMenuV3:Destroy() end
if targetParent:FindFirstChild("MobileFlyControls") then targetParent.MobileFlyControls:Destroy() end

-- Root GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EliteMenuV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- Soft shadow
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 430, 0, 320)
Shadow.Position = UDim2.new(0.5, -215, 0.5, -160)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.65
Shadow.ZIndex = 0
Shadow.Parent = ScreenGui
makeCorner(Shadow, 20)

-- Main glass frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 310)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.BackgroundTransparency = 0.22
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
makeCorner(MainFrame, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.82
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(42, 52, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 20, 28)),
})
MainGradient.Rotation = 120
MainGradient.Transparency = NumberSequence.new(0.15)
MainGradient.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, -16, 0, 52)
Header.Position = UDim2.new(0, 8, 0, 8)
Header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Header.BackgroundTransparency = 0.9
Header.Parent = MainFrame
makeCorner(Header, 12)

local headerStroke = Instance.new("UIStroke")
headerStroke.Color = Color3.fromRGB(180, 210, 255)
headerStroke.Transparency = 0.85
headerStroke.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 24)
Title.Position = UDim2.new(0, 10, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "ELITE CLICKER"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(230, 242, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -20, 0, 18)
Subtitle.Position = UDim2.new(0, 10, 0, 29)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Professional Glass UI"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextColor3 = Color3.fromRGB(145, 165, 190)
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 112, 1, -76)
Sidebar.Position = UDim2.new(0, 8, 0, 64)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.35
Sidebar.Parent = MainFrame
makeCorner(Sidebar, 12)

local sideStroke = Instance.new("UIStroke")
sideStroke.Color = Color3.fromRGB(255, 255, 255)
sideStroke.Transparency = 0.9
sideStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 10)
sidePadding.PaddingLeft = UDim.new(0, 6)
sidePadding.PaddingRight = UDim.new(0, 6)
sidePadding.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 128, 0, 64)
ContentArea.Size = UDim2.new(1, -136, 1, -72)
ContentArea.Parent = MainFrame

-- Tab system
local TabFrames = {}
local SidebarButtons = {}

local function CreateTabFrame(name)
    local f = Instance.new("ScrollingFrame")
    f.Name = name .. "Tab"
    f.Size = UDim2.new(1, 0, 1, 0)
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.AutomaticCanvasSize = Enum.AutomaticSize.Y
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ScrollBarThickness = 3
    f.ScrollBarImageColor3 = Color3.fromRGB(130, 150, 180)
    f.Visible = false
    f.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = f

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 2)
    padding.PaddingRight = UDim.new(0, 2)
    padding.Parent = f

    TabFrames[name] = f
    return f
end

local clickerTab = CreateTabFrame("Clicker")
local miscTab = CreateTabFrame("Misc")
local creditsTab = CreateTabFrame("Credits")

local function AddLabel(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -6, 0, size and (size + 10) or 24)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.Text = text
    l.TextWrapped = true
    l.TextColor3 = color or Color3.new(1, 1, 1)
    l.TextSize = size or 14
    l.Parent = parent
    return l
end

local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(42, 48, 62)
    btn.BackgroundTransparency = 0.28
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.new(0.95, 0.97, 1)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = parent
    makeCorner(btn, 9)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(140, 170, 220)
    s.Transparency = 0.76
    s.Thickness = 1
    s.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.12,
            Size = UDim2.new(1, -4, 0, 38),
        })
        tween(s, TweenInfo.new(0.15), {Transparency = 0.5})
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.28,
            Size = UDim2.new(1, -8, 0, 36),
        })
        tween(s, TweenInfo.new(0.15), {Transparency = 0.76})
    end)

    btn.MouseButton1Down:Connect(function()
        tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -10, 0, 34),
        })
    end)

    btn.MouseButton1Up:Connect(function()
        tween(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -4, 0, 38),
        })
    end)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function SetSidebarButtonState(name)
    for tabName, btn in pairs(SidebarButtons) do
        local active = tabName == name
        tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = active and 0.25 or 0.55,
            TextColor3 = active and Color3.fromRGB(230, 245, 255) or Color3.fromRGB(172, 188, 212),
        })
    end
end

local function ShowTab(name)
    for tabName, frame in pairs(TabFrames) do
        if tabName == name then
            frame.Visible = true
            frame.Position = UDim2.new(0, 12, 0, 0)
            frame.BackgroundTransparency = 1
            tween(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0),
            })
        else
            frame.Visible = false
        end
    end

    ActiveTab = name
    SetSidebarButtonState(name)
end

local function AddSidebarTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(55, 68, 95)
    btn.BackgroundTransparency = 0.55
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(172, 188, 212)
    btn.TextSize = 13
    btn.Parent = Sidebar
    makeCorner(btn, 8)

    btn.MouseButton1Click:Connect(function()
        ShowTab(name)
    end)

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            tween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.42})
        end
    end)

    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            tween(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.55})
        end
    end)

    SidebarButtons[name] = btn
end

AddSidebarTab("Clicker")
AddSidebarTab("Misc")
AddSidebarTab("Credits")

-- Clicker tab
AddLabel(clickerTab, "CLICKER GAME", 18, Color3.fromRGB(80, 255, 205))
local clickDisplay = AddLabel(clickerTab, "Total Clicks: 0", 14, Color3.fromRGB(235, 241, 255))

AddButton(clickerTab, "CLICK! (+1)", function()
    Clicks = Clicks + 1
    clickDisplay.Text = "Total Clicks: " .. tostring(Clicks)
end)

-- Misc tab
AddLabel(miscTab, "UTILITIES", 18, Color3.fromRGB(255, 175, 110))

local MobileFlyGui = Instance.new("ScreenGui")
MobileFlyGui.Name = "MobileFlyControls"
MobileFlyGui.Enabled = false
MobileFlyGui.Parent = targetParent

local function CreateMobileBtn(name, text, pos, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 50, 0, 50)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    b.BackgroundTransparency = 0.34
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 24
    b.Parent = MobileFlyGui
    makeCorner(b, 25)

    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 2
    s.Transparency = 0.15
    s.Parent = b

    return b
end

local upBtn = CreateMobileBtn("Up", "↑", UDim2.new(1, -120, 0.5, -60), Color3.fromRGB(0, 255, 150))
local downBtn = CreateMobileBtn("Down", "↓", UDim2.new(1, -120, 0.5, 10), Color3.fromRGB(255, 80, 80))

local moveUp, moveDown = false, false
upBtn.MouseButton1Down:Connect(function() moveUp = true end)
upBtn.MouseButton1Up:Connect(function() moveUp = false end)
downBtn.MouseButton1Down:Connect(function() moveDown = true end)
downBtn.MouseButton1Up:Connect(function() moveDown = false end)

-- ESP
local function RemoveEspFromCharacter(character)
    if not character then return end
    local existing = character:FindFirstChild("EliteESP")
    if existing then existing:Destroy() end
end

local function AddEspToCharacter(character)
    if not EspEnabled or not character then return end
    if character == lp.Character then return end
    if character:FindFirstChild("EliteESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "EliteESP"
    h.FillColor = Color3.fromRGB(0, 255, 140)
    h.FillTransparency = 0.62
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = character

    espHighlights[character] = h
end

local function DisableEsp()
    EspEnabled = false

    for _, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    table.clear(espConnections)

    for character, _ in pairs(espHighlights) do
        RemoveEspFromCharacter(character)
    end
    table.clear(espHighlights)
end

local function EnableEsp()
    EspEnabled = true

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            AddEspToCharacter(plr.Character)
        end

        espConnections[plr] = plr.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            AddEspToCharacter(char)
        end)
    end

    espConnections.playerAdded = Players.PlayerAdded:Connect(function(plr)
        espConnections[plr] = plr.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            AddEspToCharacter(char)
        end)
    end)

    espConnections.playerRemoving = Players.PlayerRemoving:Connect(function(plr)
        if espConnections[plr] then
            espConnections[plr]:Disconnect()
            espConnections[plr] = nil
        end

        if plr.Character then
            RemoveEspFromCharacter(plr.Character)
            espHighlights[plr.Character] = nil
        end
    end)
end

local function ToggleEsp()
    if not EspUnlocked then return end

    if EspEnabled then
        DisableEsp()
    else
        EnableEsp()
    end
end

-- Fly
local bv, bg
local function ToggleFly()
    if not FlyUnlocked then return end

    Flying = not Flying
    MobileFlyGui.Enabled = Flying

    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
        return
    end

    local hrp = char.HumanoidRootPart
    local humanoid = char.Humanoid

    if Flying then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new()
        bv.Parent = hrp

        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        humanoid.PlatformStand = true

        task.spawn(function()
            while Flying and char.Parent and humanoid.Health > 0 do
                local cam = workspace.CurrentCamera
                local velocity = humanoid.MoveDirection * FlySpeed

                if moveUp then velocity = velocity + Vector3.new(0, FlySpeed, 0) end
                if moveDown then velocity = velocity + Vector3.new(0, -FlySpeed, 0) end

                if bv then bv.Velocity = velocity end
                if bg and cam then bg.CFrame = cam.CFrame end
                task.wait()
            end

            Flying = false
            MobileFlyGui.Enabled = false
            if bv then bv:Destroy() bv = nil end
            if bg then bg:Destroy() bg = nil end
            if humanoid then humanoid.PlatformStand = false end
        end)
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        humanoid.PlatformStand = false
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
        flyToggleBtn.TextColor3 = Color3.fromRGB(120, 255, 185)
    else
        flyToggleBtn.Text = "Need " .. (2000 - Clicks) .. " more!"
        task.wait(0.8)
        if not FlyUnlocked then flyToggleBtn.Text = "Unlock Fly (2000 Clicks)" end
    end
end)

local espToggleBtn
espToggleBtn = AddButton(miscTab, "Unlock ESP (5000 Clicks)", function()
    if EspUnlocked then
        ToggleEsp()
        espToggleBtn.Text = EspEnabled and "ESP: ON" or "ESP: OFF"
    elseif Clicks >= 5000 then
        Clicks = Clicks - 5000
        EspUnlocked = true
        clickDisplay.Text = "Total Clicks: " .. tostring(Clicks)
        espToggleBtn.Text = "ESP: OFF"
        espToggleBtn.TextColor3 = Color3.fromRGB(120, 255, 180)
    else
        espToggleBtn.Text = "Need " .. (5000 - Clicks) .. " more!"
        task.wait(0.8)
        if not EspUnlocked then espToggleBtn.Text = "Unlock ESP (5000 Clicks)" end
    end
end)

-- Credits
AddLabel(creditsTab, "CREDITS", 18, Color3.fromRGB(220, 155, 255))
AddLabel(creditsTab, "UI Design: vchilina27-design", 13, Color3.fromRGB(235, 240, 250))
AddLabel(creditsTab, "Code & Logic: Jules AI Agent", 13, Color3.fromRGB(235, 240, 250))
AddLabel(creditsTab, "Polish: Professional Glass + Smooth FX", 13, Color3.fromRGB(235, 240, 250))
AddLabel(creditsTab, "Version: 4.0 Pro Glass", 11, Color3.fromRGB(160, 172, 194))

-- Dragging
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
        and UserInputService:GetFocusedTextBox() == nil then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 5, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 5)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Entry animation
MainFrame.Size = UDim2.new(0, 390, 0, 280)
MainFrame.Position = UDim2.new(0.5, -195, 0.5, -140)
MainFrame.BackgroundTransparency = 0.5
Header.BackgroundTransparency = 1
Sidebar.BackgroundTransparency = 0.7

ShowTab("Clicker")

tween(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 310),
    Position = UDim2.new(0.5, -210, 0.5, -155),
    BackgroundTransparency = 0.22,
})

tween(Header, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.9})
tween(Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.35})

print("Elite Clicker V4 Pro Glass loaded successfully.")

ScreenGui.Destroying:Connect(function()
    DisableEsp()
end)
