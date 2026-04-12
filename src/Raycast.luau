local Create = require("./Create")

local DECAY_TIME: number = 0.001
local HIT_COLOR: Color3 = Color3.new(0, 1, 0)

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
	Shading = Enum.AdornShading.AlwaysOnTop,
})

local rayAdornment: LineHandleAdornment = Create("LineHandleAdornment")({
	Color3 = Color3.new(1, 0, 0),
	Thickness = 1,
	Length = 0,
	AlwaysOnTop = true,
})

local function visualizeRaycast(origin: vector, pos: vector, hit: boolean)
	local rayClone = rayAdornment:Clone()
	rayClone.CFrame = CFrame.lookAt(origin, pos)
	rayClone.Length = vector.magnitude(pos - origin)
	rayClone.Adornee = raycastPart
	rayClone.Parent = raycastPart
	task.delay(DECAY_TIME, rayClone.Destroy, rayClone)

	if not hit then
		return
	end

	rayClone.Color3 = HIT_COLOR
	local hitClone = hitAdornment:Clone()
	hitClone.CFrame = CFrame.new(pos)
	hitClone.Adornee = raycastPart
	hitClone.Parent = raycastPart
	task.delay(DECAY_TIME, hitClone.Destroy, hitClone)
end

return function(origin: vector, direction: vector, raycastParams: RaycastParams?, visualize: boolean): RaycastResult?
	local result: RaycastResult = workspace:Raycast(origin, direction, raycastParams)
	if visualize then
		if result then
			visualizeRaycast(origin, result.Position, true)
		else
			visualizeRaycast(origin, origin + direction, false)
		end
	end
	return result
end
