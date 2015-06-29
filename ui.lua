--[[ User Interface ]]

local ui = {}
ui.controls = {}
ui.onMouseUp = lens.event()
ui.onMouseDown = lens.event()
ui.onMouseEnter = lens.event()
ui.onMouseLeave = lens.event()
ui.onMouseMove = lens.event()

local controlUnderPoint = function(control, x,y )
	--[[if x >= control.left and x <= control.left + control.width and y >= control.top and y <= control.top+control.height then
		return true
	end]]

	local adjusted = control.tdtc.toLocal(x,y)
	if adjusted.x >=0 and adjusted.x < control.tdtc.width and adjusted.y >= 0 and adjusted.y < control.tdtc.height then
		return true
	end

	return false
end

function ui:ordered(drawOrder)
	drawOrder = drawOrder or false
	local ordered = {}
	for k,v in pairs(self.controls) do
		table.insert(ordered,v)
	end
	if drawOrder then
		table.sort(ordered,
			function(a,b)
				if a.layer < b.layer then
					return true
				end
				return false
			end
		)
	else
		table.sort(ordered,
			function(a,b)
				if a.layer > b.layer then
					return true
				end
				return false
			end
		)
	end
	return ordered
end

function ui:attach( control, key )
	key = key or control
	self.controls[key] = control
	control.id = key
	return control
end

function ui:remove( key )
	self.controls[key] = nil
end

function ui:get(key)
	return self.controls[key]
end

function ui:update(dt)
	for k,v in pairs(self:ordered()) do
		v:update(dt)
	end
end

function ui:draw ()
	for k,v in ipairs(self:ordered(true)) do
		if v.visible then
			love.graphics.push()
			v.tdtc.apply()
			v:draw()
			love.graphics.pop()
		end
	end
end

function ui:keyDown(key, unicode)
end

function ui:keyUp (key, unicode)
end

function ui:mouseDown(x, y, button)
	for k,v in pairs(self:ordered()) do
		if controlUnderPoint(v,x,y) then
			local adjusted = v.tdtc.toLocal(x,y)
			if v:mouseDown(adjusted.x,adjusted.y,button) == false then
				return false
			end
		end
	end
	return self.onMouseDown:trigger(self,{x=x,y=y,button=button})
end

function ui:mouseUp (x, y, button)
	for k,v in pairs(self:ordered()) do
		local adjusted = v.tdtc.toLocal(x,y)
		if controlUnderPoint(v,x,y) then
			v:mouseUp(adjusted.x,adjusted.y,button)
		end
	end
	self.onMouseUp:trigger(self,{x=x,y=y,button=button})
end

function ui:mouseMove(x, y, dx, dy)
	for k,v in pairs(self:ordered()) do
		if controlUnderPoint(v,x,y) then
			local adjusted = v.tdtc.toLocal(x,y)
			if not v.hover then
				v:mouseEnter()
				v.hover = true
			end
			v:mouseMove(adjusted.x,adjusted.y,dx,dy)
		elseif v.hover then
			v:mouseLeave()
			v.hover = false
		end
	end
	self.onMouseMove:trigger(self,{x=x, y=y, dx=dx,dy=dy})
end

function ui:mouseEnter()
	self.onMouseEnter:trigger(self,{})
end

function ui:mouseLeave()
	self.onMouseLeave:trigger(self,{})
end

ui.control = function(o)
	local control = {}
	o = o or {}
	control.controls = {}
	control.tdtc = o.tdtc or stcm.tdtc(o)
	control.enabled = o.enabled or true
	control.visible = o.visible or true 
	control.focus = function() end
	control.hover = false
	control.layer = o.layer or 0
	control.onMouseUp = lens.event()
	control.onMouseDown = lens.event()
	control.onMouseEnter = lens.event()
	control.onMouseLeave = lens.event()
	control.onMouseMove = lens.event()
	
	control.ordered = ui.ordered
	control.draw = ui.draw
	control.update = ui.update
	control.attach = ui.attach
	control.remove = ui.remove
	control.get = ui.get
	control.mouseDown = ui.mouseDown
	control.mouseEnter = ui.mouseEnter
	control.mouseLeave = ui.mouseLeave
	control.mouseMove = ui.mouseMove
	control.mouseUp = ui.mouseUp

	return control
end

ui.panel = function(x,y,width,height,color)
	local control = ui.control()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.backColor = color
	function control:draw()
		if self.backColor ~= nil then
			icm.setColor(self.backColor)
			love.graphics.rectangle("fill",0, 0,self.tdtc.width, self.tdtc.height)
		end
		ui.draw(self)
	end
	return control
end

ui.textPanel = function(x,y,width,height,font,text,backColor,foreColor,horizontalAlignment,verticalAlignment)
	local control = ui.control()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.font = font
	control.backColor = backColor
	control.color = foreColor
	control.text = text
	control.horizontalAlignment = horizontalAlignment or "left"
	control.verticalAlignment = verticalAlignment or "top"
	function control:draw()
		if self.backColor ~= nil then
			icm.setColor(self.backColor)
			love.graphics.rectangle("fill",0, 0,self.tdtc.width, self.tdtc.height)
		end
		if self.text ~= nil then
			local y = 0
			if self.font ~= nil then
				love.graphics.setFont(self.font)
				local height = font:getWrap(self.text,self.tdtc.width)
				if self.verticalAlignment == "middle" then
					y = self.tdtc.height/2 - height/self.tdtc.width - font:getHeight()/2
				elseif self.verticalAlignment == "bottom" then
					y = self.tdtc.height - height/self.tdtc.width- font:getHeight()
				end
			end
			icm.setColor(self.color)
			
			love.graphics.printf(self.text,0,y,self.tdtc.width, self.horizontalAlignment)
		end
		ui.draw(self)
	end
	return control
end

ui.mover = function(x,y,width,height)
	local control = ui.control()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.ftdtc = stcm.tdtc(x,y,width,height)
	function control:update()
		self.tdtc.x = self.tdtc.x + (self.ftdtc.x - self.tdtc.x) / 4
		self.tdtc.y = self.tdtc.y + (self.ftdtc.y - self.tdtc.y) / 4
		self.tdtc.scaleX = self.tdtc.scaleX + (self.ftdtc.scaleX - self.tdtc.scaleX) / 4
		self.tdtc.scaleY = self.tdtc.scaleY + (self.ftdtc.scaleY - self.tdtc.scaleY) / 4
		ui.update(self)
	end
	return control
end

return ui