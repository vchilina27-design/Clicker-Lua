--[[
    GTA 1 MINI (Roblox Lua)
    Drop this script into ServerScriptService.

    Features:
    - Procedural top-down city blocks and roads
    - Player spawn points
    - Drivable simple cars (VehicleSeat)
    - Money pickups
    - Wanted level system with police car spawns
    - Minimal HUD (money + wanted stars)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local GAME_FOLDER = Instance.new("Folder")
GAME_FOLDER.Name = "GTA1Mini"
GAME_FOLDER.Parent = Workspace

local REMOTES = Instance.new("Folder")
REMOTES.Name = "GTA1Remotes"
REMOTES.Parent = ReplicatedStorage

local updateUiRemote = Instance.new("RemoteEvent")
updateUiRemote.Name = "UpdateUI"
updateUiRemote.Parent = REMOTES

local CITY_SIZE = 8
local BLOCK_SIZE = 110
local ROAD_WIDTH = 40
local BUILDING_MIN = 30
local BUILDING_MAX = 90
local GROUND_Y = 0

local SPAWN_POINTS = {}
local playerState = {}

local function makePart(config)
    local part = Instance.new("Part")
    part.Anchored = config.Anchored ~= false
    part.Size = config.Size or Vector3.new(4, 4, 4)
    part.Position = config.Position or Vector3.new()
    part.Material = config.Material or Enum.Material.Concrete
    part.Color = config.Color or Color3.fromRGB(120, 120, 120)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Name = config.Name or "Part"
    part.Parent = config.Parent or GAME_FOLDER
    return part
end

local function createRoadTile(x, z)
    return makePart({
        Name = "Road",
        Size = Vector3.new(BLOCK_SIZE, 1, ROAD_WIDTH),
        Position = Vector3.new(x, GROUND_Y, z),
        Color = Color3.fromRGB(30, 30, 30),
        Material = Enum.Material.Asphalt,
    })
end

local function createRoadCross(x, z)
    makePart({
        Name = "RoadCrossA",
        Size = Vector3.new(BLOCK_SIZE, 1, ROAD_WIDTH),
        Position = Vector3.new(x, GROUND_Y, z),
        Color = Color3.fromRGB(30, 30, 30),
        Material = Enum.Material.Asphalt,
    })
    makePart({
        Name = "RoadCrossB",
        Size = Vector3.new(ROAD_WIDTH, 1, BLOCK_SIZE),
        Position = Vector3.new(x, GROUND_Y, z),
        Color = Color3.fromRGB(30, 30, 30),
        Material = Enum.Material.Asphalt,
    })
end

local function createBuilding(center)
    local width = math.random(BUILDING_MIN, BUILDING_MAX)
    local depth = math.random(BUILDING_MIN, BUILDING_MAX)
    local height = math.random(30, 130)

    local building = makePart({
        Name = "Building",
        Size = Vector3.new(width, height, depth),
        Position = Vector3.new(center.X, height / 2 + GROUND_Y, center.Z),
        Color = Color3.fromRGB(math.random(70, 160), math.random(70, 160), math.random(70, 160)),
        Material = Enum.Material.Concrete,
    })

    local roof = makePart({
        Name = "Roof",
        Size = Vector3.new(width - 2, 1, depth - 2),
        Position = building.Position + Vector3.new(0, height / 2 + 0.5, 0),
        Color = Color3.fromRGB(45, 45, 50),
        Material = Enum.Material.Metal,
    })

    return building, roof
end

local function createCity()
    local baseSize = CITY_SIZE * BLOCK_SIZE
    makePart({
        Name = "Base",
        Size = Vector3.new(baseSize + 200, 6, baseSize + 200),
        Position = Vector3.new(0, GROUND_Y - 3.5, 0),
        Color = Color3.fromRGB(20, 120, 20),
        Material = Enum.Material.Grass,
    })

    for gx = -CITY_SIZE / 2, CITY_SIZE / 2 - 1 do
        for gz = -CITY_SIZE / 2, CITY_SIZE / 2 - 1 do
            local x = gx * BLOCK_SIZE + BLOCK_SIZE / 2
            local z = gz * BLOCK_SIZE + BLOCK_SIZE / 2

            createRoadCross(x, z)

            local quarter = (BLOCK_SIZE - ROAD_WIDTH) / 2
            createBuilding(Vector3.new(x - quarter / 2, 0, z - quarter / 2))
            createBuilding(Vector3.new(x + quarter / 2, 0, z - quarter / 2))
            createBuilding(Vector3.new(x - quarter / 2, 0, z + quarter / 2))
            createBuilding(Vector3.new(x + quarter / 2, 0, z + quarter / 2))

            if (gx + gz) % 3 == 0 then
                table.insert(SPAWN_POINTS, Vector3.new(x, 6, z))
            end
        end
    end
end

local function createCar(position, isPolice)
    local model = Instance.new("Model")
    model.Name = isPolice and "PoliceCar" or "CivilianCar"
    model.Parent = GAME_FOLDER

    local bodyColor = isPolice and Color3.fromRGB(40, 50, 200) or Color3.fromRGB(220, 40, 40)

    local chassis = makePart({
        Parent = model,
        Name = "Chassis",
        Size = Vector3.new(8, 2, 14),
        Position = position + Vector3.new(0, 3, 0),
        Anchored = false,
        Color = bodyColor,
        Material = Enum.Material.Metal,
    })

    local seat = Instance.new("VehicleSeat")
    seat.Name = "DriverSeat"
    seat.Size = Vector3.new(2, 1, 2)
    seat.Position = chassis.Position + Vector3.new(0, 1.5, 0)
    seat.Anchored = false
    seat.Color = Color3.fromRGB(20, 20, 20)
    seat.MaxSpeed = isPolice and 70 or 60
    seat.Torque = 25000
    seat.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = chassis
    weld.Part1 = seat
    weld.Parent = chassis

    for i = 1, 4 do
        local wheel = makePart({
            Parent = model,
            Name = "Wheel" .. i,
            Size = Vector3.new(2, 2, 2),
            Position = chassis.Position,
            Anchored = false,
            Color = Color3.fromRGB(15, 15, 15),
            Material = Enum.Material.Rubber,
        })

        local ox = (i <= 2) and -3 or 3
        local oz = (i % 2 == 0) and -5 or 5
        wheel.Position = chassis.Position + Vector3.new(ox, -1, oz)

        local wheelWeld = Instance.new("WeldConstraint")
        wheelWeld.Part0 = chassis
        wheelWeld.Part1 = wheel
        wheelWeld.Parent = wheel
    end

    model.PrimaryPart = chassis
    return model
end

 codex/-gta-1-fs3egr
local setWanted


 main
local function spawnPickup(position)
    local pickup = makePart({
        Name = "MoneyPickup",
        Size = Vector3.new(4, 1, 4),
        Position = position + Vector3.new(0, 1.5, 0),
        Color = Color3.fromRGB(20, 220, 90),
        Material = Enum.Material.Neon,
    })

 codex/-gta-1-fs3egr
    local claimed = false

    pickup.Touched:Connect(function(hit)
        if claimed then return end


    pickup.Touched:Connect(function(hit)
 main
        local character = hit.Parent
        if not character then return end

        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        local state = playerState[player]
        if not state then return end

 codex/-gta-1-fs3egr
        claimed = true
        state.money += 100
        setWanted(player, state.wanted + 1)

        state.money += 100
        updateUiRemote:FireClient(player, state.money, state.wanted)
 main

        pickup:Destroy()
        task.delay(math.random(4, 10), function()
            if #SPAWN_POINTS > 0 then
                spawnPickup(SPAWN_POINTS[math.random(1, #SPAWN_POINTS)])
            end
        end)
    end)
end

 codex/-gta-1-fs3egr
setWanted = function(player, value)

local function setWanted(player, value)
 main
    local state = playerState[player]
    if not state then return end

    state.wanted = math.clamp(value, 0, 5)
    updateUiRemote:FireClient(player, state.money, state.wanted)
end

local function createPlayerUiScript(player)
    local uiScript = Instance.new("LocalScript")
    uiScript.Name = "GTA1UI"
    uiScript.Source = [[
        local player = game:GetService("Players").LocalPlayer
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local update = replicatedStorage:WaitForChild("GTA1Remotes"):WaitForChild("UpdateUI")

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GTA1Hud"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.Position = UDim2.new(1, -16, 0, 16)
        frame.Size = UDim2.new(0, 220, 0, 90)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.Parent = screenGui

        local moneyLabel = Instance.new("TextLabel")
        moneyLabel.Size = UDim2.new(1, -16, 0, 35)
        moneyLabel.Position = UDim2.new(0, 8, 0, 8)
        moneyLabel.BackgroundTransparency = 1
        moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
        moneyLabel.TextColor3 = Color3.fromRGB(90, 255, 90)
        moneyLabel.Font = Enum.Font.Arcade
        moneyLabel.TextScaled = true
        moneyLabel.Text = "$0"
        moneyLabel.Parent = frame

        local wantedLabel = Instance.new("TextLabel")
        wantedLabel.Size = UDim2.new(1, -16, 0, 30)
        wantedLabel.Position = UDim2.new(0, 8, 0, 48)
        wantedLabel.BackgroundTransparency = 1
        wantedLabel.TextXAlignment = Enum.TextXAlignment.Right
        wantedLabel.TextColor3 = Color3.fromRGB(255, 190, 60)
        wantedLabel.Font = Enum.Font.GothamBold
        wantedLabel.TextScaled = true
        wantedLabel.Text = "WANTED: ☆☆☆☆☆"
        wantedLabel.Parent = frame

        local function render(money, wanted)
            moneyLabel.Text = "$" .. tostring(money)
            local stars = string.rep("★", wanted) .. string.rep("☆", 5 - wanted)
            wantedLabel.Text = "WANTED: " .. stars
        end

        update.OnClientEvent:Connect(render)
    ]]
    uiScript.Parent = player:WaitForChild("PlayerGui")
end

local function onPlayerAdded(player)
    playerState[player] = {
        money = 0,
        wanted = 0,
    }

    player.CharacterAdded:Connect(function(character)
        local humRoot = character:WaitForChild("HumanoidRootPart")

        if #SPAWN_POINTS > 0 then
            humRoot.CFrame = CFrame.new(SPAWN_POINTS[math.random(1, #SPAWN_POINTS)])
        end

        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            local state = playerState[player]
            if state then
                state.money = math.max(0, state.money - 250)
                setWanted(player, 0)
            end
        end)
    end)

    createPlayerUiScript(player)
    updateUiRemote:FireClient(player, 0, 0)
end

local function onPlayerRemoving(player)
    playerState[player] = nil
end

local function initGameplay()
    createCity()

    for i = 1, 14 do
        local point = SPAWN_POINTS[math.random(1, #SPAWN_POINTS)]
        createCar(point + Vector3.new(math.random(-16, 16), 0, math.random(-16, 16)), false)
    end

    for i = 1, 6 do
        local point = SPAWN_POINTS[math.random(1, #SPAWN_POINTS)]
        spawnPickup(point + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20)))
    end

    task.spawn(function()
        while task.wait(15) do
            for player, state in pairs(playerState) do
                if math.random() < 0.55 then
                    setWanted(player, math.max(0, state.wanted - 1))
 codex/-gta-1-fs3egr
                elseif math.random() < 0.2 then
                    setWanted(player, state.wanted + 1)

 main
                end
            end
        end
    end)

    task.spawn(function()
        while task.wait(20) do
            for player, state in pairs(playerState) do
                if state.wanted >= 3 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = player.Character.HumanoidRootPart.Position
                    local spawnAt = pos + Vector3.new(math.random(-60, 60), 2, math.random(-60, 60))
                    local policeCar = createCar(spawnAt, true)
                    Debris:AddItem(policeCar, 45)
                end
            end
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

initGameplay()
print("GTA 1 MINI loaded: city generated, cars spawned, wanted system active.")
