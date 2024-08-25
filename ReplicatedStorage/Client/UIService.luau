-- services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
-- tower folder --
local Tower = workspace:WaitForChild("Tower")

local Shared = ReplicatedStorage:WaitForChild("Shared")
-- fastnet2 (https://devforum.roblox.com/t/fastnet2-a-fast-efficient-lightweight-network-library/2097277)
local FastNet2 = require(Shared.FastNet2)

local SetTimerEvent = FastNet2.new("SetTimer")
-- class
local UIService = {}
UIService.__index = UIService

local Player = Players.LocalPlayer
-- constructor
function UIService.new()
    local self = setmetatable({}, UIService)
    -- getting UI
    self.PlayerGui = Player.PlayerGui
    self.TimerGui = self.PlayerGui:WaitForChild("Timer")
    self.HeightIndicatorGui = self.PlayerGui:FindFirstChild("HeightIndicator")
    self.PlayersGUI = self.HeightIndicatorGui.Bar:FindFirstChild("Players")
    self.StagesGUI =self.HeightIndicatorGui.Bar:FindFirstChild("Stages")

    -- Replicating timer
    SetTimerEvent:Connect(function(Time: number, Winners: {[number]: Player}) 
        local seconds = Time % 60
        local minutes = (Time-seconds)/60
        -- updating timer
        self.TimerGui.Time.Text = string.format("%02d:%02d", minutes, seconds)
        -- time booster if someone won
        if next(Winners) then
            self.TimerGui.Time.Multiplier.Text =`x{2^#Winners}`
            self.TimerGui.Time.Multiplier.Visible = true
        else
            self.TimerGui.Time.Multiplier.Visible = false
        end
        -- countdown
        -- if local player won then making text white
        if table.find(Winners, Player) then
            self.TimerGui.Time.TextColor3 = Color3.new(0, 1, 0)
        -- in case time less than 30 and time is more than 10 then making text red hahaha
        elseif Time <= 30 and Time > 10 then
            self.TimerGui.Time.TextColor3 = Color3.new(1, 0, 0)
        elseif Time <= 10 then
            -- if estimated number time is even then making text red else white (used to make "Blink" effect.)
            if Time % 2 == 0 then
                self.TimerGui.Time.TextColor3 = Color3.new(1, 0, 0)
            else
                self.TimerGui.Time.TextColor3 = Color3.new(1, 1, 1)
            end
        else
            self.TimerGui.Time.TextColor3 = Color3.new(1, 1, 1)
        end
        -- if time is over then reseting
        if Time == 0 then
            -- kinda shit code
            self.StagesGUI:ClearAllChildren()
            self.PlayersGUI:ClearAllChildren()
            for _, player: Player in Players:GetPlayers() do
                self:create_player_indicator(player)
            end
        end
    end)
    -- if someone left
    Players.PlayerRemoving:Connect(function(player: Player) 
        self.PlayersGUI:FindFirstChild(player.Name):Destroy()
    end)
    
    self:handle_height_indicator()
    
    return self
end
-- private methods
function UIService:handle_height_indicator()
    for _, player: Player in Players:GetPlayers() do
        self:create_player_indicator(player)
    end
    -- Height meter update loop
    RunService.RenderStepped:Connect(function(deltaTime: number) 
        local End: Model = Tower:WaitForChild("End")
        local Start: Model = Tower:WaitForChild("Lobby")
        
        local MinPosition = Start:GetPivot().Position
        local MaxPosition = End:GetPivot().Position
        
        local heightDifference = MaxPosition.Y - MinPosition.Y
        local increments = 1 / heightDifference

        for _, Player: Player in Players:GetPlayers() do
            local Indicator = self.PlayersGUI:FindFirstChild(Player.Name)
            if not Indicator then continue end
            local Character = Player.Character
            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then continue end

            local y = math.clamp(HumanoidRootPart.Position.Y, MinPosition.Y, MaxPosition.Y)

            local yPos = (MaxPosition.Y - y) * increments

            Indicator.Position = UDim2.new(
                Indicator.Position.X.Scale,
                Indicator.Position.X.Offset,
                yPos,
                0
            )
        end
    end)
end
function UIService:create_player_indicator(player: Player)
    local Indicator = script.Template:Clone()
    Indicator.Parent = self.PlayersGUI
    Indicator.BackgroundColor3 = BrickColor.Random().Color
    Indicator.PlayerImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    Indicator.Name = player.Name
    
    local Lobby = Tower:FindFirstChild("Lobby")
    
    self.LastHeight = 0
    
    self:create_tower_gui( Lobby )
    for i = 1, #Tower:GetChildren()-2 do
        self:create_tower_gui( Tower:FindFirstChild(i))
    end
    self:create_tower_gui( Tower:FindFirstChild("End") )
    
end
function UIService:create_tower_gui( Stage: Model)
    local totalHeight = self:calculate_tower_height()
    local Percent = (Stage:FindFirstChild("Height") and Stage:FindFirstChild("Height").Value or Stage:GetExtentsSize().Y)/totalHeight
    local Frame = Instance.new("Frame", self.StagesGUI)
    Frame.BackgroundColor3 = Stage:GetAttribute("Color")
    Frame.Size = UDim2.fromScale(1, Percent)
    Frame.BorderSizePixel = 0
    
    self.LastHeight += Frame.Size.Y.Scale
    
    Frame.Position = UDim2.fromScale(0, 1 - self.LastHeight)
    Frame.Name = Stage.Name
end
function UIService:calculate_tower_height() : number
    local totalHeight = 0
    for _, Stage:Model in Tower:GetChildren() do
        totalHeight +=  (Stage:FindFirstChild("Height") and Stage:FindFirstChild("Height").Value) or Stage:GetExtentsSize().Y
    end
    return totalHeight
end
-- singleton pattern
local singleton = UIService.new()
return singleton
