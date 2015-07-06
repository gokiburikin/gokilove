--[[ Simple State System ]]

local sss = {}
sss.states = {}
sss.dictionary = {}
sss.autoOrder = 0
sss.autoEnable = true

function sss.new(order)
	local state = {}
	state.loaded = false
	state.enabled = false
	state.order = order or nil
	state.enable = function() end
	state.disable = function() end
	state.load = function() end
	state.dispose = function() end
	state.update = function(dt) end
	state.draw = function() end
	state.keypressed = function(key,unicode) end
	state.keyreleased = function(key,unicode) end
	state.mousepressed = function(x,y,button) end
	state.mousereleased = function(x,y,button) end
	state.mousemoved = function(x,y,dx,dy) end
	return state
end

function sss.sort()
	table.sort(sss.dictionary,function(a,b)
		if sss.states[a].order > sss.states[a].order then
			return true
		end
		return false
	end)
end

function sss.attach(state,id,enabled)
	id = id or state
	if state.order == nil then
		state.order = sss.autoOrder
		sss.autoOrder = sss.autoOrder + 1
	end
	sss.states[id] = state
	table.insert(sss.dictionary,id)
	sss.sort()
	if enabled == nil then
		if sss.autoEnable then
			sss.enable(id)
		end
	elseif enabled then
		sss.enable(id)
	end
	if state.load ~= nil then
		state.loaded = true
		state.load()
	end
	return state
end

function sss.detach(id)
	local state = sss.states[id]
	if state ~= nil then
		table.remove(sss.dictionary,id)
		sss.sort()
		if state.disable then
			state.disable(id)
		end
		if state.dispose then
			state.dispose()
			state.loaded = false
		end
	end
	sss.states[id] = nil
end

function sss.enable(id)
	local state = sss.states[id]
	if state ~= nil then
		if state.enable ~= nil then
			state.enable()
		end
		state.enabled = true
	end
end

function sss.disable(id)
	if sss.states[id] ~= nil then
		if sss.states[id].disable ~= nil then
			sss.states[id].disable()
		end
		sss.states[id].enabled = false
	end
end

function sss.toggle(id)
	if sss.states[id] ~= nil then
		if sss.states[id].enabled then
			sss.disable(id)
		else
			sss.enable(id)
		end
	end
end

function sss.foreach(callback)
	local workingSet = {}
	for k,v in pairs(sss.states) do
		workingSet[k] = v
	end
	for k,v in ipairs(sss.dictionary) do
		callback(workingSet[v])
	end
end

function sss.update(dt)
	sss.foreach(function(state)
		if state and state.enabled and state.update then
			state.update(dt)
		end
	end)
end

function sss.draw()
	sss.foreach(function(state)
		if state and state.enabled and state.draw then
			state.draw()
		end
	end)
end

function sss.keypressed(key, unicode)
	sss.foreach(function(state)
		if state and state.enabled and state.keypressed then
			state.keypressed(key,unicode)
		end
	end)
end

function sss.keyreleased(key, unicode)
	sss.foreach(function(state)
		if state and state.enabled and state.keyreleased then
			state.keyreleased(key,unicode)
		end
	end)
end

function sss.mousepressed(x, y, button)
	sss.foreach(function(state)
		if state and state.enabled and state.mousepressed then
			state.mousepressed(x, y, button)
		end
	end)
end

function sss.mousereleased(x, y, button)
	sss.foreach(function(state)
		if state and state.enabled and state.mousereleased then
			state.mousereleased(x, y, button)
		end
	end)
end

function sss.mousemoved(x, y, dx,dy)
	sss.foreach(function(state)
		if state and state.enabled and state.mousemoved then
			state.mousemoved(x, y, dx,dy)
		end
	end)
end

return sss