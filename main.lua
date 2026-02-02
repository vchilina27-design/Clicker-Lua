print("Clicker-Lua: Main Script Initializing...")

-- Ensure we don't run multiple times
if _G.ClickerRunning then 
    print("Clicker-Lua: Already running!")
    return 
end
_G.ClickerRunning = true

local player = {
    clicks = 0,
    multiplier = 1
}

-- Functions
function _G.Click()
    player.clicks = player.clicks + player.multiplier
    if _G.UpdateClickLabel then _G.UpdateClickLabel() end
    print("Clicks: " .. player.clicks)
end

function _G.Upgrade()
    local cost = 10 * player.multiplier
    if player.clicks >= cost then
        player.clicks = player.clicks - cost
        player.multiplier = player.multiplier + 1
        if _G.UpdateClickLabel then _G.UpdateClickLabel() end
        if _G.UpdateUpgradeLabel then _G.UpdateUpgradeLabel() end
        print("Upgraded! New Multiplier: " .. player.multiplier)
    else
        print("Need " .. (cost - player.clicks) .. " more clicks!")
    end
end

-- GUI Setup
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickerGui"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui") -- Better for some executors
pcall(function() screenGui.Parent = CoreGui end) -- Try CoreGui for persistence

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.4, -75)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Clicker Game"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = frame

-- Click Label
local clickLabel = Instance.new("TextLabel")
clickLabel.Size = UDim2.new(1, 0, 0, 30)
clickLabel.Position = UDim2.new(0, 0, 0, 30)
clickLabel.Text = "Clicks: 0 | Mult: 1"
clickLabel.TextColor3 = Color3.new(1, 1, 1)
clickLabel.BackgroundTransparency = 1
clickLabel.Parent = frame

_G.UpdateClickLabel = function()
    clickLabel.Text = "Clicks: " .. player.clicks .. " | Mult: " .. player.multiplier
end

-- Click Button
local clickBtn = Instance.new("TextButton")
clickBtn.Size = UDim2.new(0.9, 0, 0, 30)
clickBtn.Position = UDim2.new(0.05, 0, 0, 65)
clickBtn.Text = "CLICK!"
clickBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
clickBtn.TextColor3 = Color3.new(1, 1, 1)
clickBtn.Parent = frame
clickBtn.MouseButton1Click:Connect(_G.Click)

-- Upgrade Button
local upgradeBtn = Instance.new("TextButton")
upgradeBtn.Size = UDim2.new(0.9, 0, 0, 30)
upgradeBtn.Position = UDim2.new(0.05, 0, 0, 105)
upgradeBtn.Text = "Upgrade (10)"
upgradeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
upgradeBtn.TextColor3 = Color3.new(1, 1, 1)
upgradeBtn.Parent = frame

_G.UpdateUpgradeLabel = function()
    upgradeBtn.Text = "Upgrade (" .. (10 * player.multiplier) .. ")"
end

upgradeBtn.MouseButton1Click:Connect(_G.Upgrade)

print("Clicker-Lua: Loaded with GUI!")
return {player = player}
