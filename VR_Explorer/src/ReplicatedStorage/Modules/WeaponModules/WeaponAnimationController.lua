
local AnimationController = {}
AnimationController.__index = AnimationController

local AttackAnimations = {
    RegularShot = {
        id = "rbxassetid://15035906061",
        weight = 10,
        priority = Enum.AnimationPriority.Action4,
        looped = false
    },
    FastShot = {
        id = "rbxassetid://15257721132",
        weight = 10,
        priority = Enum.AnimationPriority.Action4,
        looped = false
    }
}


function AnimationController:LoadAllAnimations()
    for key, animation in pairs(AttackAnimations) do
        local animTrack
        local animInstance
        animInstance = Instance.new("Animation")
        animInstance.AnimationId = animation.id
        local animator = self.Humanoid:FindFirstChild("Animator")
        if not animator then return end
        animTrack = animator:LoadAnimation(animInstance)
        animTrack.Priority = animation.priority
        animTrack.Looped = animation.looped
        self.AnimTrack[key] = animTrack
    end
end


function AnimationController.new(params)
    local self = {}
	setmetatable(self, AnimationController)
    self.AnimTrack = {}
    self.Humanoid = params.Humanoid
    
    return self
end
function AnimationController:PlayAnimation(animationName:string)
    self.AnimTrack[animationName]:Stop()
    self.AnimTrack[animationName]:Play()
    local cont = 0
    repeat
        cont += .05
        task.wait(.05)
    until self.AnimTrack[animationName].IsPlaying  == false or cont > self.AnimTrack[animationName].Length
    self.AnimTrack[animationName]:Stop()
end


return AnimationController