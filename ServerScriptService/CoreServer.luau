-- CoreServer.luau 
--
-- Main server script

-- services
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ServerStorage:WaitForChild("Modules")
local Shared = ReplicatedStorage:WaitForChild("Shared")
-- settings
local Settings = require(ReplicatedStorage.Settings)
-- modules
local Generation = require(Modules.TowerGeneration)
local TimerModule = require(Modules.Timer)
local FastNet2 = require(Shared.FastNet2)
-- remotes
local Remotes = {}
Remotes.SetTimer = FastNet2.new("SetTimer")
-- class instances
local Timer = TimerModule.new(Settings.TimerStep)
local TowerGeneration = Generation.new(Settings.Towers)
-- Main
local function Initialize()
    local Winners = {}
    
    local estimatedTime =  Settings.MaxTime
    
    TowerGeneration:generate()
    
    local Tower = workspace:WaitForChild("Tower")
    local End = Tower:FindFirstChild("End")
    local WinBrick: Part = End:FindFirstChild("WinBrick")
    
    Remotes.SetTimer:Fires(estimatedTime, Winners)
    Timer:returnNormalSpeed()
    local connection 
    connection = Timer.Stepped:Connect(function() 

        estimatedTime -= Settings.TimerStep

        Remotes.SetTimer:Fires(estimatedTime, Winners)
        
        if estimatedTime <= 0  then
            connection:Disconnect()
            
            TowerGeneration:remove()

            for _, Player in Players:GetPlayers() do
                Player.Character:BreakJoints()
            end
            
            Initialize()
        end
    end)
    WinBrick.Touched:Connect(function(otherPart: BasePart) 
        local Character = otherPart.Parent
        if not Character then return end
        local Player = Players:GetPlayerFromCharacter(Character)
        if not Player then return end
        if table.find(Winners, Player) then return end
        
        Winners[#Winners + 1] = Player
        
        Timer:speedUp(2)
    end)
    for _, Killbrick: BasePart in Tower:GetDescendants() do
        if Killbrick:IsA("BasePart") and Killbrick:FindFirstChild("kills") then
            Killbrick.Touched:Connect(function(otherPart: BasePart) 
                if otherPart.Parent:IsA("Model") and otherPart.Parent:FindFirstChildOfClass("Humanoid") then
                    local Character = otherPart.Parent
                    
                    Character:BreakJoints()
                end
            end)
        end
    end
end
Initialize()
