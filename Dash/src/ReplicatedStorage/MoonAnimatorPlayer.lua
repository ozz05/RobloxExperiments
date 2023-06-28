local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local moonAnimatorPlayer = {}

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
            keyFrames[keyframe.Name] = addValue(keyframe)
            keyframesList[keyframe.Name] = {frame = tonumber(keyframe.Name)}

        end
    end
    return keyFrames
end

local function addProperties(folder, keyframesList)
    local meshProperties = {}
    local properties = folder:GetChildren()
    if properties then
        for _, property in pairs(properties) do
            meshProperties[property.Name] = addKeyFrames(property, keyframesList)
            meshProperties[property.Name]["Name"]  = property.Name
        end
    end
    return meshProperties
end

local function getMeshesProperties(AnimationInfo, AnimationDictionary)
    AnimationDictionary["Keyframes"] = {}
    for _, folder in pairs(AnimationInfo:GetChildren()) do
        AnimationDictionary[folder.Name] = addProperties(folder, AnimationDictionary["Keyframes"])
    end
end

local function getVFXInfo(dicctionary)
    local items = {}
    for _key, value in pairs(dicctionary) do
        local pathLenghth = 0
        for _, path in pairs(value["Path"]["InstanceNames"]) do
            pathLenghth += 1
        end
        for i, instanceName in pairs(value["Path"]["InstanceNames"]) do
            if i == pathLenghth then
                if instanceName then
                    items[instanceName] = {Name = instanceName}
                end
            end
        end
    end
    return items
end

local function play(VFX, dictionary, RootCFrame)
    local co 
	co = coroutine.create(function()
		VFX:SetPrimaryPartCFrame(RootCFrame)
		VFX.Parent = game.Workspace
		local function FrameToSec(v)
			return v/60
		end
		local function SecToFrame(v)
			return v*60
		end

		local meshes = VFX:GetChildren()
		local frames = dictionary["Keyframes"]
		local previusFrame 
		if frames then
			if meshes then
				for i,frame in pairs(frames) do
					local previusFrame = frames[i-1]
					if not previusFrame  then
						previusFrame = 0			
					end
					local timeframe = FrameToSec(frames[i] - previusFrame)
					for _,mesh in pairs(meshes) do
						if dictionary[mesh.Name] then
							local goal = {}
							for i,property in pairs(dictionary[mesh.Name]) do
								if property[tostring(frame)] then

									if typeof(property[tostring(frame)]) == "CFrame" then
										property[tostring(frame)] = VFX.PrimaryPart.CFrame:ToWorldSpace(property[tostring(frame)])--reference.PrimaryPart.CFrame
									end
									goal[property.Name] = property[tostring(frame)]
								end
							end
							local tinfo = TweenInfo.new(timeframe)
							TweenService:Create(mesh,tinfo, goal):Play()

						end
					end
					task.wait(timeframe)
				end

			end
		end
		VFX:Destroy()
		co = nil
		coroutine.yield()
	end)
	coroutine.resume(co)
end

moonAnimatorPlayer.stringToDictionary = function(jsonString: string)
    if jsonString then
        local jsonTable = HttpService:JSONDecode(jsonString)
        local dictionary = {}
        for key, value in pairs(jsonTable) do
            dictionary[key] = value
        end
        return dictionary
    end
    return nil
end

moonAnimatorPlayer.playVFX = function(VFX:Model, rootCFrame)
    local VFXInfo = VFX:FindFirstChildOfClass("StringValue")
    if VFXInfo then
        local dicctionary = moonAnimatorPlayer.stringToDictionary(VFXInfo.Value)
        if dicctionary then
            local items = dicctionary["Items"]
            if items then
                local vfxInfo = getVFXInfo(items)
                getMeshesProperties(VFXInfo, vfxInfo)
                for index, value in pairs(vfxInfo) do
                    print(value.Name)
                    print(value.CFrame)
                end
                --play(VFX, vfxInfo, rootCFrame)
            end
        end
    end
end

return moonAnimatorPlayer