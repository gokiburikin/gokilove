--[[ Quick Math Library ]]

local qml = {}

qml.halfPi = math.pi/2

qml.distance = function(x1,y1,x2,y2)
	return math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2))
end

qml.angle = function(x1,y1,x2,y2)
	return math.atan2(y2-y1,x2-x1)
end

qml.round = function(value)
	return math.floor(value+0.5)
end

qml.decimals = function( value, decimals )
	local power = math.pow(10,decimals)
	return math.floor(value * power)/power
end

qml.between = function(value, min, max, inclusive)
	local between = false
	if inclusive then
		if value >= min and value <= max then
			between = true
		end
	else
		if value > min and value < max then
			between = true
		end
	end
	return between
end

qml.angleBetween = function( radianAngle, degreeMin, degreeMax )
	local degreeAngle = radianAngle * 180 / math.pi
	return qml.between(degreeAngle,degreeMin, degreeMax)
end

qml.wrapAngle = function(radianAngle)
	if radianAngle < -math.pi then
		radianAngle = math.pi - math.abs(radianAngle) % math.pi
	elseif radianAngle > math.pi then
		radianAngle = -math.pi + radianAngle % math.pi
	end
	return radianAngle
end

qml.random = function(min,max,decimals)
	local multiplier = math.pow(10,decimals or 0)
	return love.math.random(min*multiplier,max*multiplier)/multiplier
end

return qml