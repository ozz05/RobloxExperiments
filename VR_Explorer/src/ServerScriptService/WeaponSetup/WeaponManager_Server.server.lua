-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

--- Modules
local Modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules")
local WeaponsModules = Modules:FindFirstChild("WeaponModules") or Modules:WaitForChild("WeaponModules")
local IKWeapon = require(WeaponsModules.IKWeapon)
local WeaponManager = require(WeaponsModules.WeaponManager)
local BackpackManager = require(Modules.BackpackManager)

-- RemoteEvents 
local RemoteEvents:Folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local FireWeapon:RemoteEvent = RemoteEvents:FindFirstChild("FireWeapon") or RemoteEvents:WaitForChild("FireWeapon")

local BindableEvents:Folder = ReplicatedStorage:FindFirstChild("BindableEvents") or ReplicatedStorage:WaitForChild("BindableEvents")
local FireWeaponBindable:BindableEvent = BindableEvents:FindFirstChild("FireWeaponBindable") or BindableEvents:WaitForChild("FireWeaponBindable")

-- Bullets
local BulletsFolder = ServerStorage:FindFirstChild("Bullet") or ServerStorage:WaitForChild("Bullet")
local BulletModel = BulletsFolder:FindFirstChild("Bullet") or BulletsFolder:WaitForChild("Bullet")

local Weapon = {}
Weapon.__index = Weapon
Weapon.TAG_NAME = "Weapon"

local weapons = {}

local weaponAddedSignal = CollectionService:GetInstanceAddedSignal(Weapon.TAG_NAME)
local weaponRemovedSignal = CollectionService:GetInstanceRemovedSignal(Weapon.TAG_NAME)


function Weapon.new(weapon:Tool)
    local self = {}
	setmetatable(self, Weapon)

    self.Weapon = weapon
    self.hitbox = weapon:FindFirstChild("Hitbox")
    self.Configuration = weapon:FindFirstChild("Configuration")
    if self.Configuration then
        local BulletValue = self.Configuration:FindFirstChild("Bullet")
        if BulletValue then
            BulletValue.Value = BulletModel
        end
        self.Ammo = self.Configuration:FindFirstChild("Ammo")
        self.CurrentAmmo = self.Configuration:FindFirstChild("CurrentAmmo")
        self.ChargerSize = self.Configuration:FindFirstChild("ChargerSize")
        self.InfiniteAmmo = self.Configuration:FindFirstChild("InfiniteAmmo")
        self.Range = self.Configuration:FindFirstChild("Range")
        self.Damage = self.Configuration:FindFirstChild("Damage")
        self.Speed = self.Configuration:FindFirstChild("Speed")
    end
    if self.hitbox then
        self.hitbox.CanCollide = true
        self.prompt = self.hitbox:FindFirstChildWhichIsA("ProximityPrompt")
        if self.prompt then
            self:CheckIfEquipped()
            self.prompt.RequiresLineOfSight = false
            self.promptTriggerConnection = self.prompt.Triggered:Connect(function(...)
                self:promptTriggered(...)
            end)
        end
    end
    self:HandleWeaponCollision(true)
    self.Weapon.Equipped:Connect(function(...)
        self:toolEquipped(...)
        self:HandleWeaponCollision(false)
    end)
    self.Weapon.Unequipped:Connect(function()
        self:toolUnequipped()
        self:HandleWeaponCollision(true)
    end)

    self.Highlight = Instance.new("Highlight")
    self.Highlight.FillTransparency = 0.8
    self.Highlight.OutlineTransparency = 0
    self.Highlight.Parent = self.Weapon
    return self
end

function Weapon:CheckIfEquipped()
    local Character = self.Weapon.Parent
    if Character then
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            self.prompt.Enabled = false
        else
            self.prompt.Enabled = true
        end
    end
end

function Weapon:HandleWeaponCollision(canCollide:boolean)
    local descendants = self.Weapon:GetDescendants()
    if descendants then
        for _, part in pairs(descendants) do
            if part:IsA("BasePart") then
                part.CanCollide = canCollide
            end
        end
    end
end

function Weapon:promptTriggered(player:Player)
    self.prompt.Enabled = false
    local Character = player.Character
    if Character then
        BackpackManager:HandleBackpackSpace(player)
        self.Weapon.Parent = Character
    end
end

function Weapon:toolEquipped()
    self.Highlight.Enabled = false
    self.prompt.Enabled = false
    IKWeapon.OnEquipped(self.Weapon, self.Weapon.Parent)
end

function Weapon:toolUnequipped()
    self.Highlight.Enabled = true
    self.prompt.Enabled = true
    IKWeapon.OnUnequipped(self.Weapon)
end

function Weapon:Cleanup()
    if self.promptTriggerConnection then
        self.promptTriggerConnection:Disconnect()
        self.promptTriggerConnection = nil
    end
end

function Weapon:fireWeapon(params)
    params.Range = self.Range.Value
    params.Damage = self.Damage.Value
    params.Speed = self.Speed.Value

    if params.Type == "Player" then
        WeaponManager:FirePlayer(params)
    elseif params.Type == "NPC" then
        WeaponManager:FireNPC(params)
    end
end

local function onWeaponAdded(weapon)
	if weapon:IsA("Tool") then
		weapons[weapon] = Weapon.new(weapon)
	end
end

local function onWeaponRemoved(weapon)
	if weapons[weapon] then
		weapons[weapon]:Cleanup()
		weapons[weapon] = nil
	end
end

local function handleFireWeapon(player:Player, fireParams)
    if weapons[fireParams.Weapon] then
        fireParams.Character = player.Character
        weapons[fireParams.Weapon]:fireWeapon(fireParams)
    end
end

local function handleFireWeaponBindable(fireParams)
    if weapons[fireParams.Weapon] then
        weapons[fireParams.Weapon]:fireWeapon(fireParams)
    end
end

-- Listen for existing tags, tag additions and tag removals for the kit tag
for _, inst in pairs(CollectionService:GetTagged(Weapon.TAG_NAME)) do
	onWeaponAdded(inst)
end

FireWeaponBindable.Event:Connect(handleFireWeaponBindable)
FireWeapon.OnServerEvent:Connect(handleFireWeapon)
weaponAddedSignal:Connect(onWeaponAdded)
weaponRemovedSignal:Connect(onWeaponRemoved)