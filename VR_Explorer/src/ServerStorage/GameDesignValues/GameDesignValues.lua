local GameDesignValues = {}

local values = {
    PlayersToStartMatch = 4
}
GameDesignValues.getValue = function(name)
    if values[name] then
        return values[name]
    else
        return nil
    end
    
end

return GameDesignValues