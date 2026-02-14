--!strict

local InstanceCache = {}
InstanceCache.__index = InstanceCache

type InstanceCacheData<T> = {
	freeCache: { T }, -- stack of free instances
	usedCache: { [T]: boolean },
	freeCallback: (T) -> (),
}

type InstanceCache<T> = setmetatable<InstanceCacheData<T>, typeof(InstanceCache)>

local defaultCallbacks: { [string]: (any) -> () } = {
	PVInstance = function(instance: PVInstance)
		instance:PivotTo(CFrame.new(0, 1000000, 0))
	end,
}

function InstanceCache.new<T>(template: T, count: number, parent: Instance, freeCallback: (T) -> ()?): InstanceCache<T>
	assert(typeof(template) == "Instance", "Template is not an instance")
	template = template :: Instance

	if not freeCallback then
		for className, callback in defaultCallbacks do
			if template:IsA(className) then
				freeCallback = callback
				break
			end
		end
		assert(freeCallback, "Did not give a free callback, and no default callback was found")
	end

	parent = parent or workspace

	local freeCache = {}
	for _ = 1, count do
		local newInstance = template:Clone()
		newInstance.Parent = parent
		table.insert(freeCache, newInstance)
	end

	return setmetatable({
		freeCache = freeCache,
		usedCache = {},
		freeCallback = freeCallback,
	} :: InstanceCacheData<T>, InstanceCache)
end

function InstanceCache.get<T>(self: InstanceCache<T>): T?
	local instance = table.remove(self.freeCache)

	if not instance then
		return nil
	end

	self.usedCache[instance] = true
	return instance
end

function InstanceCache.free<T>(self: InstanceCache<T>, instance: T)
	if not self.usedCache[instance] then
		return
	end

	self.usedCache[instance] = nil
	table.insert(self.freeCache, instance)
	self.freeCallback(instance)
end

function InstanceCache.destroy<T>(self: InstanceCache<T>)
	for instance in self.usedCache do
		instance:Destroy()
	end
	table.clear(self.usedCache)
	for _, instance in self.freeCache do
		instance:Destroy()
	end
	table.clear(self.freeCache)
end

InstanceCache.new(Instance.new("Part"), )

return InstanceCache
