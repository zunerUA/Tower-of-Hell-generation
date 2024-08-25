-- Timer.luau

-- services
local RunService = game:GetService("RunService")
-- signal utilty https://github.com/Quenty/NevermoreEngine
local Signal = require(script.Signal)

local Timer = {}
Timer.__index = Timer
-- constructor
function Timer.new( Step: number? )
    local self = setmetatable({}, Timer)
    
    self.Stepped = Signal.new()
    self.Speed = 1

    local delta = 0
    
    task.spawn(function()
      -- main
        RunService.Heartbeat:Connect(function(deltaTime: number) 
            delta += deltaTime * self.Speed
            if delta >= Step then
                self.Stepped:Fire()

                delta = 0
            end
        end)
    end)
    
    return self
end
-- public methods
function Timer:returnNormalSpeed()
    self.Speed = 1
end
function Timer:speedUp(times: number)
    self.Speed *= times
end

return Timer
