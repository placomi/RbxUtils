return function(cframe: CFrame, part: BasePart): CFrame?
	cframe = part.CFrame:ToObjectSpace(cframe)
	local position = cframe.Position
	local halfSize = part.Size / 2

	local inZone = (position.X <= halfSize.X and position.X >= -halfSize.X)
		and (position.Y <= halfSize.Y and position.Y >= -halfSize.Y)
		and (position.Z <= halfSize.Z and position.Z >= -halfSize.Z)
	if inZone then
		return cframe
	else
		return nil
	end
end
