--[[ Persistent Performance Profiler ]]
local ppp = {}
ppp.totalSamples = {}
ppp.totalDuration = {}
ppp.sampleLimit = 10000
ppp.useLove = true

function ppp.getTime()
	if ppp.useLove then
		return love.timer.getTime()
	end
	return os.clock()
end

function ppp.time(callback, iterations, decimals)
	local power = math.pow(10,decimals or 4)
    collectgarbage()
    repetitions = repetitions or 1
    iterations = iterations or 100
    ppp.totalSamples[callback] = ppp.totalSamples[callback] or 0
    ppp.totalDuration[callback] = ppp.totalDuration[callback] or 0
	local before = ppp.getTime()
	for i=1,iterations,1 do
		callback()
	end
	before = ppp.getTime() - before
	ppp.totalDuration[callback] = ppp.totalDuration[callback] + before * 1000
	ppp.totalSamples[callback] = ppp.totalSamples[callback] + 1
    local result = "(" .. ppp.totalSamples[callback] .. ") " .. math.floor(ppp.totalDuration[callback]/ppp.totalSamples[callback]*power)/power
    if ppp.totalSamples[callback] > ppp.sampleLimit then
		ppp.totalSamples[callback] = 0
		ppp.totalDuration[callback] = 0
	end
    return result
end

function ppp.reset()
	ppp.totalSamples = {}
	ppp.totalDuration = {}
end

return ppp