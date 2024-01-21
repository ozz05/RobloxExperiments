-- Server
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local BindableEvents = ReplicatedStorage:FindFirstChild("BindableEvents") or ReplicatedStorage:WaitForChild("BindableEvents")
local NotifyOnDamage = BindableEvents:FindFirstChild("NotifyOnDamage") or BindableEvents:WaitForChild("NotifyOnDamage")

local VFX_Folder = ServerStorage:FindFirstChild("VFX") or ServerStorage:WaitForChild("VFX")
local WeaponsFolder = VFX_Folder:FindFirstChild("Weapons") or VFX_Folder:WaitForChild("Weapons")
local BulletHit = WeaponsFolder:FindFirstChild("BulletHit") or WeaponsFolder:WaitForChild("BulletHit")

local Bullet = {}
Bullet.__index = Bullet
Bullet.TAG_NAME = "Bullet"
Bullet.LARVA_TAG_NAME = "Larva"
Bullet.NPC_TAG_NAME = "NPC"
Bullet.IGNORE_TAG_NAME = "Ignore"
Bullet.RaycastRange = 2

local bullets = {}

local bulletAddedSignal = CollectionService:GetInstanceAddedSignal(Bullet.TAG_NAME)
local bulletRemovedSignal = CollectionService:GetInstanceRemovedSignal(Bullet.TAG_NAME)

local BulletPoolFolder = Instance.new("Folder")
BulletPoolFolder.Name = "BulletPoolFolder"
BulletPoolFolder.Parent = ServerStorage


local function playVFX(SpawnCFrame:CFrame)
    local co
    co = coroutine.create(function()
        local model = BulletHit:Clone()
        local Container = model:FindFirstChild("Container")
        if Container then
            Container.Anchored = true
            local Attachment = Container:FindFirstChild("Attachment")
            if Attachment then
                local hitEmitter = model.Container.Attachment.Hit
                local shockwave = model.Container.Attachment.Shockwave
                model:PivotTo(SpawnCFrame)
                model.Parent = game.Workspace
                RunService.Heartbeat:Wait()
                hitEmitter:Emit(15)
                shockwave:Emit(1)
            end
        end
        Debris:AddItem(model, .1)
        co = nil
        coroutine.yield()
    end)
    coroutine.resume(co)
    
end

function Bullet.new(bullet)
    local self = {}
	setmetatable(self, Bullet)

    self.Bullet = bullet
    self.DealtDamage = false
    bullet.Anchored = true

    local Config = bullet:FindFirstChild("Config")
    if Config then
        local Damage = Config:FindFirstChild("Damage")
        local TeamName = Config:FindFirstChild("TeamName")
        local Shooter = Config:FindFirstChild("Shooter")
        local Direction = Config:FindFirstChild("Direction")
        local CanDamageKaiju = Config:FindFirstChild("CanDamageKaiju")
        local WeaponName = Config:FindFirstChild("WeaponName")
        
        if WeaponName then
            self.WeaponName = WeaponName.Value
        end
        if Damage then
            self.Damage = Damage.Value
        end
        if TeamName then
            self.TeamName = TeamName.Value
        end
        if Shooter then
            self.Shooter = Shooter.Value
        end
        if Direction then
            self.Direction = Direction.Value
            self.HeartbeatConnection = RunService.Heartbeat:Connect(function(...)
                self:HandleHeartbeat(...)
            end)
        end
        if CanDamageKaiju then
            self.CanDamageKaiju = CanDamageKaiju.Value
        end
    end

    return self
end

