--!optimize 2

local ReflectionService = game:GetService("ReflectionService")

--local BLOCK_NEW_INDEX_TABLE = { __newindex = function() end }

local propertyCache: { [string]: { string } } = {}
local instanceCache: { [Instance]: { [string]: any } } = {}
local instanceCleanupCache: { [Instance]: () -> () } = {}

local function getReadableProperties(className: string): { string }
	--mm yummy memoization
	local cached = propertyCache[className]
	if cached then return cached end

	local properties: { string } = {}
	for _, info in ReflectionService:GetPropertiesOfClass(className) do
		if info.Security.Read == "None" then
			local propertyName: string = info.Name
			table.insert(properties, propertyName)
		end
	end

	propertyCache[className] = properties
	return properties
end

--[=[
Returns a table that watches an instances property changes, as well as a cleanup function.
This is intended to minimize datamodel reads, which can be costly.
The returned table can be indexed like a regular instance, but it should never be written to.
]=]
local function watchInstance<Class>(instance: Class): (Class, () -> ())
	assert(typeof(instance) == "Instance", "Tried to watch a non-instance")

	local cachedInstanceWatcher = instanceCache[instance]
	local cachedInstanceCleanup = instanceCleanupCache[instance]
	if cachedInstanceWatcher then return cachedInstanceWatcher, cachedInstanceCleanup end

	local instanceWatcher = {}
	instanceCache[instance] = instanceWatcher

	for _, name in getReadableProperties(instance.ClassName) do
		instanceWatcher[name] = instance[name]
	end

	local destroying: RBXScriptConnection, changed: RBXScriptConnection

	local function cleanup()
		instanceCache[instance] = nil
		destroying:Disconnect()
		changed:Disconnect()
	end
	instanceCleanupCache[instance] = cleanup

	changed = instance.Changed:Connect(function(key)
		instanceWatcher[key] = instance[key]
	end)
	destroying = instance.Destroying:Connect(cleanup)

	return instanceWatcher, cleanup
end

return watchInstance
