--[[ Image Font Library ]]
local ifl = {}
ifl.fonts = {}
ifl.font = "default"

function ifl.attach(imagePath,key,fontString,characterSpacing,lineSpacing,truncateSpace,scaleX,scaleY,kerning,separatorColor)
	local separatorColor = {r=255,g=255,b=0,a=255}
	local imageFont = {}
	scaleX = scaleX or 1
	scaleY =scaleY or 1
	imageFont.imageData = love.image.newImageData(imagePath)

	imageFont.glyphs = {}
	local glyphIndex = 0
	local width = imageFont.imageData:getWidth()
	local height = imageFont.imageData:getHeight()
	
	local glyphLeft = 0
	local glyphRight = 0
	local state = 0
	for x=0,imageFont.imageData:getWidth()-1,1 do
		local r,g,b,a = imageFont.imageData:getPixel(x,0)
		if r == separatorColor.r and g == separatorColor.g and b == separatorColor.b and separatorColor.a == a then
			for y=0,imageFont.imageData:getHeight()-1,1 do
				imageFont.imageData:setPixel(x,y,0,0,0,0)
			end
			if truncateSpace then
				if fontString:sub(glyphIndex,glyphIndex) == " " then
					glyphRight = x
				end
			else
				glyphRight = x
			end
			if glyphIndex > 0 then
				imageFont.glyphs[fontString:sub(glyphIndex,glyphIndex)] = {quad=love.graphics.newQuad(glyphLeft,0,glyphRight-glyphLeft,height,width,height),width=glyphRight-glyphLeft}
			end
			glyphLeft = x+1
			glyphIndex = glyphIndex+1
			state = 0
		else
			if truncateSpace == true and fontString:sub(glyphIndex,glyphIndex) ~= " " and state == 0 then
				local subX = 0
				while state == 0 and glyphLeft < width do
					for subY=0,imageFont.imageData:getHeight()-1,1 do
						local r,g,b,a = imageFont.imageData:getPixel(glyphLeft,subY)
						if a ~= 0 then
							state = 1
							break
						end
					end
					if state == 0 then
						glyphLeft = glyphLeft + 1
					end
					glyphRight = glyphLeft
				end
			elseif truncateSpace == true and fontString:sub(glyphIndex,glyphIndex) ~= " " and state == 1 then
				local empty = true
				while empty and state == 1 and glyphRight < width do
					for subY=0,imageFont.imageData:getHeight()-1,1 do
						local r,g,b,a = imageFont.imageData:getPixel(glyphRight,subY)
						if a ~= 0 then
							empty = false
							break
						end
					end
					if empty == true then
						state = 2
					else
						glyphRight = glyphRight + 1
					end
				end
			end
		end
	end

	imageFont.image = love.graphics.newImage(imageFont.imageData)
	imageFont.fontString = fontString
	imageFont.characterSpacing = characterSpacing or 0
	imageFont.lineSpacing = lineSpacing or 0
	imageFont.height = imageFont.image:getHeight()
	imageFont.kerning = kerning or nil
	imageFont.lastText = ""
	imageFont.lastFunction = nil
	imageFont.lastAlignment = ""
	imageFont.lastWrapLimit = nil
	imageFont.batch = love.graphics.newSpriteBatch(imageFont.image,10000,"dynamic")

	function imageFont.getWidth(text)
		local width = 0
		local lineWidth  = 0
		for i=1,#text,1 do
			local kernOffset = {x=0,y=0}
			for k,v in pairs(imageFont.kerning) do
				if text:sub(i,i+#k-1) == k then
					kernOffset = v
				end
			end
			local glyph = imageFont.glyphs[text:sub(i,i)]
			if text:sub(i,i) == "\n" then
				lineWidth = 0
			elseif glyph ~= nil then
				lineWidth = lineWidth + glyph.width + imageFont.characterSpacing + kernOffset.x
				if lineWidth > width  then
					width = lineWidth
				end
			end
		end
		return width
	end

	function imageFont.getLines(text,wrapLimit,key)
		local font = ifl.fonts[key or ifl.font]
		local lines = ifl.calculateLines(text,wrapLimit,nil,key)
		local width = 0
		for k,line in ipairs(lines) do
			if line.width  > width then
				width = line.width
			end
		end
		return width,#lines * (font.height + font.lineSpacing),#lines
	end

	function imageFont.getFitIndex(text,wrapLimit,heightLimit,key)
		local fitIndex = #text
		local lines,fitIndex = ifl.calculateLines(text,wrapLimit,heightLimit,key)
		return fitIndex
	end

	ifl.fonts[key] = imageFont
	return imageFont
end

function ifl.set(key)
	ifl.font = key
end

function ifl.get(key)
	return ifl.fonts[key or ifl.font]
end

function ifl.calculateLines(text,wrapLimit,heightLimit,key)
	local text = text .. ""
	local fitIndex = #text
	local lines = {}
	local font = ifl.fonts[key or ifl.font]
	local wrapLimit = wrapLimit or 0
	local heightLimit = heightLimit or 0
	if font ~= nil then
		local glyphX = 0
		local glyphY = 0
		local lineSpacing = font.lineSpacing
		local characterSpacing = font.characterSpacing
		local kerning = font.kerning
		local fontHeight = font.height
		local glyphs = font.glyphs
		local lineCount = 0

		local breakIndex = 1
		local breakWidth = 0
		local lineBreakIndex = 1
		local lineWidth = 0

		for i=1,#text,1 do
			local character = text:sub(i,i)
			local glyph = glyphs[character]

			if character == " " then
				breakIndex = i
				breakWidth = lineWidth
			end

			if character == "\n" then
				lineCount = lineCount + 1
				lines[lineCount] = {}
				lines[lineCount].text = text:sub(lineBreakIndex,i)
				lines[lineCount].width = lineWidth
				lineBreakIndex = i
				breakIndex = i
				breakWidth = lineWidth
				lineWidth = 0
			elseif glyph ~= nil then
				if kerning == nil then
					lineWidth = lineWidth + glyph.width + characterSpacing 
				else
					local kernOffset = 0
					for k,v in pairs(kerning) do
						if text:sub(i,i+#k-1) == k then
							kernOffset = v
							break
						end
					end
					lineWidth = lineWidth + glyph.width + characterSpacing + kernOffset
				end
				if lineWidth >= wrapLimit then
					lineCount = lineCount + 1
					if fitIndex == #text and (lineCount+1) * (fontHeight + lineSpacing) > heightLimit then
						fitIndex = breakIndex
					end
					lines[lineCount] = {}
					lines[lineCount].text = text:sub(lineBreakIndex,breakIndex-1)
					lines[lineCount].width = breakWidth
					lineWidth = lineWidth - breakWidth
					lineBreakIndex = breakIndex+1
				end
			end

			if i == #text then
				lineCount = lineCount + 1
				lines[lineCount] = {}
				lines[lineCount].text = text:sub(lineBreakIndex,i)
				lines[lineCount].width = lineWidth - characterSpacing
			end
		end
	end
	return lines,fitIndex
end

function ifl.print(text,x,y,key)
	local text = text .. ""
	local x = x or 0
	local y = y or 0
	local font = ifl.fonts[key or ifl.font]

	if font ~= nil then
		local batch = font.batch
		if text == font.lastText and font.lastFunction == "print" and horizontalAlignment == font.lastAlignment and wrapLimit == font.lastWrapLimit then
			love.graphics.draw(batch,x,y)
		else
			font.lastFunction = "print"
			font.lastAlignment = horizontalAlignment
			font.lastText = text
			font.lastWrapLimit = wrapLimit
			local glyphX = 0
			local glyphY = 0
			local characterSpacing = font.characterSpacing
			local lineSpacing = font.lineSpacing
			local height = font.height
			local glyphs = font.glyphs
			local kerning = font.kerning

			batch:clear()
			batch:bind()
			for i=1,#text,1 do
				local character = text:sub(i,i)
				local glyph = glyphs[character]
				if character == "\n" then
					glyphX = 0
					glyphY = glyphY + height + lineSpacing
				elseif glyph ~= nil then
					batch:add(glyph.quad, glyphX, glyphY)
					if kerning == nil then
						glyphX = glyphX + glyph.width + characterSpacing 
					else
						local kernOffset = 0
						for k,v in pairs(kerning) do
							if text:sub(i,i+#k-1) == k then
								kernOffset = v
								break
							end
						end
						glyphX = glyphX + glyph.width + characterSpacing + kernOffset
					end
				end
			end
		end
		batch:unbind()
		love.graphics.draw(batch,x,y)
	end
end


--[[local colorCodes = {}
			local found = text:find("\127")
			while found ~= nil do
				--text:gsub(text:sub(found,found+9),"")
				colorCodes[found] = tonumber(text:sub(found,found+8))
				text = text:sub(1,found-1) .. text:sub(found+9)
				found = text:find("\127")
			end]]

function ifl.printf(text,x,y,wrapLimit,horizontalAlignment,verticalAlignment,key)
	local text = text .. ""
	if #text > 0 then
		local font = ifl.fonts[key or ifl.font]
		local x = x or 0
		local y = y or 0
		local wrapLimit = wrapLimit or 0
		local horizontalAlignment = horizontalAlignment or "left"
		local verticalAlignment = verticalAlignment or "top"
		if font ~= nil then
			local batch = font.batch
			if text == font.lastText and font.lastFunction == "printf" and horizontalAlignment == font.lastAlignment and wrapLimit == font.lastWrapLimit then
				love.graphics.draw(batch,x,y)
			else
				font.lastFunction = "printf"
				font.lastAlignment = horizontalAlignment
				font.lastText = text
				font.lastWrapLimit = wrapLimit

				local fontHeight = font.height
				local characterSpacing = font.characterSpacing
				local lineSpacing = font.lineSpacing
				local glyphX = 0
				local glyphY = 0
				local glyphs = font.glyphs
				local totalWidth = 0
				local lines = ifl.calculateLines(text,wrapLimit)

				batch:clear()
				for i,line in ipairs(lines) do
					if horizontalAlignment == "left" then
						glyphX = 0
					elseif horizontalAlignment == "right" then
						glyphX = math.floor(wrapLimit - lines[i].width)
					elseif horizontalAlignment == "center" then
						glyphX = math.floor(wrapLimit/2 - math.floor(lines[i].width/2))
					end
					for j=1,#line.text,1 do
						local character = line.text:sub(j,j)
						local glyph = glyphs[character]
						if glyph ~= nil then
							batch:add(glyph.quad,glyphX,glyphY)
							if kerning == nil then
								glyphX = glyphX + glyph.width + characterSpacing 
							else
								local kernOffset = 0
								for k,v in pairs(kerning) do
									if text:sub(i,i+#k-1) == k then
										kernOffset = v
									break
									end
								end
								glyphX = glyphX + glyph.width + characterSpacing + kernOffset
							end
						end
					end
					glyphY = glyphY + fontHeight + lineSpacing
					if lines[i].width > totalWidth then
						totalWidth = lines[i].width
					end
				end
				love.graphics.draw(batch,x,y)
				return totalWidth,#lines * (fontHeight + lineSpacing),#lines
			end
		end
	end
end

function ifl.detach(key)
	ifl.fonts[key] = nil
end

return ifl