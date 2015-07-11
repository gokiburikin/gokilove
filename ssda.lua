--[[Simple Sprite Drawing Assistant]]

local ssda = {}
ssda.images = {}
ssda.sprites = {}

ssda.attach = function(filePath, x, y, width, height, key, registrationX, registrationY)
	local image = ssda.images[filePath]
	if image == nil then
		image = love.graphics.newImage(filePath)
		ssda.images[filePath] = image
	end
	width = width or image:getWidth() or 1
	height = height or image:getHeight() or 1
	registrationX = registrationX or 0
	registrationY = registrationY or registrationX
	ssda.sprites[key] = ssda.sprites[key] or {}
	local sprite = {}
	sprite.image = image
	sprite.x = x
	sprite.y = y
	sprite.registrationX = registrationX
	sprite.registrationY = registrationY
	sprite.ox = width * registrationX
	sprite.oy = height * registrationY
	sprite.width = width
	sprite.height = height
	sprite.quad = love.graphics.newQuad(x, y, width, height, image:getDimensions())
	table.insert(ssda.sprites[key],sprite)
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

ssda.get = function(sprite)
	if type(sprite) == "string" then
		if ssda.sprites[sprite] ~= nil then
			sprite = ssda.sprites[sprite][love.math.random(1,#ssda.sprites[sprite])]
		end
	end
	return sprite
end

ssda.subQuad = function( name, left, top, right, bottom )
	local sprite = ssda.get(name)
	local quad = nil
	if sprite ~= nil then
		quad = love.graphics.newQuad(x, y, width, height, image:getDimensions())
	end
	return quad
end

ssda.draw = function(sprite, x, y, r, sx, sy, ox, oy, kx, ky, quad )
	if type(sprite) == "string" then
		sprite = ssda.get(name)
	end
	if sprite ~= nil then
		x = x or 0
		y = y or 0
		r = r or 0
		sx = sx or 1
		sy = sy or 1
		ox = ox or sprite.ox
		oy = oy or sprite.oy
		kx = kx or 0
		ky = ky or 0
		quad = quad or sprite.quad
		love.graphics.draw(sprite.image, quad, x, y, r, sx, sy, ox, oy, kx, ky)
	end
end

return ssda