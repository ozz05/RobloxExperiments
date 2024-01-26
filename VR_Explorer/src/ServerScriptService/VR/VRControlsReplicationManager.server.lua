local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateOrientattion = RemoteEvents:FindFirstChild("UpdateOrientation") or RemoteEvents:WaitForChild("UpdateOrientation")


local function updatePlayerOrientation(player:Player, newCFrame:CFrame)
    
    local Charcater = player.Character
    if Charcater then
        local RootPart = Charcater.HumanoidRootPart
        if RootPart then
            local AlignOrientation:AlignOrientation = RootPart:FindFirstChild("VROrientation")
            if AlignOrientation then
                AlignOrientation.CFrame = newCFrame
            else
                AlignOrientation = Instance.new("AlignOrientation")
                AlignOrientation.Name = "VROrientation"
                AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
                AlignOrientation.RigidityEnabled = true
                AlignOrientation.Attachment0 = RootPart:FindFirstChild("RootAttachment")
                AlignOrientation.Parent = RootPart
            end

        end
    end
end

UpdateOrientattion.OnServerEvent:Connect(function(player, newCFrame)
    updatePlayerOrientation(player, newCFrame)
end)