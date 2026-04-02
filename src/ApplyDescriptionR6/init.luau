local templateCharacter = script.TemplateR15
templateCharacter:PivotTo(CFrame.new(0, 1000000, 0))

local rigidAccessoryTypes = {
	[Enum.AccessoryType.Hat] = true,
	[Enum.AccessoryType.Hair] = true,
	[Enum.AccessoryType.Face] = true,
	[Enum.AccessoryType.Neck] = true,
	[Enum.AccessoryType.Shoulder] = true,
	[Enum.AccessoryType.Front] = true,
	[Enum.AccessoryType.Back] = true,
	[Enum.AccessoryType.Waist] = true,
}

--[=[
	fixes the issue with R6 accessories being low quality by using a template R15 rig,
	then cloning the accessories over to the R6 rig.
]=]
return function(character: Model, description: HumanoidDescription)
	local humanoid: Humanoid = character:FindFirstChild("Humanoid")
	assert(humanoid, "Attempted to apply description on a rig with no humanoid")
	assert(humanoid.RigType == Enum.HumanoidRigType.R6, "Attempted to apply description on an R15 rig")

	local success, errorMessage = pcall(function()
		humanoid:ApplyDescriptionAsync(description)
	end)
	if not success then
		warn(errorMessage)
		return
	end

	humanoid:RemoveAccessories()

	local accessoryDescription = Instance.new("HumanoidDescription")
	local accessoryCharacter = templateCharacter:Clone()
	accessoryCharacter.Parent = workspace

	for _, v in description:QueryDescendants(">AccessoryDescription") do
		if rigidAccessoryTypes[v.AccessoryType] then
			v:Clone().Parent = accessoryDescription
		end
	end

	success, errorMessage = pcall(function()
		accessoryCharacter.Humanoid:ApplyDescriptionAsync(accessoryDescription)
	end)
	if success then
		for _, accessory in character:QueryDescendants(">Accessory") do
			if rigidAccessoryTypes[accessory.AccessoryType] then
				accessory:Destroy()
			end
		end
		for _, accessory in accessoryCharacter:QueryDescendants(">Accessory") do
			if rigidAccessoryTypes[accessory.AccessoryType] then
				accessory:Clone().Parent = character
			end
		end
	else
		warn(errorMessage)
	end

	accessoryCharacter:Destroy()
	accessoryDescription:Destroy()
end
