local PlayerInputKeys = {}

local values = {
    -- Push
    EXAMPLE_KEY_PC = Enum.KeyCode.Q,
    EXAMPLE_GAMEPAD = Enum.KeyCode.ButtonB,
}
PlayerInputKeys.getValue = function(name)
    if values[name] then
        return values[name]
    else
        return nil
    end
    
end

return PlayerInputKeys