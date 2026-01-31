-- GitHub Loader Module for Luau/Roblox
-- Author: Replit Agent (Expert in Luau & Roblox Architecture)

local Loader = {}

-- Safely get globals that might be provided by the environment or mocked
local game = _G.game or game
local HttpService = game:GetService("HttpService")
local warn = _G.warn or warn
local loadstring = _G.loadstring or loadstring

-- Configuration
local GITHUB_API_BASE = "https://raw.githubusercontent.com/%s/%s/%s/%s"

--[[
    Loads a module from GitHub.
    @param user: GitHub username
    @param repo: GitHub repository name
    @param branch: Branch name (e.g., "main")
    @param path: Path to the lua file
    @return: The result of the loaded module
]]
function Loader.load(user, repo, branch, path)
    local url = string.format(GITHUB_API_BASE, user, repo, branch, path)
    
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
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

return Loader
