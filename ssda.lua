--[[Simple Sprite Drawing Assistant]]

local ssda = {}
ssda.images = {}

ssda.attach = function(filePath, x, y, width, height, name, registrationX, registrationY)
	local image = ssda.images[filePath]
	if image == nil then
		image = love.graphics.newImage(filePath)
		ssda.images[filePath] = image
	end
	width = width or image:getWidth() or 1
	height = height or image:getHeight() or 1
	registrationX = registrationX or 0
	registrationY = registrationY or registrationX
	if ssda[name] == nil then
		ssda[name] = {}
		ssda[name].image = image
		ssda[name].x = x
		ssda[name].y = y
		ssda[name].registrationX = registrationX
		ssda[name].registrationY = registrationY
		ssda[name].ox = width * registrationX
		ssda[name].oy = height * registrationY
		ssda[name].width = width
		ssda[name].height = height
		ssda[name].quad = love.graphics.newQuad(x, y, width, height, image:getDimensions())
	end
end

ssda.attachSet = function(filePath, x, y, width, height, names, registrationX, registrationY )
	for k,v in ipairs(names) do
		ssda.attach(filePath,x + width * (k-1),y,width,height,v,registrationX,registrationY)
	end
end

ssda.attachImage = function(filePath, name, registrationX, registrationY)
	registrationX = registrationX or 0
	registrationY = registrationY or 0
	ssda.attach(filePath, 0,0, nil, nil, name, registrationX, registrationY)
end

ssda.get = function(name)
	return ssda.sprites[name]
end

ssda.subQuad = function( name, left, top, right, bottom )
	local sprite = ssda.get(name)
	local quad = nil
	if sprite ~= nil then
		quad = love.graphics.newQuad(x, y, width, height, image:getDimensions())
	end
	return quad
end

ssda.draw = function(name, x, y, r, sx, sy, ox, oy, kx, ky, quad )
	if ssda[name] ~= nil then
		x = x or 0
		y = y or 0
		r = r or 0
		sx = sx or 1
		sy = sy or 1
		ox = ox or ssda[name].ox
		oy = oy or ssda[name].oy
		kx = kx or 0
		ky = ky or 0
		quad = quad or ssda[name].quad
		if  ssda[name] ~= nil then
			love.graphics.draw(ssda[name].image, quad, x, y, r, sx, sy, ox, oy, kx, ky)
		end
	end
end

return ssda