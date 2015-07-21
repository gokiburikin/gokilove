--[[ Interpolation Library ]]
-- Meant to be used with Robert Penner's Easing Functions - http://robertpenner.com/easing/

local lerp = {}
lerp.interpolators = {}

function lerp.new(startValue,endValue,length,interpolatorFunction,elapsedFunction)
	local interpolator = {}

	interpolator.startValue = startValue or 0	
	interpolator.endValue = endValue or 1
	interpolator.length = length or 1
	interpolator.accumulator = 0
	interpolator.interpolatorFunction = interpolatorFunction or function(t,b,c,d) return 0 end
	interpolator.hasElapsed = false
	interpolator.elapsed = elapsedFunction or function(interpolator) 
		lerp.detach(interpolator.key or interpolator)
	end

	function interpolator.update(dt)
		interpolator.accumulator = interpolator.accumulator + dt
		if interpolator.accumulator > interpolator.length then
			interpolator.accumulator = interpolator.length
			if not interpolator.hasElapsed then
				interpolator.hasElapsed = true
				interpolator.elapsed(interpolator)
			end
		end
	end

	function interpolator.value()
		return interpolator.interpolatorFunction(interpolator.accumulator/interpolator.length,interpolator.startValue,interpolator.endValue - interpolator.startValue, 1)
	end

	function interpolator.evaluate(percent)
		return interpolator.interpolatorFunction(percent,interpolator.startValue,interpolator.endValue - interpolator.startValue, 1)
	end

	function interpolator.reset()
		interpolator.accumulator = 0
		interpolator.hasElapsed = false
	end

	function interpolator.set(value)
		interpolator.accumulator = interpolator.length * (value / interpolator.endValue)
		interpolator.hasElapsed = false
	end

	

	return interpolator
end

function lerp.newAuto(table,keys,startValue,endValue,length,interpolatorFunction,elapsedFunction)
	local interpolator = lerp.new(startValue,endValue,length,interpolatorFunction or nil,elapsedFunction or nil)

	function interpolator.update(dt)
		interpolator.accumulator = interpolator.accumulator + dt
		if interpolator.accumulator > interpolator.length then
			interpolator.accumulator = interpolator.length
		end
		for k,v in pairs(keys) do
			table[v] = interpolator.value()
		end
		if interpolator.accumulator >= interpolator.length then
			if not interpolator.hasElapsed then
				interpolator.hasElapsed = true
				interpolator.elapsed(interpolator)
			end
		end
	end

	return interpolator
end

function lerp.attach(interpolator,key)
	interpolator.key = key or nil
	key = key or interpolator
	lerp.interpolators[key] = interpolator
	return interpolator
end

function lerp.detach(key)
	lerp.interpolators[key] = nil
end

function lerp.update(dt)
	for k,v in pairs(lerp.interpolators) do
		v.update(dt)
	end
end

function lerp.get(key)
	return lerp.interpolators[key]
end

return lerp