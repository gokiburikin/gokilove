--[[Little Font Manager]]

local lfm = {}
lfm.fonts = {}

lfm.attach = function(name,image,fontString)
	lfm.fonts[name] = love.graphics.newImageFont(image, fontString)
end

lfm.detach = function(name)
	lfm.fonts[name] = nil
end

lfm.set = function(name)
	if lfm.fonts[name] ~= nil then
		love.graphics.setFont(lfm.fonts[name])
	end
end

lfm.get = function(name)
	return lfm.fonts[name]
end

lfm.print = function(string)
	love.graphics.print(string)
end

return lfm