function love.run()
	settings = {}
	settings.frameRate = 60
	settings.accumulator = 0
	settings.nextUpdateTime = love.timer.getTime() + 1 / settings.frameRate
	settings.frameUpdated = false

	if love.math then
		love.math.setRandomSeed(1)
		--love.math.setRandomSeed(101)
		for i=1,3 do love.math.random() end
	end
 
	if love.event then
		love.event.pump()
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
			settings.accumulator = settings.accumulator + dt
		end
 
		-- Call update and draw
		if settings.accumulator >= 1/settings.frameRate then
			if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
			settings.accumulator = settings.accumulator - 1/ settings.frameRate
		end
 
		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw(dt) end
			love.graphics.present()
		end
		if love.timer then love.timer.sleep(1/settings.frameRate / 2) end
	end
end