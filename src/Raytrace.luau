--* DEPENDENCIES *--
local Raycast = require("./Raycast")

--* VARIABLES *--
export type RaytraceResult = { RaycastResult }

--* CONSTANTS *--
local OFFSET = 0.01

--* PRIVATE *--
local function getReflectedVector(v: vector, n: vector): vector 
	return v - vector.dot(v, n) * n * 2
end

--* PUBLIC *--
return function(origin: vector, direction: vector, maxBounces: number, raycastParams: RaycastParams?): RaytraceResult
	local results: RaytraceResult = table.create(maxBounces)
	local currentOrigin: vector = origin
	local currentDirection: vector = vector.normalize(direction)
	local remainingDistance: number = vector.magnitude(direction)

	for _ = 1, maxBounces do
		local raycastResult:RaycastResult = Raycast(currentOrigin, currentDirection * remainingDistance, raycastParams)
		table.insert(results, raycastResult)
		if not raycastResult then
			break
		end

		local hitNormal: vector = raycastResult.Normal
		local hitPosition: vector = raycastResult.Position

		local reflectedDirection: vector = getReflectedVector(currentDirection, hitNormal)
		local segmentDistance: number = vector.magnitude(hitPosition - currentOrigin)
		remainingDistance = remainingDistance - segmentDistance

		if remainingDistance <= 0 then
			break
		end

		currentOrigin = hitPosition + hitNormal * OFFSET
		currentDirection = reflectedDirection
	end

	return results
end
