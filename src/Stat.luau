--!optimize 2
--!native

local Stat = {}
Stat.__index = Stat

type StatData = {
	_base: number,
	_addModifiers: { [{}]: number },
	_multiplyModifiers: { [{}]: number },
	_observerHead: number,
	_observers: { (number) -> () },
}

type InternalStat = setmetatable<StatData, typeof(Stat)>

export type Stat = {
	set: (self: Stat, value: number) -> (),
	get: (self: Stat) -> number,
	add: (self: Stat, value: number) -> () -> (),
	multiply: (self: Stat, value: number) -> () -> (),
	observe: (self: Stat, callback: () -> ()) -> () -> (),
}

local freeThread: thread? = nil
local function yieldLoop()
	while true do
		local stat: InternalStat, value: number = coroutine.yield()

		local thread = freeThread
		freeThread = nil

		while stat._observerHead ~= 0 do
			stat._observerHead -= 1
			stat._observers[stat._observerHead + 1](value)
		end

		freeThread = thread
	end
end

--[=[
	@class Stat

	Creates a stat object.
	Stat objects allow you to have a value with temporary modifiers, which can be either additive or multiplicative.

	Additive modifiers are added to the base value before multiplicative modifiers.

	Stat objects can also be observed.

	Returns the stat object.
]=]
local function constructor(base: number): InternalStat
	return setmetatable(
		{
			_base = base,
			_addModifiers = {},
			_multiplyModifiers = {},
			_observerHead = 0,
			_observers = {},
		} :: StatData,
		Stat
	)
end

--[=[
	Sets the base value for the stat.
]=]
function Stat.set(self: InternalStat, value: number)
	self._base = value
end

--[=[
	Gets the calculated value for the stat.
--]=]
function Stat.get(self: InternalStat): number
	local value = self._base

	for _, a in self._addModifiers do
		value += a
	end
	for _, m in self._multiplyModifiers do
		value *= m
	end

	return value
end

--[=[
	Creates a adder to the stat.

	```lua
	local newStat = Stat.new(1) 	-- stat is 1
	local adder = newStat.add(3) 	-- stat is now 4
	adder() 						-- stat is now 1
	```

	Returns a cleanup function to stop the adder.
]=]
function Stat.add(self: InternalStat, value: number): () -> ()
	local key = {}
	self._addModifiers[key] = value
	self:_update()

	return function()
		self._addModifiers[key] = nil
		self:_update()
	end
end

--[=[
	Creates a multiplier to the stat.

	```lua
	local newStat= Stat.new(5) 				-- stat is 5
	local multiplier = newStat.multiply(2) 	-- stat is now 10
	multiplier() 							-- stat is now 5
	```

	Returns a cleanup function to stop the multiplier.
]=]
function Stat.multiply(self: InternalStat, value: number): () -> ()
	local key = {}
	self._multiplyModifiers[key] = value
	self:_update()

	return function()
		self._multiplyModifiers[key] = nil
		self:_update()
	end
end

-- this uses thread reusage, consider using charm as a dependency for like utils in the future
function Stat._update(self: InternalStat)
	self._observerHead = #self._observers
	local value = self:get()
	while self._observerHead ~= 0 do
		if not freeThread then freeThread = task.spawn(yieldLoop) end
		task.spawn(freeThread, self, value)
	end
end

--[=[
	Starts observing a stat object.
	The callback will be called initially, then whenever the stat value changes.

	Returns a cleanup function to stop observing.
]=]
function Stat.observe(self: InternalStat, callback: (number) -> ()): () -> ()
	task.spawn(callback, self:get())
	table.insert(self._observers, callback)

	return function()
		local index = table.find(self._observers, callback)

		if index then table.remove(self._observers, index) end
	end
end

return constructor :: () -> Stat
