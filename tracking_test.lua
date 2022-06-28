require("Matrix")
require("LifeBoatAPI")

FOV = 0.01
AZIMUTH_V = 0
AZIMUTH_H = 0
MODE = 0
TGT = Matrix.new(3, 1)
TGT_SPEED = Matrix.new(3, 1)
DYT = Matrix.new(3, 1)
DYT:set(2, 1, 0.25)
SEARCH_RADAR_SW = false
BALISTIC_CALC = false

PIVOT_V = 0
PIVOT_H = 0

PARAMS = {}

compassToAzimuth = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth

function onTick()
	for i = 1, 32 do
		PARAMS[i] = input.getNumber(i)
	end
	if not input.getBool(1) then return end
	local rm_base = Matrix.rm(getTilt(PARAMS[10], PARAMS[12]), getTilt(PARAMS[11], PARAMS[12]), PARAMS[13])
	local rm_gun = Matrix.rm(getTilt(PARAMS[14], PARAMS[16]), getTilt(PARAMS[15], PARAMS[16]), PARAMS[17])
	local rm_base_inv = rm_base:inv()
	local rm_gun_inv = rm_gun:inv()
	if MODE == 0 then
		if PARAMS[4] ~= 0 and PARAMS[7] ~= 0 then
			MODE = 1
			TGT = rm_gun:dot(getXYZ(PARAMS[9], PARAMS[5], PARAMS[8])):sub(DYT)
			FOV = getFOV(PARAMS[9])
		end
	end
	if MODE == 1 then
		if PARAMS[4] == 0 or PARAMS[7] == 0 then
			MODE = 0
			
		end

	end
	output.setNumber(1, PIVOT_V)
	output.setNumber(2, PIVOT_H)

	output.setNumber(3, AZIMUTH_V)
	output.setNumber(4, AZIMUTH_H)
	output.setNumber(5, FOV)
end

function getXYZ(dist, azim, elev) --x,y,z
	local mat = Matrix.new(3, 1)
	mat:set(1, 1, dist * math.cos(elev) * math.sin(azim))
	mat:set(2, 1, dist * math.sin(elev))
	mat:set(3, 1, dist * math.cos(elev) * math.cos(azim))
	return mat
end
function getFOV(distance)
	return clamp(math.atan(2 / distance),0.01,0.125)
end
function clamp(value,min,max)
	if value < min then value = min elseif value > max then value = max end
	return value
end