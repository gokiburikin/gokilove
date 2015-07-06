--[[ Image Font Library ]]
local ifl = {}
ifl.fonts = {}
ifl.font = "default"

function ifl.attach(imagePath,key,fontString,characterSpacing,lineSpacing,kerning,separatorColor)
	separatorColor = {r=255,g=255,b=0,a=255}
	local imageFont = {}
	imageFont.image = love.graphics.newImage(imagePath)

	imageFont.imageData = love.image.newImageData(imagePath)
	imageFont.fontString = fontString
	imageFont.glyphs = {}
	imageFont.characterSpacing = characterSpacing or 0
	imageFont.lineSpacing = lineSpacing or 0
	imageFont.height = imageFont.image:getHeight()
	imageFont.batch = love.graphics.newSpriteBatch(imageFont.image,10000,"static")
	imageFont.kerning = kerning or {}

	local glyphIndex = 1
	local currentGlyphLeft = -1
	local width = imageFont.image:getWidth()
	local height = imageFont.height
	
	for x=0,imageFont.imageData:getWidth()-1,1 do
		local r,g,b,a = imageFont.imageData:getPixel(x,0)
		if r == separatorColor.r and g == separatorColor.g and b == separatorColor.b and separatorColor.a == a then
			if currentGlyphLeft ~= -1 then
				imageFont.glyphs[fontString:sub(glyphIndex,glyphIndex)] = {quad=love.graphics.newQuad(currentGlyphLeft,0,x-currentGlyphLeft,height,width,height),width=x-currentGlyphLeft}
				glyphIndex = glyphIndex + 1
			end
			currentGlyphLeft = x+1
		end
	end

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
		local lines = {}

		local lastBreakIndex = 1
		local nextBreakIndex = 1
		local width = 0
		local height = 0
		local lineWidth = 0
		local nextBreakWidth = 0
		for i=1,#text,1 do
			-- Get the kerning offset for any kerning sets
			local kernOffset = {x=0,y=0}
			for k,v in pairs(imageFont.kerning) do
				if text:sub(i,i+#k-1) == k then
					kernOffset = v
				end
			end

			-- The relevant glyph data
			local glyph = imageFont.glyphs[text:sub(i,i)]
			
			-- If the character is a new line, force a line break and reset line width
			if text:sub(i,i) == "\n" then
				if lastBreakIndex ~= nextBreakIndex then
					table.insert(lines, text:sub(lastBreakIndex,i))
				end
				lastBreakIndex = i
				nextBreakIndex = i
				nextBreakWidth = lineWidth
				lineWidth = 0
			-- If the glyph data is found
			elseif glyph ~= nil then
				-- Increase the line width by the width of the glyph, the fonts character spacing, and the kerning offset if any
				lineWidth = lineWidth + glyph.width + imageFont.characterSpacing + kernOffset.x
				-- If the new line width is bigger than the wrap limit
				if lineWidth > wrapLimit and lastBreakIndex ~= nextBreakIndex then
					-- Add the text from the previous break to the closest wrap safe break to the line
					table.insert(lines, text:sub(lastBreakIndex,nextBreakIndex-1))
					-- Set the previous break to the closest wrap safe break
					lastBreakIndex = nextBreakIndex + 1
					-- Subtract the width of the added line from the current line width
					lineWidth = lineWidth - nextBreakWidth
				end
			end

			-- If the character is a space, keep track of its position and the current line width
			if text:sub(i,i) == " " then
				nextBreakIndex = i
				nextBreakWidth = lineWidth
			end

			if i == #text then
				table.insert(lines, text:sub(lastBreakIndex,i))
				nextBreakWidth = lineWidth 
			end
			if nextBreakWidth > width then
				width = nextBreakWidth
			end
		end
		return width,(imageFont.height + imageFont.lineSpacing)*#lines - imageFont.lineSpacing,#lines
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
	key = key or ifl.font
	x = x or 0
	y = y or 0
	local font = ifl.fonts[key]

	if font ~= nil then
		local batch = font.batch
		local glyphX = x
		local glyphY = y
		for i=1,#text,1 do
			local character = text:sub(i,i)
			local kernOffset = 0
			for k,v in pairs(font.kerning) do
				if text:sub(i,i+#k-1) == k then
					kernOffset = v
				end
			end
			local glyph = font.glyphs[character]
			if character == "\n" then
				glyphX = x
				glyphY = glyphY + font.height + font.lineSpacing
			elseif glyph ~= nil then
				--love.graphics.draw(font.image,glyph.quad,glyphX,glyphY)
				batch:add(glyph.quad,glyphX,glyphY)
				glyphX = glyphX + glyph.width + font.characterSpacing + kernOffset
			end
		end
		love.graphics.draw(batch,0,0)
		batch:clear()
	else
		love.graphics.print(text,x,y)
	end
end

function ifl.printf(text,x,y,wrapLimit,horizontalAlignment,verticalAlignment,key)
	key = key or ifl.font
	x = x or 0
	y = y or 0
	horizontalAlignment = horizontalAlignment or "left"
	verticalAlignment = verticalAlignment or "top"
	local font = ifl.fonts[key]

	if font ~= nil then
		local batch = font.batch
		local glyphX = x
		local glyphY = y
		local lines = {}
		local lineWidths = {}

		local lastBreakIndex = 1
		local nextBreakIndex = 1
		local nextBreakWidth = 0
		local lineWidth = 0
		for i=1,#text,1 do

			local kernOffset = 0
			for k,v in pairs(font.kerning) do
				if text:sub(i,i+#k-1) == k then
					kernOffset = v
				end
			end

			local glyph = font.glyphs[text:sub(i,i)]

			if text:sub(i,i) == "\n" then
				if lastBreakIndex ~= nextBreakIndex then
					table.insert(lines, text:sub(lastBreakIndex,i))
				end
				table.insert(lineWidths, lineWidth)
				lastBreakIndex = i
				nextBreakIndex = i
				nextBreakWidth = lineWidth
				lineWidth = 0
			elseif glyph ~= nil then
				lineWidth = lineWidth + glyph.width + font.characterSpacing + kernOffset
				if lineWidth > wrapLimit and lastBreakIndex ~= nextBreakIndex then
					table.insert(lines, text:sub(lastBreakIndex,nextBreakIndex-1))
					table.insert(lineWidths, nextBreakWidth)
					lastBreakIndex = nextBreakIndex + 1
					lineWidth = lineWidth - nextBreakWidth
				end
			end

			if text:sub(i,i) == " " then
				nextBreakIndex = i
				nextBreakWidth = lineWidth
			end
			
			if i == #text then
				table.insert(lines, text:sub(lastBreakIndex,i))
				table.insert(lineWidths, nextBreakWidth)
			end
		end

		local glyphY = y
		if horizontalAlignment == "left" then
			for i,line in ipairs(lines) do
				glyphX = x
				glyphY = glyphY + font.height + font.lineSpacing
				for j=1,#line,1 do
					local kernOffset = 0
					for k,v in pairs(font.kerning) do
						if text:sub(i,i+#k-1) == k then
							kernOffset = v
						end
					end
					local glyph = font.glyphs[line:sub(j,j)]
					if glyph ~= nil then
						--love.graphics.draw(font.image,glyph.quad,glyphX,glyphY)
						batch:add(glyph.quad,glyphX,glyphY)
						glyphX = glyphX + glyph.width + font.characterSpacing + kernOffset
					end
				end
			end
		elseif horizontalAlignment == "right" then
			for i,line in ipairs(lines) do
				glyphX = x + wrapLimit - lineWidths[i]
				glyphY = glyphY + font.height + font.lineSpacing
				for j=1,#line,1 do
					local kernOffset = 0
					for k,v in pairs(font.kerning) do
						if text:sub(i,i+#k-1) == k then
							kernOffset = v
						end
					end
					local glyph = font.glyphs[line:sub(j,j)]
					if glyph ~= nil then
						--love.graphics.draw(font.image,glyph.quad,glyphX,glyphY)
						batch:add(glyph.quad,glyphX,glyphY)
						glyphX = glyphX + glyph.width + font.characterSpacing + kernOffset
					end
				end
			end
		elseif horizontalAlignment == "center" then
			for i,line in ipairs(lines) do
				glyphX = x + wrapLimit/2 - math.floor(lineWidths[i]/2)
				glyphY = glyphY + font.height + font.lineSpacing
				for j=1,#line,1 do
					local kernOffset = 0
					for k,v in pairs(font.kerning) do
						if text:sub(i,i+#k-1) == k then
							kernOffset = v
						end
					end
					local glyph = font.glyphs[line:sub(j,j)]
					if glyph ~= nil then
						--love.graphics.draw(font.image,glyph.quad,glyphX,glyphY)
						batch:add(glyph.quad,glyphX,glyphY)
						glyphX = glyphX + glyph.width + font.characterSpacing + kernOffset
					end
				end
			end
		end

		love.graphics.draw(batch,0,0)
		batch:clear()
	else
		love.graphics.print(text,x,y)
	end
end

function ifl.detach(key)
	ifl.fonts[key] = nil
end

return ifl