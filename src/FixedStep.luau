local RunService = game:GetService("RunService")

--[=[
	runs the passed callback at a fixed interval.
]=]
return function(interval: number, callback: () -> ()): () -> ()
	local accumulator = 0
	local connection = RunService.Heartbeat:Connect(function(dt: number)
		accumulator += dt
		while accumulator >= interval do
			accumulator -= interval
			callback()
		end
	end)

	return function()
		connection:Disconnect()
	end
end
