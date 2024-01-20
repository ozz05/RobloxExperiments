local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local VRCharacter = ServerStorage:FindFirstChild("VRCharacter") or ServerStorage:WaitForChild("VRCharacter")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local RightHandVR = VRCharacter.RightHandVR:Clone()
        local LeftHandVR = VRCharacter.LeftHandVR:Clone()

        RightHandVR.Parent = character
        LeftHandVR.Parent = character
    end)
end)