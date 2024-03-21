-- Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Hoverboard = {}
Hoverboard.__index = Hoverboard
Hoverboard.TAG_NAME = "Hoverboard"
Hoverboard.DEFAULT_ANIM = "rbxassetid://9818938435"
Hoverboard.HOVER_HEIGH = 3
Hoverboard.REGULAR_SPEED = 50
Hoverboard.TURBO_BOOST_TIME = 3
Hoverboard.TURBO_BOOST = 2
Hoverboard.TURNING_SPEED = 2
Hoverboard.RAYCAST_LENGHT = Hoverboard.HOVER_HEIGH + 5
local hoverboards = {}

local hoverboardAddedSignal = CollectionService:GetInstanceAddedSignal(Hoverboard.TAG_NAME)
local hoverboardRemovedSignal = CollectionService:GetInstanceRemovedSignal(Hoverboard.TAG_NAME)

function Hoverboard.new(hoverboard:Model)
    local self = {}
    setmetatable(self, Hoverboard)
    self.Hoverboard = hoverboard
    self.PrimaryPart = hoverboard.PrimaryPart
    
    self.Active = true
    self.AnimTrack = nil
    self.Acceleration = 0
    self.Turbo = false
    self.SettingsFolder = hoverboard:FindFirstChild("Settings") or hoverboard:WaitForChild("Settings", 2)
    if self.SettingsFolder then
        local AttachmentValue = self.SettingsFolder:FindFirstChild("Attachment") or self.SettingsFolder:WaitForChild("Attachment")
        self.Attachment = AttachmentValue.Value
        local SeatValue = self.SettingsFolder:FindFirstChild("Seat") or self.SettingsFolder("Seat")
        self.Seat = SeatValue.Value
        
        if not self.Seat or not self.Attachment then
            error("No Seat or Attachment Reference")
            return nil
        end
        self.Seat:GetPropertyChangedSignal("Occupant"):Connect(function(property)
            self:OnOccupantChanged()
        end)
        
    else
        error("Hoverboard is missing Setting folder")
    end

    --- Forces
    self.AlignPosition = Instance.new("AlignPosition")
    self.AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    self.AlignPosition.Attachment0 = self.Attachment
    self.AlignPosition.MaxForce = math.huge
    self.AlignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    self.AlignPosition.ForceRelativeTo = Enum.ActuatorRelativeTo.Attachment0
    self.AlignPosition.MaxAxesForce = Vector3.new(500, math.huge, 500)
    self.AlignPosition.Parent = self.PrimaryPart

    self.AlignOrientation = Instance.new("AlignOrientation")
    self.AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    self.AlignOrientation.Attachment0 = self.Attachment
    self.AlignOrientation.Responsiveness = 30
    self.AlignOrientation.Parent = self.PrimaryPart

    self.LinearVelocity = Instance.new("LinearVelocity")
    
    self.LinearVelocity.Attachment0 = self.Attachment
    self.LinearVelocity.MaxForce = math.huge
    self.LinearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
    self.LinearVelocity.Enabled = false
    self.LinearVelocity.Parent = self.PrimaryPart

    -- Raycast Info
    self.raycastParams = RaycastParams.new()
    self.raycastParams.FilterDescendantsInstances = {self.Hoverboard}
    self.raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    self.raycastParams.IgnoreWater = false

    self.Heartbeat = RunService.Heartbeat:Connect(function(_deltaTime)
        self:UpdateAlignPosition(_deltaTime)
        self:UpdateAlignOrientation(_deltaTime)
        self:UpdateLinearVelocity(_deltaTime)
    end)

    return self
end

function Hoverboard:UpdateAlignOrientation(_deltaTime)
    if self.Active then
        local rotatedCFrame = CFrame.Angles(0, math.rad(- self.Seat.SteerFloat * Hoverboard.TURNING_SPEED), 0)
        self.AlignOrientation.CFrame = self.AlignOrientation.CFrame:ToWorldSpace(rotatedCFrame)
    end
end


function Hoverboard:UpdateAlignPosition(_deltaTime)
    if self.Active then
        local rayDirection  = Vector3.new(0, - Hoverboard.RAYCAST_LENGHT, 0)
        local raycastResult = workspace:Raycast(self.PrimaryPart.CFrame.Position, rayDirection, self.raycastParams)
        if raycastResult then
            self.AlignPosition.Enabled = true
            self.AlignPosition.Position = raycastResult.Position + Vector3.new(self.Seat.ThrottleFloat, Hoverboard.HOVER_HEIGH)
        else
            self.AlignPosition.Enabled = false
        end
    end
end

function Hoverboard:UpdateLinearVelocity(_deltaTime)
    if self.Active then
        if not self.Seat.Occupant then
            return
        end
        local rootPart = self.Seat.Occupant.Parent:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return  -- HumanoidRootPart not found, return
        end
        local rightVector = rootPart.CFrame.RightVector
        self.LinearVelocity.Enabled = not (self.Seat.ThrottleFloat == 0)
        if self.Seat.ThrottleFloat == 0 then
            self.Acceleration = 0
        end
        if self.Acceleration > -Hoverboard.REGULAR_SPEED and self.Acceleration < Hoverboard.REGULAR_SPEED then
            self.Acceleration += self.Seat.ThrottleFloat
        end
        if self.Turbo then
            self.LinearVelocity.VectorVelocity = Vector3.new(rightVector.X * self.Acceleration, rightVector.Y, rightVector.Z * self.Acceleration) * Hoverboard.TURBO_BOOST
        else
            self.LinearVelocity.VectorVelocity = Vector3.new(rightVector.X * self.Acceleration, rightVector.Y, rightVector.Z * self.Acceleration)
        end
        
    else
        self.LinearVelocity.Enabled = false
    end
end

function Hoverboard:PlayAnimation(Humanoid:Humanoid)
    if Humanoid then
        local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 2)
        if Animator then
            local anim = Instance.new("Animation")
            anim.AnimationId = Hoverboard.DEFAULT_ANIM
            self.AnimTrack = Animator:LoadAnimation(anim)
            self.AnimTrack:Play()
        end
    else
        warn("Stop")
        self.AnimTrack:Stop()
    end
end

function Hoverboard:OnOccupantChanged()
    self:PlayAnimation(self.Seat.Occupant)
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

for _, hoverboard in pairs(CollectionService:GetTagged(Hoverboard.TAG_NAME)) do
    if hoverboard:IsDescendantOf(game.Workspace) then
        onHoverboardAdded(hoverboard)
    end
end

hoverboardAddedSignal:Connect(onHoverboardAdded)
hoverboardRemovedSignal:Connect(onHoverboardRemoved)