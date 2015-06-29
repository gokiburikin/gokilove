--[[Simple Transformation Context Manager]]

local stcm = {}
stcm.tdtc = function(x,y,width,height,rotation,scaleX, scaleY,registrationX, registrationY)
	local tdtc = {}
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
		tdtc.registrationY = y
	end

	tdtc.apply = function()
		love.graphics.translate(tdtc.x - tdtc.width * tdtc.registrationX, tdtc.y - tdtc.height * tdtc.registrationY)
		love.graphics.translate(tdtc.width * tdtc.registrationX,tdtc.height * tdtc.registrationY)
		love.graphics.rotate(tdtc.rotation)
		love.graphics.scale(tdtc.scaleX, tdtc.scaleY)
		love.graphics.translate(-tdtc.width * tdtc.registrationX,-tdtc.height * tdtc.registrationY)
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
return stcm