require("Libs.TrackRadarLib2")
require("Libs.Quaternion")
require("Libs.PID")


RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_TR_G = { 0, 0.25, 0 }
PivotPID = PID:new(20, 0.005, 0.3, 0.08)
MODE = 0
TARGET_POS = { 0, 0, 0 }
TARGET_POS_LIST = {}
TARGET_MASS = 0
MISSING_TIME = 0
MT = 0.37

PIVOT_V, PIVOT_H = 0, 0

--[[
-- MODE:0 -> Stop
-- MODE:1 -> Search Recieve and Tracking Start
-- MODE:2 -> Tracking

-- input:1 -> Target X from SearchRadar
-- input:2 -> Target Y from SearchRadar
-- input:2 -> Target Z from SearchRadar

-- output:1 -> Target X
-- output:2 -> Target Y
-- output:3 -> Target Z
-- output:4 -> Target X Speed
-- output:5 -> Target Y Speed
-- output:6 -> Target Z Speed

-- output:1 -> Search Radar Switch
-- output:2 -> Balistic Calc Switch
-- output:3 -> Gun Fire Switch
]]

function onTick()
	SEARCH_RADAR_SW = false
	BALISTIC_CALC = false
	FIRE = false
	local q_out, params = Quaternion:_new(), {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	if input.getNumber(20) ~= 1 then
		reset()
		goto out
	end
	rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
	rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
	if MODE == 0 then
		if MISSING_TIME == 0 then
			SEARCH_RADAR_SW = true
			PivotPID:reset()
			if params[21] == 1 then
				local vec = { params[1], params[2], params[3] }
				TARGET_POS = rotationRadar:_rotateVector(addVector(vec, OFFSET_TR_G, 5))
				local pos = rotationBase:_getConjugateQuaternion():_rotateVector(TARGET_POS)
				if math.abs(math.atan(pos[3], pos[1])) / 2 / math.pi < property.getNumber("MaxYaw") then
					MODE = 1
					RADAR:setFOV(math.sqrt(vec[1] ^ 2 + vec[2] ^ 2 + vec[3] ^ 2))
				end
			end
		else
			MISSING_TIME = MISSING_TIME - 1
		end
	end
	if MODE == 1 then
		MT = 0.42
		local isTracking_h, isTracking_v, same, mass = RADAR:isTracking()
		if isTracking_h and isTracking_v and same then
			TARGET_MASS = mass
			MODE = 2
			MT = 0.09
		else
			local posradar = rotationRadar:_getConjugateQuaternion():_rotateVector(TARGET_POS)
			posradar = addVector(posradar, rotationRadar:_getConjugateQuaternion():_rotateVector(OFFSET_TR_G), -1)
			local pospiv = rotationBase:_getConjugateQuaternion():_rotateVector(TARGET_POS)
			pospiv = addVector(pospiv, rotationBase:_getConjugateQuaternion():_rotateVector(OFFSET_TR_G), -5)

			RADAR:setViewFromPos(posradar[1], posradar[2], posradar[3])
			PIVOT_H, PIVOT_V = getAngle(pospiv)

			MISSING_TIME = MISSING_TIME + 1
			if MISSING_TIME > 60 then
				reset()
			end
		end
		RADAR:trackingUpdate()
		if math.abs(PIVOT_H) / 2 / math.pi > property.getNumber("MaxYaw") then
			reset()
		end
	end
	if MODE == 2 then
		
		local isTracking_h, isTracking_v, same, mass = RADAR:isTracking()

		if isTracking_h and isTracking_v and same and (mass - TARGET_MASS) < 0.01 then
			local posout= rotationRadar:_rotateVector(addVector(RADAR:getPos(),OFFSET_TR_G,1))
			
			table.insert(TARGET_POS_LIST, 1, posout)
			if #TARGET_POS_LIST > 5 then
				table.remove(TARGET_POS_LIST, 6)
				local buf = { 0, 0, 0 }
				for i = 1, 4 do
					for j = 1, 3 do
						buf[j] = buf[j] + (TARGET_POS_LIST[i][j] - TARGET_POS_LIST[i + 1][j])
					end
				end
				for i = 1, 3 do
					output.setNumber(i, posout[i])
					output.setNumber(i + 10, buf[i] / 4)
				end
				q_out = Quaternion:_new(rotationBase.x, rotationBase.y, rotationBase.z, rotationBase.w)
				BALISTIC_CALC = true
			end

			if input.getBool(1) then
				if MT<0.2 then
					MT=MT+0.003
				end
				local xz = math.cos(input.getNumber(22))
				local face = {
					xz * math.cos(input.getNumber(23)),
					math.sin(input.getNumber(22)),
					xz * math.sin(input.getNumber(23))
				}
				PIVOT_H, PIVOT_V = getAngle(Quaternion:_new(input.getNumber(25), input.getNumber(26), input.getNumber(27),
					input.getNumber(28)):_getConjugateQuaternion():_rotateVector(face))
				if input.getNumber(24) < property.getNumber("MaxBulletTravelTime") then
					FIRE = true
				else
					FIRE = false
				end
			else
				MT = 0.09
				PIVOT_H, PIVOT_V = getAngle(rotationBase:_getConjugateQuaternion():_rotateVector(posout))
			end
		else
			MISSING_TIME = MISSING_TIME + 1
			if MISSING_TIME > 60 then
				reset()
			end
		end
		RADAR:trackingUpdate()
		if math.abs(PIVOT_H) / 2 / math.pi > property.getNumber("MaxYaw") then
			reset()
		end
	end
	::out::
	output.setBool(1, BALISTIC_CALC)
	output.setBool(2, SEARCH_RADAR_SW)
	output.setBool(10, FIRE)
	output.setNumber(14, q_out.x)
	output.setNumber(15, q_out.y)
	output.setNumber(16, q_out.z)
	output.setNumber(17, q_out.w)
	
	output.setNumber(7, 2 * PIVOT_V / math.pi)
	output.setNumber(8, clamp(PivotPID:update((PIVOT_H / math.pi / 2 - params[12] + 1.5) % 1 - 0.5, 0),MT,-MT))
end


function getTilt(tilt, top)
	if top < 0 then
		tilt = tilt + tilt / math.abs(tilt) * 0.25
	end
	return tilt
end

function addVector(vecBase, vec2, scalar)
	local vec = { 0, 0, 0 }
	for i = 1, 3 do
		vec[i] = vecBase[i] + vec2[i] * scalar
	end
	return vec
end

function getAngle(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth, elevation
end
function clamp(value, max, min)
	if value < min then
		value = min
	elseif value > max then
		value = max
	end
	return value
end

function reset()
	MODE = 0
	TARGET_POS = { 0, 0, 0 }
	TARGET_POS_LIST = {}
	TARGET_MASS = 0
	MISSING_TIME = 30
	MT = 0.37

	PIVOT_V, PIVOT_H = 0, 0
	SEARCH_RADAR_SW = false
	BALISTIC_CALC = false
	FIRE = false
end
