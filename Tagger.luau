--* SERVICES *--
local CollectionService = game:GetService("CollectionService")

--* MODULE *--
local Tagger = {}

local connections = {}

function Tagger.hook(tag: string, callback: (instance: Instance) -> (), removed: (instance: Instance) -> ())
	local taggedInstances = CollectionService:GetTagged(tag)

	local finished = 0
	local total = #taggedInstances
	local mainThread = coroutine.running()

	if total == 0 then
		connections[`{tag}ADDED`] = CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
		if removed then
			connections[`{tag}REMOVED`] = CollectionService:GetInstanceRemovedSignal(tag):Connect(removed)
		end
		return
	end

	for _, instance in taggedInstances do
		task.spawn(function()
			callback(instance)
			finished += 1
			if finished == total then
				coroutine.resume(mainThread)
			end
		end)
	end

	connections[`{tag}ADDED`] = CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
	if removed then
		connections[`{tag}REMOVED`] = CollectionService:GetInstanceRemovedSignal(tag):Connect(removed)
	end

	if finished ~= total then
		coroutine.yield()
	end
end

function Tagger.unhook(tag: string)
	local addedConnection = connections[`{tag}ADDED`]
	local removedConnection = connections[`{tag}REMOVED`]
	if addedConnection then
		addedConnection:Disconnect()
	end
	if removedConnection then
		removedConnection:Disconnect()
	end
end

return Tagger
