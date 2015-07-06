--[[ Interpolation Library ]]
local lerp = {}
lerp.interpolators = {}
lerp.types = {}
lerp.types.linear = 1
lerp.types.cubicIn = 2
lerp.types.cubicOut = 3
lerp.types.cubicInOut = 4
lerp.types.elasticIn = 5
lerp.types.elasticOut = 6
lerp.types.elasticInOut = 7
lerp.types.backIn = 8
lerp.types.backOut = 9
lerp.types.backInOut = 10

lerp.functions = {}
function lerp.functions.linear (t, b, c, d)
    return c * t / d + b
end

function lerp.functions.cubicIn( t, b, c, d )
	t = t / d
	return c * t * t * t + b
end

function lerp.functions.cubicOut ( t, b, c, d) 
	t = t / d - 1
	return c*(t*t*t + 1) + b
end

function lerp.functions.cubicInOut ( t, b, c, d) 
	t = t / d / 2
	if (t < 1) then
		return c / 2 * t * t * t + b
	end
	t = t - 2
	return c / 2 * (t * t * t + 2) + b
end

function lerp.functions.elasticIn( t, b, c, d )

	local s = 1.70158
	local p = 0
	local a = c

	if (t==0) then
		return b
	end

	t = t / d / 2
	if (t==2) then
		return b+c
	end

	if not p then
		p = d*(.3*1.5)
	end

	if (a < math.abs(c)) then
		a=c
		s=p/4
	else
		s = p/(2*math.pi) * math.asin (c/a);
	end

	if (t < 1) then
		t = t - 1
		return -.5*(a*math.pow(2,10*t) * math.sin( (t*d-s)*(2*math.pi)/p )) + b
	end
	
	t = t - 1
	return a*math.pow(2,-10*t) * math.sin( (t*d-s)*(2*math.pi)/p )*.5 + c + b;
end

function lerp.functions.elasticOut( t, b, c, d )

	local s = 1.7015
	local p = 0
	local a = c
	
	if (t==0) then
		return b
	end
	t = t / d
	if (t==1) then
		return b + c
	end
	
	if p == 0 then
		p = d * .3
	end
	
	if (a < math.abs(c)) then
		a = c
		s = p / 4
	else
		s = p / ( 2 * math.pi ) * math.asin (c / a)
	end
	t = t - 1
	return -(a*math.pow(2,10*t) * math.sin( (t*d-s)*(2*math.pi)/p )) + b;
end

function lerp.functions.elasticInOut( t, b, c, d )

	local s = 1.70158
	local p = 0
	local a = c
	if (t==0) then
		return b
	end
	t = t / d
	if (t==1) then 
		return b+c
	end
	if p == 0 then
		p = d * .3
	end
	if (a < math.abs(c)) then
		a=c
		s=p/4
	else 
		s = p/(2*math.pi) * math.asin (c/a)
	end
	return a*math.pow(2,-10*t) * math.sin( (t*d-s)*(2*math.pi)/p ) + c + b
end

function lerp.functions.backIn ( t, b, c, d, s) 
	s = s or 1.70158
	t = t / d
	return c * t*t*((s+1)*t - s) + b
end

function lerp.functions.backOut  (t, b, c, d, s) 
	s = s or 1.70158
	t = t / d - 1
	return c*(t*t*((s+1)*t + s) + 1) + b
end

function lerp.functions.backInOut (t, b, c, d, s) 
	s = s or 1.70158
	s = s * 1.525
	t = t / d / 2
	if (t < 1) then
		return c/2*(t*t*(((s)+1)*t - s)) + b
	end
	t = t - 2
	return c/2*(t*t*(((s)+1)*t + s) + 2) + b
end

function lerp.new(startValue,endValue,length,interpolatorType)
	local interpolator = {}

	interpolator.startValue = startValue or 0	
	interpolator.endValue = endValue or 1
	interpolator.length = length or 1
	interpolator.accumulator = 0
	interpolator.interpolatorType = interpolatorType or lerp.types.linear

	local functionTable = {
		lerp.functions.linear,
		lerp.functions.cubicIn,
		lerp.functions.cubicOut,
		lerp.functions.cubicInOut,
		lerp.functions.elasticIn,
		lerp.functions.elasticOut,
		lerp.functions.elasticInOut,
		lerp.functions.backIn,
		lerp.functions.backOut,
		lerp.functions.backInOut
	}

	interpolator.interpolationFunction = functionTable[interpolator.interpolatorType]

	function interpolator.update(dt)
		interpolator.accumulator = interpolator.accumulator + dt
		if interpolator.accumulator > interpolator.length then
			interpolator.accumulator = interpolator.length
		end
	end

	function interpolator.value()
		interpolator.interpolationFunction = functionTable[interpolator.interpolatorType]
		return interpolator.interpolationFunction(interpolator.accumulator/interpolator.length,interpolator.startValue,interpolator.endValue - interpolator.startValue, 1)
	end

	function interpolator.evaluate(percent)
		return interpolator.interpolationFunction(percent,interpolator.startValue,interpolator.endValue - interpolator.startValue, 1)
	end

	function interpolator.reset()
		interpolator.accumulator = 0
	end

	return interpolator
end

function lerp.attach(interpolator,key)
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