--[[ Image Font Library ]]
local ifl = {}
ifl.fonts = {}
ifl.font = "default"

function ifl.attach(imagePath,key,fontString,characterSpacing,lineSpacing,kerning,separatorColor)
	local separatorColor = {r=255,g=255,b=0,a=255}
	local imageFont = {}
	imageFont.imageData = love.image.newImageData(imagePath)

	imageFont.glyphs = {}
	local glyphIndex = 1
	local currentGlyphLeft = -1
	local width = imageFont.imageData:getWidth()
	local height = imageFont.imageData:getHeight()
	
	for x=0,imageFont.imageData:getWidth()-1,1 do
		local r,g,b,a = imageFont.imageData:getPixel(x,0)
		if r == separatorColor.r and g == separatorColor.g and b == separatorColor.b and separatorColor.a == a then
			for y=0,imageFont.imageData:getHeight()-1,1 do
			imageFont.imageData:setPixel(x,y,0,0,0,0)
			end
			if currentGlyphLeft ~= -1 then
				imageFont.glyphs[fontString:sub(glyphIndex,glyphIndex)] = {quad=love.graphics.newQuad(currentGlyphLeft,0,x-currentGlyphLeft,height,width,height),width=x-currentGlyphLeft}
				glyphIndex = glyphIndex + 1
			end
			currentGlyphLeft = x+1
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

	function imageFont.getLines(text,wrapLimit)
		local width = 0
		local lineCount = 0
		local glyphX = 0
		local glyphY = 0
		local lines = {}
		local lineWidths = {}
		local lineSpacing = imageFont.lineSpacing
		local characterSpacing = imageFont.characterSpacing
		local kerning = imageFont.kerning
		local height = imageFont.height

		local lastBreakIndex = 1
		local nextBreakIndex = 1
		local nextBreakWidth = 0
		local nextBreakWidthAfter = 0
		local lineWidth = 0
		
		for i=1,#text,1 do
			local character = text:sub(i,i)

			local glyph = imageFont.glyphs[character]

			if character == " " then
				nextBreakIndex = i
				nextBreakWidth = lineWidth 
				nextBreakWidthAfter = lineWidth 
			end
			if character == "\n" then
				lineCount = lineCount + 1
				lastBreakIndex = i
				nextBreakIndex = i
				nextBreakWidth = lineWidth 
				nextBreakWidthAfter = lineWidth 
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
				if character == " " then
					nextBreakIndex = i
					nextBreakWidthAfter = lineWidth 
				end
				if lineWidth >= wrapLimit and lastBreakIndex ~= nextBreakIndex then
					lineCount = lineCount + 1
					lineWidth = lineWidth - nextBreakWidthAfter
					nextBreakWidth = lineWidth
					nextBreakWidthAfter = lineWidth

					lastBreakIndex = nextBreakIndex+1
					nextBreakIndex = lastBreakIndex
				end
			end

			if i == #text then
				lineCount = lineCount + 1
			end
		end
		return width,lineCount * (imageFont.height + lineSpacing),lineCount
	end

	ifl.fonts[key]  = imageFont
	return imageFont
end

function ifl.set(key)
	ifl.font = key
end

function ifl.get(key)
	return ifl.fonts[key]
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

function ifl.printf(text,x,y,wrapLimit,horizontalAlignment,verticalAlignment,key)
	local text = text .. ""
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

			local glyphX = 0
			local glyphY = 0
			local lines = {}
			local lineWidths = {}
			local lineSpacing = font.lineSpacing
			local characterSpacing = font.characterSpacing
			local kerning = font.kerning
			local height = font.height
			local glyphs = font.glyphs

			local lastBreakIndex = 1
			local nextBreakIndex = 1
			local nextBreakWidth = 0
			local nextBreakWidthAfter = 0
			local lineWidth = 0
			local totalWidth = 0
			local lineCount = 0

			--[[local colorCodes = {}
			local found = text:find("\127")
			while found ~= nil do
				--text:gsub(text:sub(found,found+9),"")
				colorCodes[found] = tonumber(text:sub(found,found+8))
				text = text:sub(1,found-1) .. text:sub(found+9)
				found = text:find("\127")
			end]]

			for i=1,#text,1 do
				local character = text:sub(i,i)
				local glyph = glyphs[character]

				if character == " " then
					nextBreakIndex = i
					nextBreakWidth = lineWidth 
					nextBreakWidthAfter = lineWidth 
				end

				if character == "\n" then
					lineCount = lineCount + 1
					lines[lineCount] = text:sub(lastBreakIndex,i)
					lineWidths[lineCount] = lineWidth
					lastBreakIndex = i
					nextBreakIndex = i
					nextBreakWidth = lineWidth 
					nextBreakWidthAfter = lineWidth 
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
					if character == " " then
						nextBreakIndex = i
						nextBreakWidthAfter = lineWidth 
					end
					if lineWidth >= wrapLimit and lastBreakIndex ~= nextBreakIndex then
						lineCount = lineCount + 1
						lines[lineCount] = text:sub(lastBreakIndex,nextBreakIndex-1)
						lineWidths[lineCount] = nextBreakWidth- characterSpacing
						lineWidth = lineWidth - nextBreakWidthAfter
						nextBreakWidth = lineWidth
						nextBreakWidthAfter = lineWidth

						lastBreakIndex = nextBreakIndex+1
						nextBreakIndex = lastBreakIndex
					end
				end

				if i == #text then
					lineCount = lineCount + 1
					lines[lineCount] = text:sub(lastBreakIndex,i)
					lineWidths[lineCount] = lineWidth - characterSpacing
				end
			end

			batch:clear()
			for i,line in ipairs(lines) do
				if horizontalAlignment == "left" then
					glyphX = 0
				elseif horizontalAlignment == "right" then
					glyphX = wrapLimit - lineWidths[i]
				elseif horizontalAlignment == "center" then
					glyphX = wrapLimit/2 - math.floor(lineWidths[i]/2)
				end
				for j=1,#line,1 do
					local character = line:sub(j,j)
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
				glyphY = glyphY + height + lineSpacing
				if lineWidths[i] > totalWidth then
					totalWidth = lineWidths[i]
				end
			end
			love.graphics.draw(batch,x,y)
			return totalWidth,lineCount * (height + lineSpacing),lineCount
		end
	end
end

function ifl.detach(key)
	ifl.fonts[key] = nil
end

return ifl