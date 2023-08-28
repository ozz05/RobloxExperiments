local TextChatService = game:GetService("TextChatService")

local BubbleChatConfiguration = TextChatService.BubbleChatConfiguration
BubbleChatConfiguration.TailVisible = false
BubbleChatConfiguration.TextSize = 24
BubbleChatConfiguration.TextColor3 = Color3.fromRGB(220, 50, 50)
BubbleChatConfiguration.FontFace = Font.fromEnum(Enum.Font.LuckiestGuy)

local UICorner = BubbleChatConfiguration:FindFirstChildOfClass("UICorner")
if not UICorner then
	UICorner = Instance.new("UICorner")
	UICorner.Parent = BubbleChatConfiguration
end
UICorner.CornerRadius = UDim.new(0, 0)

local ImageLabel = BubbleChatConfiguration:FindFirstChildOfClass("ImageLabel")
if not ImageLabel then
	ImageLabel = Instance.new("ImageLabel")
	ImageLabel.Parent = BubbleChatConfiguration
end
ImageLabel.Image = "rbxassetid://6733332557"
ImageLabel.ScaleType = Enum.ScaleType.Slice
ImageLabel.SliceCenter = Rect.new(40, 40, 360, 160)
ImageLabel.SliceScale = 0.5