--[[ User Interface Library ]]

local uil = {}

function uil.controlUnderPoint(control, x, y)
	--[[if x >= control.left and x <= control.left + control.width and y >= control.top and y <= control.top+control.height then
		return true
	end]]

	local adjusted = control.tdtc.toLocal(x,y)
	if adjusted.x >=0 and adjusted.x < control.tdtc.width and adjusted.y >= 0 and adjusted.y < control.tdtc.height then
		return true
	end

	return false
end

function uil.new()
	return uil.control.new()
end

uil.control = {}
function uil.control.new()
	local control = {}
	control.onMouseUp = lens.event()
	control.onMouseDown = lens.event()
	control.onMouseEnter = lens.event()
	control.onMouseLeave = lens.event()
	control.onMouseMove = lens.event()

	control.controls = {}
	control.tdtc = stcm.tdtc()
	control.enabled = true
	control.visible = true 
	control.focus = function() end
	control.hover = false
	control.layer = 0
	control.parent = nil

	control.ordered = uil.control.ordered
	control.update = uil.control.update
	control.draw = uil.control.draw
	control.attach = uil.control.attach
	control.detach = uil.control.detach
	control.get = uil.control.get
	control.layout = uil.control.layout
	
	control.mouseDown = uil.control.mouseDown
	control.mouseUp = uil.control.mouseUp
	control.mouseEnter = uil.control.mouseEnter
	control.mouseLeave = uil.control.mouseLeave
	control.mouseMove = uil.control.mouseMove
	control.keyDown = uil.control.keyDown
	control.keyUp = uil.control.keyUp

	return control
end

function uil.control:ordered(drawOrder)
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

function uil.control:attach( control, key )
	key = key or control
	self.controls[key] = control
	control.id = key
	control.parent = self
	self:layout()
	return control
end

function uil.control:detach( key )
	self.controls[key].parent = nil
	self.controls[key] = nil
	self:layout()
end

function uil.control:get(key)
	return self.controls[key]
end

function uil.control:update(dt)
	for k,v in pairs(self:ordered()) do
		v:update(dt)
	end
end

function uil.control:layout()
end

function uil.control:draw ()
	for k,v in ipairs(self:ordered(true)) do
		if v.visible then
			love.graphics.push()
			v.tdtc.apply()
			v:draw()
			love.graphics.pop()
		end
	end
end

function uil.control:keyDown(key, unicode)
end

function uil.control:keyUp (key, unicode)
end

function uil.control:mouseDown(x, y, button)
	for k,v in pairs(self:ordered()) do
		if uil.controlUnderPoint(v,x,y) then
			local adjusted = v.tdtc.toLocal(x,y)
			if v:mouseDown(adjusted.x,adjusted.y,button) == false then
				return false
			end
		end
	end
	return self.onMouseDown.trigger(self,{x=x,y=y,button=button})
end

function uil.control:mouseUp (x, y, button)
	for k,v in pairs(self:ordered()) do
		local adjusted = v.tdtc.toLocal(x,y)
		if uil.controlUnderPoint(v,x,y) then
			v:mouseUp(adjusted.x,adjusted.y,button)
		end
	end
	self.onMouseUp.trigger(self,{x=x,y=y,button=button})
end

function uil.control:mouseMove(x, y, dx, dy)
	for k,v in pairs(self:ordered()) do
		if uil.controlUnderPoint(v,x,y) then
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
	self.onMouseMove.trigger(self,{x=x, y=y, dx=dx,dy=dy})
end

function uil.control:mouseEnter()
	self.onMouseEnter.trigger(self,{})
end

function uil.control:mouseLeave()
	self.onMouseLeave.trigger(self,{})
end

uil.panel = {}
function uil.panel.new(x,y,width,height,color)
	local control = uil.control.new()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.backColor = color
	
	return control
end

function uil.panel:draw()
	if self.backColor ~= nil then
		icm.setColor(self.backColor)
		love.graphics.rectangle("fill",0, 0,self.tdtc.width, self.tdtc.height)
	end
	ui.draw(self)
end

uil.textPanel = {}
function uil.textPanel.new(x,y,width,height,font,text,backColor,foreColor,horizontalAlignment,verticalAlignment,autoSize)
	local control = uil.control.new()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.font = font
	control.backColor = backColor
	control.color = foreColor
	control.text = text
	control.horizontalAlignment = horizontalAlignment or "left"
	control.verticalAlignment = verticalAlignment or "top"
	control.autoSize = autoSize or true
	control.draw = uil.textPanel.draw
	return control
end

function uil.textPanel:draw()
	if self.backColor ~= nil then
		icm.setColor(self.backColor)
		love.graphics.rectangle("fill",0,0,self.tdtc.width, self.tdtc.height)
	end
	if self.text ~= nil then
		local y = 0
		if self.font ~= nil then
			love.graphics.setFont(self.font)
			local height = self.font:getWrap(self.text,self.tdtc.width)
			if self.verticalAlignment == "middle" then
				y = self.tdtc.height/2 - height/self.tdtc.width - self.font:getHeight()/2
			elseif self.verticalAlignment == "bottom" then
				y = self.tdtc.height - height/self.tdtc.width- self.font:getHeight()
			end
		end
		if self.color ~= nil then
			icm.setColor(self.color)
		end
		love.graphics.printf(self.text,0,y,self.tdtc.width, self.horizontalAlignment)
	end
	uil.control.draw(self)
end

uil.mover = {}
function uil.mover.new(x,y,width,height)
	local control = uil.control.new()
	control.tdtc = stcm.tdtc(x,y,width,height)
	control.ftdtc = stcm.tdtc(x,y,width,height)
	return control
end

function uil.mover:update()
	self.tdtc.x = self.tdtc.x + (self.ftdtc.x - self.tdtc.x) / 4
	self.tdtc.y = self.tdtc.y + (self.ftdtc.y - self.tdtc.y) / 4
	self.tdtc.scaleX = self.tdtc.scaleX + (self.ftdtc.scaleX - self.tdtc.scaleX) / 4
	self.tdtc.scaleY = self.tdtc.scaleY + (self.ftdtc.scaleY - self.tdtc.scaleY) / 4
	uil.control.update(self)
end

uil.menuStrip = {}
function uil.menuStrip.new()
	local control = uil.control.new()
	control.layout = uil.menuStrip.layout
	return control
end

function uil.menuStrip:layout()
	local height = 0
	local controlX = 0
	for k,v in ipairs(self:ordered()) do
		if v.tdtc.height > height then
			height = v.tdtc.height
		end
		v.tdtc.x = controlX
		controlX = controlX + v.tdtc.width
	end
	self.tdtc.height = height
end

uil.menuStripItem = {}
function uil.menuStripItem.new(text)
	local control = uil.control.new()
	control.text = text
	return control
end

uil.menuStripDropDown = {}
function uil.menuStripDropDown.new(text)
	local control = uil.control.new()
	return control
end

return uil