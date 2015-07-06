--[[ Improved Color Management ]]

local icm = {}
icm.colors = {}
icm.inverted = false

icm.mix = function(colorA, colorB, percent)
	return {
		r=colorA.r + (colorB.r - colorA.r) * percent,
		g=colorA.g + (colorB.g - colorA.g) * percent,
		b=colorA.b + (colorB.b - colorA.b) * percent,
		a=colorA.a + (colorB.a - colorA.a) * percent
	}
end

icm.getColor = function(r,g,b,a)
	if not icm.inverted then
		return {r=r,g=g,b=b,a=a or 255}
	else
		return {r=255-r,g=255-g,b=255-b,a=a or 255}
	end
end

icm.setColor = function(color)
	if color ~= nil then
		if color.color == nil then
			color = icm.getColor(color.r, color.g, color.b, color.a)
		else
			color = icm.getColor(color.color.r, color.color.g, color.color.b, color.color.a)
			love.graphics.setColor(color.r, color.g, color.b, color.a)
		end
		love.graphics.setColor(color.r, color.g, color.b, color.a)
	end
end

icm.setBackgroundColor = function(color)
	if color ~= nil then
		if color.color == nil then
			love.graphics.setBackgroundColor(color.r, color.g, color.b, color.a)
		else
			love.graphics.setBackgroundColor(color.color.r, color.color.g, color.color.b, color.color.a)
		end
	end
end

icm.get = function(name)
	return icm.colors[name]
end

icm.set = function(name)
	local color = icm.get(name)
	if color ~= nil then
		icm.setColor(color)
	else
		icm.setColor(name)
	end
end

icm.random = function()
	return icm.getColor(love.math.random(0,255),love.math.random(0,255),love.math.random(0,255),255)
end

icm.color = function(r,g,b,a)
	return {color={r=r,g=g,b=b,a=a}}
end

icm.specialColor = function(colors)
	local specialColor = {}
	specialColor.colors = colors
	specialColor.color = colors[1].color
	specialColor.time = 0
	function specialColor:update(dt)
		self.time = self.time + dt
		local color = nil
		local totalLength = 0
		for k,v in pairs(self.colors) do
			totalLength = totalLength + v.length
		end
		local adjustedTime = self.time % totalLength
		for k,v in ipairs(self.colors) do
			if adjustedTime < v.length then
				color = v
				break
			else
				adjustedTime = adjustedTime - v.length
			end
		end
		self.color = color.color
	end
	return specialColor
end

icm.attach = function(name,color)
	icm.colors[name] = color
end

icm.detach = function(name)
	icm.colors[name] = nil
end

icm.update = function(dt)
	for k,v in pairs(icm.colors) do
		if v.update ~= nil then
			v:update(dt)
		end
	end
end

icm.colors["black"] = icm.color(0,0,0)
icm.colors["red"] = icm.color(255,0,0)
icm.colors["green"] = icm.color(0,255,0)
icm.colors["blue"] = icm.color(0,0,255)
icm.colors["yellow"] = icm.color(255,255,0)
icm.colors["magenta"] = icm.color(255,0,255)
icm.colors["cyan"] = icm.color(0,255,255)
icm.colors["white"] = icm.color(255,255,255)
icm.colors["dark grey"] = icm.color(63,63,63)
icm.colors["grey"] = icm.color(127,127,127)
icm.colors["light grey"] = icm.color(191,191,191)

return icm