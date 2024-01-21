local BackpackManager = {}
BackpackManager.BackpackSpace = 1

local function checkNumberOfTools(player)
    local Character = player.Character
    local itemsInBackpack = 0
    if Character then
        local tool = Character:FindFirstChildWhichIsA("Tool")
        if tool then
            itemsInBackpack += 1
        end
        local Backpack = player.Backpack
        if Backpack then
            for _, value in pairs(Backpack:GetChildren()) do
                itemsInBackpack += 1
            end
        end
    end
    return itemsInBackpack
end

function BackpackManager:HandleBackpackSpace(player:Player)
    local Character = player.Character
    local itemsInBackpack = checkNumberOfTools(player)
    if Character then
        local tool = Character:FindFirstChildWhichIsA("Tool")
        if tool then
            if itemsInBackpack >= BackpackManager.BackpackSpace then
                itemsInBackpack -= 1
                tool.Parent = game.Workspace
            end
        end
        local Backpack = player.Backpack
        if Backpack then
            for _, value in pairs(Backpack:GetChildren()) do
                if itemsInBackpack >= BackpackManager.BackpackSpace then
                    itemsInBackpack -= 1
                    value.Parent = game.Workspace
                end
            end
        end
        local Humanoid:Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid:UnequipTools()
        end
    end
end

return BackpackManager