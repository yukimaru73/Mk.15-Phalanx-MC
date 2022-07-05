require("Libs.TrackRadarLib2")
require("Libs.LightMatrix")
require("LifeBoatAPI.Maths.LBMaths")
require("Libs.PID")

RADAR = TrackingRadar:new(7, 4, 6, 5, 4)
OFFSET_RADAR = LMatrix:newFromArray({ 0, 0.25, 0 }, 3, 1)
PivotPID = PID:new(4.5, 0, 0.5, 0.3)

function onTick()
	local params = {}
	for i = 1, 32 do
		params[i] = input.getNumber(i)
	end
	RADAR:trackingUpdate()
	local pi2 = math.pi * 2
	--local Rpitch = (math.asin(math.sin(params[14] * pi2) / math.cos(params[15] * pi2)) - math.asin(math.sin(params[12] * pi2) / math.cos(params[15] * pi2))) / pi2
	local pos = LMatrix:newFromArray(RADAR:getPos(), 3, 1)
	local rotationRadar = LMatrix:newRotateMatrix(params[14], params[15], params[17])
	local rotationBase = LMatrix:newRotateMatrix(params[10], params[11], params[13])
	local posout = rotationRadar:dot(pos):add(rotationRadar:dot(OFFSET_RADAR))
	--debug.log("TST/ "..posout:get(1,1).." , "..posout:get(2,1).." , "..posout:get(3,1))
	local a, e = rotationBase:inv():dot(posout):getAngle()
	local isTracking_h, isTracking_v = RADAR:isTracking()

	if isTracking_h and isTracking_v then
		output.setNumber(7, 2 * e / math.pi)
		output.setNumber(8, PivotPID:update((-params[13]+params[18] + a / pi2 + 1.5) % 1 - 0.5, 0))
	end
end
