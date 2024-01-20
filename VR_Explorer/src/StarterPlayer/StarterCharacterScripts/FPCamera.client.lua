--Services

local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local mobileDragging
local dragging
local distance = 0.5

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera
Camera.CameraSubject = script.Parent:WaitForChild("Head")
local camX,camY,camZ = Camera.CFrame:ToEulerAnglesXYZ()
Camera.CameraType = Enum.CameraType.Scriptable

local xRot = 0
local yRot = 0

local Head = Character:FindFirstChild("Head") or Character:WaitForChild("Head")
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local function rotatePlayer()
	if Humanoid.Sit or not HumanoidRootPart or not Humanoid then
		return
	end
    local direction
	local camLookVec = Camera.CFrame.LookVector
	local lookVecX, lookVecZ = camLookVec.X, camLookVec.Z
	if lookVecX ~= 0 or lookVecZ ~= 0 then
		direction = Vector3.new(lookVecX, 0, lookVecZ).Unit
	end
    Humanoid.AutoRotate = false
	local HumanoidRootPartPosition = HumanoidRootPart.Position
	HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition, HumanoidRootPartPosition + direction)
end

local function handleVRCamera()
	local HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
	Camera.CFrame = CFrame.new(Head.CFrame.Position) * CFrame.new(HeadCFrame.Position) * CFrame.Angles(HeadCFrame:ToEulerAnglesXYZ())
end

local function updateAngles(input)
	local delta = input.Delta
	local sensitivity = UserGameSettings.MouseSensitivity
	if UserInputService.GamepadEnabled then
		sensitivity = UserGameSettings.GamepadCameraSensitivity
	elseif UserInputService.MouseEnabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		sensitivity = UserGameSettings.MouseSensitivity
	end
	xRot += math.rad((delta.X * 0.25) * sensitivity * -1)
	yRot += math.rad((delta.Y * 0.25) * sensitivity * -1)
end

local function handleOtherDeviceCamera()
	yRot = math.clamp(yRot, math.rad(-75), math.rad(75))
	Camera.Focus = CFrame.new(Camera.CameraSubject.Position)
	Camera.CFrame = Camera.Focus
	Camera.CFrame *= CFrame.fromEulerAnglesYXZ(yRot, xRot, 0) * CFrame.new(0, 0, distance)
end



local function handleRenderStepped()
	if VRService.VREnabled == true then
		handleVRCamera()
	else
		handleOtherDeviceCamera()
	end
	rotatePlayer()
end

local function handleInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		dragging = true
	end
	if input.UserInputType == Enum.UserInputType.Touch then
		mobileDragging = true
	end
end

local function handleInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		dragging = false
	end
	if input.UserInputType == Enum.UserInputType.Touch then
		mobileDragging = false
	end
end

local function handleInputChanged(input)
	updateAngles(input)
end

UserInputService.InputBegan:Connect(handleInputBegan)
UserInputService.InputEnded:Connect(handleInputEnded)
UserInputService.InputChanged:Connect(handleInputChanged)
RunService:BindToRenderStep("Camera",0, handleRenderStepped)