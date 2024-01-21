local IKWeapon = {}

function IKWeapon.OnEquipped(weapon:Instance, character:Model)
    local rightHand:Instance = character:FindFirstChild("RightHand")
    local rightHolder:Instance = character:FindFirstChild("Handle")
    local RightUpperArm = character:FindFirstChild("RightUpperArm")
    if rightHand and rightHolder and RightUpperArm then
        local rightHandikController = weapon:FindFirstChild("rightHandikController") or weapon:WaitForChild("rightHandikController", 1)
        if not rightHandikController then
            rightHandikController = Instance.new("IKControl")
            rightHandikController.Name = "rightHandikController"
            rightHandikController.Weight = 1
            rightHandikController.SmoothTime = 0.05
            rightHandikController.Parent = weapon
        end
        
        rightHandikController.EndEffector = rightHand
        rightHandikController.ChainRoot = RightUpperArm
        rightHandikController.Target = rightHolder
    end
    
    local leftHand:Instance = character:FindFirstChild("LeftHand")
    local LeftUpperArm:Instance = character:FindFirstChild("LeftUpperArm")
    local leftHolder:Instance = weapon:FindFirstChild("LeftHolder")
    if leftHand and LeftUpperArm and leftHolder then
        local leftHandikController = weapon:FindFirstChild("leftHandikController") or weapon:WaitForChild("leftHandikController", 1)
        if not leftHandikController then
            leftHandikController = Instance.new("IKControl")
            leftHandikController.Name = "leftHandikController"
            leftHandikController.Weight = 1
            leftHandikController.SmoothTime = 0.05
            leftHandikController.Parent = weapon
        end
        
        leftHandikController.EndEffector = leftHand
        leftHandikController.ChainRoot = LeftUpperArm
        leftHandikController.Target = leftHolder
    end
end

function IKWeapon.OnUnequipped(weapon:Instance)
    local rightHandikController = weapon:FindFirstChild("rightHandikController") or weapon:WaitForChild("rightHandikController", 1)
    if rightHandikController then
        rightHandikController.EndEffector = nil
        rightHandikController.ChainRoot = nil
        rightHandikController.Target = nil
    end

    local leftHandikController = weapon:FindFirstChild("leftHandikController") or weapon:WaitForChild("leftHandikController", 1)
    if leftHandikController then
        leftHandikController.EndEffector = nil
        leftHandikController.ChainRoot = nil
        leftHandikController.Target = nil
    end
end

return IKWeapon