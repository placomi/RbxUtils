export type Observable<T> = {
	value: T,
	callbacks: { (T) -> () },
	set: (self: Observable<T>, value: T) -> (),
	observe: (self: Observable<T>, callback: (T) -> ()) -> () -> (),
}

local Observable = {}
Observable.__index = Observable

function Observable.__call<T>(self: Observable<T>, newValue: T)
	self.value = newValue
	for _, callback: (T) -> () in self.callbacks do
		callback(newValue)
	end
end

function Observable.set<T>(self: Observable<T>, value: T)
	self.value = value 
	for _, callback: (T) -> () in self.callbacks do
		callback(value)
	end
end

function Observable.new<T>(initialValue: T): Observable<T>
	return setmetatable({
		value = initialValue,
		callbacks = {},
	}, Observable)
end

function Observable.observe<T>(self: Observable<T>, callback: (T) -> ()): () -> ()
	table.insert(self.callbacks, callback)
	return function()
		local index: number? = table.find(self.callbacks, callback)
		if index then
			table.remove(self.callbacks, index)
		end
	end
end

return Observable
