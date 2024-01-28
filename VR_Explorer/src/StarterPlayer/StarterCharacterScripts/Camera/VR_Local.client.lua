-- Services
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local VRInputHandlerRemote = RemoteEvents:FindFirstChild("VRInputHandler") or RemoteEvents:WaitForChild("VRInputHandler")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local HeadScale = Camera.HeadScale
local RightHandVR
local LeftHandVR
local CameraVR

local debounceTime = 0.3  -- Set the debounce time in seconds
local lastUpdateTime = 0

local function rotatePlayerVR()
	if Humanoid.Sit or not HumanoidRootPart or not Humanoid then
		return
	end

	local direction
	local camLookVec = Camera:GetRenderCFrame().LookVector
	local lookVecX, lookVecZ = camLookVec.X, camLookVec.Z

	if lookVecX ~= 0 or lookVecZ ~= 0 then
		direction = Vector3.new(lookVecX, 0, lookVecZ).Unit
	end
	
	Humanoid.AutoRotate = false
	local NewCFrame = CFrame.new(HumanoidRootPart.Position, HumanoidRootPart.Position + direction)
	return NewCFrame
end

local function displayPlayerMovement(params)
    local RightHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.RightHand)
    local LeftHandCFrame = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)

    local RightHandMathfied = Camera.CFrame * RightHandCFrame
    local LeftHandMathfied = Camera.CFrame * LeftHandCFrame
    local LRotatedCFrame = CFrame.Angles(math.rad(90), 0, 0)
    local RRotatedCFrame = CFrame.Angles(math.rad(90), 0, 0)

    params.RightHandVR = RightHandMathfied:ToWorldSpace(RRotatedCFrame)
    params.LeftHandVR = LeftHandMathfied:ToWorldSpace(LRotatedCFrame)
    params.CameraVR = Camera:GetRenderCFrame()
end


local function handleRenderStepped(_deltaTime)
    
end

local function handleUserCFrameChanged(_type, _newCFrame)
    local params = {}
    displayPlayerMovement(params)
    params.HumanoidOrientation = rotatePlayerVR()
    VRInputHandlerRemote:FireServer("UPDATE", params)
end

if VRService.VREnabled == true then
    VRInputHandlerRemote:FireServer("ADD_VR_CONTROLS")
    RightHandVR = Character:FindFirstChild("RightHandVR") or Character:WaitForChild("RightHandVR")
    LeftHandVR = Character:FindFirstChild("LeftHandVR") or Character:WaitForChild("LeftHandVR")
    CameraVR = Character:FindFirstChild("CameraVR") or Character:WaitForChild("CameraVR")
    -- This disables the laser pointers that the vr controllers have
    StarterGui:SetCore("VRLaserPointerMode", 0)
    -- Not sure what controller models are
    StarterGui:SetCore("VREnableControllerModels", true)
    VRService:RecenterUserHeadCFrame()
    Camera.HeadScale = HeadScale
    VRService.AutomaticScaling = Enum.VRScaling.World
    VRService.UserCFrameChanged:Connect(handleUserCFrameChanged)
    --- Camera --
    RunService.RenderStepped:Connect(handleRenderStepped)
end