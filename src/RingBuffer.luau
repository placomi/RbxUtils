--!native

--* MODULE *--
export type RingBuffer<T> = {
	buffer: { T },
	front: number,
	size: number,
	push: (self: RingBuffer<T>, value: T) -> T,
	find: (self: RingBuffer<T>, value: T) -> number?,
	clear: (self: RingBuffer<T>) -> nil,
	getOrdered: (self: RingBuffer<T>) -> { T },
}

local RingBuffer = {}
RingBuffer.__index = RingBuffer

function RingBuffer.new<T>(size): RingBuffer<T>
	return setmetatable({
		buffer = table.create(size),
		front = 0,
		size = size,
	}, RingBuffer)
end

function RingBuffer:push<T>(value: T): T
	local previousValue = self.buffer[self.front]
	self.buffer[self.front] = value
	self.front = (self.front + 1) % self.size
	return previousValue
end

function RingBuffer:find<T>(value: T): number?
	return table.find(self.buffer, value)
end

function RingBuffer:clear<T>(): nil
	self.buffer = table.create(self.size)
	self.front = 0
	return nil
end

-- returns the buffer as an array starting with the oldest element.
function RingBuffer:getOrdered<T>(): { T }
	local size = self.size
	local front = self.front
	local result = table.create(size)
	local buff = self.buffer
	for i = front + 1, front + size + 1 do
		table.insert(result, buff[i % size])
	end
	return result
end

return RingBuffer