function Bullet:HanldeDeath(Character)
    local action = nil
    local DropPosition = nil
    if Character:HasTag(Bullet.LARVA_TAG_NAME) then
        action = "KillSlug"
        local head = Character:FindFirstChild("Head")
        if head then
            DropPosition = head.Position
        end
    else
        if Character:HasTag(Bullet.NPC_TAG_NAME) then return end

        local player = Players:GetPlayerFromCharacter(Character)
        if player then
            local PlayerStates = player:FindFirstChild("PlayerStates") or player:WaitForChild("PlayerStates", 1)
            if PlayerStates then
                local IsKaiju = PlayerStates:FindFirstChild("IsKaiju") or PlayerStates:WaitForChild("IsKaiju", 1)
                if IsKaiju then
                    if IsKaiju.Value then
                        action = "DamageWithSpecialWeaponToKaiju"
                    else
                        action = "KillEnemy"
                    end
                    local head = Character:FindFirstChild("Head")
                    if head then
                        DropPosition = head.Position
                    end
                end
            end
        end
    end

    if not DropPosition then
        DropPosition = self.Bullet.Position
    end
end

function Bullet:CheckIfCanDamage(Character)
    local player = Players:GetPlayerFromCharacter(Character)
    if player then
        local PlayerStates = player:FindFirstChild("PlayerStates")
        if PlayerStates then
            local IsKaiju = PlayerStates:FindFirstChild('IsKaiju')
            if IsKaiju then
                if IsKaiju.Value then
                    if self.CanDamageKaiju then
                        return self.CanDamageKaiju
                    end
                end
            end
        end
    end
    return true
end

function Bullet:ReduceHealthToPlayer(Character, humanoid:Humanoid)
    if self.DealtDamage then return end
    self.DealtDamage = true
    if humanoid.Health <= 0 then return end
    if self:CheckIfCanDamage(Character) then
        humanoid.Health -= self.Damage
        if humanoid.Health <= 0 then
            self:HanldeDeath(Character)
        end
        if Character:HasTag(Bullet.NPC_TAG_NAME) then
            NotifyOnDamage:Fire({ShooterCharacter = self.Shooter, DamagedCharacter = Character})
        end
    end
end

function Bullet:MoveBulletToPoolFolder()
    if self.WeaponName then
        local folder = BulletPoolFolder:FindFirstChild(self.WeaponName)
        if not folder then
            local newPoolFolder = Instance.new("Folder")
            newPoolFolder.Name = self.WeaponName
            newPoolFolder.Parent = BulletPoolFolder
        end
        if folder then
            local instances = folder:FindFirstChild("Instances")
            if instances then
                self.Bullet.CFrame = CFrame.new(0, -50, 0)
                self.Bullet.Parent = instances
            end
        end
    end
end

function Bullet:HandleHeartbeat(deltaTime)
    local raycastParams = RaycastParams.new()
    local ingnoreList = {self.Shooter, self.Bullet}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {ingnoreList}
	local raycastResult = game.Workspace:Raycast(self.Bullet.Position, (self.Direction * Bullet.RaycastRange), raycastParams)
    if raycastResult then
        self:OnTouch(raycastResult.Instance)
	end
end

function Bullet:OnTouch(part)
    local Character = part.Parent
    if Character then
        playVFX(self.Bullet.CFrame)
        local humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then
            if not (Character.Parent == game.Workspace) then
                Character = part.Parent.Parent
                humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                if not humanoid then
                    return
                end
            else
                return
            end
        end
        self:ReduceHealthToPlayer(Character, humanoid)
    end
    CollectionService:RemoveTag(self.Bullet, Bullet.TAG_NAME)
end

function Bullet:Cleanup()
    warn("Clean Up")
    if self.touchConnection then
        self.touchConnection:Disconnect()
        self.touchConnection = nil
    end

    if self.HeartbeatConnection then
        self.HeartbeatConnection:Disconnect()
        self.HeartbeatConnection = nil
    end
    self:MoveBulletToPoolFolder()
end

local function onBulletAdded(bullet)
	if bullet:IsA("BasePart") then
		bullets[bullet] = Bullet.new(bullet)
	end
end

local function onBulletRemoved(bullet)
	if bullets[bullet] then
		bullets[bullet]:Cleanup()
		bullets[bullet] = nil
	end
end

bulletAddedSignal:Connect(onBulletAdded)
bulletRemovedSignal:Connect(onBulletRemoved)