local GameDesignValues = {}

local values = {
    -- Push values
    ExampleValue = 0
}
GameDesignValues.getValue = function(name)
    if values[name] then
        return values[name]
    else
        return nil
    end
    
end

return GameDesignValues