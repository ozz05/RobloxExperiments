--- This function handles the players dash functionality 

--- Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local MoonAnimatorPlayer = require(ReplicatedStorage.MoonAnimatorPlayer)

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local playerGUI = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
if not Character or not Character.Parent then
	Character = LocalPlayer.CharacterAdded:Wait()
end
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local Humanoid:Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator")

local DASH_COOLDOWN = 2
local DISTANCE = 20
local DESTROY_PROXIMITY = 3

local CooldownFrame
local cooldownGradient
local canDash = true

--- Dash Animation
local dashAnimation_Start = Instance.new("Animation")
dashAnimation_Start.AnimationId = "rbxassetid://13386939826"
local dashAnimation_Loop = Instance.new("Animation")
dashAnimation_Loop.AnimationId = "rbxassetid://13387017473"

-- DashVFX
local VFXFolder = ReplicatedStorage:FindFirstChild("VFX") or ReplicatedStorage:WaitForChild("VFX")
local DashVFX = VFXFolder.DashVFX
local BlueExplosion = VFXFolder.BlueExplosion


local dashStartAnimationTrack = Animator:LoadAnimation(dashAnimation_Start)
local dashLoopAnimationTrack = Animator:LoadAnimation(dashAnimation_Loop)


--- Dash Sound rbxassetid://4909206080
local dashSound = Instance.new("Sound")
dashSound.SoundId = "rbxassetid://4909206080"
dashSound.Name = "Dash"
dashSound.Volume = 0.1
dashSound.Looped = false
dashSound.Parent = HumanoidRootPart



local function useTweenServiceForCooldown()
	local startTick = tick()
	local countValue = 0
    CooldownFrame.Visible = true
	while tick() - startTick <= DASH_COOLDOWN do
		countValue = 1 + ((0 - 1) * (tick() - startTick) / DASH_COOLDOWN)
		if countValue - 0.002 > 0 then
			cooldownGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0,0),
				NumberSequenceKeypoint.new(countValue - 0.002,0),
				NumberSequenceKeypoint.new(countValue,1),
				NumberSequenceKeypoint.new(1,1)
			}
		end
		RunService.RenderStepped:Wait()
	end
	canDash = true
	CooldownFrame.Visible = false
end

local function handleDashAnimation()
	local debounce = os.clock()
	dashStartAnimationTrack:Play()
	repeat
		RunService.RenderStepped:Wait()
	until not dashStartAnimationTrack.IsPlaying or (os.clock() - debounce) > dashStartAnimationTrack.Length
	dashLoopAnimationTrack:Play()
	dashSound:Play()
end

local function applyImpulse(humanoidRootPart:BasePart, targetPosition, travelTrime)
	local currentPosition = humanoidRootPart.Position
	local distance = (targetPosition - currentPosition).Magnitude
	local direction = (targetPosition - currentPosition).Unit
	local playerVelocity = math.sqrt(humanoidRootPart.AssemblyLinearVelocity:Dot(direction)^2)
	local gravity = game.Workspace.Gravity
	local impulseMagnitude = math.sqrt((gravity * 0.5) * distance * humanoidRootPart.AssemblyMass)
	local impulseForce = direction * impulseMagnitude * humanoidRootPart.AssemblyMass
	if (Humanoid:GetState() == Enum.HumanoidStateType.Jumping) or (Humanoid:GetState() == Enum.HumanoidStateType.Freefall) then
		impulseForce = impulseForce * 0.5
	end
	humanoidRootPart:ApplyImpulse(impulseForce)
	handleDashAnimation()
	task.wait(travelTrime)
	dashStartAnimationTrack:Stop()
	dashLoopAnimationTrack:Stop()
	useTweenServiceForCooldown()
end

