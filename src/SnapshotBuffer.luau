--!native

local SnapshotBuffer = {}
SnapshotBuffer.__index = SnapshotBuffer

type SnapshotBufferData<T> = {
	_buffer: { T },
	_front: number,
	_size: number,
}

export type SnapshotBuffer<T> = typeof(setmetatable({} :: SnapshotBufferData<T>, SnapshotBuffer))

function SnapshotBuffer.new<T>(size: number): SnapshotBuffer<T>
	return setmetatable({
		_buffer = table.create(size),
		_front = 1,
		_size = size,
	}, SnapshotBuffer)
end

function SnapshotBuffer:push<T>(timestamp: number, data: T)
	self._buffer[self._front] = { timestamp, data }
	self._front = self._front % self._size + 1
end

function SnapshotBuffer:clear<T>()
	self._buffer = table.create(self._size)
	self._front = 1
end

function SnapshotBuffer:getInterpolated<T>(timestamp: number): T?
	local previousTimestamp = 0
	local lowTimestamp = 0
	local highTimestamp = math.huge
	local nextTimestamp = math.huge
	local previous = nil
	local low = nil
	local high = nil
	local next = nil

	-- Find all relevant snapshots: previous, low, high, next
	for _, snapshot in self._buffer do
		if not snapshot then
			continue
		end
		local snapshotTimestamp = snapshot[1]

		-- Previous: snapshot before low
		if snapshotTimestamp > previousTimestamp and snapshotTimestamp < lowTimestamp then
			previousTimestamp = snapshotTimestamp
			previous = snapshot[2]
		end

		-- Low: latest snapshot at or before target time
		if snapshotTimestamp > lowTimestamp and snapshotTimestamp <= timestamp then
			previousTimestamp = lowTimestamp
			previous = low
			lowTimestamp = snapshotTimestamp
			low = snapshot[2]
		end

		-- High: earliest snapshot after target time
		if snapshotTimestamp < highTimestamp and snapshotTimestamp > timestamp then
			nextTimestamp = highTimestamp
			next = high
			highTimestamp = snapshotTimestamp
			high = snapshot[2]
		end

		-- Next: snapshot after high
		if snapshotTimestamp < nextTimestamp and snapshotTimestamp > highTimestamp then
			nextTimestamp = snapshotTimestamp
			next = snapshot[2]
		end
	end

	if not high or not low then
		return low or high
	end

	-- Check if we need special interpolation (large distance or direction change)
	local distance = vector.magnitude(high.Position - low.Position)
	local dot = vector.dot(high.LookVector, low.LookVector)

	if distance > 10 or dot < 0 then
		-- Teleport/portal detected - directly jump to high
		--return high

		-- Teleport/portal detected - use velocity-based extrapolation for seamless transition
		local alpha = (timestamp - lowTimestamp) / (highTimestamp - lowTimestamp)
		local midpointTime = lowTimestamp + (highTimestamp - lowTimestamp) * 0.5

		if timestamp < midpointTime then
			-- Before midpoint: continue movement from before teleport (previous -> low direction)
			if previous then
				local timeDelta = lowTimestamp - previousTimestamp
				local timeFromLow = timestamp - lowTimestamp
				local extrapolationAlpha = timeFromLow / timeDelta

				-- Extrapolate forward from low using pre-teleport velocity
				return previous:Lerp(low, 1 + extrapolationAlpha)
			else
				-- No velocity data, just use low
				return low
			end
		else
			-- After midpoint: continue movement after teleport (high -> next direction)
			if next then
				local timeDelta = nextTimestamp - highTimestamp
				local timeFromHigh = timestamp - highTimestamp
				local extrapolationAlpha = timeFromHigh / timeDelta

				-- Extrapolate from high using post-teleport velocity
				return high:Lerp(next, extrapolationAlpha)
			else
				-- No velocity data, just use high
				return high
			end
		end
	else
		-- Normal lerp interpolation
		return low:Lerp(high, math.clamp((timestamp - lowTimestamp) / (highTimestamp - lowTimestamp), 0, 1))
	end
end

return SnapshotBuffer
