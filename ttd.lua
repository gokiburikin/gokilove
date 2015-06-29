--[[ Tiny Timer Daemon ]]

local ttd = {}
ttd.timers = {}

function ttd.attach(length,tick,pingpong,tock,id)
	local timer = {}
	id = id or timer
	timer.length = length
	timer.accumulator = 0
	timer.percent = 0
	timer.pingpong = pingpong or false
	timer.flipflop = true
	timer.tick = tick or function() end
	timer.tock = tock or function() end
	ttd.timers[id] = timer
	return timer
end

function ttd.detach(id)
	ttd.timers[id] = nil
end

function ttd.update(dt)
	for k,v in pairs(ttd.timers) do
		v.accumulator = v.accumulator + dt
		if v.accumulator > v.length then
			v.accumulator = v.accumulator - v.length
			if v.flipflop then
				v.tick()
				if v.pingpong then
					v.flipflop = false
				end
			else
				v.tock()
				v.flipflop = true
			end
		end
		v.percent = v.accumulator / v.length
		if not v.flipflop then
			v.percent = 1-v.percent
		end
	end
end

return ttd