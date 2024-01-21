local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local VFX_Folder = ServerStorage:FindFirstChild("VFX") or ServerStorage:WaitForChild("VFX")
local WeaponsFolder = VFX_Folder:FindFirstChild("Weapons") or VFX_Folder:WaitForChild("Weapons")
local MuzzleFlash = WeaponsFolder:FindFirstChild("MuzzleFlash") or WeaponsFolder:WaitForChild("MuzzleFlash")
local BulletPoolFolder = ServerStorage:FindFirstChild("BulletPoolFolder") or ServerStorage:WaitForChild("BulletPoolFolder")

local WeaponManager = {}

WeaponManager.BULLET_TAG_NAME = "Bullet"


local function creatFolder(folderName)
    local folder = BulletPoolFolder:FindFirstChild(folderName)
    local instances
    if folder then
        instances = folder:FindFirstChild("Instances")
    else
        folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = BulletPoolFolder

        instances = Instance.new("Folder")
        instances.Name = "Instances"
        instances.Parent = folder
    end
    return folder
end

local function getBullet(weaponName, Bullet)
    local folder = BulletPoolFolder:FindFirstChild(weaponName)
    if not folder then
        folder = creatFolder(weaponName)
    end
    local Instances = folder:FindFirstChild("Instances")
    if Instances then
        local bullets = Instances:GetChildren()
        if #bullets > 0 then
            return bullets[1]
        else
            return Bullet.Value:Clone()
        end
    end
end

local function getRaycastResult(params)
	local raycastParams = RaycastParams.new()
	local ingnoreList = {params.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {ingnoreList}
    local hitPosition = nil
    local hitInstance = nil
	local raycastResult = workspace:Raycast(params.Origin, params.Direction * params.Range, raycastParams)
	if raycastResult then
        hitPosition = raycastResult.Position + params.Direction * 2
		hitInstance = raycastResult.Instance
	else
		hitPosition = params.Origin + params.Direction * params.Range
	end

    return hitInstance, hitPosition
end

local function getBulletSpeed(params, hitPosition)
    local newSpeed = params.Speed
    local bulletTraveldistance = (params.Origin - hitPosition).Magnitude
    newSpeed *= bulletTraveldistance / params.Range
    return newSpeed
end

local function playVFX(SpawnCFrame:CFrame)
    local co
    co = coroutine.create(function()
        local model = MuzzleFlash:Clone()
        local Container = model:FindFirstChild("Container")
        if Container then
            Container.Anchored = true
            local Attachment = Container:FindFirstChild("Attachment")
            if Attachment then
                local flashEmitter = Attachment.Flash
                local smokeAEmitter = Attachment.SmokeA
                local smokeBEmitter = Attachment.SmokeB
                model:PivotTo(SpawnCFrame)
                model.Parent = game.Workspace
                RunService.Heartbeat:Wait()
                flashEmitter:Emit(1)
                smokeAEmitter:Emit(10)
                smokeBEmitter:Emit(10)
            end
        end
        Debris:AddItem(model, .1)
        co = nil
        coroutine.yield()
    end)
    coroutine.resume(co)
end

local function fireBullet(bullet, params)
    local _hitInstance, hitPosition = getRaycastResult(params)
	local tween = TweenService:Create(bullet, TweenInfo.new(getBulletSpeed(params, hitPosition)), {CFrame = CFrame.new(hitPosition)})
    playVFX(params.FirePointCFrame)
    tween:Play()
    tween.Completed:Connect(function()
        if bullet.Parent then
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            CollectionService:RemoveTag(bullet, WeaponManager.BULLET_TAG_NAME)
        end
    end)
end

local function addConfigToBullet(bullet, params)
    local Config = bullet:FindFirstChild("Config")
    if Config then
        local Damage = Config:FindFirstChild("Damage")
        if Damage then
            Damage.Value = params.Damage
        end

        local TeamName = Config:FindFirstChild("TeamName")
        if TeamName then
            TeamName.Value = params.TeamName
        end

        local WeaponName = Config:FindFirstChild("WeaponName")
        if WeaponName then
            WeaponName.Value = params.WeaponName
        end

        local Shooter = Config:FindFirstChild("Shooter")
        if Shooter then
            Shooter.Value = params.Character
        end

        local Direction = Config:FindFirstChild("Direction")
        if Direction then
            Direction.Value = params.Direction
        end
        
        local CanDamageKaiju = Config:FindFirstChild("CanDamageKaiju")
        if CanDamageKaiju then
            CanDamageKaiju.Value = params.CanDamageKaiju
        end
    else
        Config = Instance.new("Folder")
        Config.Name = "Config"
        Config.Parent = bullet

        local Damage = Instance.new("NumberValue")
        Damage.Name = "Damage"
        Damage.Value = params.Damage
        Damage.Parent = Config

        local TeamName = Instance.new("StringValue")
        TeamName.Name = "TeamName"
        TeamName.Value = params.TeamName
        TeamName.Parent = Config

        local WeaponName = Instance.new("StringValue")
        WeaponName.Name = "WeaponName"
        WeaponName.Value = params.WeaponName
        WeaponName.Parent = Config

        local Shooter = Instance.new("ObjectValue")
        Shooter.Name = "Shooter"
        Shooter.Value = params.Character
        Shooter.Parent = Config

        local Direction = Instance.new("Vector3Value")
        Direction.Name = "Direction"
        Direction.Value = params.Direction
        Direction.Parent = Config

        local CanDamageKaiju = Instance.new("BoolValue")
        CanDamageKaiju.Name = "CanDamageKaiju"
        CanDamageKaiju.Value = params.CanDamageKaiju
        CanDamageKaiju.Parent = Config
    end
end

function WeaponManager:FirePlayer(params)
    if params.Weapon then
        local Configuration = params.Weapon:FindFirstChild("Configuration")
        if Configuration then
            local Bullet = Configuration:FindFirstChild("Bullet")
            if Bullet then
                params.WeaponName = params.Weapon.Name
                local clone = getBullet(params.WeaponName, Bullet)
                clone.CFrame = params.FirePointCFrame
                clone.Parent = game.Workspace
                addConfigToBullet(clone, params)
                
                CollectionService:AddTag(clone, WeaponManager.BULLET_TAG_NAME)
                fireBullet(clone, params)
            end
        end
    end
end


function WeaponManager:FireNPC(params)
    if params.Weapon then
        local Configuration = params.Weapon:FindFirstChild("Configuration")
        if Configuration then
            local Bullet = Configuration:FindFirstChild("Bullet")
            if Bullet then
                params.Origin = params.FirePointCFrame.Position
                params.Direction = (params.TargetCFrame.Position - params.FirePointCFrame.Position).Unit
                local clone = Bullet.Value:Clone()
                clone.CFrame = params.FirePointCFrame
                clone.Parent = game.Workspace
                addConfigToBullet(clone, params)
                CollectionService:AddTag(clone, WeaponManager.BULLET_TAG_NAME)
                fireBullet(clone, params)
            end
        end
    end
end



return WeaponManager