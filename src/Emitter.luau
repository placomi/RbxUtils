local Create = require("./Create")

local Emitter = {}
Emitter.__index = Emitter

type EmitterData = {
	host: BasePart,
	output: AudioEmitter,
	effects: { Instance },
	_source: Instance?,
	_sourcePin: string,
	_wires: { Wire },
	_destroyed: boolean,
}

type InternalEmitter = setmetatable<EmitterData, typeof(Emitter)>

export type Emitter = {
	host: BasePart,
	output: AudioEmitter,
	effects: { Instance },
	setSource: (self: Emitter, producer: Instance?, outputPin: string?) -> (),
	setEffects: (self: Emitter, effects: { Instance }) -> (),
	addEffect: (self: Emitter, effect: Instance, index: number?) -> (),
	removeEffect: (self: Emitter, effect: Instance) -> (),
	Destroy: (self: Emitter) -> (),
}

--[=[
	@class Emitter

	Wraps an AudioEmitter with a managed source → effects chain → emitter wire pipeline.
	The Emitter owns the AudioEmitter and all wires it creates; effects and source instances
	are caller-owned.
]=]
local function constructor(host: BasePart): InternalEmitter
	local output = Create("AudioEmitter")({
		Parent = host,
	})

	return setmetatable(
		{
			host = host,
			output = output,
			effects = {},
			_source = nil,
			_sourcePin = "Output",
			_wires = {},
			_destroyed = false,
		} :: EmitterData,
		Emitter
	)
end

function Emitter._rewire(self: InternalEmitter)
	for _, wire in self._wires do
		wire:Destroy()
	end
	table.clear(self._wires)

	local chain: { { instance: Instance, outputPin: string } } = {}
	if self._source then
		table.insert(chain, { instance = self._source :: Instance, outputPin = self._sourcePin })
	end
	for _, effect in self.effects do
		table.insert(chain, { instance = effect, outputPin = "Output" })
	end
	table.insert(chain, { instance = self.output, outputPin = "" })

	for i = 1, #chain - 1 do
		local from = chain[i]
		local to = chain[i + 1]
		local wire = Instance.new("Wire")
		wire.SourceInstance = from.instance
		wire.SourceName = from.outputPin
		wire.TargetInstance = to.instance
		wire.TargetName = "Input"
		wire.Parent = self.output
		table.insert(self._wires, wire)
	end
end

--[=[
	Sets the audio producer feeding the emitter chain.
	Pass nil to disconnect.
]=]
function Emitter.setSource(self: InternalEmitter, producer: Instance?, outputPin: string?)
	if self._destroyed then
		return
	end
	self._source = producer
	self._sourcePin = outputPin or "Output"
	self:_rewire()
end

--[=[
	Replaces the effects chain. Order is signal flow: effects[1] receives the source,
	effects[#effects] feeds the AudioEmitter.
]=]
function Emitter.setEffects(self: InternalEmitter, effects: { Instance })
	if self._destroyed then
		return
	end
	self.effects = table.clone(effects)
	self:_rewire()
end

--[=[
	Inserts an effect into the chain at the given index (default: end).
]=]
function Emitter.addEffect(self: InternalEmitter, effect: Instance, index: number?)
	if self._destroyed then
		return
	end
	table.insert(self.effects, index or #self.effects + 1, effect)
	self:_rewire()
end

--[=[
	Removes an effect from the chain.
]=]
function Emitter.removeEffect(self: InternalEmitter, effect: Instance)
	if self._destroyed then
		return
	end
	local index = table.find(self.effects, effect)
	if not index then
		return
	end
	table.remove(self.effects, index)
	self:_rewire()
end

--[=[
	Destroys all wires and the AudioEmitter. Effects and source are not destroyed.
]=]
function Emitter.Destroy(self: InternalEmitter)
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, wire in self._wires do
		wire:Destroy()
	end
	table.clear(self._wires)
	self.output:Destroy()
end

return constructor :: (host: BasePart) -> Emitter
