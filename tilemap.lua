--[[ Generic Tilemap Implementation ]]

local tilemap = {}

local cell = {}
function cell.new(x,y)
	local newCell = {x = x, y = y}
	newCell.data = {}
	function newCell.attach(object)
		newCell[object] = object
	end
	function newCell.detach(object)
		newCell[object] = nil
	end
	return newCell
end

function tilemap.new()
	local newTilemap = {}
	newTilemap.cells = {}
	function newTilemap.initialize(width,height,data)
		for x = 0, width, 1 do
			for y = 0, height, 1 do
				local cell = newTilemap.getCell(x,y,true)
				if data ~= nil then
					cell.data = data
				end
			end
		end
	end

	function newTilemap.getCell(x,y,create)
		create = create or false
		local cellKey = x .. "," .. y
		if newTilemap.cells[cellKey] == nil and create then
			newTilemap.cells[cellKey] = cell.new(x,y)
		end
		return newTilemap.cells[cellKey]
	end

	function newTilemap.getCellUnder(x,y,tileWidth,tileHeight)
		local cellX = math.floor(x / tileWidth)
		local cellY = math.floor(y / tileHeight)
		local cellKey = cellX .. "," .. cellY
		return newTilemap.cells[cellKey]
	end

	function newTilemap.getCellNeighbors(x,y)
		local left = newTilemap.cells[(x-1) .. "," .. y]
		local up = newTilemap.cells[x .. "," .. (y-1)]
		local right = newTilemap.cells[(x+1) .. "," .. y]
		local down = newTilemap.cells[x .. "," .. (y+1)]
		return {left=left,up=up,right=right,down=down}
	end

	return newTilemap
end
return tilemap