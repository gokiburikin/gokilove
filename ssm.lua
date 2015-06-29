--[[ Simple Sound Manager ]]

local ssm = {}
ssm.muted = false

function ssm.attach(key,file,soundType)
	soundType = soundType or "static"
	if ssm[key] == nil then
		ssm[key] = {}
	end
	table.insert(ssm[key],love.audio.newSource(file,"static"))
end

function ssm.attachNumbered(key,file,replacement,numberingStart,numberingEnd,soundType)
	soundType = soundType or "static"
	for i=numberingStart,numberingEnd,1 do
		ssm.attach(key,file:gsub(replacement,i), soundType)
	end
end

function ssm.detach(key,file)
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
		love.audio.play(ssm[key][love.math.random(1,#ssm[key])])
	end
end

return ssm