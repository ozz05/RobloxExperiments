-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local HoverboardControlsRE = RemoteEvents:FindFirstChild("HoverboardControls") or RemoteEvents:WaitForChild("HoverboardControls")

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Hoverboard = {}
Hoverboard.__index = Hoverboard
Hoverboard.TAG_NAME = "Hoverboard"
Hoverboard.TURBO_BOST_KEY_PC = Enum.KeyCode.LeftShift

local hoverboards = {}

local hoverboardAddedSignal = CollectionService:GetInstanceAddedSignal(Hoverboard.TAG_NAME)
local hoverboardRemovedSignal = CollectionService:GetInstanceRemovedSignal(Hoverboard.TAG_NAME)

function Hoverboard.new(hoverboard:Model)
    local self = {}
    setmetatable(self, Hoverboard)
    self.Hoverboard = hoverboard
    self.PrimaryPart = hoverboard.PrimaryPart
    self.IsBoostActive = false
    self.IsOnAir = false
    self.SettingsFolder = hoverboard:FindFirstChild("Settings") or hoverboard:WaitForChild("Settings", 2)
    if self.SettingsFolder then
        local SeatValue = self.SettingsFolder:FindFirstChild("Seat") or self.SettingsFolder("Seat")
        self.Seat = SeatValue.Value
        if not self.Seat then
            error("No Seat or Attachment Reference")
            return nil
        end
        self.Seat:GetPropertyChangedSignal("Occupant"):Connect(function(property)
            self:OnOccupantChanged()
        end)

        self.InputBeganConnection = UserInputService.InputBegan:Connect(function(...)
            self:OnInputBegan(...)
        end)
        self.InputEndedConnection = UserInputService.InputEnded:Connect(function(...)
            self:OnInputEnded(...)
        end)
    end
    
    return self
end

function Hoverboard:OnInputBegan(input:InputObject, _gameProcessedEvent)
    if input.KeyCode == Hoverboard.TURBO_BOST_KEY_PC then
        HoverboardControlsRE:FireServer("BOOST", {Hoverboard = self.Hoverboard, IsActive = true})
    end
end

function Hoverboard:OnInputEnded(input:InputObject, _gameProcessedEvent)
    if input.KeyCode == Hoverboard.TURBO_BOST_KEY_PC then
        HoverboardControlsRE:FireServer("BOOST", {Hoverboard = self.Hoverboard, IsActive = false})
    end
end

function Hoverboard:OnOccupantChanged()
    if self.Seat.Occupant then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    else
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end

function Hoverboard:Boost(active:boolean)
    self.IsBoostActive = active
end
function Hoverboard:Cleanup()
	print("Here")
end

local function onHoverboardAdded(hoverboard)
    if hoverboard:IsA("Model") then
        hoverboards[hoverboard] = Hoverboard.new(hoverboard)
    end
end

local function onHoverboardRemoved(hoverboard)
    if hoverboards[hoverboard] then
        hoverboards[hoverboard]:Cleanup()
        hoverboards[hoverboard] = nil
    end
end

local function handleHoverboardControlsRE(LocalPlayer:Player, action:string, params)
    
end
for _, hoverboard in pairs(CollectionService:GetTagged(Hoverboard.TAG_NAME)) do
    if hoverboard:IsDescendantOf(game.Workspace) then
        onHoverboardAdded(hoverboard)
    end
end

hoverboardAddedSignal:Connect(onHoverboardAdded)
hoverboardRemovedSignal:Connect(onHoverboardRemoved)
HoverboardControlsRE.OnClientEvent:Connect(handleHoverboardControlsRE)