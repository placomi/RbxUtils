--!native
--!optimize 2

local toObjectSpace = CFrame.new().ToObjectSpace

return function(cframe: CFrame, partCFrame: CFrame, size: vector): CFrame?
	local objectCFrame: CFrame = toObjectSpace(partCFrame, cframe)

	local absPosition = vector.abs(objectCFrame.Position :: vector)
	local halfSize = size / 2

	return if (absPosition.x <= halfSize.x)
			and (absPosition.y <= halfSize.y)
			and (absPosition.z <= halfSize.z)
		then objectCFrame
		else nil
end
