require("Libs.TrackRadarLib2")

RADAR=TrackingRadar:new(7,4,6,5,4)

function onTick()
	RADAR:trackingUpdate()
	local x,y,z = RADAR:getPos()
	debug.log("TST/ X: "..x.." , Y: "..y.." , Z: "..z.." ,")
end

function getAngle(mat, offset) --a,e
	local a, e
	a = math.atan(mat:get(1, 1), mat:get(3, 1))
	local xz = math.sqrt(mat:get(1, 1) ^ 2 + mat:get(3, 1) ^ 2)
	e = math.atan(mat:get(2, 1) - offset, xz)
	return a, e
end