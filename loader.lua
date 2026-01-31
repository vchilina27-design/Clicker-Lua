--[[
    GitHub Loader for Injectors
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/vchilina27-design/Clicker-Lua/main/loader.lua"))()
]]

local Loader = {}

-- Roblox globals
local HttpService = game:GetService("HttpService")

-- Configuration
local GITHUB_API_BASE = "https://raw.githubusercontent.com/%s/%s/%s/%s"

function Loader.load(user, repo, branch, path)
    local url = string.format(GITHUB_API_BASE, user, repo, branch, path)
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        warn("Failed to fetch script from GitHub: " .. tostring(response))
        return nil
    end
    
    local func, err = loadstring(response)
    if not func then
        warn("Failed to parse script: " .. tostring(err))
        return nil
    end
    
    local successExec, result = pcall(func)
    if not successExec then
        warn("Failed to execute script: " .. tostring(result))
        return nil
    end
    
    return result
end

-- If executed via loadstring, return the module
return Loader
