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

function _G.Click()
    player.clicks = player.clicks + player.multiplier
    print("Clicks: " .. player.clicks)
end

function _G.Upgrade()
    local cost = 10 * player.multiplier
    if player.clicks >= cost then
        player.clicks = player.clicks - cost
        player.multiplier = player.multiplier + 1
        print("Upgraded! New Multiplier: " .. player.multiplier)
    else
        print("Need " .. (cost - player.clicks) .. " more clicks!")
    end
end

print("Clicker-Lua: Loaded! Use _G.Click() and _G.Upgrade()")
return {player = player}
