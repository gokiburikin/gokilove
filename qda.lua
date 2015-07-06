--[[ Quick Drawing Assistant ]]

local qda = {}

function qda.rectangle(rectangle,drawType)
	drawType = drawType or "fill"
	love.graphics.rectangle(drawType,rectangle.x,rectangle.y,rectangle.width,rectangle.height)
end

return qda