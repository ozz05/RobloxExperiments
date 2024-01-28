local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")


local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local VRInputHandlerRemote = RemoteEvents:FindFirstChild("VRInputHandler") or RemoteEvents:WaitForChild("VRInputHandler")

local VRCharacter = ServerStorage:FindFirstChild("VRCharacter") or ServerStorage:WaitForChild("VRCharacter")

local function AddIKControls(player:Player)
    local character = player.Character or player.CharacterAdded:Wait()
    local RightHandVR = VRCharacter.RightHandVR:Clone()
    local LeftHandVR = VRCharacter.LeftHandVR:Clone()
    local CameraVR = VRCharacter.CameraVR:Clone()

    RightHandVR.Parent = character
    LeftHandVR.Parent = character
    CameraVR.Parent = character
    local rightHand:Instance = character:FindFirstChild("RightHand")
    local RightUpperArm = character:FindFirstChild("RightUpperArm")
    if rightHand and RightUpperArm then
        local rightHandikController = Instance.new("IKControl")
        rightHandikController.Name = "rightHandikController"
        rightHandikController.Weight = 1
        rightHandikController.SmoothTime = 0.05
        rightHandikController.Parent = RightHandVR
        
        rightHandikController.EndEffector = rightHand
        rightHandikController.ChainRoot = RightUpperArm
        rightHandikController.Target = RightHandVR
    end
    
    local leftHand:Instance = character:FindFirstChild("LeftHand")
    local LeftUpperArm = character:FindFirstChild("LeftUpperArm")
    if leftHand and LeftUpperArm then
        local leftHandikController = Instance.new("IKControl")
        leftHandikController.Name = "leftHandikController"
        leftHandikController.Weight = 1
        leftHandikController.SmoothTime = 0.05
        leftHandikController.Parent = LeftHandVR
        leftHandikController.EndEffector = leftHand
        leftHandikController.ChainRoot = LeftUpperArm
        leftHandikController.Target = LeftHandVR
    end
end

local function updatePlayerOrientation(player:Player, params)
    local Character = player.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            local AlignOrientation:AlignOrientation = RootPart:FindFirstChild("VROrientation")
            if AlignOrientation then
                AlignOrientation.CFrame = params.HumanoidOrientation
            else
                AlignOrientation = Instance.new("AlignOrientation")
                AlignOrientation.Name = "VROrientation"
                AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                AlignOrientation.RigidityEnabled = true
                AlignOrientation.Attachment0 = RootPart:FindFirstChild("RootAttachment")
                AlignOrientation.Parent = RootPart
                AlignOrientation.CFrame = params.HumanoidOrientation
            end
        end
        local RightHandVR = Character:FindFirstChild("RightHandVR")
        if RightHandVR then
            RightHandVR.CFrame = params.RightHandVR
        end
        local LeftHandVR = Character:FindFirstChild("LeftHandVR")
        if LeftHandVR then
            LeftHandVR.CFrame = params.LeftHandVR
        end
        local CameraVR = Character:FindFirstChild("CameraVR")
        if CameraVR then
            CameraVR.CFrame = params.CameraVR
        end
    end
end

VRInputHandlerRemote.OnServerEvent:Connect(function(player:Player, action:string , params)
    if action == "UPDATE" then
        updatePlayerOrientation(player, params)
    elseif action == "ADD_VR_CONTROLS" then
        AddIKControls(player)
    end
    
end)