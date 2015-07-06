--[[ Simple Sound Manager ]]

local ssm = {}
ssm.muted = false
ssm.volume = .2

function ssm.attach(file,key,soundType)
	soundType = soundType or "static"
	if ssm[key] == nil then
		ssm[key] = {}
	end
	table.insert(ssm[key],love.audio.newSource(file,"static"))
end

function ssm.attachNumbered(file,key,replacement,numberingStart,numberingEnd,soundType)
	soundType = soundType or "static"
	for i=numberingStart,numberingEnd,1 do
		ssm.attach(file:gsub(replacement,i),key, soundType)
	end
end

function ssm.detach(file,key)
	if ssm[key] ~= nil then
		local index = 0
		for i=1,#ssm[key],1 do
			if ssm[key] == file then
				index = i
				break
			end
		end
		if index ~= 0 then
			table.remove(ssm[key],index)
			if #ssm[key] == 0 then
				ssm[key] = nil
			end
		end
	end
end

function ssm.play(key)
	if not ssm.muted and ssm[key] ~= nil then
		love.audio.setVolume(ssm.volume)
		love.audio.play(ssm[key][love.math.random(1,#ssm[key])])
	end
end

return ssm