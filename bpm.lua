--[[ BPM Library ]]

local bpm = {}
bpm.beats = {}
bpm.time = 0
bpm.bpm = 100
bpm.snap = true

bpm.update = function(dt)
	local hitBeats = {}
	local beatsHit = false
	for k,v in pairs(bpm.beats) do
		v.accumulator = v.accumulator + dt
		if v.last + v.accumulator > v.last + v.length then
			v.last = v.last + v.length
			v.accumulator = v.accumulator - v.length
			v.hits = v.hits + 1
			hitBeats[v.name] = v
			beatsHit = true
		end
	end
	if beatsHit then
		bpm.beat(hitBeats)
	end
	bpm.time = bpm.time + dt
end

bpm.beat = function(beats) end

bpm.attach = function(name, beatLength, offset, tag)
	local beat = {name=name,beatLength=beatLength,length=60/bpm.bpm * beatLength,accumulator=-60/bpm.bpm * offset,last=0,hits=0,tag=tag}
	local attachTime = bpm.time
	if bpm.snap then
		attachTime = bpm.calculateSnap(bpm.bpm,beatLength,bpm.time)
	end
	beat.last = attachTime
	bpm.beats[name] = beat
end

bpm.detach = function(name)
	bpm.beat[name] = nil
end

bpm.calculateSnap = function(bpm, length, time)
	return time - time % (bpm * length / 60)
end

bpm.changeBpm = function(newBpm)
	if newBpm <= 0 then
		newBpm = 0.00
	end
	for k,v in pairs(bpm.beats) do
		local oldLength = v.length
		local accumulatorRatio = v.accumulator / oldLength
		v.length = 60/newBpm * v.beatLength
		v.accumulator = v.length  *accumulatorRatio
		bpm.bpm = newBpm
	end
end

return bpm