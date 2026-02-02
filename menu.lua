--[[
    STYLISH LUAU MENU
    Design: Modern Dark with Neon Accents
    Functionality: UI Layout Only (No script logic)
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local UIStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local DecorationLine = Instance.new("Frame")
local ButtonContainer = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local UIPadding = Instance.new("UIPadding")

-- Parent the GUI to CoreGui or PlayerGui
local success, parent = pcall(function()
    return game:GetService("CoreGui")
end)

if not success or not parent then
    parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- ScreenGui Properties
ScreenGui.Name = "StylishMenuUI"
ScreenGui.Parent = parent
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.Size = UDim2.new(0, 320, 0, 400)

UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(70, 70, 80)
UIStroke.Thickness = 1.8
UIStroke.Transparency = 0.1
UIStroke.Parent = MainFrame

-- Title
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 15)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "ELITE V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Stylish Glow Line
DecorationLine.Name = "DecorationLine"
DecorationLine.Parent = MainFrame
DecorationLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DecorationLine.BorderSizePixel = 0
DecorationLine.Position = UDim2.new(0, 20, 0, 50)
DecorationLine.Size = UDim2.new(1, -40, 0, 2)

local LineGradient = Instance.new("UIGradient")
LineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255))
}
LineGradient.Parent = DecorationLine

-- Scrolling Container for Buttons
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.Active = true
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.BorderSizePixel = 0
ButtonContainer.Position = UDim2.new(0, 10, 0, 65)
ButtonContainer.Size = UDim2.new(1, -20, 1, -80)
ButtonContainer.CanvasSize = UDim2.new(0, 0, 0, 450)
ButtonContainer.ScrollBarThickness = 3
ButtonContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)

UIListLayout.Parent = ButtonContainer
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

UIPadding.Parent = ButtonContainer
UIPadding.PaddingTop = UDim.new(0, 5)

-- Helper to create styled elements without functional logic
local function AddMenuButton(name, label)
    local btn = Instance.new("TextButton")
    local btnCorner = Instance.new("UICorner")
    local btnStroke = Instance.new("UIStroke")

    btn.Name = name
    btn.Parent = ButtonContainer
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 14

    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    btnStroke.Color = Color3.fromRGB(60, 60, 70)
    btnStroke.Thickness = 1
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = btn

    -- Optional: Hover effect style could be added here,
    -- but user requested "No Functions", so we keep it static.
end

-- Create placeholders
AddMenuButton("Aim", "Aimbot Settings")
AddMenuButton("Esp", "Visuals / ESP")
AddMenuButton("Misc", "Miscellaneous")
AddMenuButton("Skins", "Skin Changer")
AddMenuButton("Configs", "Cloud Configs")
AddMenuButton("Info", "Script Information")

-- Footer
local Footer = Instance.new("TextLabel")
Footer.Name = "Footer"
Footer.Parent = MainFrame
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Font = Enum.Font.Gotham
Footer.Text = "github.com/vchilina27-design"
Footer.TextColor3 = Color3.fromRGB(100, 100, 100)
Footer.TextSize = 10

print("Stylish UI Menu successfully initialized.")
