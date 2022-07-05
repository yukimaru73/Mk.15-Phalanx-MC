require("Libs.LightMatrix")

function onTick()
	local pitch = input.getNumber(1)
	local roll = input.getNumber(2)
	local yaw = input.getNumber(3)


	local mat = LMatrix:newFromArray({input.getNumber(4),input.getNumber(5),input.getNumber(6)},3,1)

	local r = LMatrix:newRotateMatrix(roll,pitch,yaw)
	local matr = r:solve(mat)
	local ad = math.atan(matr:get(1,1),matr:get(3,1))
	local xzd = math.sqrt(matr:get(3,1)^2+matr:get(1,1)^2)
	local ed = math.atan(matr:get(2,1),xzd)
	output.setNumber(1,2*ed/math.pi)
	output.setNumber(2,2*ad/math.pi)
end