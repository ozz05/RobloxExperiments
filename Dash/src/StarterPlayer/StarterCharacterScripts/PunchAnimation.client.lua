--- Services 
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")


local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
if not Character or not Character.Parent then
	Character = LocalPlayer.CharacterAdded:Wait()
end

local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator")

local IsAtacking = Instance.new("BoolValue")
IsAtacking.Name = "IsAtacking"
IsAtacking.Parent = Character
--- Animation
local animationID = "rbxassetid://13387017473"
local punchAnimation = Instance.new("Animation")
punchAnimation.AnimationId = animationID
local punchAnimationTrack:AnimationTrack = Animator:LoadAnimation(punchAnimation)


--- handles the activation of the punch
local function onActivated()
	if not punchAnimationTrack.IsPlaying then
		IsAtacking.Value = true
		punchAnimationTrack:Play()
		task.wait(punchAnimationTrack.Length)
		IsAtacking.Value = false
	end
end


local function onInputBegan(input, _gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	else
		if input.KeyCode == Enum.KeyCode.F then
			onActivated()
		end
	end
end


UserInputService.InputBegan:Connect(onInputBegan)