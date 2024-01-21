-- Services 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

--Modules
local Modules = ReplicatedStorage:FindFirstChild("Modules") or ReplicatedStorage:WaitForChild("Modules")
local WeaponModules = Modules:FindFirstChild("WeaponModules") or Modules:WaitForChild("WeaponModules")
local AnimationController = require(WeaponModules.WeaponAnimationController)

-- RemoteEvents 
local RemoteEvents:Folder = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents")
local FireWeapon:RemoteEvent = RemoteEvents:FindFirstChild("FireWeapon") or RemoteEvents:WaitForChild("FireWeapon")


local Camera = game.Workspace.CurrentCamera

--Player
local LocalPlayer = Players.LocalPlayer
--UI
--[[local Gui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
local MainUI = Gui:FindFirstChild("MainUI") or Gui:WaitForChild("MainUI")
local WeaponControls = MainUI:FindFirstChild("WeaponControls") or MainUI:WaitForChild("WeaponControls")
local Mobile_Controls = WeaponControls:FindFirstChild("Mobile_Controls") or WeaponControls:WaitForChild("Mobile_Controls")
local FireButton:ImageButton = Mobile_Controls:FindFirstChild("Fire") or Mobile_Controls:WaitForChild("Fire")--]]

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")

local animationTracks = AnimationController.new({Humanoid = Humanoid})
animationTracks:LoadAllAnimations()

local WEAPON_TAG = "Weapon"
local ACTION_WEAPON = "FireWeapon"
local FIRE_KEY_PC = Enum.UserInputType.MouseButton1
local FIRE_KEY_GP = Enum.KeyCode.ButtonR2
local Weapon = nil
local rotationRenderSteppedConnection = nil
local FireButtonInputBeganConnection = nil
local FireButtonInputEndedConnection = nil
local renderStepped



local function rotatePlayer()
	if Humanoid.Sit or not HumanoidRootPart or not Humanoid then
		return
	end
    local direction
	local camLookVec = Camera.CFrame.LookVector
	local lookVecX, lookVecZ = camLookVec.X, camLookVec.Z
	if lookVecX ~= 0 or lookVecZ ~= 0 then
		direction = Vector3.new(lookVecX, 0, lookVecZ).Unit
	end
    Humanoid.AutoRotate = false
	local HumanoidRootPartPosition = HumanoidRootPart.Position
	HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPartPosition, HumanoidRootPartPosition + direction)
end

local function activateCrossHair(status:boolean)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
    if playerGui then
        local Crosshair = playerGui:FindFirstChild("Crosshair") or playerGui:WaitForChild("Crosshair", 2)
        if Crosshair then
            Crosshair.Enabled = status
        end
    end
end

local function cleanConnection()
    Humanoid.AutoRotate = true
    UserInputService.MouseIconEnabled = true
    activateCrossHair(false)
    if rotationRenderSteppedConnection then
        rotationRenderSteppedConnection:Disconnect()
        rotationRenderSteppedConnection = nil
    end
    if FireButtonInputBeganConnection then
        FireButtonInputBeganConnection:Disconnect()
        FireButtonInputBeganConnection = nil
    end
    if FireButtonInputEndedConnection then
        FireButtonInputEndedConnection:Disconnect()
        FireButtonInputEndedConnection = nil
    end
end

local function getFireParams()
    local viewportPoint = Camera.ViewportSize / 2
    local centerOfScreen = Camera:ViewportPointToRay(viewportPoint.X, viewportPoint.Y, 0)
    local handle = Weapon:FindFirstChild("Handle")
    local firePoint = handle:FindFirstChild("FIRE")
    local fireParams = {
        Type = "Player",
        TeamName = "Blue",
        Weapon = Weapon,
        Origin = centerOfScreen.Origin,
        Direction = centerOfScreen.Direction,
        FirePointCFrame = firePoint.CFrame
    }
    return fireParams
end

local function fireInput(actionName:string, inputState:Enum, _inputObject:Instance)
    if LocalPlayer.Character.Humanoid.Health < 0  then return end
    if not Weapon then return end
    if actionName ~= ACTION_WEAPON then return end
    local fireRate = 0.5
    local Configuration = Weapon:FindFirstChild("Configuration")
    if Configuration then
        local Rate = Configuration:FindFirstChild("Rate")
        if Rate then
            fireRate = 1/Rate.Value
        end
    end
    

    local startTick = tick()

    if inputState == Enum.UserInputState.Begin then
        FireWeapon:FireServer(getFireParams())
        renderStepped = RunService.RenderStepped:Connect(function()
            if tick() - startTick <= fireRate then return end
            startTick = tick()
            FireWeapon:FireServer(getFireParams())
            animationTracks:PlayAnimation("FastShot")
        end)
        animationTracks:PlayAnimation("RegularShot")
    elseif inputState == Enum.UserInputState.End then
        if renderStepped then
            renderStepped:Disconnect()
            renderStepped = nil
        end
        
    end
end


local function onChildRemoved(child)
    if child:IsA("Tool") then
        Weapon = nil
        ContextActionService:UnbindAction(ACTION_WEAPON)
        cleanConnection()
    end
end

--[[local function activateMobileControls()
    if UserInputService.GamepadEnabled or UserInputService.MouseEnabled then
        WeaponControls.Visible = false
        Mobile_Controls.Visible = false
        return
    end
    WeaponControls.Visible = true
    Mobile_Controls.Visible = true
    FireButtonInputBeganConnection = FireButton.InputBegan:Connect(function(input)
        fireInput(ACTION_WEAPON, Enum.UserInputState.Begin, input)
    end)
    FireButtonInputEndedConnection = FireButton.InputEnded:Connect(function(input)
        fireInput(ACTION_WEAPON, Enum.UserInputState.End, input)
    end)
end--]]

local function weaponAdded()
    cleanConnection()
    rotationRenderSteppedConnection = RunService.RenderStepped:Connect(function(_deltaTime)
        rotatePlayer()
    end)
    --activateMobileControls()
    activateCrossHair(true)
    UserInputService.MouseIconEnabled = false
    ContextActionService:UnbindAction(ACTION_WEAPON)
    ContextActionService:BindActionAtPriority(ACTION_WEAPON, fireInput, true, 1, FIRE_KEY_PC, FIRE_KEY_GP)
    local SprintButton = ContextActionService:GetButton(ACTION_WEAPON)
    if SprintButton then
        ContextActionService:SetImage(ACTION_WEAPON, "rbxassetid://8763581859")
        ContextActionService:SetTitle(ACTION_WEAPON, "Fire")
        ContextActionService:SetPosition(ACTION_WEAPON, UDim2.new(0.2, 0, 0.4, 0))
        SprintButton.Size = UDim2.new(0.3, 0, 0.35, 0)
    end
end

local function onChildAdded(child)
    if child:IsA("Tool") then
        if child:HasTag(WEAPON_TAG) then
            Weapon = child
            weaponAdded()
        end
    end
end

--[[local function updateControls()
    if Weapon then
        weaponAdded()
    end
end
UserInputService.GamepadConnected:Connect(updateControls)
UserInputService.GamepadDisconnected:Connect(updateControls)--]]


Character.ChildRemoved:Connect(onChildRemoved)
Character.ChildAdded:Connect(onChildAdded)