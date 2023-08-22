local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid:Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")

local playerHasLanded = true
local impulseVector = Vector3.new(0, 100, 0)

local function applyImpulseToRootPart(humanoidRootPart:BasePart)
	if humanoidRootPart then
        playerHasLanded = false
		humanoidRootPart:ApplyImpulse((impulseVector * humanoidRootPart.AssemblyMass))
        repeat
            task.wait()
        until Humanoid:GetState() == Enum.HumanoidStateType.Landed
        playerHasLanded = true
	end
    
end


UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Space then
        if Humanoid:GetState() == Enum.HumanoidStateType.Freefall and playerHasLanded then
            applyImpulseToRootPart(HumanoidRootPart)
        end
    end
end)