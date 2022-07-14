require("Libs.TrackRadarLib2")
require("Libs.Quaternion")
require("Libs.PID")


RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_TR_G = { 0, 0.25, 0 }
PivotPID = PID:new(9, 0.08, 0.5, 0.3)
MODE = 0
TARGET_POS = { 0, 0, 0 }
TARGET_POS_LIST ={}
TARGET_MASS = 0
MISSING_TIME = 0

PIVOT_V, PIVOT_H = 0, 0
SEARCH_RADAR_SW = false
BALISTIC_CALC = false
FIRE = false

-- MODE:0 -> Stop
-- MODE:1 -> Search Recieve
-- MODE:2 -> Tracking
-- MODE:3 -> Tracking Miss and Retrying

-- input:1 -> Target X from SearchRadar
-- input:2 -> Target Y from SearchRadar
-- input:2 -> Target Z from SearchRadar

-- output:1 -> Target X
-- output:2 -> Target Y
-- output:3 -> Target Z
-- output:4 -> Target X Speed
-- output:5 -> Target Y Speed
-- output:5 -> Target Z Speed


function onTick()
	SEARCH_RADAR_SW = false
	BALISTIC_CALC = false
	FIRE = false
	local params = {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	if input.getNumber(20) ~= 1 then
		MODE, TARGET_MASS, MISSING_TIME, PIVOT_V, PIVOT_H  = 0, 0, 0, 0, 0
		TARGET_POS = { 0, 0, 0 }
		goto out
	end
	if MODE == 0 then
		SEARCH_RADAR_SW = true
		if params[21] == 1 then
			local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
			local vec = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
			TARGET_POS = rotationRadar:_rotateVector(addVector(vec, OFFSET_TR_G, 5))
			MODE = 1
			RADAR:setFOV(math.sqrt(vec[1] ^ 2 + vec[2] ^ 2 + vec[3] ^ 2))
		end
	end
	if MODE == 1 then
		local isTracking_h, isTracking_v, same, mass = RADAR:isTracking()
		if isTracking_h and isTracking_v and same then
			TARGET_MASS = mass
			MODE = 2
		else
			local rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
			local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])

			local posradar = rotationRadar:_getConjugateQuaternion():_rotateVector(TARGET_POS)
			posradar = addVector(posradar, rotationRadar:_getConjugateQuaternion():_rotateVector(OFFSET_TR_G), -1)
			local pospiv = rotationBase:_getConjugateQuaternion():_rotateVector(TARGET_POS)
			pospiv = addVector(pospiv, rotationBase:_getConjugateQuaternion():_rotateVector(OFFSET_TR_G), -5)

			RADAR:setViewFromPos(posradar[1], posradar[2], posradar[3])
			PIVOT_H, PIVOT_V = getAngle(pospiv)

			MISSING_TIME = MISSING_TIME + 1
			if MISSING_TIME > 60 then
				MISSING_TIME, MODE, PIVOT_H, PIVOT_V = 0, 0, 0, 0
			end
		end
		RADAR:trackingUpdate()
	end
	if MODE == 2 then
		local isTracking_h, isTracking_v, same, mass = RADAR:isTracking()
		if isTracking_h and isTracking_v and same and nequal(mass, TARGET_MASS, 0.25) then
			local pos = RADAR:getPos()
			pos[2] = pos[2] + 0.25
			local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
			local rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
			local posout = rotationRadar:_rotateVector(pos)
			local offset = rotationBase:_rotateVector(OFFSET_TR_G)
			for i = 1, 3 do
				posout[i] = posout[i] + offset[i]
			end

			table.insert(TARGET_POS_LIST,1,posout)
			if #TARGET_POS_LIST > 5 then
				table.remove(TARGET_POS_LIST,6)
				local buf ={0,0,0}
				for i = 1, 5 do
					for j = 1, 3 do
						buf[j] = buf[j] + TARGET_POS_LIST[i][j]
					end
				end
				for i = 1, 3 do
					output.setNumber(i,posout[i])
					output.setNumber(i+3, buf[i] / 5)
				end
				BALISTIC_CALC = true
			end
			
			if input.getBool(1) then
				local face ={}
				face[2] = math.sin(input.getNumber(22)) --y
				local xz = math.cos(input.getNumber(22))
				face[1] = xz * math.cos(input.getNumber(23)) --x
				face[3] = xz * math.sin(input.getNumber(23)) --z
				PIVOT_H, PIVOT_V = getAngle(rotationBase:_getConjugateQuaternion():_rotateVector(face))
			else
				PIVOT_H, PIVOT_V = getAngle(rotationBase:_getConjugateQuaternion():_rotateVector(posout))
			end
		else
			MISSING_TIME = MISSING_TIME + 1
			if MISSING_TIME > 60 then
				MISSING_TIME, MODE, PIVOT_H, PIVOT_V = 0, 0, 0, 0
			end
		end
		RADAR:trackingUpdate()
	end
	::out::
	output.setBool(1, BALISTIC_CALC)
	output.setBool(2, SEARCH_RADAR_SW)
	output.setNumber(7, 2 * PIVOT_V / math.pi)
	output.setNumber(8, PivotPID:update((PIVOT_H / math.pi / 2 - params[12] + 1.5) % 1 - 0.5, 0))
end

function getTilt(tilt, top)
	if top < 0 then
		tilt = tilt + tilt / math.abs(tilt) * 0.25
	end
	return tilt
end

function nequal(a, b, eps)
	local flag = false
	if a - b < eps then flag = true end
	return flag
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
