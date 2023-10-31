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

local ATTACK_COOLDOWN = 2

local CooldownFrame
local cooldownGradient
local canAttack = true

--- Dash Animation
local dashAnimation_Start = Instance.new("Animation")
dashAnimation_Start.AnimationId = "rbxassetid://13386939826"

-- DashVFX
local VFXFolder = ReplicatedStorage:FindFirstChild("VFX") or ReplicatedStorage:WaitForChild("VFX")
local AttackVFX = VFXFolder.Attack


local dashStartAnimationTrack = Animator:LoadAnimation(dashAnimation_Start)


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
	while tick() - startTick <= ATTACK_COOLDOWN do
		countValue = 1 + ((0 - 1) * (tick() - startTick) / ATTACK_COOLDOWN)
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
	canAttack = true
	CooldownFrame.Visible = false
end

local function playVFX(humanoidRootPart)
    local VFXCopy = AttackVFX:Clone()
	MoonAnimatorPlayer.playVFX(VFXCopy, humanoidRootPart.CFrame)
end

--- handles the activation of the dash
local function onActivated()
	if canAttack then
		canAttack = false
		playVFX(HumanoidRootPart)
        useTweenServiceForCooldown()
        canAttack = true
	end

end


local function onInputBegan(input, _gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	else
		if input.KeyCode == Enum.KeyCode.R then
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
				local AttackFrame = ControlsFrame:FindFirstChild("AttackFrame") or ControlsFrame:WaitForChild("AttackFrame") 
				if AttackFrame then
					if isOnMobile then
						local Key = AttackFrame:FindFirstChild("Key") or AttackFrame:WaitForChild("Key")
						if Key then
							Key.Visible = false
						end
					end
					local AttackButton =  AttackFrame:FindFirstChild("AttackButton") or AttackFrame:WaitForChild("AttackButton")
					if AttackButton then
						AttackButton.Activated:Connect(onActivated)
					end
					CooldownFrame = AttackFrame:FindFirstChild("Cooldown") or AttackFrame:WaitForChild("Cooldown")
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
