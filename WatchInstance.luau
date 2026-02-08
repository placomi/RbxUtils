--!strict
--!native

local ReflectionService = game:GetService("ReflectionService")

--local BLOCK_NEW_INDEX_TABLE = { __newindex = function() end }

local propertyCache: { [string]: { string } } = {}
local instanceCache: { [Instance]: { [string]: any } } = {}
local instanceCleanupCache: { [Instance]: () -> () } = {}

--mm yummy memoization
local function getReadableProperties(className: string): { string }
	local cached = propertyCache[className]
	if cached then
		return cached
	end

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

return function<Class>(instance: Instance & Class): (Class, () -> ())
	local cachedInstanceWatcher = instanceCache[instance]
	local cachedInstanceCleanup = instanceCleanupCache[instance]
	if cachedInstanceWatcher then
		return cachedInstanceWatcher, cachedInstanceCleanup
	end

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

	changed = instance.Changed:Connect(function(key)
		instanceWatcher[key] = instance[key]
	end)
	destroying = instance.Destroying:Connect(cleanup)

	return instanceWatcher, cleanup
end
