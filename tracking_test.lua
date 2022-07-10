require("Libs.TrackRadarLib2")
require("Libs.PID")
require("Libs.Quaternion")

RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_RADAR = { 0, 0.25, 0 }
PivotPID = PID:new(4.5, 0, 0.5, 0.3)

function onTick()
	local params = {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	RADAR:trackingUpdate()
	local pi2 = math.pi * 2
	--local Rpitch = (math.asin(math.sin(params[14] * pi2) / math.cos(params[15] * pi2)) - math.asin(math.sin(params[12] * pi2) / math.cos(params[15] * pi2))) / pi2
	local pos = RADAR:getPos()
	local rotationRadar = Quaternion:createPitchRollYawQuaternion(params[14], params[15], params[17])
	local rotationBase = Quaternion:createPitchRollYawQuaternion(params[10], params[11], params[13])
	local posout = rotationRadar:_rotateVector(pos)
	--debug.log("TST/ "..posout:get(1,1).." , "..posout:get(2,1).." , "..posout:get(3,1))
	local a, e = getAngle(rotationBase:_getConjugateQuaternion():_rotateVector(posout))
	local isTracking_h, isTracking_v = RADAR:isTracking()

	if isTracking_h and isTracking_v then
		output.setNumber(7, 2 * e / math.pi)
		output.setNumber(8, PivotPID:update((a / pi2 - params[12] + 1.5) % 1 - 0.5, 0))
	end
end

function getAngle(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[1], vector[3])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth, elevation
end
