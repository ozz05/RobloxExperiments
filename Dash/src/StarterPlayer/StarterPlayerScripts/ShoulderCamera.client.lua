--Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local ExtrernalModulesFolder = ReplicatedStorage:FindFirstChild("ExternalModules") or ReplicatedStorage:WaitForChild("ExternalModules")
local Spring = require(ExtrernalModulesFolder.Spring)

--Player
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
Humanoid.AutoRotate = true

--Camera
local Camera = game.Workspace.CurrentCamera
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

local descendantAddedConnection = nil

---- Locked camera settings
local CAMERA_Y_SENSITIVITY = 1		-- anything higher would make looking up and down harder; recommend anything between 0~1
local CAMERA_X_SENSITIVITY = 2
local CAMERA_SMOOTHNESS = 1    -- recommend anything between 0~1
local FORWARD_ROTATTION_LIMIT = 88
local BACKWARD_ROTATTION_LIMIT = 30
local X_TOUCH_LIMIT = Camera.ViewportSize.X/3 -- Limit for the touch input
local THUMSTICK_SENSITIVITY = 5
local THUMSTICK_TOLERANCE = 0.03
local CAMERA_OFFSET = CFrame.new(2, 4, 12)
local AngleX,TargetAngleX = 0,0
local AngleY,TargetAngleY = 0,0
local thumbStick2MovementCoroutine = nil
local cameraLocked = true

--- Spring Settings
local positionSpring = Spring.new(Vector3.new(0, 0, 0))
positionSpring.Damper = 1
positionSpring.Speed = 15

--Functions
-- Remove back accessories since they frequently block the camera
local function isBackAccessory(instance)
	if instance and instance:IsA("Accessory") then
		local handle = instance:WaitForChild("Handle", 5)
		if handle and handle:IsA("Part") then
			local bodyBackAttachment = handle:WaitForChild("BodyBackAttachment", 5)
			if bodyBackAttachment and bodyBackAttachment:IsA("Attachment") then
				return true
			end

			local waistBackAttachment = handle:WaitForChild("WaistBackAttachment", 5)
			if waistBackAttachment and waistBackAttachment:IsA("Attachment") then
				return true
			end
		end
	end

	return false
end

local function removeBackAccessoriesFromCharacter(character)
	for _, child in ipairs(character:GetChildren()) do
		coroutine.wrap(function()
			if isBackAccessory(child) then
				child:Destroy()
			end
		end)()
	end
end

local function onCharacterAdded(character)
	Character = character
    HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
	removeBackAccessoriesFromCharacter(character)
	descendantAddedConnection = character.DescendantAdded:Connect(function(descendant)
		coroutine.wrap(function()
			if isBackAccessory(descendant) then
				descendant:Destroy()
			end
		end)()
	end)
end

local function onCharacterRemoving(character)
	Character = nil
	Humanoid = nil
	HumanoidRootPart = nil
	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
		descendantAddedConnection = nil
	end
end


local function rotatePlayer()
    local direction
	local camLookVec = Camera.CFrame.LookVector
	local lookVecX, lookVecZ = camLookVec.X, camLookVec.Z
	if lookVecX ~= 0 or lookVecZ ~= 0 then
		direction = Vector3.new(lookVecX, 0, lookVecZ).Unit
	end
	if not HumanoidRootPart or not Humanoid then
		return
	end
    Humanoid.AutoRotate = false
	local HumanoidRootPartPosition = HumanoidRootPart.Position
	HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition, HumanoidRootPartPosition + direction)
end


local function mouseMoved(input)
	if cameraLocked then
		local delta = Vector2.new(input.Delta.X/CAMERA_X_SENSITIVITY,input.Delta.Y/CAMERA_Y_SENSITIVITY) * CAMERA_SMOOTHNESS
		local X = TargetAngleX - delta.Y
		local Y = TargetAngleY - delta.X
		TargetAngleX = (X >= BACKWARD_ROTATTION_LIMIT and BACKWARD_ROTATTION_LIMIT) or (X <= -FORWARD_ROTATTION_LIMIT and -FORWARD_ROTATTION_LIMIT) or X -- this helps control the rotating distance
		TargetAngleY = Y
		AngleX = AngleX + (TargetAngleX - AngleX) * CAMERA_SMOOTHNESS
		AngleY = AngleY + (TargetAngleY - AngleY) * CAMERA_SMOOTHNESS
	end
end

local function mobileInputChanged(input)
	if cameraLocked then
		if input.Position.X > X_TOUCH_LIMIT then
			mouseMoved(input)
		end
	end
end

local function thumStickInputChanged(input)
	if thumbStick2MovementCoroutine == nil  then
		thumbStick2MovementCoroutine = coroutine.create(function()
			local function moveCamera(deltaX, deltaY)
				if cameraLocked then
					local delta = Vector2.new(deltaX/CAMERA_X_SENSITIVITY, deltaY/CAMERA_Y_SENSITIVITY) * THUMSTICK_SENSITIVITY
					local X = TargetAngleX - delta.Y
					local Y = TargetAngleY - delta.X
					TargetAngleX = (X >= BACKWARD_ROTATTION_LIMIT and BACKWARD_ROTATTION_LIMIT) or (X <= -FORWARD_ROTATTION_LIMIT and -FORWARD_ROTATTION_LIMIT) or X -- this helps control the rotating distance
					TargetAngleY = Y
					AngleX = AngleX + (TargetAngleX - AngleX) * CAMERA_SMOOTHNESS
					AngleY = AngleY + (TargetAngleY - AngleY) * CAMERA_SMOOTHNESS
				end
			end
			while true do
				if input.Position.X < THUMSTICK_TOLERANCE and input.Position.X > -THUMSTICK_TOLERANCE and input.Position.Y < THUMSTICK_TOLERANCE and input.Position.Y > -THUMSTICK_TOLERANCE then
					break
				else
					moveCamera(input.Position.X, - input.Position.Y)
					RunService.RenderStepped:Wait()
				end
			end
			thumbStick2MovementCoroutine = nil
			coroutine.yield()
		end)
		coroutine.resume(thumbStick2MovementCoroutine)
	end
end

local function inputChanged(input)
	if cameraLocked then
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			mouseMoved(input)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			mobileInputChanged(input)
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			thumStickInputChanged(input)
		end
	end
end

local function updateCamera(step)
	if cameraLocked then
		if not HumanoidRootPart or not Humanoid or not Character then
			return
		end

		local TargetAnglesCFrame = CFrame.Angles(0,math.rad(AngleY),0) * CFrame.Angles(math.rad(AngleX),0,0)
		positionSpring.Target = HumanoidRootPart.Position

		Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		local finalCameraCFrame = CFrame.new(positionSpring.Position) * TargetAnglesCFrame * CAMERA_OFFSET
		Camera.CFrame = finalCameraCFrame
		rotatePlayer()
	end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)
UserInputService.InputChanged:Connect(inputChanged)
RunService.RenderStepped:Connect(updateCamera)