--[[
    GitHub Script Loader for Roblox (Delta/Mobile Optimized)
    Usage: 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/vchilina27-design/Clicker-Lua/main/loader.lua"))()
]]

local Loader = {}

-- Main load function
function Loader.load(user, repo, branch, path)
    -- Using a direct raw string to avoid any string.format issues on some executors
    local url = "https://raw.githubusercontent.com/" .. user .. "/" .. repo .. "/" .. branch .. "/" .. path
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Delta Loader: Failed to fetch. Check your internet or URL.")
        print("URL Attempted: " .. url)
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("Delta Loader: Script has errors and cannot run.")
        print("Error: " .. tostring(err))
        return nil
    end
    
    local successExec, result = pcall(func)
    if not successExec then
        warn("Delta Loader: Script crashed during execution.")
        print("Error: " .. tostring(result))
        return nil
    end
    
    return result
end

-- Immediately define a global if running via loadstring for easier access in Delta
_G.GitHubLoader = Loader

print("Delta Loader: System Ready!")
return Loader
