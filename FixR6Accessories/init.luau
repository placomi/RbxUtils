local templateDummy: Model = script.TemplateR15
templateDummy:PivotTo(CFrame.new(0, 1000000, 0))

return function(character: Model): boolean
	local originalHumanoid: Humanoid = character:WaitForChild("Humanoid")

	if originalHumanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return false
	end

	local originalDescription: HumanoidDescription = originalHumanoid:GetAppliedDescription()

	local newHumanoidDescription: HumanoidDescription = Instance.new("HumanoidDescription")
	local newTemplate: Model = templateDummy:Clone()

	newTemplate.Parent = workspace.Temp

	for _, v: AccessoryDescription in originalDescription:QueryDescendants(">AccessoryDescription[IsLayered = false]") do
		v:Clone().Parent = newHumanoidDescription
	end

	local success: boolean, err: string? = pcall(function()
		(newTemplate :: any).Humanoid:ApplyDescription(newHumanoidDescription)
	end)

	if success then
		for _, accessory: Accessory in character:QueryDescendants(">Accessory") do
			accessory:Destroy()
		end

		for _, accessory: Accessory in newTemplate:QueryDescendants(">Accessory") do
			local accessoryClone: Accessory = accessory:Clone()
			--accessory.Handle.CanQuery = false
			accessoryClone.Handle.CanTouch = false
			accessoryClone.Handle.CanCollide = false
			accessoryClone.Handle.Massless = true
			accessoryClone.Handle.CollisionGroup = "Player"
			accessoryClone.Parent = character
		end
	else
		warn(err)
	end

	newTemplate:Destroy()
	newHumanoidDescription:Destroy()

	return success
end
