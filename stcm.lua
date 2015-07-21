--[[Simple Transformation Context Manager]]

local stcm = {}
stcm.floorValues = true
function stcm.tdtc(x,y,width,height,rotation,scaleX, scaleY,registrationX, registrationY)
	local tdtc = {}
	tdtc.mt = {}
	tdtc.mt.__index = function(table,key)
		if key == "rx" then
			return tdtc.x - tdtc.width * tdtc.registrationX
		elseif key == "ry" then
			return tdtc.y - tdtc.height * tdtc.registrationY
		elseif key == "rw" then
			return tdtc.width * tdtc.registrationX
		elseif key == "rh" then
			return tdtc.height * tdtc.registrationY
		end
	end
	setmetatable(tdtc,tdtc.mt)
	tdtc.x = x or 0
	tdtc.y = y or 0
	tdtc.width = width or 100
	tdtc.height = height or 100
	tdtc.rotation = rotation or 0
	tdtc.scaleX = scaleX or 1
	tdtc.scaleY = scaleY or 1
	tdtc.registrationX = registrationX or 0
	tdtc.registrationY = registrationY or 0

	tdtc.toLocal = function(x,y)
		local c = math.cos(tdtc.rotation)
		local s = math.sin(tdtc.rotation)
		local nx = c * (x - tdtc.x ) + s * (y - tdtc.y) + tdtc.width * tdtc.registrationX * tdtc.scaleX
	    local ny = c * (y - tdtc.y ) - s * (x - tdtc.x) + tdtc.height * tdtc.registrationY * tdtc.scaleY
		return {x=nx/tdtc.scaleX,y=ny/tdtc.scaleY}
	end

	tdtc.translate = function(x,y)
		tdtc.x = tdtc.x + x
		tdtc.y = tdtc.y + y
	end

	tdtc.scale = function(x,y)
		tdtc.scaleX = x
		tdtc.scaleY = y
	end

	tdtc.rotate = function(angle)
		tdtc.rotation  = tdtc.rotation + angle
	end

	tdtc.register = function(x,y)
		tdtc.registrationX = x
		tdtc.registrationY = y or x
	end

	tdtc.apply = function()
		if stcm.floorValues then
			love.graphics.translate(math.floor(tdtc.x - tdtc.width * tdtc.registrationX), math.floor(tdtc.y - tdtc.height * tdtc.registrationY))
			love.graphics.translate(tdtc.width * tdtc.registrationX,tdtc.height * tdtc.registrationY)
			love.graphics.rotate(tdtc.rotation)
			love.graphics.scale(tdtc.scaleX, tdtc.scaleY)
			love.graphics.translate(-tdtc.width * tdtc.registrationX,-tdtc.height * tdtc.registrationY)
		end
	end
	
	tdtc.copy = function(copy, registration)
		copy.x = tdtc.x
		copy.y = tdtc.y
		copy.scaleX = tdtc.scaleX
		copy.scaleY = tdtc.scaleY
		copy.rotation = tdtc.rotation
		if registration then
			copy.registrationX = tdtc.registrationX
			copy.registrationY = tdtc.registrationY
		end
	end

	return tdtc
end

function stcm.ltdtc(x,y,width,height,rotation,scaleX, scaleY,registrationX, registrationY,length,interpolatorType)
	local tdtc = {}
	tdtc.interpolators = {}

	length = length or .2
	tdtc.interpolatorType = interpolatorType or lerp.types.linear

	local lerpValues = {
		x = x or 0,
		y = y or 0,
		width = width or 100,
		height = height or 100,
		rotation = rotation or 0,
		scaleX = scaleX or 1,
		scaleY = scaleY or 1,
		registrationX = registrationX or 0,
		registrationY = registrationY or 0
	}
	for k,v in pairs(lerpValues) do
		tdtc.interpolators[k] = lerp.attach(lerp.new(v,v,length,interpolatorType))
	end

	tdtc.mt = {}
	setmetatable(tdtc,tdtc.mt)
	tdtc.mt.__index = function(table,key)
		if tdtc.interpolators[key] ~= nil then
			return tdtc.interpolators[key].value()
		end
		return nil
	end
	tdtc.mt.__newindex = function(table,key,newValue)
		if tdtc.interpolators[key] ~= nil then
			tdtc.interpolators[key].startValue = tdtc.interpolators[key].endValue
			tdtc.interpolators[key].endValue = newValue
			tdtc.interpolators[key].reset()
		end
	end
	return tdtc
end
return stcm