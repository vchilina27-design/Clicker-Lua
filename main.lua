print("Loading Clicker Lua...")

local player = {
    clicks = 0,
    multiplier = 1
}

function click()
    player.clicks = player.clicks + (1 * player.multiplier)
    print("Clicked! Total clicks: " .. player.clicks)
end

function upgrade()
    local cost = 10 * player.multiplier
    if player.clicks >= cost then
        player.clicks = player.clicks - cost
        player.multiplier = player.multiplier + 1
        print("Upgraded! Multiplier is now: " .. player.multiplier)
    else
        print("Not enough clicks to upgrade. Need " .. cost)
    end
end

-- Simulate some clicks
click()
click()
click()
upgrade()
for i=1,10 do click() end
upgrade()

print("Final Clicks: " .. player.clicks)
return player
