--[[ Region Implementation ]]

local regions = {}

function regions.new(x,y,width,height)
	local region = {}
	region.x = x 
	region.y = y
	region.width = width
	region.height = height

	function region.location(xPercent, yPercent)
		return region.width * xPercent + region.x, region.height * yPercent + region.y
	end

	function region.subSize()
		return region.width * xPercent, region.height * yPercent
	end

	function region.subRegion( leftPercent,  topPercent,  rightPercent,  bottomPercent,  leftMargin,  topMargin,  rightMargin,  bottomMargin)
		leftPercent = leftPercent or 1
		topPercent = topPercent or 1
		rightPercent = rightPercent or 1
		bottomPercent = bottomPercent or 1
		leftMargin = leftMargin or 0
		topMargin = topMargin or 0 
		rightMargin = rightMargin or 0
		bottomMargin = bottomMargin or 0
		local x = region.x + leftPercent * region.width + leftMargin
		local y = region.y + topPercent * region.height + topMargin
		local width = region.width - rightPercent * region.width - leftPercent * region.width - rightMargin - leftMargin
		local height = region.height - bottomPercent * region.height - topPercent * region.height - bottomMargin - topMargin
		return regions.new(x,y,width,height)
	end

	function region.contains( x, y )
		return x >= region.x and x < region.x + region.width and y >= region.y and y < region.y + region.height
	end

	function region.containedCell( x, y, xSegments, ySegments )
		if not region.contains( x, y ) then
			return -1,-1
		end
		if xSegments == 0 or ySegments == 0 then
			return -1,-1
		end
		return	math.floor((x - region.x) / (region.width / xSegments)),
				math.floor((y - region.y) / (region.height / ySegments))
	end

	function region.cellSubRegion( x, y, xSegments, ySegments )
		local width = region.width / xSegments
		local height = region.height / ySegments
		local newX = region.x + width * x
		local newY = region.y + height * y
		return regions.new(newX, newY, width, height)
	end

	function region.containedSubRegion( x, y, xSegments, ySegments )
		xSegments = xSegments or 1
		ySegments = ySegments or 1
		local cellX,cellY = region.containedCell(x, y, xSegments, ySegments)
		local newWidth = region.width / xSegments
		local newHeight = region.height / ySegments
		return regions.new(cellX * newWidth, cellY * newHeight, newWidth, newHeight)
	end
	function region.stretchRatio ( containerRegion )
		local ax = containerRegion.width / region.width
		local ay = containerRegion.height / region.height
		region.width = region.width * ax
		region.height = region.height * ay
		return region
	end
	function region.fitRatio( containerRegion )
		local ax = containerRegion.width / region.width
		local ay = containerRegion.height / region.height
		ax = math.min( ax, ay )
		ay = ax
		region.width = region.width * ax
		region.height = region.height * ay
		return region
	end
	function region.fillRatio( containerRegion )
		local ax = containerRegion.width / region.width
		local ay = containerRegion.height / region.height
		ax = math.max( ax, ay )
		ay = ax
		region.width = region.width * ax
		region.height = region.height * ay
		return region
	end
	return region
end

return regions