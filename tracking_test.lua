require("Libs.TrackRadarLib2")
require("Libs.PID")
require("Libs.Quaternion")

RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_TR_G = { 0, 0.25, 0 }
PivotPID = PID:new(4.5, 0, 0.5, 0.3)

function onTick()
	local params = {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	RADAR:trackingUpdate()
	local pi2 = math.pi * 2
	local pos = RADAR:getPos()
	pos[2]=pos[2] + 0.25
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

function getAngle(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth, elevation
end
