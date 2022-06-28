require("Matrix")
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
	if #tgt == 0 then return end
	table.sort(tgt, function(a, b) return (a[1] < b[1]) end)
	f = tgt[1][1] < 2000
	output.setBool(1, f)
	local mat = getXYZ(tgt[1][1], tgt[1][2], tgt[1][3])
	for i = 1, 3 do
		output.setNumber(i, mat:get(i, 1))
	end
end

function getXYZ(dist, azim, elev)
	local mat = Matrix.new(3, 1)
	mat:set(1, 1, dist * math.cos(elev) * math.sin(azim))
	mat:set(2, 1, dist * math.sin(elev))
	mat:set(3, 1, dist * math.cos(elev) * math.cos(azim))
	return mat
end
