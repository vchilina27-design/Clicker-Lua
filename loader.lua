--[[
    GitHub Script Loader for Roblox
    Optimized for personal testing in your own game.
    Usage: 
    local Loader = loadstring(game:HttpGet("https://raw.githubusercontent.com/vchilina27-design/Clicker-Lua/main/loader.lua"))()
    local MyScript = Loader.load("user", "repo", "main", "script.lua")
]]

local Loader = {}

-- Function to load a script from GitHub
function Loader.load(user, repo, branch, path)
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", user, repo, branch, path)
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Loader Error: Could not fetch from GitHub. " .. tostring(response))
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("Loader Error: Syntax error in fetched script. " .. tostring(err))
        return nil
    end
    
    local successExec, result = pcall(func)
    if not successExec then
        warn("Loader Error: Execution error. " .. tostring(result))
        return nil
    end
    
    return result
end

return Loader
