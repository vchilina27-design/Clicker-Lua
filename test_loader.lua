-- Mocking Roblox environment for local testing
_G.game = {
    GetService = function(self, name)
        if name == "HttpService" then
            return {
                GetAsync = function(self, url)
                    print("Mocking Http Request to: " .. url)
                    -- For testing purposes, we return a simple script
                    return "print('Hello from GitHub!') return { status = 'success' }"
                end
            }
        end
    end
}

_G.warn = print
_G.loadstring = loadstring

local Loader = require("loader")

-- Test the loader
print("Testing GitHub Loader...")
local result = Loader.load("vchilina27-design", "Clicker-Lua", "main", "main.lua")

if result and result.status == "success" then
    print("Test passed!")
else
    print("Test failed or returned unexpected result.")
end
