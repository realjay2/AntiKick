local scanned = {}
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local FindFunc = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/FindFunction.lua"))()
local Class,Default = loadstring(game:HttpGet("https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/Data2Code%40Amity.lua"))()
getgenv().Log = getgenv().Log or function(...) print(...) end

local PlayerName = game.Players.LocalPlayer.Name

local function hookRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFire
        oldFire = hookfunction(remote.FireServer, function(self, ...)
            local args = {...}
            if args[1] and (tostring(args[1]):lower() == "x-15" or tostring(args[1]) == "X-15") or (tostring(args[1]):lower() == "x-16" or tostring(args[1]) == "X-16") then
                return task.wait(9e9)
            end
            return oldFire(self, unpack(args))
        end)
    end
end
local function isRemote(obj)
    return typeof(obj) == "Instance" and obj:IsA("RemoteEvent")
end
local function deepScan(value)
    if scanned[value] then return end
    scanned[value] = true
    if isRemote(value) then
        if not value:IsDescendantOf(ReplicatedStorage) then
            hookRemote(value)
            local Old
            Old = hookfunction(getrenv().coroutine.wrap, function(...)
                if not checkcaller() then
                    print(...,getfenv(2).script)
                   return task.wait(9e9)
                end
                return Old(...)
            end)
        end
        return
    end
    if typeof(value) == "function" then
        local upvalues = getupvalues(value)
        for i, v in pairs(upvalues) do
            deepScan(v)
        end
    end
    if typeof(value) == "table" then
        for k, v in pairs(value) do
            deepScan(v)
        end
    end
end

for _, obj in next, getgc(true) do
    if typeof(obj) == "function" and islclosure(obj) and not isexecutorclosure(obj) then
        deepScan(obj)
    end
end
