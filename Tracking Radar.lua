-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
require("Matrix")
require("LifeBoatAPI")

FOV = 0.01
AZIMUTH_V = 0
AZIMUTH_H = 0
MODE = 0
TGT = Matrix.new(3, 1)
DYT=Matrix.new(3,1)
DYT:set(2,1,0.25)
TGT_SPEED = Matrix.new(3, 1)
SEARCH_RADAR_SW = false
BALISTIC_CALC = false

-- MODE:0 -> Stop
-- MODE:1 -> Search Recieve
-- MODE:2 -> Tracking
-- MODE:3 -> Tracking Miss and Retrying

function onTick()
	SEARCH_RADAR_SW = false
	local params = {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	if MODE == 0 and input.getNumber(18) == 1 then
		SEARCH_RADAR_SW = true
		if input.getBool(1) then --switch to mode 1
			MODE = 1
			for i = 1, 3 do TGT:set(i, 1, params[i]) end
			local r = Matrix.rm(getTilt(params[14], params[16]), getTilt(params[15], params[16]), params[17])
			local dy = Matrix.new(3, 1)
			dy:set(2, 1, 1.25)
			dy = r:dot(dy)
			TGT = r:dot(TGT)
			TGT = TGT:add(dy)
			setFOV(math.sqrt(TGT:get(1,1)^2+TGT:get(2,1)^2+TGT:get(3,1)^2))
		end
	else
		SEARCH_RADAR_SW = false
	end
	if MODE == 1 then
		local rm_base = Matrix.rm(getTilt(params[10], params[12]), getTilt(params[11], params[12]), params[13])
		local rm_gun = Matrix.rm(getTilt(params[14], params[16]), getTilt(params[15], params[16]), params[17])
		local rm_base_inv = rm_base:inv()
		local rm_gun_inv = rm_gun:inv()

		if params(6) ~= 0 and params(9) ~= 0 and nequal(params(4),params(7),0.01) then
			MODE=2
			TGT=rm_gun:dot(getXYZ(params(9),params(5),params(8))):sub(DYT)
			
		end

		--look gun to target
		local pa, pe = getAngle(rm_base_inv:dot(TGT), 0)
		--set radar angle
		local ga, ge = getAngle(rm_gun_inv:dot(TGT), 0.75)

	end
	output.setNumber(4, FOV)
	output.setNumber(5, AZIMUTH_V)
	output.setNumber(6, AZIMUTH_H)

	output.setBool(1, BALISTIC_CALC)
	output.setBool(2, SEARCH_RADAR_SW)
end

function setFOV(distance)
	FOV = math.atan(2 / distance)
end

function getXYZ(dist, azim, elev) --x,y,z
	local mat = Matrix.new(3, 1)
	mat:set(1, 1, dist * math.cos(elev) * math.sin(azim))
	mat:set(2, 1, dist * math.sin(elev))
	mat:set(3, 1, dist * math.cos(elev) * math.cos(azim))
	return mat
end

function getAngle(mat, offset) --a,e
	local a, e
	a = math.atan(mat:get(1, 1), mat:get(3, 1))
	local xz = math.sqrt(mat:get(1, 1) ^ 2 + mat:get(3, 1) ^ 2)
	e = math.atan(mat:get(2, 1) - offset, xz)
	return a, e
end

function sign(value)
	if value < 0 then return -1 end
	return 1
end

function getTilt(tilt, top)
	if top < 0 then
		tilt = tilt + sign(tilt) * 0.25
	end
	return tilt
end

function getYaw(base, top) --returns darian
	base = -base % 1 * math.pi * 2
	top = -top % 1 * math.pi * 2
	return top - base
end

function nequal(a, b, eps)
	local flag = false
	if a - b < eps then flag = true end
	return flag
end
