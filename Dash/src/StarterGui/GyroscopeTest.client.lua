--- https://create.roblox.com/docs/reference/engine/classes/UserInputService#GetDeviceRotation

local UserInputService = game:GetService("UserInputService")

local gyroEnabled = UserInputService.GyroscopeEnabled

if gyroEnabled then
    while true do
        task.wait(1)
        local _inputObj, cframe = UserInputService:GetDeviceRotation()
        print("CFrame: {", cframe, "}")
        warn("Position: {", cframe.Position, "}")
    end
else
	print("Cannot get device rotation because device does not have an enabled gyroscope!")
end