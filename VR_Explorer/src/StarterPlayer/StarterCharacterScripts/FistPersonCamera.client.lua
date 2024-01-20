-- Services
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = game.Workspace.CurrentCamera
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Head = Character:FindFirstChild("Head") or Character:WaitForChild("Head")


local function updateRotation()
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    -- Extract the rotation part of the camera CFrame
    local rotation = CFrame.new(Vector3.new(), Camera.CFrame.LookVector)
    -- Apply the rotation to the character's humanoid root part
    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * rotation
end

local function handleUserCFrameChanged(_type, _newCFrame)
    updateRotation()
end

local function handleRenderStepped(_deltaTime)
    Camera.CameraType = Enum.CameraType.Scriptable
    
    Humanoid.AutoRotate = false
    local HeadCFrame = Head.CFrame
    if VRService.VREnabled == true then
        HeadCFrame = VRService:GetUserCFrame(Enum.UserCFrame.Head)
        Camera.CFrame = CFrame.new(Head.CFrame.Position) * CFrame.new(HeadCFrame.Position) * CFrame.Angles(HeadCFrame:ToEulerAnglesXYZ())
    else
        Camera.CFrame = CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(HeadCFrame:ToEulerAnglesXYZ())
    end
end

local function handleInputChanged(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateRotation()
    end
end

if VRService.VREnabled == true then
    VRService.UserCFrameChanged:Connect(handleUserCFrameChanged)
end


-- Connect the function to the user input changed event
UserInputService.InputChanged:Connect(handleInputChanged)
RunService.RenderStepped:Connect(handleRenderStepped)