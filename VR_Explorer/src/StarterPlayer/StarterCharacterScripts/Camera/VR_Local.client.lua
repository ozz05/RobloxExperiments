-- Services
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")


local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local HeadScale = 1
local RightHandVR = Character:FindFirstChild("RightHandVR") or Character:WaitForChild("RightHandVR")
local LeftHandVR = Character:FindFirstChild("LeftHandVR") or Character:WaitForChild("LeftHandVR")
local RootPartVR = Character:FindFirstChild("RootPartVR") or Character:WaitForChild("RootPartVR")
--local CameraVR = Character:FindFirstChild("CameraVR") or Character:WaitForChild("CameraVR")


local function AddIKControls (character:Model)
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


local function handleUserCFrameChanged(_type, _newCFrame)
    local RightHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
    local LeftHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
    local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)

    local RightHandMathfied = 
        CFrame.new(Camera.CFrame.Position) * CFrame.new((RightHandCFrame.Position - HeadCFrame.Position) 
        * HeadScale) * CFrame.fromEulerAnglesXYZ(RightHandCFrame:ToEulerAnglesXYZ())

    local LeftHandMathfied = 
        CFrame.new(Camera.CFrame.Position) * CFrame.new((LeftHandCFrame.Position - HeadCFrame.Position) 
        * HeadScale) * CFrame.fromEulerAnglesXYZ(LeftHandCFrame:ToEulerAnglesXYZ())
    
    local LRotatedCFrame = CFrame.Angles(math.rad(90), 0, 0)
    local RRotatedCFrame = CFrame.Angles(math.rad(90), 0, 0)
    RightHandVR.CFrame = RightHandMathfied:ToWorldSpace(RRotatedCFrame)
    LeftHandVR.CFrame = LeftHandMathfied:ToWorldSpace(LRotatedCFrame)
    RootPartVR.CFrame = Character.HumanoidRootPart.CFrame
    --CameraVR.CFrame = Camera.CFrame:ToWorldSpace(CFrame.new(0, 0, -2))
end


local function handleRenderStepped(_deltaTime)
    handleUserCFrameChanged()
end

if VRService.VREnabled == true then
    Camera.CameraType = Enum.CameraType.Scriptable;
    -- This disables the laser pointers that the vr controllers have
    StarterGui:SetCore("VRLaserPointerMode", 0)
    -- Not sure what controller models are
    StarterGui:SetCore("VREnableControllerModels", false)
    VRService:RecenterUserHeadCFrame()
    Camera.HeadScale = HeadScale
    AddIKControls(Character)
    --VRService.UserCFrameChanged:Connect(handleUserCFrameChanged)
    --- Camera --
    RunService.RenderStepped:Connect(handleRenderStepped)
end