local function applyImpulseToRootPart(humanoidRootPart:BasePart, goalPosition:Vector3, travelTrime)
	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local direction = goalPosition - humanoidRootPart.Position
		local Magnitude = (goalPosition - humanoidRootPart.Position).Magnitude
		local force = (direction * Magnitude) + Vector3.new(0, 10, 0)
		humanoidRootPart:ApplyImpulse((force * humanoidRootPart.AssemblyMass))
		handleDashAnimation()
		task.wait(travelTrime)
		dashStartAnimationTrack:Stop()
		dashLoopAnimationTrack:Stop()
		useTweenServiceForCooldown()
	end
end

local function useAlignPosition(humanoidRootPart, goalPosition)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Position = goalPosition
	part.Size = Vector3.new(0.1,0.1,0.1)
	part.Transparency = 1
	part.Parent = game.Workspace
	
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.RigidityEnabled = true
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.Parent = HumanoidRootPart
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Parent = humanoidRootPart
	
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = part
	
	
	alignPosition.Attachment0 = attachment1
	alignPosition.Attachment1 = attachment2
	handleDashAnimation()
	local connection 
	local function checkGoal()
		local currentPosition = humanoidRootPart.Position
		local distance = (currentPosition - goalPosition).Magnitude
		if distance < DESTROY_PROXIMITY then
			alignPosition:Destroy()
			attachment1:Destroy()
			attachment2:Destroy()
			part:Destroy()
			dashStartAnimationTrack:Stop()
			dashLoopAnimationTrack:Stop()
			connection:Disconnect(checkGoal)
			useTweenServiceForCooldown()
		end
	end
	connection = RunService.RenderStepped:Connect(checkGoal)
end

local function moveHumanoidRootPart(distance, humanoidRootPart)
	local lookVector = humanoidRootPart.CFrame.lookVector
	local offset = lookVector * distance
    --local origin = HumanoidRootPart.Position
    local goalPosition = humanoidRootPart.Position + offset
    --[[local result = workspace:Raycast(origin, offset)
    if result then
        goalPosition = result.Position
    end--]]
	local VFXCopy = DashVFX:Clone()
	MoonAnimatorPlayer.playVFX(VFXCopy, HumanoidRootPart.CFrame)

	local ExplosionVFXCopy = BlueExplosion:Clone()
	MoonAnimatorPlayer.playVFX(ExplosionVFXCopy, HumanoidRootPart.CFrame)
	--useAlignPosition(humanoidRootPart, goalPosition)
	--applyImpulseToRootPart(humanoidRootPart, goalPosition, .5)
	applyImpulse(humanoidRootPart, goalPosition, .5)
end

--- handles the activation of the dash
local function onActivated()
	if canDash then
		canDash = false
		moveHumanoidRootPart(DISTANCE, HumanoidRootPart)
	end

end


local function onInputBegan(input, _gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	else
		if input.KeyCode == Enum.KeyCode.Q then
			onActivated()
		end
	end
end

local function actiavteButton(isOnMobile)
	if playerGUI then
		local Controls = playerGUI:FindFirstChild("Controls") or playerGUI:WaitForChild("Controls")
		if Controls then
			local ControlsFrame = Controls:FindFirstChild("ControlsFrame") or Controls:WaitForChild("ControlsFrame")
			if ControlsFrame then
				local DashFrame = ControlsFrame:FindFirstChild("DashFrame") or ControlsFrame:WaitForChild("DashFrame") 
				if DashFrame then
					if isOnMobile then
						local Key = DashFrame:FindFirstChild("Key") or DashFrame:WaitForChild("Key")
						if Key then
							Key.Visible = false
						end
					end
					local DashButton =  DashFrame:FindFirstChild("DashButton") or DashFrame:WaitForChild("DashButton")
					if DashButton then
						DashButton.Activated:Connect(onActivated)
					end
					CooldownFrame = DashFrame:FindFirstChild("Cooldown") or DashFrame:WaitForChild("Cooldown")
					cooldownGradient = CooldownFrame:FindFirstChildWhichIsA("UIGradient")
				end
			end
		end
	end
end

if UserInputService.MouseEnabled then
	UserInputService.InputBegan:Connect(onInputBegan)
	actiavteButton(false)
else
	actiavteButton(true)
end
