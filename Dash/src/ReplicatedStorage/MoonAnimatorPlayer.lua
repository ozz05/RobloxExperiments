local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local moonAnimatorPlayer = {}
local Properties = {
    "CFrame",
    "Size",
    "Transparency"
}

local function addValue(keyframe)
    local value = nil
    if keyframe then
        local valuesFolder = keyframe:FindFirstChild("Values")
        if valuesFolder then
            local value0 = valuesFolder["0"]
            if value0 then
                value = value0.Value
            end
        end
    end
    return value
end

local function addKeyFrames(property, keyframesList)
    local keyFrames = {}
    local keyFramesFolders = property:GetChildren()
    if keyFramesFolders then
        for _, keyframe in pairs(keyFramesFolders) do
            if not (keyframe.Name == "default") then
                keyFrames[tonumber(keyframe.Name)] = addValue(keyframe)
                keyframesList[tonumber(keyframe.Name)] = {frame = tonumber(keyframe.Name)}
            end
        end
    end
    local counter = 0
    for _, _keyframe in pairs(keyFrames) do
        counter += 1
    end
    if counter == 0 then
        return nil
    end
    return keyFrames
end

local function getAnimationlength(frames)
    local length = 0
    for _, frame in pairs(frames) do
        if frame["frame"] > length then
            length = frame["frame"]
        end
    end
    return length
end

local function addProperties(folder, keyframesList)
    local meshProperties = {}
    local properties = folder:GetChildren()
    if properties then
        for _, property in pairs(properties) do
            meshProperties[property.Name] = addKeyFrames(property, keyframesList)
        end
    end
    return meshProperties
end

local function getMeshesProperties(AnimationInfo, AnimationDictionary)
    local AnimationKeyFrames = {}
    local newAnimationDictionary = {}
    for _index, folder in pairs(AnimationInfo:GetChildren()) do
        newAnimationDictionary[tonumber(folder.Name)] = addProperties(folder, AnimationKeyFrames)
        for _, info in pairs(AnimationDictionary) do
            if info["FolderName"] == tonumber(folder.Name) then
                newAnimationDictionary[tonumber(folder.Name)]["Name"] = info["Name"]
            end
        end
    end
    newAnimationDictionary["AnimationKeyFrames"] = AnimationKeyFrames
    return newAnimationDictionary
end

local function getVFXInfo(dicctionary)
    local items = {}
    for _key, value in ipairs(dicctionary) do
        local pathLenghth = 0
        for _, path in pairs(value["Path"]["InstanceNames"]) do
            pathLenghth += 1
        end
        for i, instanceName in pairs(value["Path"]["InstanceNames"]) do
            if i == pathLenghth then
                if instanceName then
                    items[_key] = {Name = instanceName, FolderName = _key}
                end
            end
        end
    end
    return items
end

local function play(VFX:Model, dictionary, RootCFrame)
    local co 
	co = coroutine.create(function()
		VFX:PivotTo(RootCFrame)
		VFX.Parent = game.Workspace
		local function FrameToSec(v)
			return v/60
		end
		local function SecToFrame(v)
			return v*60
		end
		local frames = dictionary["AnimationKeyFrames"]
		
		if frames then
            for _, meshPartInfo in pairs(dictionary) do
                local name = meshPartInfo["Name"]
                if name then
                    local mesh = VFX:FindFirstChild(name)
                    if mesh then
                        for _, property in (Properties) do
                            local co2
                            co2 = coroutine.create(function()
                                local previusFrame
                                for i = 0, getAnimationlength(frames), 1 do
                                    if frames[i] then
                                        if not previusFrame  then
                                            previusFrame = 0
                                        end
                                        local timeframe = FrameToSec(i - previusFrame)
                                        local goal = {}
                                        if meshPartInfo[property] then
                                            if meshPartInfo[property][i] then
                                                if property == "CFrame" then
                                                    if VFX.PrimaryPart then
                                                        local cframe = CFrame.new(mesh.Position) * VFX.PrimaryPart.CFrame.Rotation
                                                        goal[property] = cframe:ToWorldSpace(meshPartInfo[property][i].Rotation)
                                                    end
                                                else
                                                    goal[property] = meshPartInfo[property][i]
                                                end
                                                local tinfo = TweenInfo.new(timeframe)
                                                TweenService:Create(mesh,tinfo, goal):Play()
                                                previusFrame = i
                                                task.wait(timeframe)
                                            end
                                        end
                                        
                                    end
                                end
                            end)
                            coroutine.resume(co2)
                        end
                    end
                end
            end
		end
		task.wait(FrameToSec(getAnimationlength(frames)))
		VFX:Destroy()
		co = nil
		coroutine.yield()
	end)
	coroutine.resume(co)
end

moonAnimatorPlayer.stringToDictionary = function(jsonString: string)
    if jsonString then
        local jsonTable = HttpService:JSONDecode(jsonString)
        return table.clone(jsonTable)
    end
    return nil
end

moonAnimatorPlayer.playVFX = function(VFX:Model, rootCFrame)
    local co
    co = coroutine.create(function()
        local VFXInfo = VFX:FindFirstChildOfClass("StringValue")
        if VFXInfo then
            local dicctionary = moonAnimatorPlayer.stringToDictionary(VFXInfo.Value)
            if dicctionary then
                local items = dicctionary["Items"]
                if items then
                    local vfxInfo = getVFXInfo(items)
                    if vfxInfo then
                        vfxInfo = getMeshesProperties(VFXInfo, vfxInfo)
                        if vfxInfo then
                            play(VFX, vfxInfo, rootCFrame)
                        end
                    end
                end
            end
        end
    end)
    coroutine.resume(co)
end

return moonAnimatorPlayer