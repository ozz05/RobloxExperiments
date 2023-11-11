--- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


local LocalPlayer = Players.LocalPlayer
local Gui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
local MiniMapGui = Gui:FindFirstChild("MiniMapGui") or Gui:WaitForChild("MiniMapGui")
local Frame = MiniMapGui:FindFirstChild("Frame") or MiniMapGui:WaitForChild("Frame")
local ViewportFrame:ViewportFrame = Frame:FindFirstChild("ViewportFrame") or Frame:WaitForChild("ViewportFrame")
local PlayerArrow = Frame:FindFirstChild("PlayerArrow") or Frame:WaitForChild("PlayerArrow")
PlayerArrow.Parent = nil
local players = {}

local Camera = game.Workspace.CurrentCamera
local offset = Vector3.new(0, 500, 0)
local ViewportCamera = Instance.new("Camera")
ViewportCamera.FieldOfView = 20
ViewportFrame.CurrentCamera = ViewportCamera

local chunkSize = offset.Y * math.tan(math.rad(ViewportCamera.FieldOfView) / 2)
local chunkHalfSize = chunkSize / 2
local currentX, currentZ = math.huge, math.huge

for _, descendant in pairs(game.Workspace.Map:GetDescendants()) do
    if not descendant:IsA("BasePart") then
        continue
    end
    local clone = descendant:Clone()
    clone.Parent = ViewportFrame
end

local function updatePlayers()
    local focusX = Camera.Focus.Position.X / chunkSize
    local focusZ = Camera.Focus.Position.Z / chunkSize

    for player, gui in pairs(players) do
        if not player.Character then continue end
        local cFrame = player.Character:GetPivot()
        local x = cFrame.Position.X / chunkSize
        local z = cFrame.Position.Z / chunkSize
        gui.Position = UDim2.new(0.5 - focusX + x, 0, 0.5 - focusZ + z)
        
        local yOrientation = math.atan2(cFrame.LookVector.Z, cFrame.LookVector.X)
        yOrientation = math.deg(yOrientation)
        gui.Rotation = yOrientation
    end
end

local function onPlayerAdded(player:Player)
    local gui = PlayerArrow:Clone()
    gui.Parent = Frame
    players[player] = gui
end

local function onPlayerRemoving(player:Player)
    players[player]:Destroy()
    players[player] = nil
end

RunService.RenderStepped:Connect(function(deltaTime)
    local focusX = Camera.Focus.Position.X / chunkSize
    local focusZ = Camera.Focus.Position.Z / chunkSize

    local chunkX = math.floor(focusX)
    local chunkZ = math.floor(focusZ)

    local x = focusX % 1
    local z = focusZ % 1

    if not (currentX == chunkX) or not (currentZ == chunkZ) then
        currentX = chunkX
        currentZ = chunkZ
        local position = Vector3.new(chunkX * chunkSize + chunkHalfSize, 0, chunkZ * chunkSize + chunkHalfSize)
        ViewportCamera.CFrame = CFrame.lookAt(position + offset, position, -Vector3.zAxis)
    end
    
    ViewportFrame.Position = UDim2.new(1 - x, 0, 1 - z, 0)
end)

RunService.RenderStepped:Connect(function(deltaTime)
    updatePlayers()
end)

for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)