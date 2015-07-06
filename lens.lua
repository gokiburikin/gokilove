--[[ Little Event and Notification System ]]

local lens = {}
lens.events = {}

lens.event = function()
	local event = {}
	event.callbacks = {}
	event.cancelable = true

	event.trigger = function(sender, arguments)
		for k,v in pairs(event.callbacks) do
			local result = v(sender, arguments)
			if result == false then
				return false
			end
		end
	end

	event.attach = function(callback, key)
		key = key or callback
		event.callbacks[key] = callback
	end

	event.detach = function(key)
		event.callbacks[key] = nil
	end

	return event
end

lens.attach = function(event,name)
	name = name or event
	lens.events[name] = event
end

lens.detach = function(name)
	lens.events[name] = nil
end

lens.get = function(name)
	return lens.events[name]
end

lens.trigger = function(name,sender,arguments)
	if lens.get(name) ~= nil then
		lens.gets(name).trigger(sender,arguments)
	end
end

return lens