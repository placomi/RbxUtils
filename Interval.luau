--!strict
--!native

return function(seconds: number)
	local lastTick: number

	return function()
		if not lastTick then
			lastTick = os.clock()
		end

		local elapsed: boolean = os.clock() - lastTick > seconds
		if elapsed then
			lastTick = os.clock()
		end
		return elapsed
	end
end
