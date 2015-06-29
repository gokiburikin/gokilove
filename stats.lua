statSet = class('stats')

function statSet:initialize()
end

function statSet:attach(key, stat)
	self[key] = stat
	return stat
end

function statSet:detach(key)
	self[key] = nil
end

function statSet:get(key)
	return self[key]
end

function statSet:valueOf(key)
	return self[key]:value()
end

stat = class('stat')

function stat:initialize(base, minimum, maximum)
	self.base = base
	self.minimum = minimum or 0
	self.maximum = maximum or 9999999999
	self.modifiers = {}
end

function stat:value()
	local value = self.base
	local ordered = {}
	for k,v in pairs(self.modifiers) do
		table.insert(ordered,v)
	end
	table.sort(ordered,
		function(a,b)
			if a.order > b.order then
				return true
			end
			return false
		end)
	for k,v in ipairs(ordered) do
		value = v:apply(value)
	end
	return value
end

function stat:attach(key, statModifier)
	self.modifiers[key] = statModifier
	return stat
end

function stat:detach(key)
	self.modifiers[key] = nil
end

statModifier = class('statModifier')

statModifiers = {}
statModifiers.additive = 0
statModifiers.subtractive = 1
statModifiers.multiplicative = 2
statModifiers.divisive = 3

function statModifier:initialize(  modifierType, order )
	self.type = modifierType or statModifiers.additive
	self.order = order or 0
end

function statModifier:apply(value)
	return value
end

simpleStatModifier = class('simpleStatModifier', statModifier)

function simpleStatModifier:initialize(value, minimum, maximum, modifierType, order)
	statModifier.initialize(self, modifierType, order )
	self.value = value
end

function simpleStatModifier:apply(value)
	if self.type == statModifiers.additive then
		value = value + self.value
	elseif self.type == statModifiers.subtractive then
		value = value - self.value
	elseif self.type == statModifiers.multiplicative then
		value = value * self.value
	elseif self.type == statModifiers.divisive then
		value = value / self.value
	end
	return value
end

function simpleStatModifier:add(value)
	self.value = self.value + value
end

function simpleStatModifier:set(value)
	self.value = value
end