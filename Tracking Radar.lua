require("Libs.TrackRadarLib2")
require("Libs.Quaternion")
require("Libs.PID")


RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_TR_G = { 0, 0.25, 0 }
OFFSET_SR_TR = { 0, 1, 0 }
OFFSET_SR_G = { 0, 1.25, 0 }
PivotPID = PID:new(4.5, 0, 0.5, 0.3)
MODE = 0
TARGET = { 0, 0, 0 }
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
	if MODE == 0 and input.getNumber(20) == 1 then
		SEARCH_RADAR_SW = true
		if input.getBool(1) then
			local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
			local vec = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
			MODE = 1
		end
	end
	if MODE == 1 then
		local rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
		local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])

		local posradar = rotationRadar:_getConjugateQuaternion():_rotateVector(TARGET)
		posradar = addVector(posradar, rotationRadar:_getConjugateQuaternion():_rotateVector(OFFSET_TR_G), -1)
		local pospiv = rotationBase:_getConjugateQuaternion():_rotateVector(TARGET)
		pospiv = addVector(pospiv, rotationBase:_getConjugateQuaternion():_rotateVector(OFFSET_SR_G), -1)

		RADAR:setViewFromPos(posradar[1], posradar[2], posradar[3])
		local a, e = getAngle(pospiv)

		local isTracking_h, isTracking_v, same = RADAR:isTracking()
		if isTracking_h and isTracking_v and same then
			MODE = 2
		else
			output.setNumber(7, 2 * e / math.pi)
			output.setNumber(8, PivotPID:update((a / math.pi / 2 - params[12] + 1.5) % 1 - 0.5, 0))
		end
	end
	if MODE == 2 then
		RADAR:trackingUpdate()
		local pi2 = math.pi * 2
		local pos = RADAR:getPos()
		pos[2] = pos[2] + 0.25
		local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
		local rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
		local posout = rotationRadar:_rotateVector(pos)
		local offset = rotationBase:_rotateVector(OFFSET_TR_G)
		for i = 1, 3 do
			posout[i] = posout[i] + offset[i]
		end
		local a, e = getAngle(rotationBase:_getConjugateQuaternion():_rotateVector(posout))
		local isTracking_h, isTracking_v, same = RADAR:isTracking()

		if isTracking_h and isTracking_v and same then
			--debug.log("TST/ "..posout[1].." , "..posout[2].." , "..posout[3])
			output.setNumber(7, 2 * e / math.pi)
			output.setNumber(8, PivotPID:update((a / pi2 - params[12] + 1.5) % 1 - 0.5, 0))
		end
	end

	output.setBool(1, BALISTIC_CALC)
	output.setBool(2, SEARCH_RADAR_SW)
end

function setFOV(distance)
	FOV = math.atan(2 / distance)
end

function getTilt(tilt, top)
	if top < 0 then
		tilt = tilt + sign(tilt) * 0.25
	end
	return tilt
end

function nequal(a, b, eps)
	local flag = false
	if a - b < eps then flag = true end
	return flag
end

function sign(value)
	if value < 0 then return -1 end
	return 1
end

function getXYZ(dist, azim, elev) --x,y,z
	return { dist * math.cos(elev) * math.cos(azim), dist * math.sin(elev), dist * math.cos(elev) * math.sin(azim) }
end

function addVector(vecBase, vec2, scalar)
	local vec = { 0, 0, 0 }
	for i = 1, 3 do
		vec[i] = vecBase[i] + vec2[i] * scalar
	end
	return vec
end
