-- TowerGeneration.luau

-- services
local ServerStorage = game:GetService("ServerStorage")
-- prefabs
local GenerationPrefabs = ServerStorage:WaitForChild("GenerationPrefabs")
local Storage = GenerationPrefabs:WaitForChild("Storage")
local Stages = GenerationPrefabs:WaitForChild("Stages"):GetChildren()

local Tower = workspace:WaitForChild("Tower")
-- class
local Generation = {}
Generation.__index = Generation
-- constructors
function Generation.new(numberOfTowers: number)
    local self = setmetatable({}, Generation)
    
    self.Amount = numberOfTowers
    
    return self
end
-- public methods
function Generation:remove()
    Tower:ClearAllChildren()
end
function Generation:generate()
    local Lobby = Storage:WaitForChild("Lobby"):Clone()
    
    Lobby.Parent = Tower
    
    local PreviousStage = Lobby

    for i = 1, self.Amount do
        local Stage: Model = Stages[Random.new():NextInteger(1, #Stages)]:Clone()
        
        Stage.Parent = Tower
        Stage.Name = i
        
        if i > 1 then
            Stage:PivotTo(
                (PreviousStage:GetPivot() + Vector3.new(0, PreviousStage:FindFirstChild("Height").Value, 0)) *
                    CFrame.Angles(0, math.pi, 0)
            )
        end
        
        PreviousStage = Stage
        
    end
    
    local End = Storage:WaitForChild("End"):Clone()
    
    End.Parent = Tower
    End:PivotTo((PreviousStage:GetPivot() * CFrame.Angles(0, math.pi, 0)) + Vector3.new(0, PreviousStage:FindFirstChild("Height").Value, 0))
    
end


return Generation
