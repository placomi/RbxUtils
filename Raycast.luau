local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = require(ReplicatedStorage.Modules.Utils.Create)

local DECAY_TIME: number = 0.001
local HIT_COLOR: Color3 = Color3.new(0, 1, 0)

local debugMode = _G.DEBUG
if debugMode then
	local raycastPart: BasePart = Create("Part")({
		Position = Vector3.new(),
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
		CanTouch = false,
		CanQuery = false,
		Parent = workspace,
	})
	local hitAdornment: BoxHandleAdornment = Create("BoxHandleAdornment")({
		Color3 = Color3.new(0, 1, 0),
		Size = Vector3.one * 0.1,
		AlwaysOnTop = true,
	})
	local rayAdornment: LineHandleAdornment = Create("LineHandleAdornment")({
		Color3 = Color3.new(1, 0, 0),
		Thickness = 1,
		Length = 0,
		AlwaysOnTop = true,
	})

	local function visualize(origin: vector, pos: vector, hit: boolean)
		local rayClone: LineHandleAdornment = rayAdornment:Clone()
		rayClone.CFrame = CFrame.lookAt(origin, pos)
		rayClone.Length = vector.magnitude(pos - origin)
		rayClone.Adornee = raycastPart
		rayClone.Parent = raycastPart
		task.delay(DECAY_TIME, function()
			rayClone:Destroy()
		end)

		if hit then
			rayClone.Color3 = HIT_COLOR
			local hitClone: BoxHandleAdornment = hitAdornment:Clone()
			hitClone.CFrame = CFrame.new(pos)
			hitClone.Adornee = raycastPart
			hitClone.Parent = raycastPart
			task.delay(DECAY_TIME, function()
				hitClone:Destroy()
			end)
		end
	end

	return function(origin: vector, direction: vector, raycastParams: RaycastParams?): RaycastResult?
		local result: RaycastResult = workspace:Raycast(origin, direction, raycastParams)
		if result then
			visualize(origin, result.Position, true)
		else
			visualize(origin, origin + direction, false)
		end
		return result
	end
end

return function(origin: vector, direction: vector, raycastParams: RaycastParams?): RaycastResult?
	return workspace:Raycast(origin, direction, raycastParams)
end
