local StarterGui = game:GetService("StarterGui")

local MAX_RETRIES = 10

return function(method: string, ...)
	local result = {}
	for retries = 1, MAX_RETRIES do
		result = { pcall(StarterGui[method], StarterGui, ...) }
		if result[1] then
			break
		end
		task.wait()
	end
	return table.unpack(result)
end
