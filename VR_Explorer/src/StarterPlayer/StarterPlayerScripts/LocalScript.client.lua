-- Services
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function SetTransparency(playerCharacter)
    -- Check if the player's character exists
    if playerCharacter and playerCharacter:IsA("Model") then
        -- Iterate through the parts of the character
        for _, part in pairs(playerCharacter:GetDescendants()) do
            if (part:IsA("BasePart") or part:IsA("Decal") or part:IsA("Texture")) and not part:FindFirstAncestorOfClass("Tool") then
                if part.Name == "RightHand" or part.Name == "LeftHand" or part.Name == "RightHandVR" or part.Name == "LeftHandVR" or part.Name == "UpperTorso" or part.Name == "Head" or part.Name == "CameraVR" then
                    part.LocalTransparencyModifier = 0.5
                    
                else
                    part.LocalTransparencyModifier = 1
                    part.Changed:Connect(function(property)
                        if property == "LocalTransparencyModifier" then
                            part.LocalTransparencyModifier = 1
                        end
                    end)
                end
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(3)
    SetTransparency(character)
end)