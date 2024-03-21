-- Services
local CollectionService = game:GetService("CollectionService")

local ItemSpawner = {}
ItemSpawner.__index = ItemSpawner
ItemSpawner.TAG_NAME = "ItemSpawner"

local itemSpawners = {}

local itemSpawnerAddedSignal = CollectionService:GetInstanceAddedSignal(ItemSpawner.TAG_NAME)
local itemSpawnerRemovedSignal = CollectionService:GetInstanceRemovedSignal(ItemSpawner.TAG_NAME)

function ItemSpawner.new(itemSpawner:Model)
    local self = {}
    setmetatable(self, ItemSpawner)
    self.ItemSpawner = itemSpawner
    
    self.SettingsFolder = itemSpawner:FindFirstChild("Settings") or itemSpawner:WaitForChild("Settings", 2)
    if self.SettingsFolder then
        local ItemToSpawnValue = self.SettingsFolder:FindFirstChild("ItemToSpawn") or self.SettingsFolder:WaitForChild("ItemToSpawn")
        local PromptValue = self.SettingsFolder:FindFirstChild("Prompt") or self.SettingsFolder:WaitForChild("Prompt")
        local ItemSpawnPointValue = self.SettingsFolder:FindFirstChild("ItemSpawnPoint") or self.SettingsFolder:WaitForChild("ItemSpawnPoint")
        if ItemToSpawnValue.Value and PromptValue.Value and ItemSpawnPointValue.Value then
            self.ItemToSpawn = ItemToSpawnValue.Value
            self.ProximityPrompt = PromptValue.Value
            self.ItemSpawnPoint = ItemSpawnPointValue.Value

            self.ProximityPrompt.Triggered:Connect(function(_player)
                self:SpawnItem()
            end)
        else
            error("Missing ItemToSpawn or Propmt references")
        end
    else
        error("ItemSpawner is missing Setting folder")
    end
end

function ItemSpawner:SpawnItem()
    warn("here")
    local newItem = self.ItemToSpawn:Clone()
    newItem:SetPrimaryPartCFrame(self.ItemSpawnPoint.CFrame:ToWorldSpace(CFrame.new(0, 5, 0)))
    newItem.Parent = game.Workspace
end

function ItemSpawner:Cleanup()
	print("Here")
end

local function onItemSpawnerAdded(itemSpawner)
    if itemSpawner:IsA("Model") then
        itemSpawners[itemSpawner] = ItemSpawner.new(itemSpawner)
    end
end

local function onItemSpawnerRemoved(itemSpawner)
    if itemSpawners[itemSpawner] then
        itemSpawners[itemSpawner]:Cleanup()
        itemSpawners[itemSpawner] = nil
    end
end

for _, itemSpawner in pairs(CollectionService:GetTagged(ItemSpawner.TAG_NAME)) do
    onItemSpawnerAdded(itemSpawner)
end

itemSpawnerAddedSignal:Connect(onItemSpawnerAdded)
itemSpawnerRemovedSignal:Connect(onItemSpawnerRemoved)