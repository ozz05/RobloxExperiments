local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local toolbar = plugin:CreateToolbar("MoonAnimator Player")


local pluginButton = toolbar:CreateButton(
"Set up Player", --Text that will appear below button
"Button to set up the moonanimator player", --Text that will appear if you hover your mouse on button
"rbxassetid://13934081811")


local function instanceModule(folder)
    local module = Instance.new("ModuleScript")
    module.Name = "MoonAnimatorPlayer"
    module.Parent = folder
    module.LinkedSource = "https://www.roblox.com/library/13929585074/Moon-Animator-VFX-Player"
end

local function instanceFolder()
    local MoonAnimatorFolder = Instance.new("Folder")
    MoonAnimatorFolder.Name = "MoonAnimatorPlayer"
    MoonAnimatorFolder.Parent = ReplicatedStorage
    instanceModule(MoonAnimatorFolder)
end

local function addModule()
    local MoonAnimatorFolder = ReplicatedStorage:FindFirstChild("MoonAnimatorPlayer")
    if not MoonAnimatorFolder then
        instanceFolder()
    else
        if MoonAnimatorFolder:IsA("Folder") then
            local MoonAnimatorModule = MoonAnimatorFolder:FindFirstChild("MoonAnimatorPlayer")
            if not MoonAnimatorModule then
                instanceModule(MoonAnimatorFolder)
            end
        else
            instanceFolder()
        end
    end
end 


pluginButton.Click:Connect(function()
    addModule()
end)