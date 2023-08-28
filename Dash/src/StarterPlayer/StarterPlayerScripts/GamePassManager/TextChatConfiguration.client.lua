--- Services
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

--- Chat Window settings
local chatWindowConfiguration = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

if chatWindowConfiguration then
	chatWindowConfiguration.Enabled = true
end
if chatInputBarConfiguration then
	chatInputBarConfiguration.Enabled = true
end


local nameColors = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 255, 0),
}

TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")

	if message.TextSource then
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)
		if player:GetAttribute("IsVIP") then
			--[[
            --- This adds a prefix
            properties.PrefixText = "<font color='#F5CD30'>[VIP]</font>" .. message.PrefixText
            -- This changes the color of the Player´s name chossing a random color from the list
            local index: number = (message.TextSource.UserId % #nameColors) + 1
            local randomColor: Color3 = nameColors[index]
            properties.PrefixText = string.format("<font color='#%s'>%s</font>", randomColor:ToHex(), message.PrefixText)
            --- This is a combination of both
            local newColor: Color3 = nameColors[1]
            properties.PrefixText = "<font color='#F5CD30'>[VIP] </font>".. string.format("<font color='#%s'>%s</font>", newColor:ToHex(), message.PrefixText)
            --]]
            
            properties.PrefixText = "<font color='#F5CD30'>[VIP]</font>" .. message.PrefixText
		end
	end

	return properties
end