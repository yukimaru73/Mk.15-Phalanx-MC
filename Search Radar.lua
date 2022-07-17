function onTick()
	local tgt = {}
	local f = false
	for i = 0, 7 do
		if input.getBool(i + 1) then
			local t = {}
			for j = 1, 4 do
				t[j] = input.getNumber(i * 4 + j)
			end
			tgt[#tgt + 1] = t
		end
	end
	if #tgt ~= 0 then
		table.sort(tgt, function(a, b) return (a[1] < b[1]) end)
		f = tgt[1][1] < 1500
		local pos = getXYZ(tgt[1][1], tgt[1][2], tgt[1][3])
		for i = 1, 3 do
			output.setNumber(i, pos[i])
		end
	end
	if f then
		output.setNumber(21,1)
	else
		output.setNumber(21,0)
	end
end
function getXYZ(dist, azim, elev) --x,y,z
	return {dist * math.cos(elev*2*math.pi) * math.cos(azim*2*math.pi),dist * math.sin(elev*2*math.pi),dist * math.cos(elev*2*math.pi) * math.sin(azim*2*math.pi)}
end
